import 'room_model.dart';

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
  final RoomModel? room;

  // Machine Learning Inference Fields (Linear Regression, Logistic Regression, Naive Bayes, SVM)
  final String? autoCategory;
  final bool? isSpam;
  final double? noShowRiskScore;
  final bool? isHighRiskNoShow;
  final String? approvalRecommendation; // 'AUTO_APPROVE', 'MANUAL_REVIEW', 'AUTO_REJECT'
  final double? estimatedOccupancyHours;
  final double? estimatedEnergyKwh;
  final DateTime? mlInferredAt;

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
    this.room,
    this.autoCategory,
    this.isSpam,
    this.noShowRiskScore,
    this.isHighRiskNoShow,
    this.approvalRecommendation,
    this.estimatedOccupancyHours,
    this.estimatedEnergyKwh,
    this.mlInferredAt,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    RoomModel? parsedRoom;
    if (json['rooms'] != null) {
      if (json['rooms'] is Map<String, dynamic>) {
        parsedRoom = RoomModel.fromJson(json['rooms'] as Map<String, dynamic>);
      } else if (json['rooms'] is List && (json['rooms'] as List).isNotEmpty) {
        parsedRoom = RoomModel.fromJson((json['rooms'] as List).first as Map<String, dynamic>);
      }
    } else if (json['room'] != null && json['room'] is Map<String, dynamic>) {
      parsedRoom = RoomModel.fromJson(json['room'] as Map<String, dynamic>);
    }

    return ReservationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
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
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      room: parsedRoom,
      autoCategory: json['auto_category'] as String?,
      isSpam: json['is_spam'] as bool?,
      noShowRiskScore: (json['no_show_risk_score'] as num?)?.toDouble(),
      isHighRiskNoShow: json['is_high_risk_noshow'] as bool?,
      approvalRecommendation: json['approval_recommendation'] as String?,
      estimatedOccupancyHours:
          (json['estimated_occupancy_hours'] as num?)?.toDouble(),
      estimatedEnergyKwh: (json['estimated_energy_kwh'] as num?)?.toDouble(),
      mlInferredAt: json['ml_inferred_at'] != null
          ? DateTime.tryParse(json['ml_inferred_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'room_id': roomId,
        'user_name': userName,
        'organization': organization,
        'start_time': startTime.toUtc().toIso8601String(),
        'end_time': endTime.toUtc().toIso8601String(),
        'purpose': purpose,
        'participant_count': participantCount,
        'additional_facilities': additionalFacilities,
        'notes': notes,
        'status': status,
        'created_at': createdAt.toUtc().toIso8601String(),
        'auto_category': autoCategory,
        'is_spam': isSpam,
        'no_show_risk_score': noShowRiskScore,
        'is_high_risk_noshow': isHighRiskNoShow,
        'approval_recommendation': approvalRecommendation,
        'estimated_occupancy_hours': estimatedOccupancyHours,
        'estimated_energy_kwh': estimatedEnergyKwh,
        'ml_inferred_at': mlInferredAt?.toUtc().toIso8601String(),
      };

  String get roomDisplayName => room?.name ?? 'Ruangan #$roomId';

  /// Ekstrak nama atau URL berkas lampiran yang tersimpan di dalam notes
  String? get attachmentInfo {
    if (notes == null || notes!.isEmpty) return null;
    final regex = RegExp(r'\[Lampiran:\s*([^\]]+)\]');
    final match = regex.firstMatch(notes!);
    if (match != null && match.groupCount >= 1) {
      return match.group(1)?.trim();
    }
    return null;
  }

  /// Catatan murni tanpa tag [Lampiran: ...]
  String? get cleanNotes {
    if (notes == null || notes!.isEmpty) return null;
    final cleaned = notes!.replaceAll(RegExp(r'\[Lampiran:\s*([^\]]+)\]'), '').trim();
    return cleaned.isNotEmpty ? cleaned : null;
  }

  ReservationModel copyWith({
    String? id,
    String? userId,
    String? roomId,
    String? userName,
    String? organization,
    DateTime? startTime,
    DateTime? endTime,
    String? purpose,
    int? participantCount,
    String? additionalFacilities,
    String? notes,
    String? status,
    DateTime? createdAt,
    RoomModel? room,
    String? autoCategory,
    bool? isSpam,
    double? noShowRiskScore,
    bool? isHighRiskNoShow,
    String? approvalRecommendation,
    double? estimatedOccupancyHours,
    double? estimatedEnergyKwh,
    DateTime? mlInferredAt,
  }) {
    return ReservationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      roomId: roomId ?? this.roomId,
      userName: userName ?? this.userName,
      organization: organization ?? this.organization,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      purpose: purpose ?? this.purpose,
      participantCount: participantCount ?? this.participantCount,
      additionalFacilities: additionalFacilities ?? this.additionalFacilities,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      room: room ?? this.room,
      autoCategory: autoCategory ?? this.autoCategory,
      isSpam: isSpam ?? this.isSpam,
      noShowRiskScore: noShowRiskScore ?? this.noShowRiskScore,
      isHighRiskNoShow: isHighRiskNoShow ?? this.isHighRiskNoShow,
      approvalRecommendation: approvalRecommendation ?? this.approvalRecommendation,
      estimatedOccupancyHours: estimatedOccupancyHours ?? this.estimatedOccupancyHours,
      estimatedEnergyKwh: estimatedEnergyKwh ?? this.estimatedEnergyKwh,
      mlInferredAt: mlInferredAt ?? this.mlInferredAt,
    );
  }
}
