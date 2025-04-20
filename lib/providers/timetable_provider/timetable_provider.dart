import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/models/time_table.dart';

class TimetableNotifier extends StateNotifier<TimeTable> {
  TimetableNotifier(super.initial);

  void addLecture(TimetableEntry lecture) {
    final updatedEntries = [...state.entries, lecture];
    state = TimeTable(
      id: state.id,
      entries: updatedEntries,
      createdAt: state.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  void updateLecture(TimetableEntry lecture) {
    final updatedEntries = state.entries.map((e) {
      if (e.id == lecture.id) return lecture;
      return e;
    }).toList();

    state = TimeTable(
      id: state.id,
      entries: updatedEntries,
      createdAt: state.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  void reorderLectures(int day, int oldIndex, int newIndex) {
    final dayLectures = state.entries.where((e) => e.day == day).toList();
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = dayLectures.removeAt(oldIndex);
    dayLectures.insert(newIndex, item);

    // Update lecture numbers
    for (var i = 0; i < dayLectures.length; i++) {
      dayLectures[i] = dayLectures[i].copyWith(lectureNumber: i + 1);
    }

    // Update state
    final otherLectures = state.entries.where((e) => e.day != day).toList();
    state = TimeTable(
      id: state.id,
      entries: [...otherLectures, ...dayLectures],
      createdAt: state.createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

final timetableProvider =
    StateNotifierProvider.family<TimetableNotifier, TimeTable, TimeTable>(
        (ref, timeTable) {
  return TimetableNotifier(timeTable);
});
