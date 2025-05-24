// lib/main.dart
import 'package:flutter/material.dart';
import 'component/date_header.dart';
import 'component/booking_item.dart';
import 'component/login_button.dart';
import 'component/new_booking_button.dart';
import 'component/time_ruler.dart';
import 'models/booking.dart';

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
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto', // Atau font lain yang Anda inginkan
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
  // Data booking dummy
  final List<Booking> _bookings = [
    Booking(
      title: 'Kalkulus 2',
      startTime: '09.00',
      endTime: '10.00',
      color: Colors.redAccent,
      dayColumn: 0, // Kolom pertama
    ),
    Booking(
      title: 'Kalkulus', // Judul berbeda sedikit untuk membedakan
      startTime: '13.00',
      endTime: '14.00', // Akhir jam berbeda
      color: const Color(0xFFAED581), // Warna hijau muda seperti gambar
      dayColumn: 2, // Kolom ketiga (dengan asumsi ada 3 kolom hari yang terlihat)
    ),
    // Tambahkan booking lain jika perlu
  ];

  final double _hourHeight = 80.0; // Tinggi representasi satu jam di UI
  final int _numberOfDayColumns = 4; // Jumlah kolom hari yang ingin ditampilkan
  final double _dayColumnWidth = 100.0; // Lebar setiap kolom hari

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Warna background utama
      body: SafeArea(
        child: Column(
          children: [
            DateHeader(
              dateText: 'Mon, Aug 17',
              onEditPressed: () {
                // Aksi ketika tombol edit ditekan
                print('Edit date pressed');
              },
            ),
            Expanded(
              child: Stack(
                children: [
                  // Garis-garis vertikal untuk pemisah hari/kolom
                  Row(
                    children: [
                      SizedBox(width: 70), // Space untuk TimeRuler
                      for (int i = 0; i < _numberOfDayColumns; i++)
                        Container(
                          width: _dayColumnWidth,
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1.0,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  // Garis-garis horizontal untuk pemisah jam (opsional, jika ingin lebih detail)
                  // Bisa ditambahkan di dalam CustomPaint jika perlu
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TimeRuler(
                        hourHeight: _hourHeight,
                        startHour: 9,
                        endHour: 14,
                      ),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              child: SizedBox(
                                height: (_hourHeight * (14 - 9 + 1)), // Tinggi total timeline
                                child: Stack(
                                  children: _bookings.map((booking) {
                                    // Filter booking yang berada dalam rentang kolom yang ditampilkan
                                    if (booking.dayColumn < _numberOfDayColumns) {
                                      return BookingItem(
                                        booking: booking,
                                        hourHeight: _hourHeight,
                                      );
                                    }
                                    return const SizedBox.shrink(); // Jangan tampilkan jika di luar kolom
                                  }).toList(),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  LoginButton(
                    onPressed: () {
                      // Aksi ketika tombol login ditekan
                      print('Login pressed');
                    },
                  ),
                  NewBookingButton(
                    onPressed: () {
                      // Aksi ketika tombol booking ditekan
                      print('New Booking pressed');
                    },
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