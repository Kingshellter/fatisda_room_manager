import '../models/room_model.dart';
import 'api_client.dart';
import 'dart:developer' as developer;

class RoomService {
  final ApiClient _apiClient = ApiClient();

  // Singleton instance
  static final RoomService _instance = RoomService._internal();
  factory RoomService() => _instance;
  RoomService._internal();

  /// Get all public rooms
  Future<List<Room>> getPublicRooms() async {
    try {
      developer.log('Getting public rooms...');

      final response = await _apiClient.get('/rooms-public');

      final roomResponse = _apiClient.handleResponse<RoomResponse>(
        response,
        (data) => RoomResponse.fromJson(data),
      );

      // Filter only active rooms
      final activeRooms = roomResponse.data.data
          .where((room) => room.isActive)
          .toList();

      developer.log('Retrieved ${activeRooms.length} active rooms');
      return activeRooms;
    } catch (e) {
      developer.log('Get public rooms error: $e');
      throw Exception('Error getting rooms: $e');
    }
  }

  /// Get room detail by ID
  Future<Room> getRoomDetail(int roomId) async {
    try {
      developer.log('Getting room detail for ID: $roomId');

      final response = await _apiClient.get('/rooms-public/$roomId');

      return _apiClient.handleResponse<Room>(response, (data) {
        if (data['success'] == true && data['data'] != null) {
          return Room.fromJson(data['data']);
        }
        throw Exception('Invalid response format');
      });
    } catch (e) {
      developer.log('Get room detail error: $e');
      throw Exception('Error getting room detail: $e');
    }
  }

  /// Check room availability for specific date
  Future<Map<String, dynamic>> checkRoomAvailability(
    int roomId,
    String date,
  ) async {
    try {
      developer.log('Checking availability for room $roomId on $date');

      final response = await _apiClient.get(
        '/rooms-public/$roomId/availability?date=$date',
      );

      return _apiClient.handleResponse<Map<String, dynamic>>(
        response,
        (data) => data,
      );
    } catch (e) {
      developer.log('Check room availability error: $e');
      throw Exception('Error checking room availability: $e');
    }
  }

  /// Convert Room list to format compatible with existing app
  List<String> roomsToStringList(List<Room> rooms) {
    return rooms.map((room) => room.displayName).toList();
  }

  /// Find room by display name
  Room? findRoomByDisplayName(List<Room> rooms, String displayName) {
    try {
      return rooms.firstWhere((room) => room.displayName == displayName);
    } catch (e) {
      return null;
    }
  }
}
