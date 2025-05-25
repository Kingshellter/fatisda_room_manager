// lib/main.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';  // Add this import for date formatting
import 'component/date_header.dart';
import 'component/booking_item.dart';
import 'component/login_button.dart';
import 'component/new_booking_button.dart';
import 'component/time_ruler.dart';
import 'component/booking_form_dialog.dart';
import 'models/booking.dart';
import 'login_screen.dart';


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
  final List<Booking> _bookings = []; // Inisialisasi daftar booking kosong

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

  // Daftar ruangan (contoh)
  final List<String> _availableRooms = ['Ruang A101', 'Ruang B203', 'Lab Komputer 1', 'Aula Fatisda'];


  final double _hourHeight = 100.0; // Tinggi representasi satu jam di UI (bisa disesuaikan)
  final int _numberOfDayColumns = 5; // Jumlah kolom hari yang ingin ditampilkan (misal Senin-Jumat)
  final double _dayColumnWidth = 150.0; // Lebar setiap kolom hari

  void _addBooking(Booking newBooking) {
    setState(() {
      _bookings.add(newBooking);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booking untuk ${newBooking.title} di ${newBooking.room} berhasil ditambahkan!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showBookingForm() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BookingFormDialog(
          onBookingConfirmed: _addBooking,
          timeSlots: _timeSlots,
          rooms: _availableRooms,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Hitung tinggi total untuk konten kalender agar bisa di-scroll
    double totalCalendarHeight = 0;
    if (_timeSlots.isNotEmpty) {
      final lastSlotEnd = _timeSlots.last['end']!;
      final parts = lastSlotEnd.split('.');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      const timelineStartHour = 7;
      const timelineStartMinute = 30;

      final slotEndTotalMinutes = hour * 60 + minute;
      final timelineStartTotalMinutes = timelineStartHour * 60 + timelineStartMinute;
      final diffMinutes = slotEndTotalMinutes - timelineStartTotalMinutes;
      totalCalendarHeight = (diffMinutes / 60.0) * _hourHeight + _hourHeight ; // Tambah buffer
    }

    // Get current date formatted
    final String currentDate = DateFormat('E, MMM d').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Column(
          children: [
            DateHeader(
              dateText: currentDate,
              onEditPressed: () {
                print('Edit date pressed');
              },
            ),
            Expanded(
              child: SingleChildScrollView( // Scroll vertikal untuk seluruh area kalender
                child: SingleChildScrollView( // Scroll horizontal untuk kalender
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    // Lebar total kalender = lebar time ruler + (jumlah kolom * lebar kolom)
                    width: 60.0 + (_numberOfDayColumns * _dayColumnWidth),
                    height: totalCalendarHeight, // Tinggi berdasarkan slot waktu
                    child: Stack(
                      children: [
                        // Garis-garis vertikal untuk pemisah hari/kolom
                        Row(
                          children: [
                            const SizedBox(width: 60), // Space untuk TimeRuler
                            for (int i = 0; i < _numberOfDayColumns; i++)
                              Container(
                                width: _dayColumnWidth,
                                decoration: BoxDecoration(
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
                                children: _bookings.map((booking) {
                                  if (booking.dayColumn < _numberOfDayColumns) {
                                    return BookingItem(
                                      booking: booking,
                                      hourHeight: _hourHeight,
                                      dayColumnWidth: _dayColumnWidth,
                                    );
                                  }
                                  return const SizedBox.shrink();
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  LoginButton(
                   onPressed: () {
                      Navigator.push(
                      context,
                     MaterialPageRoute(builder: (context) => const LoginScreen()),
                       );
                    },
                  ),
                  NewBookingButton(
                    onPressed: _showBookingForm, // Panggil fungsi untuk menampilkan form
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
