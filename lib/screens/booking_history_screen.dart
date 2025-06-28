// screens/booking_history_screen.dart
import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';
import '../component/custom_notification.dart';
import 'dart:developer' as developer;

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen>
    with TickerProviderStateMixin {
  final BookingService _bookingService = BookingService();
  List<Booking> bookings = [];
  List<Booking> filteredBookings = [];
  bool isLoading = true;
  String? error;
  String selectedStatus = 'All';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> statusFilters = [
    'All',
    'Pending',
    'Approved',
    'Rejected',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _loadBookingHistory();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadBookingHistory() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final response = await _bookingService.getMyBookings();

      if (mounted) {
        setState(() {
          bookings = response.data;
          _filterBookings();
          isLoading = false;
        });
        _animationController.forward();
      }
    } catch (e) {
      developer.log('Error loading booking history: $e');
      if (mounted) {
        setState(() {
          error = e.toString().replaceAll('Exception: ', '');
          isLoading = false;
        });
      }
    }
  }

  void _filterBookings() {
    if (selectedStatus == 'All') {
      filteredBookings = List.from(bookings);
    } else {
      filteredBookings = bookings
          .where(
            (booking) =>
                booking.status.toLowerCase() == selectedStatus.toLowerCase(),
          )
          .toList();
    }

    // Sort by created date (newest first)
    filteredBookings.sort(
      (a, b) =>
          DateTime.parse(b.createdAt).compareTo(DateTime.parse(a.createdAt)),
    );
  }

  void _onStatusFilterChanged(String status) {
    setState(() {
      selectedStatus = status;
      _filterBookings();
    });
  }

  Future<void> _showCancelConfirmation(Booking booking) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Batalkan Booking',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Apakah Anda yakin ingin membatalkan booking ini?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.room?.name ?? 'Unknown Room',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    BookingService.formatDate(booking.bookingDate),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (shouldCancel == true) {
      await _cancelBooking(booking);
    }
  }

  Future<void> _cancelBooking(Booking booking) async {
    try {
      final success = await _bookingService.cancelBooking(booking.id);

      if (success && mounted) {
        CustomNotification.show(
          context,
          message: 'Booking Dibatalkan',
          type: NotificationType.success,
          subtitle: 'Booking berhasil dibatalkan',
        );

        // Reload the booking history
        await _loadBookingHistory();
      }
    } catch (e) {
      developer.log('Cancel booking error: $e');
      if (mounted) {
        CustomNotification.show(
          context,
          message: 'Gagal Membatalkan',
          type: NotificationType.error,
          subtitle: e.toString().replaceAll('Exception: ', ''),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFF6B73FF)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              ),
              const Expanded(
                child: Text(
                  'Riwayat Booking',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                onPressed: _loadBookingHistory,
                icon: const Icon(Icons.refresh, color: Colors.white),
              ),
            ],
          ),
        ),

        // Filter Status
        if (!isLoading && error == null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildStatusFilter(),
          ),

        // Content
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(top: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: _buildContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: statusFilters.map((status) {
          final isSelected = selectedStatus == status;

          return FilterChip(
            label: Text(status),
            selected: isSelected,
            onSelected: (_) => _onStatusFilterChanged(status),
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            selectedColor: Colors.white,
            labelStyle: TextStyle(
              color: isSelected ? const Color(0xFF667eea) : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
            side: BorderSide(
              color: isSelected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.3),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF667eea)),
            SizedBox(height: 16),
            Text(
              'Memuat riwayat booking...',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 50,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Gagal memuat data',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                error!,
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadBookingHistory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667eea),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (filteredBookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(Icons.event_busy, size: 50, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Text(
              selectedStatus == 'All'
                  ? 'Belum ada riwayat booking'
                  : 'Tidak ada booking dengan status $selectedStatus',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Booking Anda akan muncul di sini',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: filteredBookings.length,
        itemBuilder: (context, index) {
          final booking = filteredBookings[index];
          return _buildBookingCard(booking);
        },
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    Color statusColor;
    IconData statusIcon;

    switch (booking.status.toLowerCase()) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.access_time;
        break;
      case 'approved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case 'cancelled':
        statusColor = Colors.grey;
        statusIcon = Icons.block;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: statusColor.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  booking.room?.name ?? 'Unknown Room',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 16, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      booking.statusDisplayName,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Booking details
          _buildDetailRow(
            Icons.calendar_today,
            'Tanggal',
            BookingService.formatDate(booking.bookingDate),
            Colors.black87,
          ),
          _buildDetailRow(
            Icons.access_time,
            'Waktu',
            booking.timeSlot?.timeRange ?? 'Unknown Time',
            Colors.black87,
          ),
          _buildDetailRow(
            Icons.room,
            'Ruangan',
            booking.room?.name ?? 'Unknown Room',
            Colors.black87,
          ),
          _buildDetailRow(
            Icons.school,
            'Keperluan',
            booking.keperluan ?? "-",
            Colors.black87,
          ),
          _buildDetailRow(
            Icons.book,
            'Mata Kuliah',
            booking.mataKuliah ?? "-",
            Colors.black87,
          ),
          _buildDetailRow(
            Icons.person,
            'Dosen',
            booking.dosen ?? '-',
            Colors.black87,
          ),
          _buildDetailRow(
            Icons.note,
            'Catatan',
            booking.catatan ?? "-",
            Colors.black87,
          ),

          // Admin notes if rejected
          if (booking.isRejected &&
              booking.adminNotes != null &&
              booking.adminNotes!.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.red, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Catatan Admin:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          booking.adminNotes!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Action buttons
          if (booking.isPending)
            Container(
              margin: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showCancelConfirmation(booking),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Batalkan'),
                    ),
                  ),
                ],
              ),
            ),

          // Created date
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.only(top: 16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey, width: 0.2)),
            ),
            child: Text(
              'Dibuat: ${BookingService.formatDateTime(booking.createdAt)}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    Color textColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF667eea)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: textColor,
                    fontWeight: FontWeight.w600,
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
