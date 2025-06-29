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
          // Logo dengan ukuran tetap
          SizedBox(
            width: 60,
            height: 44, // Sedikit lebih kecil dari container
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain, // Ubah dari cover ke contain
            ),
          ),

          const SizedBox(width: 8), // Spacing antara logo dan date
          // Expanded untuk mengisi sisa ruang
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Flexible text yang bisa menyesuaikan
                Flexible(
                  child: Text(
                    widget.dateText,
                    style: const TextStyle(
                      fontSize: 16, // Sedikit diperkecil dari 18
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis, // Handle overflow text
                    maxLines: 1,
                  ),
                ),

                const SizedBox(width: 4), // Spacing yang lebih kecil
                // Icon button dengan ukuran yang disesuaikan
                SizedBox(
                  width: 32,
                  height: 32,
                  child: IconButton(
                    icon: const Icon(
                      Icons.edit_calendar_outlined,
                      color: Colors.black54,
                      size: 24, // Sedikit diperkecil dari 28
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

// ALTERNATIF 1: Jika ingin layout yang lebih responsive
class DateHeaderResponsive extends StatefulWidget {
  final String dateText;
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;

  const DateHeaderResponsive({
    super.key,
    required this.dateText,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  State<DateHeaderResponsive> createState() => _DateHeaderResponsiveState();
}

class _DateHeaderResponsiveState extends State<DateHeaderResponsive> {
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 350;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      color: Colors.grey[300],
      height: 60,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              SizedBox(
                width: isSmallScreen ? 50 : 60,
                height: 44,
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(width: 8),

              // Sisa ruang untuk date dan icon
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        widget.dateText,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),

                    const SizedBox(width: 4),

                    IconButton(
                      icon: Icon(
                        Icons.edit_calendar_outlined,
                        color: Colors.black54,
                        size: isSmallScreen ? 20 : 24,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(
                        minWidth: isSmallScreen ? 28 : 32,
                        minHeight: isSmallScreen ? 28 : 32,
                      ),
                      onPressed: () => _selectDate(context),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ALTERNATIF 2: Layout dengan IntrinsicHeight untuk auto-sizing
class DateHeaderAutoSize extends StatefulWidget {
  final String dateText;
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;

  const DateHeaderAutoSize({
    super.key,
    required this.dateText,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  State<DateHeaderAutoSize> createState() => _DateHeaderAutoSizeState();
}

class _DateHeaderAutoSizeState extends State<DateHeaderAutoSize> {
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
      constraints: const BoxConstraints(minHeight: 60, maxHeight: 80),
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      color: Colors.grey[300],
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 60, maxHeight: 44),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Date section dengan flex
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      widget.dateText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.end,
                    ),
                  ),

                  const SizedBox(width: 4),

                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _selectDate(context),
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.edit_calendar_outlined,
                          color: Colors.black54,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
