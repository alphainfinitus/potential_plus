import 'package:cloud_firestore/cloud_firestore.dart';

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
      entries: map['entries'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
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
  const TimetableEntry({
    required this.subject,
    required this.teacherId,
    this.to,
    this.from,
  });

  final String subject;
  final String teacherId;
  final Timestamp? to;
  final Timestamp? from;

  factory TimetableEntry.fromMap(Map<String, String> map) {
    return TimetableEntry(
      subject: map['subject']!,
      teacherId: map['teacherId']!,
      to: map['to'] != null ? Timestamp.fromDate(DateTime.parse(map['to']!)) : null,
      from: map['from'] != null ? Timestamp.fromDate(DateTime.parse(map['from']!)) : null,
    );
  }

  Map<String, String> toMap() => {
    'subject': subject,
    'teacherId': teacherId,
    'to': to != null ? to!.toDate().toString() : '',
    'from': from != null ? from!.toDate().toString() : '',
  };
}