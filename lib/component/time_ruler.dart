// lib/component/time_ruler.dart
import 'package:flutter/material.dart';

class TimeRuler extends StatelessWidget {
  final double hourHeight; // Tinggi untuk setiap blok 1 jam
  final List<Map<String, String>> timeSlots; // Daftar slot waktu

  const TimeRuler({
    Key? key,
    required this.hourHeight,
    required this.timeSlots,
  }) : super(key: key);

  // Helper untuk menghitung posisi Y untuk setiap slot waktu
  double _calculateSlotOffsetY(String startTime) {
    final parts = startTime.split('.');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    // Waktu mulai timeline
    const timelineStartHour = 7;
    const timelineStartMinute = 30;

    // Total menit dari awal hari
    final slotStartTotalMinutes = hour * 60 + minute;
    final timelineStartTotalMinutes = timelineStartHour * 60 + timelineStartMinute;

    // Perbedaan dalam menit dari awal timeline
    final diffMinutes = slotStartTotalMinutes - timelineStartTotalMinutes;

    // Konversi ke offset "jam"
    return (diffMinutes / 60.0) * hourHeight;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> timeMarkers = [];

    // Tambahkan marker untuk waktu awal (07:30)
    timeMarkers.add(
      const Positioned(
        top: 0,
        left: 8,
        child: Text(
          '07.30',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ),
    );

    for (var slot in timeSlots) {
      final startTime = slot['start']!;
      if (startTime != '07.30') { // Skip jika ini adalah waktu awal
        timeMarkers.add(
          Positioned(
            top: _calculateSlotOffsetY(startTime),
            left: 8,
            child: Text(
              startTime,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        );
      }
    }

    // Hitung tinggi total ruler
    double totalHeight = 0;
    if (timeSlots.isNotEmpty) {
      final lastSlotEnd = timeSlots.last['end']!;
      final parts = lastSlotEnd.split('.');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      const timelineStartHour = 7;
      const timelineStartMinute = 30;

      final slotEndTotalMinutes = hour * 60 + minute;
      final timelineStartTotalMinutes = timelineStartHour * 60 + timelineStartMinute;
      final diffMinutes = slotEndTotalMinutes - timelineStartTotalMinutes;
      totalHeight = (diffMinutes / 60.0) * hourHeight + hourHeight; // Tambah buffer untuk waktu terakhir
    }

    return Container(
      width: 60,
      height: totalHeight,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Colors.grey[350]!,
            width: 0.5,
          ),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none, // Izinkan overflow untuk memastikan semua teks terlihat
        children: timeMarkers,
      ),
    );
  }
}
