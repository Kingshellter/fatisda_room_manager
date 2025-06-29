import 'package:flutter/material.dart';

class DateHeader extends StatefulWidget {
  final String dateText;
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;

  const DateHeader({
    super.key,
    required this.dateText,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  State<DateHeader> createState() => _DateHeaderState();
}

class _DateHeaderState extends State<DateHeader> {
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.indigo,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.indigo),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      widget.onDateChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      color: Colors.grey[300],
      height: 60,
      child: Row(
        children: [
          SizedBox(
            width: 60,
            height: 44,
            child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    widget.dateText,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.end,
                  ),
                ),

                const SizedBox(width: 4),

                SizedBox(
                  width: 28,
                  height: 28,
                  child: IconButton(
                    icon: const Icon(
                      Icons.edit_calendar_outlined,
                      color: Colors.black54,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    onPressed: () => _selectDate(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
