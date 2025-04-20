import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/models/time_table.dart';
import 'package:potential_plus/providers/timetable_provider/timetable_provider.dart';
import 'package:uuid/uuid.dart';

class TimetableController {
  final WidgetRef ref;
  final TimeTable timeTable;
  final String classId;
  late final provider = timetableProvider(timeTable);

  TimetableController(this.ref, this.timeTable, this.classId);

  List<TimetableEntry> getLecturesForDay(int day) {
    return ref
        .watch(provider)
        .entries
        .where((entry) => entry.day == day)
        .toList()
      ..sort((a, b) => a.lectureNumber.compareTo(b.lectureNumber));
  }

  void addLecture(TimetableEntry lecture) {
    ref.read(provider.notifier).addLecture(lecture);
  }

  void updateLecture(TimetableEntry lecture) {
    ref.read(provider.notifier).updateLecture(lecture);
  }

  void reorderLectures(int day, int oldIndex, int newIndex) {
    ref.read(provider.notifier).reorderLectures(day, oldIndex, newIndex);
  }

  TimetableEntry createNewLecture({
    required String subject,
    required String teacherId,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required int day,
    required int lectureNumber,
  }) {
    final now = DateTime.now();
    final startDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      startTime.hour,
      startTime.minute,
    );
    final endDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      endTime.hour,
      endTime.minute,
    );

    return TimetableEntry(
      id: const Uuid().v4(),
      subject: subject,
      teacherId: teacherId,
      from: Timestamp.fromDate(startDateTime),
      to: Timestamp.fromDate(endDateTime),
      day: day,
      lectureNumber: lectureNumber,
    );
  }

  TimetableEntry updateExistingLecture({
    required TimetableEntry lecture,
    required String subject,
    required String teacherId,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
  }) {
    final now = DateTime.now();
    final startDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      startTime.hour,
      startTime.minute,
    );
    final endDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      endTime.hour,
      endTime.minute,
    );

    return lecture.copyWith(
      subject: subject,
      teacherId: teacherId,
      from: Timestamp.fromDate(startDateTime),
      to: Timestamp.fromDate(endDateTime),
    );
  }
}
