// Enums that match Flutter app
export enum ActivityType {
    attendance = "attendance",
    announcement = "announcement"
}

export enum TargetType {
    ALL = "ALL",
    ALL_STUDENTS = "ALL_STUDENTS",
    ALL_TEACHERS = "ALL_TEACHERS",
    SPECIFIC_STUDENT = "SPECIFIC_STUDENT",
    SPECIFIC_TEACHER = "SPECIFIC_TEACHER"
}

// Interface for attendance data
export interface AttendanceData {
    id: string;
    userId: string;
    isPresent: boolean;
    institutionId: string;
    classId?: string;
    createdAt: any; // Firebase Timestamp
    updatedAt: any; // Firebase Timestamp
    markedByUserId: string;
    metaData?: {
        subject: string;
        timeTableId: string;
        timeTableEntryId: string;
    };
}

// Interface for activity data
export interface ActivityData {
    id: string;
    userId: string;
    activityType: ActivityType;
    activityRefId: string;
    targetType: TargetType;
    createdAt: any; // Firebase Timestamp
    updatedAt: any; // Firebase Timestamp
    institutionId: string;
    title?: string;
    message?: string;
    specificUserId?: string;
}

// Interface for batch attendance update
export interface BatchAttendanceUpdateData {
    classId: string;
    timeTableEntryId: string;
    attendanceData: {
        userId: string;
        isPresent: boolean;
        attendanceId?: string;
    }[];
    institutionId: string;
} 