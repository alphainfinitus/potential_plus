/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import {onDocumentCreated, onDocumentUpdated} from "firebase-functions/v2/firestore";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import cuid from "cuid";

// Initialize Firebase Admin SDK
admin.initializeApp();

// ActivityType and TargetType enums to match Flutter app
enum ActivityType {
  attendance = "attendance",
  announcement = "announcement"
}

enum TargetType {
  ALL = "ALL",
  ALL_STUDENTS = "ALL_STUDENTS",
  ALL_TEACHERS = "ALL_TEACHERS",
  SPECIFIC_STUDENT = "SPECIFIC_STUDENT",
  SPECIFIC_TEACHER = "SPECIFIC_TEACHER"
}

// Function that triggers when an attendance document is updated
export const onAttendanceUpdate = onDocumentUpdated("attendances/{attendanceId}", async (event) => {
  try {
    // Get the attendance document data (after update)
    const attendanceData = event.data?.after.data();
    if (!attendanceData) {
      logger.error("No attendance data found");
      return;
    }

    const beforeData = event.data?.before.data();
    
    if (beforeData && beforeData.isPresent === attendanceData.isPresent) {
      logger.info("No change in attendance status, skipping");
      return;
    }

    const db = admin.firestore();
    
    const activityData = {
      id: cuid(),
      userId: attendanceData.userId,
      activityType: ActivityType.attendance,
      activityRefId: event.params.attendanceId,
      targetType: TargetType.SPECIFIC_STUDENT,
      createdAt: admin.firestore.Timestamp.now(),
      updatedAt: admin.firestore.Timestamp.now(),
      institutionId: attendanceData.institutionId,
      title: "Attendance Update",
      message: `Your attendance has been marked as ${attendanceData.isPresent ? 'present' : 'absent'}.`,
      specificUserId: attendanceData.userId,
    };
    
    await db.collection("activities").doc(activityData.id).set(activityData);
    logger.info(`Created activity for attendance change: ${activityData.id}`);
    
    await sendNotificationToUser(
      attendanceData.userId, 
      "Attendance Update", 
      `Your attendance has been marked as ${attendanceData.isPresent ? 'present' : 'absent'}.`,
      { attendanceId: event.params.attendanceId }
    );
    
  } catch (error) {
    logger.error("Error processing attendance change:", error);
  }
});

// Helper function to send notifications
async function sendNotificationToUser(userId: string, title: string, body: string, data: any = {}) {
  try {
    const db = admin.firestore();
    const userDoc = await db.collection("users").doc(userId).get();
    const userData = userDoc.data();
    
    if (userData && userData.fcmToken) {
      // Send a notification to the user
      const message = {
        notification: {
          title: title,
          body: body,
        },
        data: data,
        token: userData.fcmToken,
      };
      
      await admin.messaging().send(message);
      logger.info(`Sent notification to user ${userId}`);
    } else {
      logger.info(`No FCM token found for user ${userId}, skipping notification`);
    }
  } catch (error) {
    logger.error(`Error sending notification to user ${userId}:`, error);
  }
}

// Function that handles when a new attendance record is created
export const onNewAttendance = onDocumentCreated("attendances/{attendanceId}", async (event) => {
  try {
    // Get the attendance document data
    const attendanceData = event.data?.data();
    if (!attendanceData) {
      logger.error("No attendance data found");
      return;
    }

    const db = admin.firestore();
    
    // Create an activity for the new attendance
    const activityData = {
      id: cuid(),
      userId: attendanceData.userId,
      activityType: ActivityType.attendance,
      activityRefId: event.params.attendanceId,
      targetType: TargetType.SPECIFIC_STUDENT,
      createdAt: admin.firestore.Timestamp.now(),
      updatedAt: admin.firestore.Timestamp.now(),
      institutionId: attendanceData.institutionId,
      title: "New Attendance",
      message: `Your attendance has been marked as ${attendanceData.isPresent ? 'present' : 'absent'}.`,
      specificUserId: attendanceData.userId,
    };
    
    // Add the activity to the database
    await db.collection("activities").doc(activityData.id).set(activityData);
    logger.info(`Created activity for new attendance: ${activityData.id}`);
    
    // Send notification to user
    await sendNotificationToUser(
      attendanceData.userId,
      "New Attendance",
      `Your attendance has been marked as ${attendanceData.isPresent ? 'present' : 'absent'}.`,
      { attendanceId: event.params.attendanceId }
    );
    
  } catch (error) {
    logger.error("Error processing new attendance:", error);
  }
});
