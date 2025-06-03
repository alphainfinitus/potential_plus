import * as logger from "firebase-functions/logger";
import { CallableRequest } from "firebase-functions/v2/https";
import cuid from "cuid";
import { ActivityType, TargetType, BatchAttendanceUpdateData } from "../models/types";
import { sendNotificationToUser } from "../services/notification-service";
import { createActivity, createActivitiesBatch } from "../services/activity-service";


export async function handleAttendanceUpdate(
    attendanceId: string,
    beforeData: any,
    afterData: any
): Promise<void> {
    try {
        if (beforeData && beforeData.isPresent === afterData.isPresent) {
            logger.info("No change in attendance status, skipping");
            return;
        }

        // Create activity for attendance change
        await createActivity({
            userId: afterData.userId,
            activityType: ActivityType.attendance,
            activityRefId: attendanceId,
            targetType: TargetType.SPECIFIC_STUDENT,
            institutionId: afterData.institutionId,
            title: "Attendance Update",
            message: `Your attendance has been marked as ${afterData.isPresent ? 'present' : 'absent'}.`,
            specificUserId: afterData.userId,
        });
        
        // Send notification to the student
        await sendNotificationToUser(
            afterData.userId, 
            "Attendance Update", 
            `Your attendance has been marked as ${afterData.isPresent ? 'present' : 'absent'}.`,
            { attendanceId: attendanceId }
        );
    } catch (error) {
        logger.error("Error handling attendance update:", error);
        throw error;
    }
}


export async function handleNewAttendance(
    attendanceId: string,
    attendanceData: any
): Promise<void> {
    try {
        await createActivity({
            userId: attendanceData.userId,
            activityType: ActivityType.attendance,
            activityRefId: attendanceId,
            targetType: TargetType.SPECIFIC_STUDENT,
            institutionId: attendanceData.institutionId,
            title: "New Attendance",
            message: `Your attendance has been marked as ${attendanceData.isPresent ? 'present' : 'absent'}.`,
            specificUserId: attendanceData.userId,
        });
        
        await sendNotificationToUser(
            attendanceData.userId,
            "New Attendance",
            `Your attendance has been marked as ${attendanceData.isPresent ? 'present' : 'absent'}.`,
            { attendanceId: attendanceId }
        );
    } catch (error) {
        logger.error("Error handling new attendance:", error);
        throw error;
    }
}

export async function handleBatchAttendanceUpdate(
    request: CallableRequest
): Promise<{ success: boolean; error?: string }> {
    try {
        const data = request.data as BatchAttendanceUpdateData;
        const { classId, timeTableEntryId, attendanceData, institutionId } = data;

        if (!attendanceData || !Array.isArray(attendanceData) || !classId || !timeTableEntryId || !institutionId) {
            logger.error("Invalid data for attendance update");
            return { success: false, error: "Invalid data" };
        }

        logger.info(`Processing batch attendance update for class ${classId}, ${attendanceData.length} students`);
        
        const activitiesData = attendanceData
            .filter(record => record.userId && record.isPresent !== undefined)
            .map(record => ({
                userId: record.userId,
                activityType: ActivityType.attendance,
                activityRefId: record.attendanceId || cuid(),
                targetType: TargetType.SPECIFIC_STUDENT,
                institutionId: institutionId,
                title: "Attendance Update",
                message: `Your attendance has been marked as ${record.isPresent ? 'present' : 'absent'}.`,
                specificUserId: record.userId,
            }));
        
        // Create activities in batch
        await createActivitiesBatch(activitiesData);
        
        // Send notifications in parallel
        const notificationPromises = attendanceData
            .filter(record => record.userId && record.isPresent !== undefined)
            .map(record => 
                sendNotificationToUser(
                    record.userId,
                    "Attendance Update",
                    `Your attendance has been marked as ${record.isPresent ? 'present' : 'absent'}.`,
                    { 
                        classId: classId,
                        timeTableEntryId: timeTableEntryId,
                        isPresent: record.isPresent.toString(),
                    }
                )
            );
        
        await Promise.all(notificationPromises);
        
        logger.info(`Successfully processed batch attendance update for ${attendanceData.length} students`);
        
        return { success: true };
    } catch (error) {
        logger.error("Error processing batch attendance update:", error);
        return { 
            success: false, 
            error: error instanceof Error ? error.message : "Unknown error" 
        };
    }
} 