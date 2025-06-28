import 'package:flutter/material.dart';

class Booking {
  final String title;
  final String startTime;
  final String endTime;
  final Color color;
  final int dayColumn;
  final String room;
  final String studentName;
  final String major;
  final String classYear;
  final String necessary;
  final String notes;
  final String lecturer;
  final DateTime bookingDate;
  final DateTime createdAt;

  Booking({
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.color,
    required this.dayColumn,
    required this.room,
    required this.studentName,
    required this.major,
    required this.classYear,
    required this.necessary,
    required this.notes,
    required this.lecturer,
    required this.bookingDate,
    required this.createdAt,
  });

  // Helper methods that might be used in your existing app
  String get timeRange => '$startTime - $endTime';

  bool get isToday {
    final now = DateTime.now();
    return bookingDate.year == now.year &&
        bookingDate.month == now.month &&
        bookingDate.day == now.day;
  }

  String get formattedDate {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${bookingDate.day} ${months[bookingDate.month - 1]} ${bookingDate.year}';
  }

  // Create a copy with updated properties
  Booking copyWith({
    String? title,
    String? startTime,
    String? endTime,
    Color? color,
    int? dayColumn,
    String? room,
    String? studentName,
    String? major,
    String? classYear,
    String? necessary,
    String? notes,
    String? lecturer,
    DateTime? bookingDate,
    DateTime? createdAt,
  }) {
    return Booking(
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      color: color ?? this.color,
      dayColumn: dayColumn ?? this.dayColumn,
      room: room ?? this.room,
      studentName: studentName ?? this.studentName,
      major: major ?? this.major,
      classYear: classYear ?? this.classYear,
      necessary: necessary ?? this.necessary,
      notes: notes ?? this.notes,
      lecturer: lecturer ?? this.lecturer,
      bookingDate: bookingDate ?? this.bookingDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
