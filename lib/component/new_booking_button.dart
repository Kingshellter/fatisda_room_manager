// lib/component/new_booking_button.dart
import 'package:flutter/material.dart';

class NewBookingButton extends StatelessWidget {
  final VoidCallback onPressed;

  const NewBookingButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add, color: Colors.black87),
      label: const Text('Booking', style: TextStyle(color: Colors.black87)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFAED581), // Warna hijau muda seperti gambar
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        elevation: 3,
      ),
    );
  }
}