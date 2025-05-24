// lib/component/time_ruler.dart
import 'package:flutter/material.dart';

class TimeRuler extends StatelessWidget {
  final double hourHeight;
  final int startHour; // Jam mulai timeline (misal: 9 untuk 09.00)
  final int endHour;   // Jam akhir timeline (misal: 14 untuk 14.00)

  const TimeRuler({
    Key? key,
    required this.hourHeight,
    this.startHour = 9,
    this.endHour = 14,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> timeMarkers = [];
    for (int i = startHour; i <= endHour; i++) {
      timeMarkers.add(
        Positioned(
          top: (i - startHour) * hourHeight - 8, // -8 untuk penyesuaian posisi teks
          left: 16,
          child: Text(
            '${i.toString().padLeft(2, '0')}.00',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      );
    }

    return SizedBox(
      width: 70, // Lebar area time ruler
      child: Stack(
        children: timeMarkers,
      ),
    );
  }
}