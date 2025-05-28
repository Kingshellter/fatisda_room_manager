// lib/models/booking.dart
import 'package:flutter/material.dart';

class Booking {
  final String title; // Akan diisi dari 'Course' di form
  final String startTime; // Format HH.mm
  final String endTime;   // Format HH.mm
  final Color color;
  final int dayColumn; // Kolom hari (0 untuk kolom pertama, dst.)
  final String room;    // Informasi ruangan

  // Informasi tambahan dari form
  final String studentName;
  final String major;
  final String classYear;
  final String necessary; // Keperluan
  final String notes;
  final String lecturer;
  final DateTime bookingDate; // Add booking date
  final DateTime createdAt; // Add timestamp for creation time


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
    this.notes = '', // Notes bisa opsional
    required this.lecturer,
    required this.bookingDate, // Add booking date parameter
    DateTime? createdAt, // Make it optional with default value
  }) : createdAt = createdAt ?? DateTime.now(); // Set current time if not provided

  // Helper untuk mengubah string "HH.mm" menjadi TimeOfDay
  TimeOfDay _parseTime(String time) {
    final parts = time.split('.');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  // Helper untuk mendapatkan durasi dalam jam
  double get durationInHours {
    try {
      final start = _parseTime(startTime);
      final end = _parseTime(endTime);

      final startTotalMinutes = start.hour * 60 + start.minute;
      final endTotalMinutes = end.hour * 60 + end.minute;

      if (endTotalMinutes < startTotalMinutes) {
        return 0.0;
      }
      return (endTotalMinutes - startTotalMinutes) / 60.0;
    } catch (e) {
      print('Error parsing time for durationInHours: $e');
      return 0.0;
    }
  }

  // Helper untuk mendapatkan offset Y berdasarkan waktu mulai
  // Jam mulai timeline kita adalah 07:30
  double get startOffset {
    try {
      final timelineStartHour = 7;
      final timelineStartMinute = 30;

      final bookingStart = _parseTime(startTime);

      // Konversi waktu ke menit dari awal hari
      final timelineStartTotalMinutes = timelineStartHour * 60 + timelineStartMinute;
      final bookingStartTotalMinutes = bookingStart.hour * 60 + bookingStart.minute;

      // Offset dalam menit dari awal timeline
      final offsetInMinutes = bookingStartTotalMinutes - timelineStartTotalMinutes;

      // Konversi offset ke "jam" relatif terhadap hourHeight
      return offsetInMinutes / 60.0;

    } catch (e) {
      print('Error parsing time for startOffset: $e');
      return 0.0;
    }
  }
}
