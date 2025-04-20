import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class TimeTable {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<TimetableEntry> entries;

  TimeTable({
    required this.id,
    required this.entries,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TimeTable.fromMap(Map<String, dynamic> map) {
    return TimeTable(
      id: map['id'],
      entries: (map['entries'] as List)
          .map((entry) => TimetableEntry.fromMap(entry))
          .toList(),
      createdAt: map['createdAt'].toDate(),
      updatedAt: map['updatedAt'].toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'entries': entries,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}

class TimetableEntry {
  final String id;
  final String subject;
  final String teacherId;
  final Timestamp? from;
  final Timestamp? to;
  final int day;
  final int lectureNumber;

  TimetableEntry({
    required this.id,
    required this.subject,
    required this.teacherId,
    this.from,
    this.to,
    required this.day,
    required this.lectureNumber,
  });

  TimetableEntry copyWith({
    String? id,
    String? subject,
    String? teacherId,
    Timestamp? from,
    Timestamp? to,
    int? day,
    int? lectureNumber,
  }) {
    return TimetableEntry(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      teacherId: teacherId ?? this.teacherId,
      from: from ?? this.from,
      to: to ?? this.to,
      day: day ?? this.day,
      lectureNumber: lectureNumber ?? this.lectureNumber,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject': subject,
      'teacherId': teacherId,
      'from': from,
      'to': to,
      'day': day,
      'lectureNumber': lectureNumber,
    };
  }

  factory TimetableEntry.fromMap(Map<String, dynamic> map) {
    return TimetableEntry(
      id: map['id'],
      subject: map['subject'],
      teacherId: map['teacherId'],
      from: map['from'],
      to: map['to'],
      day: map['day'],
      lectureNumber: map['lectureNumber'],
    );
  }
}
