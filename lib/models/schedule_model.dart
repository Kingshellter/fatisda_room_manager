class ScheduleResponse {
  final bool success;
  final String message;
  final ScheduleData data;

  ScheduleResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ScheduleResponse.fromJson(Map<String, dynamic> json) {
    return ScheduleResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: ScheduleData.fromJson(json['data'] ?? {}),
    );
  }
}

class ScheduleData {
  final String date;
  final int totalBookings;
  final List<ScheduleBooking> bookings;

  ScheduleData({
    required this.date,
    required this.totalBookings,
    required this.bookings,
  });

  factory ScheduleData.fromJson(Map<String, dynamic> json) {
    return ScheduleData(
      date: json['date'] ?? '',
      totalBookings: json['total_bookings'] ?? 0,
      bookings:
          (json['bookings'] as List<dynamic>?)
              ?.map((item) => ScheduleBooking.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class ScheduleBooking {
  final int id;
  final String bookingDate;
  final String keperluan;
  final String mataKuliah;
  final String dosen;
  final String status;
  final String userName;
  final ScheduleRoom room;
  final ScheduleTimeSlot timeSlot;

  ScheduleBooking({
    required this.id,
    required this.bookingDate,
    required this.keperluan,
    required this.mataKuliah,
    required this.dosen,
    required this.status,
    required this.userName,
    required this.room,
    required this.timeSlot,
  });

  factory ScheduleBooking.fromJson(Map<String, dynamic> json) {
    return ScheduleBooking(
      id: json['id'] ?? 0,
      bookingDate: json['booking_date'] ?? '',
      keperluan: json['keperluan'] ?? '',
      mataKuliah: json['mata_kuliah'] ?? '',
      dosen: json['dosen'] ?? '',
      status: json['status'] ?? '',
      userName: json['user_name'] ?? '',
      room: ScheduleRoom.fromJson(json['room'] ?? {}),
      timeSlot: ScheduleTimeSlot.fromJson(json['time_slot'] ?? {}),
    );
  }

  // Convert to the existing Booking model format for compatibility
  Map<String, dynamic> toBookingFormat(int dayColumn) {
    return {
      'id': id,
      'title': mataKuliah.isNotEmpty ? mataKuliah : keperluan,
      'startTime': timeSlot.startTimeFormatted,
      'endTime': timeSlot.endTimeFormatted,
      'room': room.displayName,
      'studentName': userName,
      'lecturer': dosen,
      'necessary': keperluan,
      'notes': '',
      'major': '',
      'classYear': '',
      'dayColumn': dayColumn,
      'bookingDate': bookingDate,
      'status': status,
    };
  }

  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isPending => status.toLowerCase() == 'pending';
}

class ScheduleRoom {
  final int id;
  final String name;
  final int capacity;

  ScheduleRoom({required this.id, required this.name, required this.capacity});

  factory ScheduleRoom.fromJson(Map<String, dynamic> json) {
    return ScheduleRoom(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      capacity: json['capacity'] ?? 0,
    );
  }

  String get displayName => 'Ruang $name';
}

class ScheduleTimeSlot {
  final int id;
  final String label;
  final String startTime;
  final String endTime;

  ScheduleTimeSlot({
    required this.id,
    required this.label,
    required this.startTime,
    required this.endTime,
  });

  factory ScheduleTimeSlot.fromJson(Map<String, dynamic> json) {
    return ScheduleTimeSlot(
      id: json['id'] ?? 0,
      label: json['label'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
    );
  }

  String get startTimeFormatted {
    try {
      final dateTime = DateTime.parse(startTime);
      return '${dateTime.hour.toString().padLeft(2, '0')}.${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return startTime;
    }
  }

  String get endTimeFormatted {
    try {
      final dateTime = DateTime.parse(endTime);
      return '${dateTime.hour.toString().padLeft(2, '0')}.${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return endTime;
    }
  }
}
