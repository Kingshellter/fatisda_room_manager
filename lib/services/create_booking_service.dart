// services/create_booking_service.dart
import '../models/booking_model.dart';
import '../services/auth_service.dart';
import 'api_client.dart';
import 'dart:developer' as developer;

class CreateBookingService {
  final AuthService _authService = AuthService();
  final ApiClient _apiClient = ApiClient();

  // Singleton instance
  static final CreateBookingService _instance =
      CreateBookingService._internal();
  factory CreateBookingService() => _instance;
  CreateBookingService._internal();

  /// Create a new booking
  Future<Booking> createBooking({
    required int roomId,
    required int timeSlotId,
    required String bookingDate,
    required String keperluan,
    String? mataKuliah,
    String? dosen,
    String? catatan,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No token found. Please login again.');
      }

      developer.log('Creating booking...');
      developer.log(
        'Room ID: $roomId, TimeSlot ID: $timeSlotId, Date: $bookingDate',
      );

      final requestBody = {
        'room_id': roomId,
        'time_slot_id': timeSlotId,
        'booking_date': bookingDate,
        'keperluan': keperluan,
        if (mataKuliah != null && mataKuliah.isNotEmpty)
          'mata_kuliah': mataKuliah,
        if (dosen != null && dosen.isNotEmpty) 'dosen': dosen,
        if (catatan != null && catatan.isNotEmpty) 'catatan': catatan,
      };

      developer.log('Request body: $requestBody');

      final response = await _apiClient.post(
        '/bookings',
        body: requestBody,
        token: token,
      );

      return _apiClient.handleResponse<Booking>(response, (data) {
        if (data['success'] == true && data['data'] != null) {
          return Booking.fromJson(data['data']);
        }
        throw Exception('Invalid response format');
      }, onUnauthorized: () async => await _authService.logout());
    } catch (e) {
      developer.log('Create booking error: $e');
      if (e.toString().contains('Session expired') ||
          e.toString().contains('No token found')) {
        rethrow;
      }
      throw Exception('Error creating booking: $e');
    }
  }

  /// Check availability before creating booking
  Future<Map<String, dynamic>> checkAvailability({
    required int roomId,
    required int timeSlotId,
    required String bookingDate,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No token found. Please login again.');
      }

      developer.log('Checking availability...');

      final queryParams = {
        'room_id': roomId.toString(),
        'time_slot_id': timeSlotId.toString(),
        'date': bookingDate, // Note: API uses 'date' not 'booking_date'
      };

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final response = await _apiClient.get(
        '/booking/check-availability?$queryString',
        token: token,
      );

      return _apiClient.handleResponse<Map<String, dynamic>>(
        response,
        (data) => data,
        onUnauthorized: () async => await _authService.logout(),
      );
    } catch (e) {
      developer.log('Check availability error: $e');
      if (e.toString().contains('Session expired') ||
          e.toString().contains('No token found')) {
        rethrow;
      }
      throw Exception('Error checking availability: $e');
    }
  }

  /// Validate booking data before submission
  String? validateBookingData({
    required int roomId,
    required int timeSlotId,
    required String bookingDate,
    required String keperluan,
    String? mataKuliah,
    String? dosen,
    String? catatan,
  }) {
    if (roomId <= 0) {
      return 'Please select a valid room';
    }

    if (timeSlotId <= 0) {
      return 'Please select a valid time slot';
    }

    if (bookingDate.isEmpty) {
      return 'Please select a booking date';
    }

    if (keperluan.isEmpty) {
      return 'Please select purpose (keperluan)';
    }

    // Validate keperluan values according to API
    if (!['kelas', 'rapat', 'lainnya'].contains(keperluan)) {
      return 'Invalid purpose. Must be kelas, rapat, or lainnya';
    }

    // Validate mata_kuliah is required if keperluan is 'kelas'
    if (keperluan == 'kelas' &&
        (mataKuliah == null || mataKuliah.trim().isEmpty)) {
      return 'Mata kuliah is required when purpose is kelas';
    }

    // Validate catatan is required if keperluan is 'lainnya'
    if (keperluan == 'lainnya' && (catatan == null || catatan.trim().isEmpty)) {
      return 'Catatan is required when purpose is lainnya';
    }

    // Validate date format
    try {
      DateTime.parse(bookingDate);
    } catch (e) {
      return 'Invalid date format';
    }

    // Check if booking date is in the past
    final selectedDate = DateTime.parse(bookingDate);
    final today = DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);
    final selectedDateOnly = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    if (selectedDateOnly.isBefore(todayDateOnly)) {
      return 'Cannot book for past dates';
    }

    return null; // No validation errors
  }

  /// Format date for API (YYYY-MM-DD)
  static String formatDateForApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Get keperluan options
  static List<Map<String, String>> getKeperluanOptions() {
    return [
      {'value': 'kelas', 'label': 'Kelas'},
      {'value': 'rapat', 'label': 'Rapat'},
      {'value': 'lainnya', 'label': 'Lainnya'},
    ];
  }
}
