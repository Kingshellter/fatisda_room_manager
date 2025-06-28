import '../models/room_model.dart';
import '../models/timeslot_model.dart';
import '../models/booking.dart'; // Your existing booking model
import 'room_service.dart';
import 'timeslot_service.dart';
import 'schedule_service.dart';
import 'dart:developer' as developer;

class MainDataService {
  final RoomService _roomService = RoomService();
  final TimeSlotService _timeSlotService = TimeSlotService();
  final ScheduleService _scheduleService = ScheduleService();

  // Singleton instance
  static final MainDataService _instance = MainDataService._internal();
  factory MainDataService() => _instance;
  MainDataService._internal();

  // Cache untuk data yang jarang berubah
  List<Room>? _cachedRooms;
  List<TimeSlot>? _cachedTimeSlots;
  DateTime? _lastCacheUpdate;

  /// Get all rooms (with caching)
  Future<List<Room>> getRooms({bool forceRefresh = false}) async {
    try {
      final now = DateTime.now();

      // Check if cache is still valid (cache for 5 minutes)
      if (!forceRefresh &&
          _cachedRooms != null &&
          _lastCacheUpdate != null &&
          now.difference(_lastCacheUpdate!).inMinutes < 5) {
        developer.log('Using cached rooms data');
        return _cachedRooms!;
      }

      developer.log('Fetching fresh rooms data');
      _cachedRooms = await _roomService.getPublicRooms();
      _lastCacheUpdate = now;

      return _cachedRooms!;
    } catch (e) {
      developer.log('Error getting rooms: $e');
      // Return cached data if available, otherwise rethrow
      if (_cachedRooms != null) {
        developer.log('Returning cached rooms due to error');
        return _cachedRooms!;
      }
      rethrow;
    }
  }

  /// Get all time slots (with caching)
  Future<List<TimeSlot>> getTimeSlots({bool forceRefresh = false}) async {
    try {
      final now = DateTime.now();

      // Check if cache is still valid (cache for 5 minutes)
      if (!forceRefresh &&
          _cachedTimeSlots != null &&
          _lastCacheUpdate != null &&
          now.difference(_lastCacheUpdate!).inMinutes < 5) {
        developer.log('Using cached time slots data');
        return _cachedTimeSlots!;
      }

      developer.log('Fetching fresh time slots data');
      _cachedTimeSlots = await _timeSlotService.getPublicTimeSlots();
      _lastCacheUpdate = now;

      return _cachedTimeSlots!;
    } catch (e) {
      developer.log('Error getting time slots: $e');
      // Return cached data if available, otherwise rethrow
      if (_cachedTimeSlots != null) {
        developer.log('Returning cached time slots due to error');
        return _cachedTimeSlots!;
      }
      rethrow;
    }
  }

  /// Get schedule for specific date and convert to Booking format
  Future<List<Booking>> getScheduleForDate(DateTime date) async {
    try {
      final dateString = ScheduleService.formatDateForApi(date);
      developer.log('Getting schedule for date: $dateString');

      // Get schedule data
      final scheduleData = await _scheduleService.getPublicSchedule(dateString);

      // Get rooms for mapping
      final rooms = await getRooms();

      // Convert to Booking format
      final bookings = _scheduleService.convertToBookingList(
        scheduleData.bookings,
        rooms,
      );

      developer.log('Converted ${bookings.length} bookings for $dateString');
      return bookings;
    } catch (e) {
      developer.log('Error getting schedule for date: $e');
      throw Exception('Error loading schedule: $e');
    }
  }

  /// Get room names compatible with existing app format
  Future<List<String>> getRoomNames() async {
    try {
      final rooms = await getRooms();
      return _roomService.roomsToStringList(rooms);
    } catch (e) {
      developer.log('Error getting room names: $e');
      rethrow;
    }
  }

  /// Get time slots compatible with existing app format
  Future<List<Map<String, String>>> getTimeSlotMaps() async {
    try {
      final timeSlots = await getTimeSlots();
      return _timeSlotService.timeSlotsToMapList(timeSlots);
    } catch (e) {
      developer.log('Error getting time slot maps: $e');
      rethrow;
    }
  }

  /// Find room by display name
  Future<Room?> findRoomByName(String displayName) async {
    try {
      final rooms = await getRooms();
      return _roomService.findRoomByDisplayName(rooms, displayName);
    } catch (e) {
      developer.log('Error finding room by name: $e');
      return null;
    }
  }

  /// Find time slot by time range
  Future<TimeSlot?> findTimeSlotByTime(String startTime, String endTime) async {
    try {
      final timeSlots = await getTimeSlots();
      return _timeSlotService.findTimeSlotByTime(timeSlots, startTime, endTime);
    } catch (e) {
      developer.log('Error finding time slot by time: $e');
      return null;
    }
  }

  /// Check if a specific time slot is available
  Future<bool> isTimeSlotAvailable(
    String roomDisplayName,
    String startTime,
    String endTime,
    DateTime date,
  ) async {
    try {
      // Get schedule for the date
      final bookings = await getScheduleForDate(date);

      // Check if any booking conflicts with the requested slot
      final hasConflict = bookings.any(
        (booking) =>
            booking.room == roomDisplayName &&
            booking.startTime == startTime &&
            booking.endTime == endTime,
      );

      return !hasConflict;
    } catch (e) {
      developer.log('Error checking time slot availability: $e');
      return false; // Assume not available if error occurs
    }
  }

  /// Get available time slots for a specific room and date
  Future<List<Map<String, String>>> getAvailableTimeSlots(
    String roomDisplayName,
    DateTime date,
  ) async {
    try {
      final allTimeSlots = await getTimeSlotMaps();
      final bookings = await getScheduleForDate(date);

      // Filter out booked time slots
      final availableTimeSlots = allTimeSlots.where((timeSlot) {
        final startTime = timeSlot['start']!;
        final endTime = timeSlot['end']!;

        final hasConflict = bookings.any(
          (booking) =>
              booking.room == roomDisplayName &&
              booking.startTime == startTime &&
              booking.endTime == endTime,
        );

        return !hasConflict;
      }).toList();

      return availableTimeSlots;
    } catch (e) {
      developer.log('Error getting available time slots: $e');
      return [];
    }
  }

  /// Refresh all cached data
  Future<void> refreshAllData() async {
    try {
      developer.log('Refreshing all cached data');
      await Future.wait([
        getRooms(forceRefresh: true),
        getTimeSlots(forceRefresh: true),
      ]);
      developer.log('All data refreshed successfully');
    } catch (e) {
      developer.log('Error refreshing data: $e');
      rethrow;
    }
  }

  /// Clear cache
  void clearCache() {
    _cachedRooms = null;
    _cachedTimeSlots = null;
    _lastCacheUpdate = null;
    developer.log('Cache cleared');
  }

  /// Get comprehensive data for a specific date (rooms, time slots, and bookings)
  Future<Map<String, dynamic>> getCompleteDataForDate(DateTime date) async {
    try {
      developer.log('Getting complete data for date: $date');

      final results = await Future.wait([
        getRooms(),
        getTimeSlots(),
        getScheduleForDate(date),
      ]);

      return {
        'rooms': results[0] as List<Room>,
        'timeSlots': results[1] as List<TimeSlot>,
        'bookings': results[2] as List<Booking>,
        'roomNames': _roomService.roomsToStringList(results[0] as List<Room>),
        'timeSlotMaps': _timeSlotService.timeSlotsToMapList(
          results[1] as List<TimeSlot>,
        ),
        'date': date,
      };
    } catch (e) {
      developer.log('Error getting complete data: $e');
      rethrow;
    }
  }
}
