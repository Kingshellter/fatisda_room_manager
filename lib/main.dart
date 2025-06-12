// lib/main.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this import for date formatting
import 'component/date_header.dart';
import 'component/booking_item.dart';
import 'component/login_button.dart';
import 'component/new_booking_button.dart';
import 'component/time_ruler.dart';
import 'component/booking_form_dialog.dart';
import 'models/booking.dart';
import 'login_screen.dart';
import 'screens/profile_screen.dart';
import 'services/auth_service.dart';

void main() {
  runApp(const FatisdaBookingApp());
}

class FatisdaBookingApp extends StatelessWidget {
  const FatisdaBookingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fatisda Booking',
      theme: ThemeData(
        primarySwatch: Colors.indigo, // Ganti tema jika diinginkan
        fontFamily: 'Roboto',
        // Atur warna utama untuk dialog agar konsisten
        dialogBackgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, // Warna teks tombol
          ),
        ),
      ),
      home: const BookingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class BookingScreen extends StatefulWidget {
  const BookingScreen({Key? key}) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final List<Booking> _bookings = [];
  bool _isLoggedIn = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final isLoggedIn = await AuthService().isLoggedIn();
    setState(() {
      _isLoggedIn = isLoggedIn;
    });
  }

  void _handleDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
  }

  // Filter bookings for selected date and sort by creation time
  List<Booking> get _filteredBookings {
    // First, filter bookings for the selected date
    final dayBookings = _bookings.where((booking) {
      return booking.bookingDate.year == _selectedDate.year &&
          booking.bookingDate.month == _selectedDate.month &&
          booking.bookingDate.day == _selectedDate.day;
    }).toList();

    // Sort bookings by creation time (oldest first)
    dayBookings.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    // Update dayColumn based on room index
    return dayBookings.map((booking) {
      // Dapatkan indeks ruangan untuk booking ini
      final roomIndex = _availableRooms.indexOf(booking.room);
      if (roomIndex == -1) return booking; // Jika ruangan tidak ditemukan, kembalikan booking asli

      // Buat booking baru dengan dayColumn yang sesuai dengan indeks ruangan
      return Booking(
        title: booking.title,
        startTime: booking.startTime,
        endTime: booking.endTime,
        color: booking.color,
        dayColumn: roomIndex, // Set kolom berdasarkan indeks ruangan
        room: booking.room,
        studentName: booking.studentName,
        major: booking.major,
        classYear: booking.classYear,
        necessary: booking.necessary,
        notes: booking.notes,
        lecturer: booking.lecturer,
        bookingDate: booking.bookingDate,
        createdAt: booking.createdAt,
      );
    }).toList();
  }

  // Daftar slot waktu sesuai permintaan
  final List<Map<String, String>> _timeSlots = [
    {'jam': '1', 'start': '07.30', 'end': '08.20'},
    {'jam': '2', 'start': '08.25', 'end': '09.15'},
    {'jam': '3', 'start': '09.20', 'end': '10.10'},
    {'jam': '4', 'start': '10.15', 'end': '11.05'},
    {'jam': '5', 'start': '11.10', 'end': '12.00'},
    {'jam': '6', 'start': '13.00', 'end': '13.50'},
    {'jam': '7', 'start': '13.55', 'end': '14.45'},
    {'jam': '8', 'start': '15.30', 'end': '16.20'},
    {'jam': '9', 'start': '16.25', 'end': '17.15'},
  ];

  // Daftar ruangan
  final List<String> _availableRooms = [
    'Ruang B404',
    'Ruang B405',
    'Ruang B406',
    'Ruang B410',
    'Ruang B411',
    'Ruang B412',
    'Lab 3 TIK lt.3',
    'Lab 4 TIK lt.4',
  ];

  final double _hourHeight = 100.0;
  final double _dayColumnWidth = 150.0;
  
  // Mengubah numberOfDayColumns menjadi sesuai jumlah ruangan
  int get _numberOfDayColumns => _availableRooms.length;

  void _addBooking(Booking newBooking) {
    setState(() {
      _bookings.add(newBooking);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Booking untuk ${newBooking.title} di ${newBooking.room} berhasil ditambahkan!',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _cancelBooking(Booking booking) {
    setState(() {
      // Cari dan hapus booking yang sesuai berdasarkan semua properti yang relevan
      _bookings.removeWhere((b) => 
        b.room == booking.room &&
        b.startTime == booking.startTime &&
        b.endTime == booking.endTime &&
        b.bookingDate.year == booking.bookingDate.year &&
        b.bookingDate.month == booking.bookingDate.month &&
        b.bookingDate.day == booking.bookingDate.day &&
        b.title == booking.title &&
        b.studentName == booking.studentName
      );
    });
    
    // Tampilkan snackbar konfirmasi
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Booking untuk ${booking.title} di ${booking.room} berhasil dibatalkan!',
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showBookingForm() async {
    if (!_isLoggedIn) {
      // Show login screen if not logged in
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );

      // Check login status after returning from login screen
      _checkLoginStatus();
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BookingFormDialog(
          onBookingConfirmed: _addBooking,
          rooms: _availableRooms,
          existingBookings: _bookings,
        );
      },
    );
  }

  void _handleProfileOrLogin() async {
    if (_isLoggedIn) {
      // Show profile screen
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
      // Check login status after returning from profile screen
      _checkLoginStatus();
    } else {
      // Show login screen
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      // Check login status after returning from login screen
      _checkLoginStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hitung tinggi total untuk konten kalender
    double totalCalendarHeight = 0;
    if (_timeSlots.isNotEmpty) {
      // Konversi waktu awal dan akhir ke menit
      final firstSlotStart = _timeSlots.first['start']!;
      final lastSlotEnd = _timeSlots.last['end']!;

      final firstParts = firstSlotStart.split('.');
      final lastParts = lastSlotEnd.split('.');

      final startHour = int.parse(firstParts[0]);
      final startMinute = int.parse(firstParts[1]);
      final endHour = int.parse(lastParts[0]);
      final endMinute = int.parse(lastParts[1]);

      final startTotalMinutes = startHour * 60 + startMinute;
      final endTotalMinutes = endHour * 60 + endMinute;

      final diffMinutes = endTotalMinutes - startTotalMinutes;
      totalCalendarHeight =
          (diffMinutes / 60.0) * _hourHeight + 60; // Tambah padding
    }

    // Format the selected date
    final String formattedDate = DateFormat('E, MMM d').format(_selectedDate);

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Column(
          children: [
            DateHeader(
              dateText: formattedDate,
              onDateChanged: _handleDateChanged,
            ),
            Container(height: 0.5, color: Colors.grey[350]),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.zero, // Hilangkan padding
                    child: SizedBox(
                      height: totalCalendarHeight + 40,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: 60.0 + (_numberOfDayColumns * _dayColumnWidth),
                          child: Column(
                            children: [
                              // Header Ruangan
                              Row(
                                children: [
                                  const SizedBox(width: 60),
                                  for (int i = 0; i < _availableRooms.length; i++)
                                    Container(
                                      width: _dayColumnWidth,
                                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          left: BorderSide(color: Colors.grey[350]!, width: 0.5),
                                          bottom: BorderSide(color: Colors.grey[350]!, width: 0.5),
                                        ),
                                        color: Colors.grey[100],
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Baris pertama untuk "Ruang" atau "Lab"
                                          Text(
                                            _availableRooms[i].contains('Lab') ? 'Lab' : 'Ruang',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          // Baris kedua untuk nomor ruangan
                                          Text(
                                            _availableRooms[i].contains('Lab') 
                                              ? _availableRooms[i].split('Lab ')[1]  // Ambil bagian setelah "Lab "
                                              : _availableRooms[i].split('Ruang ')[1], // Ambil bagian setelah "Ruang "
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              // Tabel Booking
                              Expanded(
                                child: Stack(
                                  clipBehavior: Clip.none, // Izinkan overflow
                                  children: [
                                    // Garis-garis vertikal untuk pemisah hari/kolom
                                    Row(
                                      children: [
                                        const SizedBox(width: 60),
                                        for (int i = 0; i < _numberOfDayColumns; i++)
                                          Container(
                                            width: _dayColumnWidth,
                                            height: totalCalendarHeight,
                                            decoration: BoxDecoration(
                                              color: Colors.white, // Tambahkan background color
                                              border: Border(
                                                left: BorderSide(
                                                  color: Colors.grey[350]!,
                                                  width: 0.5,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    // Time Ruler dan Booking Items
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        TimeRuler(
                                          hourHeight: _hourHeight,
                                          timeSlots: _timeSlots,
                                        ),
                                        // Area untuk booking items
                                        SizedBox(
                                          width: _numberOfDayColumns * _dayColumnWidth,
                                          height: totalCalendarHeight,
                                          child: Stack(
                                            children: _filteredBookings.map((booking) {
                                              return BookingItem(
                                                booking: booking,
                                                hourHeight: _hourHeight,
                                                dayColumnWidth: _dayColumnWidth,
                                                onCancelBooking: _cancelBooking,
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ],
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
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 15.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _handleProfileOrLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                    child: Text(
                      _isLoggedIn ? 'Mahasiswa' : 'Login',
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                  NewBookingButton(onPressed: _showBookingForm),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
