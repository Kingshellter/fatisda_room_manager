// lib/component/booking_form_dialog.dart
import 'package:flutter/material.dart';
import '../models/booking.dart'; // Sesuaikan path jika perlu

class BookingFormDialog extends StatefulWidget {
  final Function(Booking) onBookingConfirmed;
  final List<String> rooms;

  const BookingFormDialog({
    Key? key,
    required this.onBookingConfirmed,
    required this.rooms,
  }) : super(key: key);

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

  final List<String> _necessaries = ['Kuliah', 'Rapat', 'Seminar', 'Lainnya'];
  
  // Separate lists for start and end times
  final List<String> _startTimes = [
    '07.30', '08.25', '09.20', '10.15', '11.10',
    '13.00', '13.55', '15.30', '16.25'
  ];

  final List<String> _endTimes = [
    '08.20', '09.15', '10.10', '11.05', '12.00',
    '13.50', '14.45', '16.20', '17.15'
  ];

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedStartTime == null || _selectedEndTime == null || _selectedRoom == null || _selectedNecessary == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please complete all required fields!')),
        );
        return;
      }

      // Validate that end time is after start time
      if (_compareTimeStrings(_selectedStartTime!, _selectedEndTime!) >= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('End time must be after start time!')),
        );
        return;
      }

      final newBooking = Booking(
        title: _courseController.text,
        startTime: _selectedStartTime!,
        endTime: _selectedEndTime!,
        color: Colors.blueAccent,
        dayColumn: 0,
        room: _selectedRoom!,
        studentName: _nameController.text,
        major: _majorController.text,
        classYear: _classYearController.text,
        necessary: _selectedNecessary!,
        notes: _notesController.text,
        lecturer: _lecturerController.text,
      );
      widget.onBookingConfirmed(newBooking);
      Navigator.of(context).pop();
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
    return _endTimes.where((endTime) => 
      _compareTimeStrings(_selectedStartTime!, endTime) < 0
    ).toList();
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
    return AlertDialog(
      title: const Text('BOOKING YOUR ROOM', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
      contentPadding: const EdgeInsets.all(16.0),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('Input Data Dengan Benar!', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 20),

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
                onChanged: (value) => setState(() => _selectedNecessary = value),
                itemText: (item) => item,
              ),
              _buildTextFormField(_notesController, 'Catatan (Opsional)', isOptional: true, maxLines: 3),
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
                          // Reset end time if it's no longer valid
                          if (_selectedEndTime != null && 
                              _compareTimeStrings(_selectedStartTime!, _selectedEndTime!) >= 0) {
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
                      onChanged: (value) => setState(() => _selectedEndTime = value),
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
                  '${DateTime.now().day} ${_getMonthName(DateTime.now().month)}, ${DateTime.now().year}',
                  style: const TextStyle(color: Colors.blueAccent),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        Center(
          child: ElevatedButton(
            onPressed: _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent[400],
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15)
            ),
            child: const Text('Booking Now', style: TextStyle(color: Colors.white)),
          ),
        )
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
    );
  }

  Widget _buildTextFormField(TextEditingController controller, String label, {bool isOptional = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        ),
        value: value,
        hint: Text(hint),
        isExpanded: true,
        items: items.map((T item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(itemText(item)),
          );
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

  String _getMonthName(int month) {
    const monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return monthNames[month - 1];
  }
}
