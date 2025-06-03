/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import {onDocumentCreated, onDocumentUpdated} from "firebase-functions/v2/firestore";
import {onCall} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

import { 
  handleAttendanceUpdate, 
  handleNewAttendance, 
  handleBatchAttendanceUpdate 
} from "./handlers/attendance-handlers";

admin.initializeApp();


export const onAttendanceUpdate = onDocumentUpdated("attendances/{attendanceId}", async (event) => {
  try {
    const beforeData = event.data?.before.data();
    const afterData = event.data?.after.data();
    
    if (!afterData) {
      return;
    }
    
    await handleAttendanceUpdate(event.params.attendanceId, beforeData, afterData);
  } catch (error) {
    console.error("Error in onAttendanceUpdate:", error);
  }
});


// Function that handles when a new attendance record is created
export const onNewAttendance = onDocumentCreated("attendances/{attendanceId}", async (event) => {
  try {
    const attendanceData = event.data?.data();
    
    if (!attendanceData) {
      return;
    }
    
    await handleNewAttendance(event.params.attendanceId, attendanceData);
  } catch (error) {
    console.error("Error in onNewAttendance:", error);
  }
});

export const processAttendanceUpdate = onCall(handleBatchAttendanceUpdate);
