// services/booking_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/booking_model.dart';
import '../services/auth_service.dart';
import 'dart:developer' as developer;

class BookingService {
  final AuthService _authService = AuthService();
  final String baseUrl = 'http://192.168.100.87:8000/api/v1';

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
      final response = await http
          .get(
            Uri.parse('$baseUrl/my-bookings'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception(
                'Connection timeout. Please check your internet connection.',
              );
            },
          );

      developer.log('My bookings response status: ${response.statusCode}');
      developer.log('My bookings response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return BookingResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        await _authService.logout();
        throw Exception('Session expired. Please login again.');
      } else {
        final errorData = jsonDecode(response.body);
        String errorMessage = 'Failed to get booking history';

        if (errorData['message'] != null) {
          errorMessage = errorData['message'];
        }

        throw Exception(errorMessage);
      }
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
      final response = await http
          .get(
            Uri.parse('$baseUrl/my-bookings/$bookingId'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception(
                'Connection timeout. Please check your internet connection.',
              );
            },
          );

      developer.log('Booking detail response status: ${response.statusCode}');
      developer.log('Booking detail response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Booking.fromJson(data['data']);
        } else {
          throw Exception('Invalid response format');
        }
      } else if (response.statusCode == 401) {
        await _authService.logout();
        throw Exception('Session expired. Please login again.');
      } else if (response.statusCode == 404) {
        throw Exception('Booking not found');
      } else {
        final errorData = jsonDecode(response.body);
        String errorMessage = 'Failed to get booking detail';

        if (errorData['message'] != null) {
          errorMessage = errorData['message'];
        }

        throw Exception(errorMessage);
      }
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
      final response = await http
          .delete(
            Uri.parse('$baseUrl/my-bookings/$bookingId'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception(
                'Connection timeout. Please check your internet connection.',
              );
            },
          );

      developer.log('Cancel booking response status: ${response.statusCode}');
      developer.log('Cancel booking response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else if (response.statusCode == 401) {
        await _authService.logout();
        throw Exception('Session expired. Please login again.');
      } else if (response.statusCode == 404) {
        throw Exception('Booking not found');
      } else {
        final errorData = jsonDecode(response.body);
        String errorMessage = 'Failed to cancel booking';

        if (errorData['message'] != null) {
          errorMessage = errorData['message'];
        }

        throw Exception(errorMessage);
      }
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
