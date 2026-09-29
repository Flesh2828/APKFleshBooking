class ReservationModel {
  final String id;
  final String userId;
  final String roomId;
  final String userName;
  final String organization;
  final DateTime startTime;
  final DateTime endTime;
  final String purpose;
  final int participantCount;
  final String? additionalFacilities;
  final String? notes;
  final String status; // 'PENDING', 'APPROVED', 'REJECTED', 'CANCELLED', 'COMPLETED'
  final DateTime createdAt;

  ReservationModel({
    required this.id,
    required this.userId,
    required this.roomId,
    required this.userName,
    required this.organization,
    required this.startTime,
    required this.endTime,
    required this.purpose,
    required this.participantCount,
    this.additionalFacilities,
    this.notes,
    required this.status,
    required this.createdAt,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      roomId: json['room_id'] as String,
      userName: json['user_name'] as String? ?? '',
      organization: json['organization'] as String? ?? '',
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      purpose: json['purpose'] as String? ?? '',
      participantCount: json['participant_count'] as int? ?? 1,
      additionalFacilities: json['additional_facilities'] as String?,
      notes: json['notes'] as String?,
      status: json['status'] as String? ?? 'PENDING',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
