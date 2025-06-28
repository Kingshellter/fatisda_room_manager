class RoomResponse {
  final bool success;
  final String message;
  final RoomData data;

  RoomResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory RoomResponse.fromJson(Map<String, dynamic> json) {
    return RoomResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: RoomData.fromJson(json['data'] ?? {}),
    );
  }
}

class RoomData {
  final List<Room> data;

  RoomData({required this.data});

  factory RoomData.fromJson(Map<String, dynamic> json) {
    return RoomData(
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => Room.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class Room {
  final int id;
  final String name;
  final int capacity;
  final String facilities;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  Room({
    required this.id,
    required this.name,
    required this.capacity,
    required this.facilities,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      capacity: json['capacity'] ?? 0,
      facilities: json['facilities'] ?? '',
      isActive: json['is_active'] ?? false,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  // Format display name for room
  String get displayName {
    return 'Ruang $name';
  }
}
