import 'package:intl/intl.dart';

import 'vehicle_models.dart';

class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.tripCode,
    required this.status,
    required this.customerName,
    required this.vehicleId,
    this.customerPhone,
    this.tariffId,
    this.startDate,
    this.endDate,
    this.destination,
    this.notes,
    this.pricePerDay,
    this.durationDays,
    this.totalCost,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.vehicle,
  });

  final int id;
  final String tripCode;
  final String status;
  final String customerName;
  final String? customerPhone;
  final int vehicleId;
  final int? tariffId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? destination;
  final String? notes;
  final double? pricePerDay;
  final int? durationDays;
  final double? totalCost;
  final int? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final VehicleModel? vehicle;

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: _toInt(json['id']) ?? 0,
      tripCode: (json['trip_code'] ?? '') as String,
      status: (json['status'] ?? '') as String,
      customerName: (json['customer_name'] ?? '') as String,
      customerPhone: json['customer_phone'] as String?,
      vehicleId: _toInt(json['vehicle_id']) ?? 0,
      tariffId: _toInt(json['tariff_id']),
      startDate: _parseDate(json['start_date']),
      endDate: _parseDate(json['end_date']),
      destination: json['destination'] as String?,
      notes: json['notes'] as String?,
      pricePerDay: _toDouble(json['price_per_day']),
      durationDays: _toInt(json['duration_days']),
      totalCost: _toDouble(json['total_cost']),
      createdBy: _toInt(json['created_by']),
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      vehicle:
          json['vehicle'] is Map<String, dynamic>
              ? VehicleModel.fromJson(json['vehicle'] as Map<String, dynamic>)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trip_code': tripCode,
      'status': status,
      'customer_name': customerName,
      if (customerPhone != null) 'customer_phone': customerPhone,
      'vehicle_id': vehicleId,
      if (tariffId != null) 'tariff_id': tariffId,
      if (startDate != null)
        'start_date': DateFormat('yyyy-MM-dd').format(startDate!),
      if (endDate != null)
        'end_date': DateFormat('yyyy-MM-dd').format(endDate!),
      if (destination != null) 'destination': destination,
      if (notes != null) 'notes': notes,
      if (pricePerDay != null) 'price_per_day': pricePerDay,
      if (durationDays != null) 'duration_days': durationDays,
      if (totalCost != null) 'total_cost': totalCost,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      if (vehicle != null) 'vehicle': vehicle!.toJson(),
    };
  }

  String? get formattedStartDate => _formatDate(startDate);

  String? get formattedEndDate => _formatDate(endDate);

  static String? _formatDate(DateTime? date) {
    if (date == null) return null;
    return DateFormat('dd MMM yyyy').format(date);
  }
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}
