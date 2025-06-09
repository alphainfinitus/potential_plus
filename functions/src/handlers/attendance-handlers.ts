
import { CallableRequest } from "firebase-functions/v2/https";
import cuid from "cuid";
import { ActivityType, TargetType, BatchAttendanceUpdateData } from "../models/types";
import { sendNotificationToUser } from "../services/notification-service";
import { createActivity, createActivitiesBatch } from "../services/activity-service";
import * as admin from "firebase-admin";

// Helper function to format date as "DD/MMM"
function formatDate(date: Date): string {
    try {
        const day = date.getDate().toString().padStart(2, '0');
        const month = date.toLocaleString('default', { month: 'short' }).toUpperCase();
        return `${day}/${month}`;
    } catch (error) {

        return "Unknown Date";
    }
}

// Helper function to get lecture name from metadata or timeTableEntryId
async function getLectureName(metadata: any, timeTableEntryId?: string): Promise<string> {
    try {
        // Debug log the input data


        // First check if subject name is directly in the metadata
        if (metadata && metadata.subject) {

            return metadata.subject;
        }

        // Then check for subjectId in metadata
        if (metadata && metadata.subjectId) {
            const db = admin.firestore();
            const subjectDoc = await db.collection("subjects").doc(metadata.subjectId).get();
            const subjectData = subjectDoc.data();
            if (subjectData && subjectData.name) {

                return subjectData.name;
            }
        }

        // Fall back to timeTableEntryId lookup if provided and metadata didn't contain subject
        if (timeTableEntryId) {
            const db = admin.firestore();
            const entryDoc = await db.collection("timeTableEntries").doc(timeTableEntryId).get();
            const entryData = entryDoc.data();



            if (!entryData) return "Unknown Lecture";

            // If there's a subject reference, get the subject name
            if (entryData.subjectId) {
                const subjectDoc = await db.collection("subjects").doc(entryData.subjectId).get();
                const subjectData = subjectDoc.data();
                if (subjectData && subjectData.name) {

                    return subjectData.name;
                }
            }

            // If there's a name field directly on the entry
            if (entryData.name) {

                return entryData.name;
            }

            // If there's a title field
            if (entryData.title) {

                return entryData.title;
            }

            // If there's a subject field
            if (entryData.subject) {

                return entryData.subject;
            }
        }


        return "Unknown Lecture";
    } catch (error) {

        return "Unknown Lecture";
    }
}

export async function handleAttendanceUpdate(
    attendanceId: string,
    beforeData: any,
    afterData: any
): Promise<void> {
    try {
        if (beforeData && beforeData.isPresent === afterData.isPresent) {

            return;
        }

        // Debug log the attendance data


        // Get the date from attendance data
        let date: Date;
        if (afterData.dateTime) {
            // If dateTime is a string, parse it
            if (typeof afterData.dateTime === 'string') {
                date = new Date(afterData.dateTime);

            }
            // If dateTime is a Firestore Timestamp
            else if (afterData.dateTime.toDate && typeof afterData.dateTime.toDate === 'function') {
                date = afterData.dateTime.toDate();

            } else {
                date = new Date(afterData.dateTime);

            }
        }
        // Use attendanceDate if available
        else if (afterData.attendanceDate) {
            if (typeof afterData.attendanceDate === 'string') {
                date = new Date(afterData.attendanceDate);

            } else if (afterData.attendanceDate.toDate && typeof afterData.attendanceDate.toDate === 'function') {
                date = afterData.attendanceDate.toDate();

            } else {
                date = new Date(afterData.attendanceDate);

            }
        }
        // If no specific attendance date, fall back to timestamp fields
        else if (afterData.updatedAt && afterData.updatedAt.toDate) {
            date = afterData.updatedAt.toDate();

        } else if (afterData.createdAt && afterData.createdAt.toDate) {
            date = afterData.createdAt.toDate();

        } else {
            date = new Date();

        }

        const formattedDate = formatDate(date);


        // Get lecture name from metadata
        let lectureName = "Unknown Lecture";
        if (afterData.metaData) {
            lectureName = await getLectureName(afterData.metaData, afterData.metaData.timeTableEntryId);
        }

        const status = afterData.isPresent ? 'present' : 'absent';
        const message = `You have been marked ${status} for ${lectureName} for date ${formattedDate}.`;


        // Create activity for attendance change
        await createActivity({
            userId: afterData.markedByUserId,
            activityType: ActivityType.attendance,
            activityRefId: attendanceId,
            targetType: TargetType.SPECIFIC_STUDENT,
            institutionId: afterData.institutionId,
            title: "Attendance Update",
            message: message,
            specificUserId: afterData.userId,
        });

        // Send notification to the student
        await sendNotificationToUser(
            afterData.userId,
            "Attendance Update",
            message,
            {
                attendanceId: attendanceId,
                lectureName: lectureName,
                date: formattedDate,
                status: status
            }
        );
    } catch (error) {

        throw error;
    }
}


export async function handleNewAttendance(
    attendanceId: string,
    attendanceData: any
): Promise<void> {
    try {
        // Debug log the attendance data


        // Get the date from attendance data
        let date: Date;
        if (attendanceData.dateTime) {
            // If dateTime is a string, parse it
            if (typeof attendanceData.dateTime === 'string') {
                date = new Date(attendanceData.dateTime);

            }
            // If dateTime is a Firestore Timestamp
            else if (attendanceData.dateTime.toDate && typeof attendanceData.dateTime.toDate === 'function') {
                date = attendanceData.dateTime.toDate();

            } else {
                date = new Date(attendanceData.dateTime);

            }
        }
        // Use attendanceDate if available
        else if (attendanceData.attendanceDate) {
            if (typeof attendanceData.attendanceDate === 'string') {
                date = new Date(attendanceData.attendanceDate);

            } else if (attendanceData.attendanceDate.toDate && typeof attendanceData.attendanceDate.toDate === 'function') {
                date = attendanceData.attendanceDate.toDate();

            } else {
                date = new Date(attendanceData.attendanceDate);

            }
        }
        // If no specific attendance date, fall back to timestamp fields
        else if (attendanceData.createdAt && attendanceData.createdAt.toDate) {
            date = attendanceData.createdAt.toDate();

        } else {
            date = new Date();

        }

        const formattedDate = formatDate(date);


        // Get lecture name from metadata
        let lectureName = "Unknown Lecture";
        if (attendanceData.metaData) {
            lectureName = await getLectureName(attendanceData.metaData, attendanceData.metaData.timeTableEntryId);
        }

        const status = attendanceData.isPresent ? 'present' : 'absent';
        const message = `You have been marked ${status} for ${lectureName} for date ${formattedDate}.`;


        await createActivity({
            userId: attendanceData.markedByUserId,
            activityType: ActivityType.attendance,
            activityRefId: attendanceId,
            targetType: TargetType.SPECIFIC_STUDENT,
            institutionId: attendanceData.institutionId,
            title: "New Attendance",
            message: message,
            specificUserId: attendanceData.userId,
        });

        await sendNotificationToUser(
            attendanceData.userId,
            "New Attendance",
            message,
            {
                attendanceId: attendanceId,
                lectureName: lectureName,
                date: formattedDate,
                status: status
            }
        );
    } catch (error) {

        throw error;
    }
}

export async function handleBatchAttendanceUpdate(
    request: CallableRequest
): Promise<{ success: boolean; error?: string }> {
    try {
        const data = request.data as BatchAttendanceUpdateData;
        const { classId, timeTableEntryId, attendanceData, institutionId } = data;

        // Get the ID of the user who is marking attendance (the caller)
        const markedByUserId = request.auth?.uid;

        if (!attendanceData || !Array.isArray(attendanceData) || !classId || !timeTableEntryId || !institutionId) {

            return { success: false, error: "Invalid data" };
        }

        if (!markedByUserId) {

            return { success: false, error: "Unauthorized" };
        }

        // Debug log the batch update data




        // Get attendance date from data if available
        let attendanceDate: Date;

        if (data.dateTime) {
            if (typeof data.dateTime === 'string') {
                attendanceDate = new Date(data.dateTime);

            } else if (data.dateTime.toDate && typeof data.dateTime.toDate === 'function') {
                attendanceDate = data.dateTime.toDate();

            } else {
                attendanceDate = new Date(data.dateTime);

            }
        } else if (data.attendanceDate) {
            if (typeof data.attendanceDate === 'string') {
                attendanceDate = new Date(data.attendanceDate);

            } else if (data.attendanceDate.toDate && typeof data.attendanceDate.toDate === 'function') {
                attendanceDate = data.attendanceDate.toDate();

            } else {
                attendanceDate = new Date(data.attendanceDate);

            }
        } else {
            // Use current date as fallback
            attendanceDate = new Date();

        }

        const formattedDate = formatDate(attendanceDate);


        // First try to get subject name directly from the request data
        let lectureName = "Unknown Lecture";

        if (data.subject) {
            lectureName = data.subject;

        } else if (data.metadata && data.metadata.subject) {
            lectureName = data.metadata.subject;

        } else {
            // Get timetable entry data to extract metadata
            const db = admin.firestore();
            const entryDoc = await db.collection("timeTableEntries").doc(timeTableEntryId).get();
            const entryData = entryDoc.data();


            // Get lecture name from the entry data or metadata
            if (entryData) {
                lectureName = await getLectureName(entryData, timeTableEntryId);
            }
        }


        const activitiesData = attendanceData
            .filter(record => record.userId && record.isPresent !== undefined)
            .map(record => {
                const status = record.isPresent ? 'present' : 'absent';
                const message = `You have been marked ${status} for ${lectureName} for date ${formattedDate}.`;

                return {
                    userId: markedByUserId,
                    activityType: ActivityType.attendance,
                    activityRefId: record.attendanceId || cuid(),
                    targetType: TargetType.SPECIFIC_STUDENT,
                    institutionId: institutionId,
                    title: "Attendance Update",
                    message: message,
                    specificUserId: record.userId,
                };
            });

        // Create activities in batch
        await createActivitiesBatch(activitiesData);

        // Send notifications in parallel
        const notificationPromises = attendanceData
            .filter(record => record.userId && record.isPresent !== undefined)
            .map(record => {
                const status = record.isPresent ? 'present' : 'absent';
                const message = `You have been marked ${status} for ${lectureName} for date ${formattedDate}.`;

                return sendNotificationToUser(
                    record.userId,
                    "Attendance Update",
                    message,
                    {
                        classId: classId,
                        timeTableEntryId: timeTableEntryId,
                        isPresent: record.isPresent.toString(),
                        lectureName: lectureName,
                        date: formattedDate,
                        status: status
                    }
                );
            });

        await Promise.all(notificationPromises);



        return { success: true };
    } catch (error) {

        return {
            success: false,
            error: error instanceof Error ? error.message : "Unknown error"
        };
    }
} 