class VehicleModel {
  VehicleModel({
    required this.id,
    required this.plateNumber,
    this.brand,
    this.model,
    this.manufactureYear,
    this.status,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String plateNumber;
  final String? brand;
  final String? model;
  final int? manufactureYear;
  final String? status;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: _parseInt(json['id']),
      plateNumber: (json['plate_number'] ?? '').toString(),
      brand: json['brand']?.toString(),
      model: json['model']?.toString(),
      manufactureYear:
          json.containsKey('manufacture_year')
              ? _parseNullableInt(json['manufacture_year'])
              : null,
      status: json['status']?.toString(),
      notes: json['notes']?.toString(),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plate_number': plateNumber,
      'brand': brand,
      'model': model,
      'manufacture_year': manufactureYear,
      'status': status,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? 0;
}

int? _parseNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}
