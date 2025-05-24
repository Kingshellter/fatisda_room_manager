// lib/component/booking_form_dialog.dart
import 'package:flutter/material.dart';
import '../models/booking.dart'; // Sesuaikan path jika perlu

class BookingFormDialog extends StatefulWidget {
  final Function(Booking) onBookingConfirmed;
  final List<Map<String, String>> timeSlots; // Untuk dropdown waktu
  final List<String> rooms; // Untuk dropdown ruangan

  const BookingFormDialog({
    Key? key,
    required this.onBookingConfirmed,
    required this.timeSlots,
    required this.rooms,
  }) : super(key: key);

  @override
  State<BookingFormDialog> createState() => _BookingFormDialogState();
}

class _BookingFormDialogState extends State<BookingFormDialog> {
  final _formKey = GlobalKey<FormState>();

  // Controllers untuk input fields
  final _nameController = TextEditingController();
  final _majorController = TextEditingController();
  final _classYearController = TextEditingController();
  final _courseController = TextEditingController();
  final _lecturerController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedNecessary;
  String? _selectedRoom;
  Map<String, String>? _selectedTimeSlot; // Untuk menyimpan start dan end time

  final List<String> _necessaries = ['Kuliah', 'Rapat', 'Seminar', 'Lainnya'];


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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedTimeSlot == null || _selectedRoom == null || _selectedNecessary == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Harap lengkapi semua pilihan dropdown!')),
        );
        return;
      }

      final newBooking = Booking(
        title: _courseController.text, // Menggunakan nama mata kuliah sebagai judul
        startTime: _selectedTimeSlot!['start']!,
        endTime: _selectedTimeSlot!['end']!,
        color: Colors.blueAccent, // Warna default untuk booking baru
        dayColumn: 0, // Default ke kolom hari pertama, bisa dikembangkan
        room: _selectedRoom!,
        studentName: _nameController.text,
        major: _majorController.text,
        classYear: _classYearController.text,
        necessary: _selectedNecessary!,
        notes: _notesController.text,
        lecturer: _lecturerController.text,
      );
      widget.onBookingConfirmed(newBooking);
      Navigator.of(context).pop(); // Tutup dialog
    }
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
              const Text('Fill the data correctly', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 20),

              _buildSectionTitle('Identity'),
              _buildTextFormField(_nameController, 'Name'),
              _buildTextFormField(_majorController, 'Major'),
              _buildTextFormField(_classYearController, 'Class Year'),
              const SizedBox(height: 20),

              _buildSectionTitle('Necessary'),
              _buildDropdownFormField<String>(
                value: _selectedNecessary,
                hint: 'Select Necessary',
                items: _necessaries,
                onChanged: (value) => setState(() => _selectedNecessary = value),
                itemText: (item) => item,
              ),
              _buildTextFormField(_notesController, 'Notes (Optional)', isOptional: true, maxLines: 3),
              _buildTextFormField(_courseController, 'Course'),
              _buildTextFormField(_lecturerController, 'Lecturer'),
              _buildDropdownFormField<String>(
                value: _selectedRoom,
                hint: 'Select Room',
                items: widget.rooms,
                onChanged: (value) => setState(() => _selectedRoom = value),
                itemText: (item) => item,
              ),
              const SizedBox(height: 10),
              _buildDropdownFormField<Map<String, String>>(
                value: _selectedTimeSlot,
                hint: 'Select Time Slot',
                items: widget.timeSlots,
                onChanged: (value) => setState(() => _selectedTimeSlot = value),
                itemText: (slot) => '${slot['start']} - ${slot['end']}',
              ),

              const SizedBox(height: 20),
              // Placeholder untuk tanggal dan waktu (sesuai gambar)
              // Ini bisa diisi otomatis atau dipilih pengguna
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  '${DateTime.now().day} ${_getMonthName(DateTime.now().month)}, ${DateTime.now().year}   ${TimeOfDay.now().format(context)}',
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent[400], padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15)),
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
