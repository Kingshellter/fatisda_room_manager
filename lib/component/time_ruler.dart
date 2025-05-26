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
  // relatif terhadap awal timeline (07:30)
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

    for (var slot in timeSlots) {
      final startTime = slot['start']!;
      // Tampilkan hanya waktu mulai untuk setiap slot
      timeMarkers.add(
        Positioned(
          top: _calculateSlotOffsetY(startTime) - 8, // Penyesuaian posisi teks
          left: 8, // Beri sedikit padding dari kiri
          child: Text(
            startTime,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      );
    }

    // Hitung tinggi total ruler berdasarkan slot terakhir
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
      totalHeight = (diffMinutes / 60.0) * hourHeight + hourHeight /2 ; // Tambah sedikit buffer
    }


    return SizedBox(
      width: 60, // Lebar area time ruler disesuaikan
      height: totalHeight, // Tinggi ruler dinamis
      child: Stack(
        children: timeMarkers,
      ),
    );
  }
}
