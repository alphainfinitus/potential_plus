import * as admin from "firebase-admin";

import cuid from "cuid";
import { ActivityData, ActivityType, TargetType } from "../models/types";


export async function createActivity(activityData: Partial<ActivityData>): Promise<string> {
    try {
        const db = admin.firestore();
        const activityId = activityData.id || cuid();
        const now = admin.firestore.Timestamp.now();

        const activity: ActivityData = {
            id: activityId,
            userId: activityData.userId || "",
            activityType: activityData.activityType || ActivityType.attendance,
            activityRefId: activityData.activityRefId || activityId,
            targetType: activityData.targetType || TargetType.SPECIFIC_STUDENT,
            createdAt: activityData.createdAt || now,
            updatedAt: activityData.updatedAt || now,
            institutionId: activityData.institutionId || "",
            title: activityData.title,
            message: activityData.message,
            specificUserId: activityData.specificUserId,
        };

        await db.collection("activities").doc(activityId).set(activity);


        return activityId;
    } catch (error) {

        throw error;
    }
}

/**
 * Creates multiple activities in a batch operation
 * @param activitiesData Array of activity data to create
 * @returns A promise that resolves with the created activity IDs
 */
export async function createActivitiesBatch(activitiesData: Partial<ActivityData>[]): Promise<string[]> {
    try {
        const db = admin.firestore();
        const batch = db.batch();
        const activityIds: string[] = [];
        const now = admin.firestore.Timestamp.now();

        for (const data of activitiesData) {
            const activityId = data.id || cuid();
            activityIds.push(activityId);

            const activity: ActivityData = {
                id: activityId,
                userId: data.userId || "",
                activityType: data.activityType || ActivityType.attendance,
                activityRefId: data.activityRefId || activityId,
                targetType: data.targetType || TargetType.SPECIFIC_STUDENT,
                createdAt: data.createdAt || now,
                updatedAt: data.updatedAt || now,
                institutionId: data.institutionId || "",
                title: data.title,
                message: data.message,
                specificUserId: data.specificUserId,
            };

            const activityRef = db.collection("activities").doc(activityId);
            batch.set(activityRef, activity);
        }

        await batch.commit();


        return activityIds;
    } catch (error) {

        throw error;
    }
} 