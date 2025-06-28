// main.dart - Improved Loading UI
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'component/booking_item.dart';
import 'component/time_ruler.dart';
import 'component/booking_form_dialog.dart';
import 'models/booking.dart';
import 'models/room_model.dart';
import 'models/timeslot_model.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'services/auth_service.dart';
import 'services/main_data_service.dart';

void main() {
  runApp(const FatisdaBookingApp());
}

class FatisdaBookingApp extends StatelessWidget {
  const FatisdaBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fatisda Booking',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: 'Inter',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF667EEA),
          brightness: Brightness.light,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        cardTheme: const CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      ),
      home: const BookingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with TickerProviderStateMixin {
  // Services
  final MainDataService _dataService = MainDataService();

  // Animation controllers
  late AnimationController _refreshController;
  late AnimationController _fabController;
  late AnimationController _loadingController;

  // State variables
  List<Booking> _bookings = [];
  List<Room> _rooms = [];
  List<TimeSlot> _timeSlots = [];
  List<String> _availableRooms = [];
  List<Map<String, String>> _timeSlotMaps = [];

  bool _isLoggedIn = false;
  bool _isInitialLoading = true; // Loading pertama kali app dibuka
  bool _isContentLoading = false; // Loading saat ganti tanggal
  bool _isRefreshing = false;
  DateTime _selectedDate = DateTime.now();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeData();
  }

  void _initializeAnimations() {
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fabController.forward();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _fabController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _checkLoginStatus();
    await _loadData(isInitial: true);
  }

  Future<void> _checkLoginStatus() async {
    try {
      final isLoggedIn = await AuthService().isLoggedIn();
      if (mounted) {
        setState(() {
          _isLoggedIn = isLoggedIn;
        });
      }
    } catch (e) {
      debugPrint('Error checking login status: $e');
    }
  }

  Future<void> _loadData({
    bool isInitial = false,
    bool isRefresh = false,
  }) async {
    if (!mounted) return;

    setState(() {
      if (isInitial) {
        _isInitialLoading = true;
      } else if (isRefresh) {
        _isRefreshing = true;
      } else {
        _isContentLoading = true;
        _loadingController.repeat();
      }
      _errorMessage = null;
    });

    try {
      final completeData = await _dataService.getCompleteDataForDate(
        _selectedDate,
      );

      if (mounted) {
        setState(() {
          _rooms = completeData['rooms'] as List<Room>;
          _timeSlots = completeData['timeSlots'] as List<TimeSlot>;
          _bookings = completeData['bookings'] as List<Booking>;
          _availableRooms = completeData['roomNames'] as List<String>;
          _timeSlotMaps =
              completeData['timeSlotMaps'] as List<Map<String, String>>;

          _isInitialLoading = false;
          _isContentLoading = false;
          _isRefreshing = false;
        });
        _loadingController.reset();
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading data: ${e.toString()}';
          _isInitialLoading = false;
          _isContentLoading = false;
          _isRefreshing = false;
        });
        _loadingController.reset();
      }
    }
  }

  Future<void> _refreshData() async {
    if (_isRefreshing || _isContentLoading) return;

    _refreshController.repeat();

    try {
      await _dataService.refreshAllData();
      await _loadData(isRefresh: true);
    } finally {
      _refreshController.reset();
    }
  }

  void _handleDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
    _loadData(); // This will trigger content loading
  }

  List<Booking> get _filteredBookings {
    final dayBookings = _bookings.where((booking) {
      return booking.bookingDate.year == _selectedDate.year &&
          booking.bookingDate.month == _selectedDate.month &&
          booking.bookingDate.day == _selectedDate.day;
    }).toList();

    dayBookings.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return dayBookings;
  }

  final double _hourHeight = 100.0;
  final double _dayColumnWidth = 160.0;
  int get _numberOfDayColumns => _availableRooms.length;

  void _addBooking(Booking newBooking) {
    setState(() {
      _bookings.add(newBooking);
    });

    _showSnackBar(
      'Booking created successfully! 🎉',
      backgroundColor: const Color(0xFF38A169),
      icon: Icons.check_circle,
    );

    _loadData();
  }

  void _cancelBooking(Booking booking) {
    setState(() {
      _bookings.removeWhere(
        (b) =>
            b.room == booking.room &&
            b.startTime == booking.startTime &&
            b.endTime == booking.endTime &&
            b.bookingDate.year == booking.bookingDate.year &&
            b.bookingDate.month == booking.bookingDate.month &&
            b.bookingDate.day == booking.bookingDate.day &&
            b.title == booking.title &&
            b.studentName == booking.studentName,
      );
    });

    _showSnackBar(
      'Booking cancelled successfully',
      backgroundColor: const Color(0xFFE53E3E),
      icon: Icons.cancel,
    );
  }

  void _showSnackBar(String message, {Color? backgroundColor, IconData? icon}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
            ],
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showBookingForm() async {
    if (!_isLoggedIn) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      _checkLoginStatus();
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BookingFormDialog(
          onBookingConfirmed: _addBooking,
          rooms: _availableRooms,
          existingBookings: _bookings,
          availableRooms: _rooms,
          availableTimeSlots: _timeSlots,
          selectedDate: _selectedDate,
        );
      },
    );
  }

  void _handleProfileOrLogin() async {
    if (_isLoggedIn) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
      _checkLoginStatus();
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      _checkLoginStatus();
    }
  }

  Widget _buildInitialLoadingWidget() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF7FAFC), Color(0xFFEDF2F7)],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
            ),
            SizedBox(height: 24),
            Text(
              'Loading schedule...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4A5568),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF7FAFC), Color(0xFFEDF2F7)],
        ),
      ),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFED7D7),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Color(0xFFE53E3E),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage ?? 'An unexpected error occurred',
                style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _refreshData,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667EEA),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    final String formattedDate = DateFormat(
      'EEEE, MMMM d',
    ).format(_selectedDate);
    final bool isToday =
        _selectedDate.day == DateTime.now().day &&
        _selectedDate.month == DateTime.now().month &&
        _selectedDate.year == DateTime.now().year;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        width: 70,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Room Schedule',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Fatisda University',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFFE2E8F0),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                  GestureDetector(
                    onTap: _handleProfileOrLogin,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isLoggedIn ? Icons.person : Icons.login,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isLoggedIn ? 'Profile' : 'Login',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
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
                          GestureDetector(
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime.now().subtract(
                                  const Duration(days: 365),
                                ),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                              );
                              if (picked != null && picked != _selectedDate) {
                                _handleDateChanged(picked);
                              }
                            },
                            child: Row(
                              children: [
                                Text(
                                  formattedDate,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    decoration: TextDecoration.underline,
                                    decorationStyle: TextDecorationStyle.dotted,
                                  ),
                                ),
                                if (_isContentLoading) ...[
                                  const SizedBox(width: 12),
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white.withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (isToday)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Today',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _isContentLoading
                              ? null
                              : () {
                                  _handleDateChanged(
                                    _selectedDate.subtract(
                                      const Duration(days: 1),
                                    ),
                                  );
                                },
                          icon: const Icon(
                            Icons.chevron_left,
                            color: Colors.white,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withValues(
                              alpha: _isContentLoading ? 0.1 : 0.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _isContentLoading
                              ? null
                              : () {
                                  _handleDateChanged(
                                    _selectedDate.add(const Duration(days: 1)),
                                  );
                                },
                          icon: const Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withValues(
                              alpha: _isContentLoading ? 0.1 : 0.2,
                            ),
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
    );
  }

  Widget _buildRoomHeaders() {
    return Row(
      children: [
        const SizedBox(width: 60),
        for (int i = 0; i < _availableRooms.length; i++)
          Container(
            width: _dayColumnWidth,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Colors.grey[50]!],
              ),
              border: Border(
                left: BorderSide(color: Colors.grey[200]!, width: 1),
                bottom: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _availableRooms[i].contains('Lab') ? 'Lab' : 'Room',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _availableRooms[i].contains('Lab')
                      ? _availableRooms[i].split('Lab ')[1]
                      : _availableRooms[i].split('Ruang ')[1],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildContentLoadingOverlay() {
    return Container(
      color: Colors.white.withValues(alpha: 0.8),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
            ),
            SizedBox(height: 16),
            Text(
              'Loading schedule...',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4A5568),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show initial loading screen only on first load
    if (_isInitialLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7FAFC),
        body: _buildInitialLoadingWidget(),
      );
    }

    // Show error screen if there's an error and no data
    if (_errorMessage != null && _availableRooms.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7FAFC),
        body: _buildErrorWidget(),
      );
    }

    double totalCalendarHeight = 0;
    if (_timeSlotMaps.isNotEmpty) {
      final firstSlotStart = _timeSlotMaps.first['start']!;
      final lastSlotEnd = _timeSlotMaps.last['end']!;

      final firstParts = firstSlotStart.split('.');
      final lastParts = lastSlotEnd.split('.');

      final startHour = int.parse(firstParts[0]);
      final startMinute = int.parse(firstParts[1]);
      final endHour = int.parse(lastParts[0]);
      final endMinute = int.parse(lastParts[1]);

      final startTotalMinutes = startHour * 60 + startMinute;
      final endTotalMinutes = endHour * 60 + endMinute;

      final diffMinutes = endTotalMinutes - startTotalMinutes;
      totalCalendarHeight = (diffMinutes / 60.0) * _hourHeight + 60;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      body: Column(
        children: [
          _buildModernHeader(),
          Expanded(
            child: _availableRooms.isEmpty
                ? const Center(child: Text('No rooms available'))
                : RefreshIndicator(
                    onRefresh: _refreshData,
                    color: const Color(0xFF667EEA),
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: totalCalendarHeight + 100,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(
                                width:
                                    60.0 +
                                    (_numberOfDayColumns * _dayColumnWidth),
                                child: Column(
                                  children: [
                                    _buildRoomHeaders(),
                                    Expanded(
                                      child: Stack(
                                        children: [
                                          // Background grid
                                          Row(
                                            children: [
                                              const SizedBox(width: 60),
                                              for (
                                                int i = 0;
                                                i < _numberOfDayColumns;
                                                i++
                                              )
                                                Container(
                                                  width: _dayColumnWidth,
                                                  height: totalCalendarHeight,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    border: Border(
                                                      left: BorderSide(
                                                        color:
                                                            Colors.grey[200]!,
                                                        width: 1,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          // Time ruler and bookings
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              TimeRuler(
                                                hourHeight: _hourHeight,
                                                timeSlots: _timeSlotMaps,
                                              ),
                                              SizedBox(
                                                width:
                                                    _numberOfDayColumns *
                                                    _dayColumnWidth,
                                                height: totalCalendarHeight,
                                                child: Stack(
                                                  children: _filteredBookings
                                                      .map((booking) {
                                                        return BookingItem(
                                                          booking: booking,
                                                          hourHeight:
                                                              _hourHeight,
                                                          dayColumnWidth:
                                                              _dayColumnWidth,
                                                          onCancelBooking:
                                                              _cancelBooking,
                                                        );
                                                      })
                                                      .toList(),
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
                        ),
                        // Content loading overlay
                        if (_isContentLoading) _buildContentLoadingOverlay(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabController,
        child: FloatingActionButton.extended(
          onPressed: _isContentLoading ? null : _showBookingForm,
          backgroundColor: _isContentLoading
              ? const Color(0xFF667EEA).withValues(alpha: 0.6)
              : const Color(0xFF667EEA),
          foregroundColor: Colors.white,
          elevation: 8,
          icon: AnimatedRotation(
            turns: _isRefreshing ? 1 : 0,
            duration: const Duration(milliseconds: 1000),
            child: const Icon(Icons.add),
          ),
          label: const Text(
            'New Booking',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
