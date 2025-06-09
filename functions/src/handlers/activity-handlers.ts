import * as admin from "firebase-admin";
import { ActivityType, TargetType } from "../models/types";
import { sendNotificationToUser } from "../services/notification-service";
import * as console from "firebase-functions/logger";

/**
 * Handles a newly created activity document and sends notifications based on the activity type and target type
 * @param activityId ID of the newly created activity
 * @param activityData Data of the activity
 */
export async function handleActivityCreated(
    activityId: string,
    activityData: any
): Promise<void> {
    try {
        if (!activityData.activityType) {
            console.info(`Activity ${activityId} has no type, skipping notification`);
            return;
        }

        console.info(`Processing activity ${activityId} of type ${activityData.activityType} with target type ${activityData.targetType}`);

        // Get the notification content
        const title = activityData.title || getDefaultTitle(activityData.activityType);
        const body = activityData.message || "You have a new notification";

        // Prepare the notification data
        const notificationData: Record<string, string> = {
            activityId: activityId,
            activityType: activityData.activityType,
        };

        // Add reference ID if available
        if (activityData.activityRefId) {
            notificationData.refId = activityData.activityRefId;
        }

        // For attendance activities, fetch additional details
        if (
            activityData.activityType === ActivityType.attendance &&
            activityData.activityRefId
        ) {
            try {
                const attendanceDoc = await admin
                    .firestore()
                    .collection("attendances")
                    .doc(activityData.activityRefId)
                    .get();

                const attendanceData = attendanceDoc.data();
                if (attendanceData) {
                    notificationData.isPresent = attendanceData.isPresent
                        ? "true"
                        : "false";

                    if (attendanceData.metaData && attendanceData.metaData.subject) {
                        notificationData.subject = attendanceData.metaData.subject;
                    }

                    if (attendanceData.dateTime) {
                        const dateTime =
                            typeof attendanceData.dateTime.toDate === "function"
                                ? attendanceData.dateTime.toDate()
                                : new Date(attendanceData.dateTime);
                        notificationData.dateTime = dateTime.toISOString();
                    }
                }
            } catch (error) {
                console.error(`Error fetching attendance data: ${error}`);
            }
        }

        // Determine target users based on targetType
        switch (activityData.targetType) {
            case TargetType.SPECIFIC_STUDENT:
            case TargetType.SPECIFIC_TEACHER:
                // For specific user targets, use specificUserId
                if (activityData.specificUserId) {
                    await sendNotificationToUser(
                        activityData.specificUserId,
                        title,
                        body,
                        notificationData
                    );
                    console.info(`Sent notification to specific user: ${activityData.specificUserId}`);
                } else {
                    console.warn(`Activity ${activityId} has target type ${activityData.targetType} but no specificUserId`);
                }
                break;

            case TargetType.ALL_STUDENTS:
                // For all students, query users with role "student" in the institution
                await sendNotificationToUserGroup(
                    "student",
                    activityData.institutionId,
                    title,
                    body,
                    notificationData
                );
                break;

            case TargetType.ALL_TEACHERS:
                // For all teachers, query users with role "teacher" in the institution
                await sendNotificationToUserGroup(
                    "teacher",
                    activityData.institutionId,
                    title,
                    body,
                    notificationData
                );
                break;

            case TargetType.ALL:
                // For all users in the institution
                await sendNotificationToUserGroup(
                    null,
                    activityData.institutionId,
                    title,
                    body,
                    notificationData
                );
                break;

            default:
                // For other cases or if targetType is missing, send to the activity creator
                if (activityData.userId) {
                    await sendNotificationToUser(
                        activityData.userId,
                        title,
                        body,
                        notificationData
                    );
                    console.info(`Sent notification to activity creator: ${activityData.userId}`);
                }
        }
    } catch (error) {
        console.error(`Error handling activity ${activityId}: ${error}`);
        throw error;
    }
}

/**
 * Send notifications to a group of users based on role and institution
 */
async function sendNotificationToUserGroup(
    role: string | null,
    institutionId: string,
    title: string,
    body: string,
    data: Record<string, string>
): Promise<void> {
    try {
        const db = admin.firestore();
        let query = db.collection("users").where("institutionId", "==", institutionId);

        // Add role filter if specified
        if (role) {
            query = query.where("role", "==", role);
        }

        const usersSnapshot = await query.get();
        console.info(`Found ${usersSnapshot.size} users to notify for institution ${institutionId}${role ? ` with role ${role}` : ''}`);

        // Create batch of notification promises
        const promises = usersSnapshot.docs.map(doc => {
            const userData = doc.data();
            if (userData.fcmToken) {
                return sendNotificationToUser(doc.id, title, body, data);
            }
            return Promise.resolve();
        });

        // Send all notifications in parallel
        await Promise.all(promises);
        console.info(`Sent notifications to ${promises.length} users`);
    } catch (error) {
        console.error(`Error sending group notifications: ${error}`);
    }
}

/**
 * Get a default title based on activity type
 */
function getDefaultTitle(activityType: string): string {
    switch (activityType) {
        case ActivityType.attendance:
            return "Attendance Update";
        case ActivityType.announcement:
            return "New Announcement";
        default:
            return "Notification";
    }
}
