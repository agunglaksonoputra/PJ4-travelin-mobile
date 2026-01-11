import 'package:intl/intl.dart';

class TransactionReport {
  final int? id;
  final int transactionId;

  final String driverName;
  final int kmStart;
  final int kmEnd;

  final double driverFee;
  final double gasolineCost;
  final double tollCost;
  final double parkingCost;
  final double miscCost;

  final double totalOperationalCost;

  final String? notes;
  final DateTime reportDate;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  TransactionReport({
    this.id,
    required this.transactionId,
    required this.driverName,
    required this.kmStart,
    required this.kmEnd,
    required this.driverFee,
    required this.gasolineCost,
    required this.tollCost,
    required this.parkingCost,
    required this.miscCost,
    required this.totalOperationalCost,
    this.notes,
    required this.reportDate,
    this.createdAt,
    this.updatedAt,
  });

  factory TransactionReport.fromJson(Map<String, dynamic> json) {
    return TransactionReport(
      id: _toInt(json['id']),
      transactionId: _toInt(json['transaction_id']),

      driverName: json['driver_name'] ?? '-',
      kmStart: _toInt(json['km_start']),
      kmEnd: _toInt(json['km_end']),

      driverFee: _toDouble(json['driver_fee']),
      gasolineCost: _toDouble(json['gasoline_cost']),
      tollCost: _toDouble(json['toll_cost']),
      parkingCost: _toDouble(json['parking_cost']),
      miscCost: _toDouble(json['misc_cost']),

      totalOperationalCost: _toDouble(json['total_operational_cost']),

      notes: json['notes'],
      reportDate: json['report_date'] ?? '',
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_id': transactionId,
      'driver_name': driverName,
      'km_start': kmStart,
      'km_end': kmEnd,
      'driver_fee': driverFee,
      'gasoline_cost': gasolineCost,
      'toll_cost': tollCost,
      'parking_cost': parkingCost,
      'misc_cost': miscCost,
      'total_operational_cost': totalOperationalCost,
      'notes': notes,
    'report_date': DateFormat('yyyy-MM-dd').format(reportDate),
    };
  }

  /// ========================
  /// Helper Parsers
  /// ========================
  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}
