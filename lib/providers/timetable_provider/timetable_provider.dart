import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/models/time_table.dart';
import 'package:potential_plus/services/db_service.dart';

class TimetableNotifier extends StateNotifier<TimeTable> {
  TimetableNotifier(super.initial);

  void addEntry(TimetableEntry entry) {
    final updatedEntries = [...state.entries, entry];
    state = TimeTable(
      id: state.id,
      entries: updatedEntries,
      createdAt: state.createdAt,
      updatedAt: DateTime.now(),
    );
    _updateFirestore();
  }

  void removeEntry(TimetableEntry entry) {
    state.entries.remove(entry);
    _updateFirestore();
  }

  void updateEntry(TimetableEntry entry) {
    final updatedEntries = state.entries.map((e) {
      if (e.id == entry.id) return entry;
      return e;
    }).toList();
    state = TimeTable(
      id: state.id,
      entries: updatedEntries,
      createdAt: state.createdAt,
      updatedAt: DateTime.now(),
    );

    _updateFirestore();
  }

  void reorderEntrys({
    required int day,
    required int oldIndex,
    required int newIndex,
  }) {
    final dayEntrys = state.entries.where((e) => e.day == day).toList();
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = dayEntrys.removeAt(oldIndex);
    dayEntrys.insert(newIndex, item);

    // Update entry numbers
    for (var i = 0; i < dayEntrys.length; i++) {
      dayEntrys[i] = dayEntrys[i].copyWith(entryNumber: i + 1);
    }

    // Update state
    final otherEntrys = state.entries.where((e) => e.day != day).toList();
    state = TimeTable(
      id: state.id,
      entries: [...otherEntrys, ...dayEntrys],
      createdAt: state.createdAt,
      updatedAt: DateTime.now(),
    );
    _updateFirestore();
  }

  Future<void> _updateFirestore() async {
    try {
      await DbService.updateClassTimetable(state.id, state);
    } catch (e) {
      rethrow;
    }
  }
}

final timetableProvider =
    StateNotifierProvider.family<TimetableNotifier, TimeTable, TimeTable>(
        (ref, timeTable) {
  return TimetableNotifier(timeTable);
});
