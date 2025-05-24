import 'package:flutter/material.dart';

class DateHeader extends StatelessWidget {
  final String dateText;
  final VoidCallback onEditPressed;

  const DateHeader ({
  Key? key,
  required this.dateText,
  required this.onEditPressed,
}) : super(key: key);

@override
Widget build(BuildContext context) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    color: Colors.grey[300],
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.home_work_outlined, color: Colors.black54, size: 28), // Placeholder logo
          ),
          const SizedBox(width: 12),
          Text(
            dateText,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: Colors.black54),
          onPressed: onEditPressed,
        ),
      ],
    ),
  );
}
}
