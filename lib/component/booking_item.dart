// lib/component/booking_item.dart
import 'package:flutter/material.dart';
// Pastikan path import ini sesuai dengan struktur proyek Anda
// Jika nama folder proyek Anda bukan 'project', sesuaikan 'project' dengan nama folder proyek Anda.
// Contoh: import 'package:fatisda_booking_app/models/booking.dart';
import '../models/booking.dart'; // Jika models berada satu level di atas component

class BookingItem extends StatelessWidget {
  final Booking booking;
  final double hourHeight; // Tinggi untuk setiap jam pada timeline

  const BookingItem({
    Key? key,
    required this.booking,
    required this.hourHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Menghitung tinggi berdasarkan durasi.
    // Pastikan durationInHours menghasilkan nilai non-negatif.
    double itemHeight = booking.durationInHours * hourHeight;
    if (itemHeight < 0) {
      itemHeight = 0; // Mencegah tinggi negatif
    }

    // Menghitung posisi top.
    // Pastikan startOffset menghasilkan nilai yang wajar.
    double itemTop = booking.startOffset * hourHeight;

    return Positioned(
      top: itemTop,
      // Lebar time ruler (70.0) + (kolom * lebar kolom (misal 100.0))
      // Sesuaikan 100.0 jika lebar kolom hari Anda berbeda di main.dart
      left: 70.0 + (booking.dayColumn * 100.0),
      height: itemHeight,
      width: 90.0, // Lebar item booking, bisa disesuaikan
      child: Container(
        padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.only(right: 4.0, bottom: 2.0),
        decoration: BoxDecoration(
          color: booking.color,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              booking.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1, // Batasi judul agar tidak terlalu panjang
            ),
            const SizedBox(height: 2),
            if (itemHeight > 30) // Hanya tampilkan waktu jika item cukup tinggi
              Text(
                '${booking.startTime} - ${booking.endTime}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
          ],
        ),
      ),
    );
  }
}
