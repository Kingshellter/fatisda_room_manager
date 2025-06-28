// models/booking_model.dart
class BookingResponse {
  final bool success;
  final String message;
  final List<Booking> data;

  BookingResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    return BookingResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => Booking.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class Booking {
  final int id;
  final int userId;
  final int roomId;
  final int timeSlotId;
  final String bookingDate;
  final String purpose;
  final String status;
  final String? adminNotes;
  final String createdAt;
  final String updatedAt;
  final Room? room;
  final TimeSlot? timeSlot;
  final User? user;
  final String? color;
  final String? keperluan;
  final String? mataKuliah;
  final String? dosen;
  final String? catatan;

  Booking({
    required this.id,
    required this.userId,
    required this.roomId,
    required this.timeSlotId,
    required this.bookingDate,
    required this.purpose,
    required this.status,
    this.adminNotes,
    required this.createdAt,
    required this.updatedAt,
    this.room,
    this.timeSlot,
    this.color,
    this.user,
    this.keperluan,
    this.mataKuliah,
    this.dosen,
    this.catatan,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      roomId: json['room_id'] ?? 0,
      timeSlotId: json['time_slot_id'] ?? 0,
      bookingDate: json['booking_date'] ?? '',
      purpose: json['purpose'] ?? '',
      status: json['status'] ?? '',
      adminNotes: json['admin_notes'],
      color: json['color'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      room: json['room'] != null ? Room.fromJson(json['room']) : null,
      timeSlot: json['time_slot'] != null
          ? TimeSlot.fromJson(json['time_slot'])
          : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      keperluan: json['keperluan'],
      mataKuliah: json['mata_kuliah'],
      dosen: json['dosen'],
      catatan: json['catatan'],
    );
  }

  String get statusDisplayName {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu Persetujuan';
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isRejected => status.toLowerCase() == 'rejected';
  bool get isCancelled => status.toLowerCase() == 'cancelled';
}

class Room {
  final int id;
  final String name;

  Room({required this.id, required this.name});

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(id: json['id'] ?? 0, name: json['name'] ?? '');
  }
}

class TimeSlot {
  final int id;
  final String label;
  final String startTime;
  final String endTime;

  TimeSlot({
    required this.id,
    required this.label,
    required this.startTime,
    required this.endTime,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      id: json['id'] ?? 0,
      label: json['label'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
    );
  }

  String get timeRange => label.isNotEmpty ? label : '$startTime - $endTime';
}

class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}
