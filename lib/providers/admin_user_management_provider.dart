import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/constants/user_role.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/services/db_service.dart';
import 'package:cuid2/cuid2.dart';

/// State class for admin user management
class AdminUserManagementState {
  final bool isLoading;
  final List<AppUser> students;
  final List<AppUser> teachers;
  final String? error;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;

  const AdminUserManagementState({
    this.isLoading = false,
    this.students = const [],
    this.teachers = const [],
    this.error,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
  });

  AdminUserManagementState copyWith({
    bool? isLoading,
    List<AppUser>? students,
    List<AppUser>? teachers,
    String? error,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
  }) {
    return AdminUserManagementState(
      isLoading: isLoading ?? this.isLoading,
      students: students ?? this.students,
      teachers: teachers ?? this.teachers,
      error: error,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }
}

/// Provider for admin user management
final adminUserManagementProvider = StateNotifierProvider<
    AdminUserManagementNotifier, AdminUserManagementState>((ref) {
  return AdminUserManagementNotifier();
});

/// Notifier class for admin user management
class AdminUserManagementNotifier
    extends StateNotifier<AdminUserManagementState> {
  AdminUserManagementNotifier() : super(const AdminUserManagementState());

  /// Load all students and teachers for an institution
  Future<void> loadUsers(String institutionId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final students = await DbService.getInstitutionStudents(institutionId);
      final teachers = await DbService.getInstitutionTeachers(institutionId);

      state = state.copyWith(
        isLoading: false,
        students: students,
        teachers: teachers,
      );

      debugPrint(
          'Loaded ${students.length} students and ${teachers.length} teachers');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load users: $e',
      );
      debugPrint('Error loading users: $e');
    }
  }

  /// Create a new user
  Future<bool> createUser({
    required String name,
    required String email,
    required String username,
    required UserRole role,
    required String institutionId,
    String? classId,
  }) async {
    try {
      state = state.copyWith(isCreating: true, error: null);

      final now = DateTime.now();
      final userId = cuid();

      final newUser = AppUser(
        id: userId,
        username: username,
        name: name,
        email: email,
        role: role,
        institutionId: institutionId,
        classId: classId,
        createdAt: now,
        updatedAt: now,
      );

      await DbService.usersCollRef().doc(userId).set(newUser);

      // Refresh the user lists
      await loadUsers(institutionId);

      state = state.copyWith(isCreating: false);
      debugPrint('Successfully created user: ${newUser.name}');
      return true;
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        error: 'Failed to create user: $e',
      );
      debugPrint('Error creating user: $e');
      return false;
    }
  }

  /// Update an existing user
  Future<bool> updateUser({
    required String userId,
    required String name,
    required String email,
    required String username,
    required UserRole role,
    required String institutionId,
    String? classId,
  }) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);

      final now = DateTime.now();

      final updatedUser = AppUser(
        id: userId,
        username: username,
        name: name,
        email: email,
        role: role,
        institutionId: institutionId,
        classId: classId,
        createdAt: now, // We'll preserve the original createdAt
        updatedAt: now,
      );

      await DbService.usersCollRef().doc(userId).set(updatedUser);

      // Refresh the user lists
      await loadUsers(institutionId);

      state = state.copyWith(isUpdating: false);
      debugPrint('Successfully updated user: ${updatedUser.name}');
      return true;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Failed to update user: $e',
      );
      debugPrint('Error updating user: $e');
      return false;
    }
  }

  /// Delete a user
  Future<bool> deleteUser({
    required String userId,
    required String institutionId,
  }) async {
    try {
      state = state.copyWith(isDeleting: true, error: null);

      await DbService.usersCollRef().doc(userId).delete();

      // Refresh the user lists
      await loadUsers(institutionId);

      state = state.copyWith(isDeleting: false);
      debugPrint('Successfully deleted user: $userId');
      return true;
    } catch (e) {
      state = state.copyWith(
        isDeleting: false,
        error: 'Failed to delete user: $e',
      );
      debugPrint('Error deleting user: $e');
      return false;
    }
  }

  /// Get user by ID
  AppUser? getUserById(String userId) {
    final allUsers = [...state.students, ...state.teachers];
    try {
      return allUsers.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }

  /// Check if username is already taken
  bool isUsernameTaken(String username, {String? excludeUserId}) {
    final allUsers = [...state.students, ...state.teachers];
    return allUsers
        .any((user) => user.username == username && user.id != excludeUserId);
  }

  /// Check if email is already taken
  bool isEmailTaken(String email, {String? excludeUserId}) {
    final allUsers = [...state.students, ...state.teachers];
    return allUsers
        .any((user) => user.email == email && user.id != excludeUserId);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}
