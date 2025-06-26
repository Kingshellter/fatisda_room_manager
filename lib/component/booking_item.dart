// lib/component/booking_item.dart
import 'package:flutter/material.dart';
import '../models/booking.dart';
import 'booking_detail_dialog.dart';

class BookingItem extends StatelessWidget {
  final Booking booking;
  final double hourHeight;
  final double dayColumnWidth;
  final Function(Booking) onCancelBooking;

  const BookingItem({
    super.key,
    required this.booking,
    required this.hourHeight,
    required this.dayColumnWidth,
    required this.onCancelBooking,
  });

  // Helper untuk menghitung posisi Y berdasarkan waktu
  double _calculateTimeOffset(String time) {
    final parts = time.split('.');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    // Waktu mulai timeline
    const timelineStartHour = 7;
    const timelineStartMinute = 30;

    // Total menit dari awal hari
    final timeTotalMinutes = hour * 60 + minute;
    final timelineStartTotalMinutes =
        timelineStartHour * 60 + timelineStartMinute;

    // Perbedaan dalam menit dari awal timeline
    final diffMinutes = timeTotalMinutes - timelineStartTotalMinutes;

    // Konversi ke offset "jam"
    return (diffMinutes / 60.0) * hourHeight;
  }

  void _showBookingDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BookingDetailDialog(
          booking: booking,
          onCancel: () => onCancelBooking(booking),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Hitung posisi dan tinggi item booking
    final startOffset = _calculateTimeOffset(booking.startTime);
    final endOffset = _calculateTimeOffset(booking.endTime);
    final height = endOffset - startOffset;

    return Positioned(
      top: startOffset,
      left: booking.dayColumn * dayColumnWidth,
      width: dayColumnWidth,
      height: height,
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: GestureDetector(
          onTap: () => _showBookingDetail(context),
          child: Container(
            decoration: BoxDecoration(
              color: booking.color.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(4.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    booking.room,
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (height > 50) // Only show lecturer if there's enough space
                    Text(
                      booking.lecturer,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
