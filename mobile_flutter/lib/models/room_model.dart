import 'dart:convert';

class RoomModel {
  final String id;
  final String name;
  final String building;
  final int floor;
  final int capacity;
  final List<String> facilities;
  final String status; // 'ACTIVE', 'INACTIVE', 'MAINTENANCE'
  final String openingHour;
  final String closingHour;
  final String? imageUrl;
  final String? description;

  RoomModel({
    required this.id,
    required this.name,
    required this.building,
    required this.floor,
    required this.capacity,
    required this.facilities,
    required this.status,
    required this.openingHour,
    required this.closingHour,
    this.imageUrl,
    this.description,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedFacilities = [];
    if (json['facilities'] != null) {
      if (json['facilities'] is List) {
        parsedFacilities = List<String>.from(json['facilities']);
      } else if (json['facilities'] is String) {
        try {
          parsedFacilities = List<String>.from(jsonDecode(json['facilities']));
        } catch (_) {}
      }
    }

    return RoomModel(
      id: json['id'] as String,
      name: json['name'] as String,
      building: json['building'] as String,
      floor: json['floor'] as int? ?? 1,
      capacity: json['capacity'] as int? ?? 0,
      facilities: parsedFacilities,
      status: json['status'] as String? ?? 'ACTIVE',
      openingHour: json['opening_hour'] as String? ?? '08:00',
      closingHour: json['closing_hour'] as String? ?? '17:00',
      imageUrl: json['image_url'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'building': building,
      'floor': floor,
      'capacity': capacity,
      'facilities': facilities,
      'status': status,
      'opening_hour': openingHour,
      'closing_hour': closingHour,
      'image_url': imageUrl,
      'description': description,
    };
  }
}
