import * as admin from "firebase-admin";



export async function sendNotificationToUser(
    userId: string,
    title: string,
    body: string,
    data: Record<string, string> = {}
): Promise<void> {
    try {
        const db = admin.firestore();
        const userDoc = await db.collection("users").doc(userId).get();
        const userData = userDoc.data();

        if (userData && userData.fcmToken) {
            const message = {
                notification: {
                    title: title,
                    body: body,
                },
                data: data,
                token: userData.fcmToken,
            };

            await admin.messaging().send(message);

        } else {

        }
    } catch (error) {

    }
}

/**
 * Sends notifications to multiple users in parallel
 * @param notifications Array of notification data
 * @returns A promise that resolves when all notifications are sent
 */
export async function sendBatchNotifications(
    notifications: Array<{
        userId: string;
        title: string;
        body: string;
        data?: Record<string, string>;
    }>
): Promise<void> {
    try {
        const promises = notifications.map(notification =>
            sendNotificationToUser(
                notification.userId,
                notification.title,
                notification.body,
                notification.data || {}
            )
        );

        await Promise.all(promises);

    } catch (error) {

    }
} 