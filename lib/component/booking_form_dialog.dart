// component/booking_form_dialog.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking.dart';
import '../models/room_model.dart';
import '../models/timeslot_model.dart';
import '../models/booking_model.dart' as api_booking;
import '../services/create_booking_service.dart';
import '../services/main_data_service.dart';

class BookingFormDialog extends StatefulWidget {
  final Function(Booking) onBookingConfirmed;
  final List<String> rooms;
  final List<Booking> existingBookings;
  final List<Room> availableRooms;
  final List<TimeSlot> availableTimeSlots;
  final DateTime selectedDate;

  const BookingFormDialog({
    super.key,
    required this.onBookingConfirmed,
    required this.rooms,
    required this.existingBookings,
    required this.availableRooms,
    required this.availableTimeSlots,
    required this.selectedDate,
  });

  @override
  State<BookingFormDialog> createState() => _BookingFormDialogState();
}

class _BookingFormDialogState extends State<BookingFormDialog>
    with TickerProviderStateMixin {
  final CreateBookingService _createBookingService = CreateBookingService();
  final MainDataService _dataService = MainDataService();

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _mataKuliahController = TextEditingController();
  final _dosenController = TextEditingController();
  final _catatanController = TextEditingController();

  // Animation controllers
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // Form state
  Room? _selectedRoom;
  TimeSlot? _selectedTimeSlot;
  String _selectedKeperluan = '';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // Available time slots for selected room and date
  List<TimeSlot> _availableTimeSlotsForRoom = [];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _availableTimeSlotsForRoom = _getFilteredTimeSlots(
      widget.availableTimeSlots,
    );

    // Initialize animations
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
        );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    // Start animations
    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _mataKuliahController.dispose();
    _dosenController.dispose();
    _catatanController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // Helper method to filter and validate data for dropdowns
  List<T> _getUniqueItems<T>(List<T> items, String Function(T) getKey) {
    if (items.isEmpty) return [];

    final Map<String, T> uniqueMap = {};
    for (final item in items) {
      if (item != null) {
        final key = getKey(item);
        if (key.isNotEmpty && !uniqueMap.containsKey(key)) {
          uniqueMap[key] = item;
        }
      }
    }
    return uniqueMap.values.toList();
  }

  // Filter time slots to remove duplicates and null values
  List<TimeSlot> _getFilteredTimeSlots(List<TimeSlot> timeSlots) {
    return _getUniqueItems<TimeSlot>(
      timeSlots,
      (timeSlot) =>
          '${timeSlot.id}_${timeSlot.startTimeFormatted}_${timeSlot.endTimeFormatted}',
    );
  }

  // Filter rooms to remove duplicates and null values
  List<Room> _getFilteredRooms(List<Room> rooms) {
    return _getUniqueItems<Room>(
      rooms,
      (room) => '${room.id}_${room.displayName}',
    );
  }

  // Check if time slot is already booked
  bool _isTimeSlotBooked(TimeSlot timeSlot, Room room) {
    if (widget.existingBookings.isEmpty) return false;

    final dateString = DateFormat('yyyy-MM-dd').format(_selectedDate);

    return widget.existingBookings.any((booking) {
      final bookingDateString = DateFormat(
        'yyyy-MM-dd',
      ).format(booking.bookingDate);
      return bookingDateString == dateString &&
          booking.room == room.displayName &&
          booking.startTime == timeSlot.startTimeFormatted &&
          booking.endTime == timeSlot.endTimeFormatted;
    });
  }

  Future<void> _updateAvailableTimeSlots() async {
    if (_selectedRoom == null) {
      setState(() {
        _availableTimeSlotsForRoom = [];
        _selectedTimeSlot = null;
      });
      return;
    }

    try {
      // Get available time slots from API
      final availableTimeSlotMaps = await _dataService.getAvailableTimeSlots(
        _selectedRoom!.displayName,
        _selectedDate,
      );

      if (availableTimeSlotMaps.isEmpty) {
        setState(() {
          _availableTimeSlotsForRoom = [];
          _selectedTimeSlot = null;
        });
        return;
      }

      // Convert API response to TimeSlot objects
      final availableTimeSlots = <TimeSlot>[];
      for (final timeSlotMap in availableTimeSlotMaps) {
        if (timeSlotMap != null &&
            timeSlotMap['start'] != null &&
            timeSlotMap['end'] != null) {
          final matchingTimeSlot = widget.availableTimeSlots.firstWhere(
            (ts) =>
                ts.startTimeFormatted == timeSlotMap['start'] &&
                ts.endTimeFormatted == timeSlotMap['end'],
            orElse: () => TimeSlot(
              id:
                  int.tryParse(
                    '${timeSlotMap['start']}_${timeSlotMap['end']}'.hashCode
                        .toString(),
                  ) ??
                  0,
              startTime: timeSlotMap['start']!,
              endTime: timeSlotMap['end']!,
              label: '${timeSlotMap['start']} - ${timeSlotMap['end']}',
              isActive: true,
              createdAt: DateTime.now().toIso8601String(),
              updatedAt: DateTime.now().toIso8601String(),
            ),
          );

          // Double check - make sure this slot is not already booked
          if (!_isTimeSlotBooked(matchingTimeSlot, _selectedRoom!)) {
            availableTimeSlots.add(matchingTimeSlot);
          }
        }
      }

      // Filter to ensure unique time slots
      final filteredTimeSlots = _getFilteredTimeSlots(availableTimeSlots);

      setState(() {
        _availableTimeSlotsForRoom = filteredTimeSlots;

        // Check if currently selected time slot is still available
        if (_selectedTimeSlot != null) {
          final isStillAvailable = _availableTimeSlotsForRoom.any(
            (ts) =>
                ts.id == _selectedTimeSlot!.id ||
                (ts.startTimeFormatted ==
                        _selectedTimeSlot!.startTimeFormatted &&
                    ts.endTimeFormatted == _selectedTimeSlot!.endTimeFormatted),
          );

          if (!isStillAvailable) {
            _selectedTimeSlot = null;
          }
        }
      });
    } catch (e) {
      debugPrint('Error updating available time slots: $e');
      setState(() {
        _availableTimeSlotsForRoom = [];
        _selectedTimeSlot = null;
      });
    }
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRoom == null) {
      _showError('Please select a room');
      return;
    }

    if (_selectedTimeSlot == null) {
      _showError('Please select a time slot');
      return;
    }

    if (_selectedKeperluan.isEmpty) {
      _showError('Please select purpose');
      return;
    }

    // Additional validation - check if slot is still available
    if (_isTimeSlotBooked(_selectedTimeSlot!, _selectedRoom!)) {
      _showError(
        'Selected time slot is no longer available. Please choose another time.',
      );
      await _updateAvailableTimeSlots(); // Refresh available slots
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dateString = CreateBookingService.formatDateForApi(_selectedDate);

      final validationError = _createBookingService.validateBookingData(
        roomId: _selectedRoom!.id,
        timeSlotId: _selectedTimeSlot!.id,
        bookingDate: dateString,
        keperluan: _selectedKeperluan,
        mataKuliah: _mataKuliahController.text.trim(),
        dosen: _dosenController.text.trim(),
        catatan: _catatanController.text.trim(),
      );

      if (validationError != null) {
        _showError(validationError);
        return;
      }

      // Check availability first
      final availabilityCheck = await _createBookingService.checkAvailability(
        roomId: _selectedRoom!.id,
        timeSlotId: _selectedTimeSlot!.id,
        bookingDate: dateString,
      );

      if (availabilityCheck['success'] != true ||
          availabilityCheck['data']?['available'] != true) {
        _showError('Selected time slot is no longer available');
        await _updateAvailableTimeSlots(); // Refresh available slots
        return;
      }

      // Create booking
      final newApiBooking = await _createBookingService.createBooking(
        roomId: _selectedRoom!.id,
        timeSlotId: _selectedTimeSlot!.id,
        bookingDate: dateString,
        keperluan: _selectedKeperluan,
        mataKuliah: _mataKuliahController.text.trim().isNotEmpty
            ? _mataKuliahController.text.trim()
            : null,
        dosen: _dosenController.text.trim().isNotEmpty
            ? _dosenController.text.trim()
            : null,
        catatan: _catatanController.text.trim().isNotEmpty
            ? _catatanController.text.trim()
            : null,
      );

      _showSuccess('Booking created successfully! Waiting for approval.');

      // Convert API booking to app booking format
      final appBooking = _convertApiBookingToAppBooking(newApiBooking);

      // Wait a bit to show success message
      await Future.delayed(const Duration(seconds: 1));

      // Call success callback
      widget.onBookingConfirmed(appBooking);

      // Close dialog
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
      _successMessage = null;
      _isLoading = false;
    });
  }

  void _showSuccess(String message) {
    setState(() {
      _successMessage = message;
      _errorMessage = null;
      _isLoading = false;
    });
  }

  Booking _convertApiBookingToAppBooking(api_booking.Booking apiBooking) {
    final filteredRooms = _getFilteredRooms(widget.availableRooms);
    final roomIndex = filteredRooms.indexWhere(
      (room) => room.id == apiBooking.roomId,
    );

    return Booking(
      title: _selectedKeperluan == 'kelas'
          ? _mataKuliahController.text.trim()
          : _selectedKeperluan == 'rapat'
          ? 'Rapat'
          : _catatanController.text.trim(),
      startTime: _selectedTimeSlot!.startTimeFormatted,
      endTime: _selectedTimeSlot!.endTimeFormatted,
      color: const Color(0xFFFF9800), // Orange for pending
      dayColumn: roomIndex >= 0 ? roomIndex : 0,
      room: _selectedRoom!.displayName,
      studentName: '', // Will be filled from user data
      major: '',
      classYear: '',
      necessary: _selectedKeperluan,
      notes: _catatanController.text.trim(),
      lecturer: _dosenController.text.trim(),
      bookingDate: _selectedDate,
      createdAt: DateTime.now(),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextFormField(
              controller: controller,
              maxLines: maxLines,
              enabled: enabled,
              validator: validator,
              decoration: InputDecoration(
                hintText: hint,
                prefixIcon: Icon(icon, color: const Color(0xFF667EEA)),
                filled: true,
                fillColor: enabled ? Colors.white : Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF667EEA),
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE53E3E)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required IconData icon,
    required T? value,
    required List<T> items,
    required String Function(T) getLabel,
    required void Function(T?) onChanged,
    String? hint,
    String? Function(T?)? validator,
  }) {
    // Filter items to ensure no nulls and unique values
    final filteredItems = items.where((item) => item != null).toList();

    // Ensure value is in the filtered list
    final validValue = filteredItems.contains(value) ? value : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonFormField<T>(
              value: validValue,
              validator: validator,
              isExpanded: true, // Prevent overflow
              decoration: InputDecoration(
                hintText: hint,
                prefixIcon: Icon(icon, color: const Color(0xFF667EEA)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF667EEA),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              items: filteredItems.isEmpty
                  ? []
                  : filteredItems.map((item) {
                      return DropdownMenuItem<T>(
                        value: item,
                        child: Text(
                          getLabel(item),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      );
                    }).toList(),
              onChanged: filteredItems.isEmpty ? null : onChanged,
            ),
          ),
          // Show message if no items available
          if (filteredItems.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'No ${label.toLowerCase()} available',
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildKeperluanSelector() {
    final options = CreateBookingService.getKeperluanOptions();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Purpose',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: options.map((option) {
              final isSelected = _selectedKeperluan == option['value'];
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedKeperluan = option['value']!;
                      // Clear controllers when changing purpose
                      if (_selectedKeperluan != 'kelas') {
                        _mataKuliahController.clear();
                      }
                      if (_selectedKeperluan != 'rapat') {
                        _dosenController.clear();
                      }
                      if (_selectedKeperluan != 'lainnya') {
                        _catatanController.clear();
                      }
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF667EEA)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF667EEA)
                            : const Color(0xFFE2E8F0),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      option['label']!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF4A5568),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get filtered data for dropdowns
    final filteredRooms = _getFilteredRooms(widget.availableRooms);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF7FAFC), Color(0xFFEDF2F7)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'New Booking',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              DateFormat(
                                'EEEE, MMMM d, y',
                              ).format(_selectedDate),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                    ],
                  ),
                ),

                // Status Messages
                if (_errorMessage != null || _successMessage != null)
                  Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _errorMessage != null
                          ? const Color(0xFFFED7D7)
                          : const Color(0xFFC6F6D5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _errorMessage != null
                            ? const Color(0xFFE53E3E)
                            : const Color(0xFF38A169),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _errorMessage != null
                              ? Icons.error_outline
                              : Icons.check_circle,
                          color: _errorMessage != null
                              ? const Color(0xFFE53E3E)
                              : const Color(0xFF38A169),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage ?? _successMessage!,
                            style: TextStyle(
                              color: _errorMessage != null
                                  ? const Color(0xFFE53E3E)
                                  : const Color(0xFF38A169),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Form Content
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),

                            // Room Selection
                            _buildDropdown<Room>(
                              label: 'Room',
                              icon: Icons.meeting_room,
                              value: _selectedRoom,
                              items: filteredRooms,
                              getLabel: (room) => room.displayName,
                              hint: 'Select a room',
                              onChanged: (Room? newValue) {
                                setState(() {
                                  _selectedRoom = newValue;
                                  _selectedTimeSlot = null;
                                });
                                _updateAvailableTimeSlots();
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a room';
                                }
                                return null;
                              },
                            ),

                            // Time Slot Selection
                            _buildDropdown<TimeSlot>(
                              label: 'Time Slot',
                              icon: Icons.access_time,
                              value: _selectedTimeSlot,
                              items: _availableTimeSlotsForRoom,
                              getLabel: (timeSlot) => timeSlot.displayTime,
                              hint: _selectedRoom == null
                                  ? 'Select a room first'
                                  : _availableTimeSlotsForRoom.isEmpty
                                  ? 'No time slots available'
                                  : 'Select time slot',
                              onChanged: (TimeSlot? newValue) {
                                setState(() {
                                  _selectedTimeSlot = newValue;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a time slot';
                                }
                                return null;
                              },
                            ),

                            // Purpose Selector
                            _buildKeperluanSelector(),

                            // Conditional Fields based on purpose
                            if (_selectedKeperluan == 'kelas') ...[
                              _buildTextField(
                                controller: _mataKuliahController,
                                label: 'Subject (Mata Kuliah)',
                                icon: Icons.school,
                                hint: 'Enter subject name',
                                validator: (value) {
                                  if (_selectedKeperluan == 'kelas' &&
                                      (value == null || value.trim().isEmpty)) {
                                    return 'Subject is required for class';
                                  }
                                  return null;
                                },
                              ),
                              _buildTextField(
                                controller: _dosenController,
                                label: 'Lecturer (Dosen)',
                                icon: Icons.person,
                                hint: 'Enter lecturer name',
                              ),
                            ],

                            if (_selectedKeperluan == 'rapat')
                              _buildTextField(
                                controller: _dosenController,
                                label: 'Meeting Leader',
                                icon: Icons.person,
                                hint: 'Enter meeting leader name',
                              ),

                            if (_selectedKeperluan == 'lainnya')
                              _buildTextField(
                                controller: _catatanController,
                                label: 'Notes (Required)',
                                icon: Icons.note,
                                hint: 'Please describe the purpose',
                                maxLines: 3,
                                validator: (value) {
                                  if (_selectedKeperluan == 'lainnya' &&
                                      (value == null || value.trim().isEmpty)) {
                                    return 'Notes are required for other purposes';
                                  }
                                  return null;
                                },
                              ),

                            // Additional Notes (always visible except for lainnya)
                            if (_selectedKeperluan != 'lainnya' &&
                                _selectedKeperluan.isNotEmpty)
                              _buildTextField(
                                controller: _catatanController,
                                label: 'Additional Notes (Optional)',
                                icon: Icons.note,
                                hint: 'Any additional information',
                                maxLines: 3,
                              ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Action Buttons
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextButton(
                          onPressed: _isLoading
                              ? null
                              : () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF667EEA,
                                ).withValues(alpha: 0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitBooking,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.bookmark_add,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Create Booking',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
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
        ),
      ),
    );
  }
}
