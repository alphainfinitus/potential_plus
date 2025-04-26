import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/models/time_table.dart';
import 'package:potential_plus/providers/timetable_provider/timetable_provider.dart';
import 'package:cuid2/cuid2.dart';

class TimetableController {
  final WidgetRef ref;
  final TimeTable timeTable;
  final String classId;
  late final provider = timetableProvider(timeTable);

  TimetableController(this.ref, this.timeTable, this.classId);

  List<TimetableEntry> getEntrysForDay(int day) {
    return ref
        .watch(provider)
        .entries
        .where((entry) => entry.day == day)
        .toList()
      ..sort((a, b) => a.entryNumber.compareTo(b.entryNumber));
  }

  void addEntry(TimetableEntry entry) {
    ref.read(provider.notifier).addEntry(entry);
  }

  void removeEntry(TimetableEntry entry){
    ref.read(provider.notifier).removeEntry(entry);
  }

  void updateEntry(TimetableEntry entry) {
    ref.read(provider.notifier).updateEntry(entry);
  }

  void reorderEntrys({
    required int day,
    required int oldIndex,
    required int newIndex,
  }) {
    ref.read(provider.notifier).reorderEntrys(day: day, oldIndex: oldIndex, newIndex: newIndex);
  }

  TimetableEntry createNewEntry({
    required String subject,
    required String teacherId,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required int day,
    required int entryNumber,
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
      id: cuid(),
      subject: subject,
      teacherId: teacherId,
      from: Timestamp.fromDate(startDateTime),
      to: Timestamp.fromDate(endDateTime),
      day: day,
      entryNumber: entryNumber,
    );
  }

  TimetableEntry updateExistingEntry({
    required TimetableEntry entry,
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

    return entry.copyWith(
      subject: subject,
      teacherId: teacherId,
      from: Timestamp.fromDate(startDateTime),
      to: Timestamp.fromDate(endDateTime),
    );
  }
}
