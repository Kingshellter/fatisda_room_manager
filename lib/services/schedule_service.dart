import 'package:flutter/material.dart';
import '../models/schedule_model.dart';
import '../models/room_model.dart';
import '../models/booking.dart'; // Your existing booking model
import 'api_client.dart';
import 'dart:developer' as developer;

class ScheduleService {
  final ApiClient _apiClient = ApiClient();

  // Singleton instance
  static final ScheduleService _instance = ScheduleService._internal();
  factory ScheduleService() => _instance;
  ScheduleService._internal();

  /// Get public schedule for specific date
  Future<ScheduleData> getPublicSchedule(String date) async {
    try {
      developer.log('Getting public schedule for date: $date');

      final response = await _apiClient.get('/public-schedule?date=$date');

      final scheduleResponse = _apiClient.handleResponse<ScheduleResponse>(
        response,
        (data) => ScheduleResponse.fromJson(data),
      );

      developer.log(
        'Retrieved ${scheduleResponse.data.totalBookings} bookings for $date',
      );
      return scheduleResponse.data;
    } catch (e) {
      developer.log('Get public schedule error: $e');
      throw Exception('Error getting schedule: $e');
    }
  }

  /// Get public schedule matrix (if available)
  Future<Map<String, dynamic>> getPublicScheduleMatrix({
    String? startDate,
    String? endDate,
  }) async {
    try {
      developer.log('Getting public schedule matrix...');

      final queryParams = <String, String>{};
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final endpoint = queryString.isNotEmpty
          ? '/public-schedule-matrix?$queryString'
          : '/public-schedule-matrix';

      final response = await _apiClient.get(endpoint);

      return _apiClient.handleResponse<Map<String, dynamic>>(
        response,
        (data) => data,
      );
    } catch (e) {
      developer.log('Get public schedule matrix error: $e');
      throw Exception('Error getting schedule matrix: $e');
    }
  }

  /// Convert schedule bookings to existing Booking format for compatibility
  List<Booking> convertToBookingList(
    List<ScheduleBooking> scheduleBookings,
    List<Room> rooms,
  ) {
    final List<Booking> bookings = [];

    for (final scheduleBooking in scheduleBookings) {
      // Find room index for dayColumn
      final roomIndex = rooms.indexWhere(
        (room) => room.id == scheduleBooking.room.id,
      );

      if (roomIndex != -1 && scheduleBooking.isApproved) {
        // Only show approved bookings
        try {
          final booking = Booking(
            title: scheduleBooking.mataKuliah.isNotEmpty
                ? scheduleBooking.mataKuliah
                : scheduleBooking.keperluan,
            startTime: scheduleBooking.timeSlot.startTimeFormatted,
            endTime: scheduleBooking.timeSlot.endTimeFormatted,
            color: getBookingColor(scheduleBooking.status),
            dayColumn: roomIndex,
            room: scheduleBooking.room.displayName,
            studentName: scheduleBooking.userName,
            major: '', // Not available in API response
            classYear: '', // Not available in API response
            necessary: scheduleBooking.keperluan,
            notes: '', // Not available in API response
            lecturer: scheduleBooking.dosen,
            bookingDate: DateTime.parse(scheduleBooking.bookingDate),
            createdAt: DateTime.now(), // Use current time as placeholder
          );

          bookings.add(booking);
        } catch (e) {
          developer.log('Error converting booking ${scheduleBooking.id}: $e');
        }
      }
    }

    return bookings;
  }

  /// Get color based on booking status
  static Color getBookingColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFF4CAF50); // Green
      case 'pending':
        return const Color(0xFFFF9800); // Orange
      case 'rejected':
        return const Color(0xFFF44336); // Red
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  /// Format date for API call (YYYY-MM-DD)
  static String formatDateForApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Check if booking exists for specific room and time slot
  bool isTimeSlotBooked(
    List<ScheduleBooking> bookings,
    int roomId,
    int timeSlotId,
  ) {
    return bookings.any(
      (booking) =>
          booking.room.id == roomId &&
          booking.timeSlot.id == timeSlotId &&
          booking.isApproved,
    );
  }

  /// Get booking for specific room and time slot
  ScheduleBooking? getBookingForSlot(
    List<ScheduleBooking> bookings,
    int roomId,
    int timeSlotId,
  ) {
    try {
      return bookings.firstWhere(
        (booking) =>
            booking.room.id == roomId &&
            booking.timeSlot.id == timeSlotId &&
            booking.isApproved,
      );
    } catch (e) {
      return null;
    }
  }
}
