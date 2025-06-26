// lib/component/booking_form_dialog.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking.dart'; // Sesuaikan path jika perlu

class BookingFormDialog extends StatefulWidget {
  final Function(Booking) onBookingConfirmed;
  final List<String> rooms;
  final List<Booking>
  existingBookings; // Tambahkan parameter untuk booking yang ada

  const BookingFormDialog({
    super.key,
    required this.onBookingConfirmed,
    required this.rooms,
    required this.existingBookings, // Tambahkan parameter ini
  });

  @override
  State<BookingFormDialog> createState() => _BookingFormDialogState();
}

class _BookingFormDialogState extends State<BookingFormDialog> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for input fields
  final _nameController = TextEditingController();
  final _majorController = TextEditingController();
  final _classYearController = TextEditingController();
  final _courseController = TextEditingController();
  final _lecturerController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedNecessary;
  String? _selectedRoom;
  String? _selectedStartTime;
  String? _selectedEndTime;
  DateTime _selectedDate = DateTime.now();

  final List<String> _necessaries = ['Kuliah', 'Rapat', 'Seminar', 'Lainnya'];

  // Separate lists for start and end times
  final List<String> _startTimes = [
    '07.30',
    '08.25',
    '09.20',
    '10.15',
    '11.10',
    '13.00',
    '13.55',
    '15.30',
    '16.25',
  ];

  final List<String> _endTimes = [
    '08.20',
    '09.15',
    '10.10',
    '11.05',
    '12.00',
    '13.50',
    '14.45',
    '16.20',
    '17.15',
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
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
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Fungsi untuk mengecek apakah ada booking yang bertabrakan
  bool _hasConflictingBooking(
    String room,
    String startTime,
    String endTime,
    DateTime bookingDate,
  ) {
    return widget.existingBookings.any((booking) {
      // Cek apakah di ruangan yang sama dan tanggal yang sama
      if (booking.room == room &&
          booking.bookingDate.year == bookingDate.year &&
          booking.bookingDate.month == bookingDate.month &&
          booking.bookingDate.day == bookingDate.day) {
        // Konversi waktu booking yang ada ke menit
        final existingStart = _timeToMinutes(booking.startTime);
        final existingEnd = _timeToMinutes(booking.endTime);

        // Konversi waktu booking baru ke menit
        final newStart = _timeToMinutes(startTime);
        final newEnd = _timeToMinutes(endTime);

        // Cek apakah waktu bertabrakan
        return (newStart < existingEnd && newEnd > existingStart);
      }
      return false;
    });
  }

  // Helper untuk mengkonversi format waktu "HH.mm" ke menit
  int _timeToMinutes(String time) {
    final parts = time.split('.');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final selectedStartTime = _selectedStartTime;
      final selectedEndTime = _selectedEndTime;
      final selectedRoom = _selectedRoom;

      if (selectedStartTime != null &&
          selectedEndTime != null &&
          selectedRoom != null) {
        // Cek konflik booking
        if (_hasConflictingBooking(
          selectedRoom,
          selectedStartTime,
          selectedEndTime,
          _selectedDate,
        )) {
          // Tampilkan pesan error jika ada konflik
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ruangan sudah dibooking untuk waktu tersebut!'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
          return;
        }

        // Dapatkan indeks ruangan yang dipilih
        final roomIndex = widget.rooms.indexOf(selectedRoom);

        final booking = Booking(
          title: _courseController.text,
          startTime: selectedStartTime,
          endTime: selectedEndTime,
          color: _getRandomColor(),
          dayColumn: roomIndex,
          room: selectedRoom,
          studentName: _nameController.text,
          major: _majorController.text,
          classYear: _classYearController.text,
          necessary: _selectedNecessary!,
          notes: _notesController.text,
          lecturer: _lecturerController.text,
          bookingDate: _selectedDate,
          createdAt: DateTime.now(),
        );

        widget.onBookingConfirmed(booking);
        Navigator.of(context).pop();
      }
    }
  }

  // Helper function to compare time strings in format "HH.mm"
  int _compareTimeStrings(String time1, String time2) {
    final parts1 = time1.split('.');
    final parts2 = time2.split('.');

    int hours1 = int.parse(parts1[0]);
    int minutes1 = int.parse(parts1[1]);
    int hours2 = int.parse(parts2[0]);
    int minutes2 = int.parse(parts2[1]);

    if (hours1 != hours2) {
      return hours1.compareTo(hours2);
    }
    return minutes1.compareTo(minutes2);
  }

  // Helper to get valid end times based on selected start time
  List<String> _getValidEndTimes() {
    if (_selectedStartTime == null) return _endTimes;
    return _endTimes
        .where(
          (endTime) => _compareTimeStrings(_selectedStartTime!, endTime) < 0,
        )
        .toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _majorController.dispose();
    _classYearController.dispose();
    _courseController.dispose();
    _lecturerController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: AlertDialog(
          title: const Text(
            'BOOKING YOUR ROOM',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 20.0,
          ),
          insetPadding: EdgeInsets.zero,
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Text(
                    'Input Data Dengan Benar!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),

                  _buildSectionTitle('Identitas'),
                  _buildTextFormField(_nameController, 'Nama'),
                  _buildTextFormField(_majorController, 'Prodi'),
                  _buildTextFormField(_classYearController, 'Angkatan'),
                  const SizedBox(height: 20),

                  _buildSectionTitle('Keperluan'),
                  _buildDropdownFormField<String>(
                    value: _selectedNecessary,
                    hint: 'Pilih Keperluan',
                    items: _necessaries,
                    onChanged: (value) =>
                        setState(() => _selectedNecessary = value),
                    itemText: (item) => item,
                  ),
                  _buildTextFormField(
                    _notesController,
                    'Catatan (Opsional)',
                    isOptional: true,
                    maxLines: 3,
                  ),
                  _buildTextFormField(_courseController, 'Mata kuliah'),
                  _buildTextFormField(_lecturerController, 'Dosen'),
                  _buildDropdownFormField<String>(
                    value: _selectedRoom,
                    hint: 'Pilih Room',
                    items: widget.rooms,
                    onChanged: (value) => setState(() => _selectedRoom = value),
                    itemText: (item) => item,
                  ),
                  const SizedBox(height: 20),

                  _buildSectionTitle('Pilih Waktu'),
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('E, MMM d, y').format(_selectedDate),
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdownFormField<String>(
                          value: _selectedStartTime,
                          hint: 'Start Time',
                          items: _startTimes,
                          onChanged: (value) {
                            setState(() {
                              _selectedStartTime = value;
                              if (_selectedEndTime != null &&
                                  _compareTimeStrings(
                                        _selectedStartTime!,
                                        _selectedEndTime!,
                                      ) >=
                                      0) {
                                _selectedEndTime = null;
                              }
                            });
                          },
                          itemText: (time) => time,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDropdownFormField<String>(
                          value: _selectedEndTime,
                          hint: 'End Time',
                          items: _getValidEndTimes(),
                          onChanged: (value) =>
                              setState(() => _selectedEndTime = value),
                          itemText: (time) => time,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueAccent),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      DateFormat('d MMM, y').format(DateTime.now()),
                      style: const TextStyle(color: Colors.blueAccent),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent[400],
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                child: const Text(
                  'Booking Now',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.orangeAccent,
        ),
      ),
    );
  }

  Widget _buildTextFormField(
    TextEditingController controller,
    String label, {
    bool isOptional = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 12.0,
          ),
        ),
        validator: (value) {
          if (!isOptional && (value == null || value.isEmpty)) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownFormField<T>({
    required T? value,
    required String hint,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required String Function(T) itemText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<T>(
        decoration: InputDecoration(
          labelText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 12.0,
          ),
        ),
        value: value,
        hint: Text(hint),
        isExpanded: true,
        items: items.map((T item) {
          return DropdownMenuItem<T>(value: item, child: Text(itemText(item)));
        }).toList(),
        onChanged: onChanged,
        validator: (value) {
          if (value == null) {
            return 'Please select $hint';
          }
          return null;
        },
      ),
    );
  }

  Color _getRandomColor() {
    final colors = [
      Colors.blue[400]!,
      Colors.green[400]!,
      Colors.orange[400]!,
      Colors.purple[400]!,
      Colors.red[400]!,
      Colors.teal[400]!,
    ];
    return colors[DateTime.now().microsecond % colors.length];
  }
}
