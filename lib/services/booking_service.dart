import '../models/booking_model.dart';
import '../services/auth_service.dart';
import 'api_client.dart';
import 'dart:developer' as developer;

class BookingService {
  final AuthService _authService = AuthService();
  final ApiClient _apiClient = ApiClient();

  // Singleton instance
  static final BookingService _instance = BookingService._internal();
  factory BookingService() => _instance;
  BookingService._internal();

  Future<BookingResponse> getMyBookings() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No token found. Please login again.');
      }

      developer.log('Getting my bookings...');

      final response = await _apiClient.get('/my-bookings', token: token);

      return _apiClient.handleResponse<BookingResponse>(
        response,
        (data) => BookingResponse.fromJson(data),
        onUnauthorized: () async => await _authService.logout(),
      );
    } catch (e) {
      developer.log('Get my bookings error: $e');
      if (e.toString().contains('Session expired') ||
          e.toString().contains('No token found')) {
        rethrow;
      }
      throw Exception('Error getting booking history: $e');
    }
  }

  Future<Booking> getBookingDetail(int bookingId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No token found. Please login again.');
      }

      developer.log('Getting booking detail for ID: $bookingId');

      final response = await _apiClient.get(
        '/my-bookings/$bookingId',
        token: token,
      );

      return _apiClient.handleResponse<Booking>(response, (data) {
        if (data['success'] == true && data['data'] != null) {
          return Booking.fromJson(data['data']);
        } else {
          throw Exception('Invalid response format');
        }
      }, onUnauthorized: () async => await _authService.logout());
    } catch (e) {
      developer.log('Get booking detail error: $e');
      if (e.toString().contains('Session expired') ||
          e.toString().contains('No token found')) {
        rethrow;
      }
      throw Exception('Error getting booking detail: $e');
    }
  }

  Future<bool> cancelBooking(int bookingId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No token found. Please login again.');
      }

      developer.log('Cancelling booking ID: $bookingId');

      final response = await _apiClient.delete(
        '/my-bookings/$bookingId',
        token: token,
      );

      return _apiClient.handleSimpleResponse(
        response,
        onUnauthorized: () async => await _authService.logout(),
      );
    } catch (e) {
      developer.log('Cancel booking error: $e');
      if (e.toString().contains('Session expired') ||
          e.toString().contains('No token found')) {
        rethrow;
      }
      throw Exception('Error cancelling booking: $e');
    }
  }

  // Helper method to format date for display
  static String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  // Helper method to format datetime for display
  static String formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year} $hour:$minute';
    } catch (e) {
      return dateTimeString;
    }
  }
}
