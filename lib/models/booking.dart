// lib/models/booking.dart
import 'package:flutter/material.dart';

class Booking {
  final String title;
  final String startTime; // Format HH.mm
  final String endTime;   // Format HH.mm
  final Color color;
  final int dayColumn; // Kolom hari (0 untuk kolom pertama, 1 untuk kedua, dst.)

  Booking({
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.color,
    required this.dayColumn,
  });

  // Helper untuk mendapatkan durasi dalam jam
  double get durationInHours {
    try {
      final startHour = int.parse(startTime.split('.')[0]);
      final startMinute = int.parse(startTime.split('.')[1]);
      final endHour = int.parse(endTime.split('.')[0]);
      final endMinute = int.parse(endTime.split('.')[1]);

      final startTotalMinutes = startHour * 60 + startMinute;
      final endTotalMinutes = endHour * 60 + endMinute;

      if (endTotalMinutes < startTotalMinutes) {
        // Jika waktu selesai lebih awal dari waktu mulai (misal melewati tengah malam atau data salah)
        // Untuk kasus sederhana ini, kita anggap durasinya 0 atau bisa juga throw error.
        // Atau jika melewati tengah malam, (24*60 - startTotalMinutes) + endTotalMinutes
        return 0.0; // Atau handle sesuai logika bisnis Anda
      }

      return (endTotalMinutes - startTotalMinutes) / 60.0;
    } catch (e) {
      // Handle parsing error, misalnya format waktu tidak sesuai
      print('Error parsing time for durationInHours: $e');
      return 0.0; // Default duration jika ada error
    }
  }

  // Helper untuk mendapatkan offset Y berdasarkan waktu mulai
  double get startOffset {
    try {
      final startHour = int.parse(startTime.split('.')[0]);
      final startMinute = int.parse(startTime.split('.')[1]);
      // Asumsi timeline dimulai jam 09.00
      // Jika startHour adalah 9, offset adalah (9-9) + min/60 = min/60
      // Jika startHour adalah 10, offset adalah (10-9) + min/60 = 1 + min/60
      return (startHour - 9.0) + (startMinute / 60.0);
    } catch (e) {
      // Handle parsing error
      print('Error parsing time for startOffset: $e');
      return 0.0; // Default offset jika ada error
    }
  }
}
