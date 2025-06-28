import '../models/timeslot_model.dart';
import 'api_client.dart';
import 'dart:developer' as developer;

class TimeSlotService {
  final ApiClient _apiClient = ApiClient();

  // Singleton instance
  static final TimeSlotService _instance = TimeSlotService._internal();
  factory TimeSlotService() => _instance;
  TimeSlotService._internal();

  /// Get all public time slots
  Future<List<TimeSlot>> getPublicTimeSlots() async {
    try {
      developer.log('Getting public time slots...');

      final response = await _apiClient.get('/time-slots-public');

      final timeSlotResponse = _apiClient.handleResponse<TimeSlotResponse>(
        response,
        (data) => TimeSlotResponse.fromJson(data),
      );

      // Filter only active time slots and sort by start time
      final activeTimeSlots = timeSlotResponse.data
          .where((timeSlot) => timeSlot.isActive)
          .toList();

      // Sort by start time
      activeTimeSlots.sort((a, b) {
        try {
          final timeA = DateTime.parse(a.startTime);
          final timeB = DateTime.parse(b.startTime);
          return timeA.compareTo(timeB);
        } catch (e) {
          return 0;
        }
      });

      developer.log('Retrieved ${activeTimeSlots.length} active time slots');
      return activeTimeSlots;
    } catch (e) {
      developer.log('Get public time slots error: $e');
      throw Exception('Error getting time slots: $e');
    }
  }

  /// Get time slot detail by ID
  Future<TimeSlot> getTimeSlotDetail(int timeSlotId) async {
    try {
      developer.log('Getting time slot detail for ID: $timeSlotId');

      final response = await _apiClient.get('/time-slots-public/$timeSlotId');

      return _apiClient.handleResponse<TimeSlot>(response, (data) {
        if (data['success'] == true && data['data'] != null) {
          return TimeSlot.fromJson(data['data']);
        }
        throw Exception('Invalid response format');
      });
    } catch (e) {
      developer.log('Get time slot detail error: $e');
      throw Exception('Error getting time slot detail: $e');
    }
  }

  /// Check time slot availability
  Future<Map<String, dynamic>> checkTimeSlotAvailability({
    String? date,
    int? roomId,
  }) async {
    try {
      developer.log('Checking time slot availability...');

      final queryParams = <String, String>{};
      if (date != null) queryParams['date'] = date;
      if (roomId != null) queryParams['room_id'] = roomId.toString();

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final endpoint = queryString.isNotEmpty
          ? '/time-slots-availability?$queryString'
          : '/time-slots-availability';

      final response = await _apiClient.get(endpoint);

      return _apiClient.handleResponse<Map<String, dynamic>>(
        response,
        (data) => data,
      );
    } catch (e) {
      developer.log('Check time slot availability error: $e');
      throw Exception('Error checking time slot availability: $e');
    }
  }

  /// Convert TimeSlot list to format compatible with existing app
  List<Map<String, String>> timeSlotsToMapList(List<TimeSlot> timeSlots) {
    return timeSlots.map((timeSlot) => timeSlot.toTimeSlotMap()).toList();
  }

  /// Find time slot by ID
  TimeSlot? findTimeSlotById(List<TimeSlot> timeSlots, int id) {
    try {
      return timeSlots.firstWhere((timeSlot) => timeSlot.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Find time slot by time range
  TimeSlot? findTimeSlotByTime(
    List<TimeSlot> timeSlots,
    String startTime,
    String endTime,
  ) {
    try {
      return timeSlots.firstWhere(
        (timeSlot) =>
            timeSlot.startTimeFormatted == startTime &&
            timeSlot.endTimeFormatted == endTime,
      );
    } catch (e) {
      return null;
    }
  }
}
