import 'package:flutter/material.dart';
import '../models/booking.dart';

class BookingDetailDialog extends StatelessWidget {
  final Booking booking;
  final VoidCallback onCancel;

  const BookingDetailDialog({
    Key? key,
    required this.booking,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Detail Booking',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailItem('Mata Kuliah', booking.title),
            _buildDetailItem('Ruangan', booking.room),
            _buildDetailItem('Waktu', '${booking.startTime} - ${booking.endTime}'),
            _buildDetailItem('Nama', booking.studentName),
            _buildDetailItem('Prodi', booking.major),
            _buildDetailItem('Angkatan', booking.classYear),
            _buildDetailItem('Keperluan', booking.necessary),
            _buildDetailItem('Dosen', booking.lecturer),
            if (booking.notes.isNotEmpty) _buildDetailItem('Catatan', booking.notes),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Tutup dialog
                  onCancel(); // Panggil fungsi pembatalan
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: const Text(
                  'Batalkan Booking',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
} 