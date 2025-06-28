class TimeSlotResponse {
  final bool success;
  final String message;
  final List<TimeSlot> data;

  TimeSlotResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory TimeSlotResponse.fromJson(Map<String, dynamic> json) {
    return TimeSlotResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => TimeSlot.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class TimeSlot {
  final int id;
  final String startTime;
  final String endTime;
  final String label;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  TimeSlot({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.label,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      id: json['id'] ?? 0,
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      label: json['label'] ?? '',
      isActive: json['is_active'] ?? false,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  // Helper method to get formatted time for display
  String get displayTime => label.isNotEmpty ? label : '$startTime - $endTime';

  // Helper method to get start time in HH:mm format
  String get startTimeFormatted {
    try {
      final dateTime = DateTime.parse(startTime);
      return '${dateTime.hour.toString().padLeft(2, '0')}.${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return startTime;
    }
  }

  // Helper method to get end time in HH:mm format
  String get endTimeFormatted {
    try {
      final dateTime = DateTime.parse(endTime);
      return '${dateTime.hour.toString().padLeft(2, '0')}.${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return endTime;
    }
  }

  // Convert to time slot format similar to existing app
  Map<String, String> toTimeSlotMap() {
    return {
      'jam': id.toString(),
      'start': startTimeFormatted,
      'end': endTimeFormatted,
    };
  }
}
