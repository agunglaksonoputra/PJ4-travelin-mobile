class TransactionSummaryModel {
  TransactionSummaryModel({
    required this.status,
    required this.tripCount,
    required this.totalAmount,
  });

  final String status;
  final int tripCount;
  final double totalAmount;

  factory TransactionSummaryModel.fromJson(Map<String, dynamic> json) {
    return TransactionSummaryModel(
      status: (json['status'] ?? '').toString(),
      tripCount: _toInt(json['trip_count']) ?? 0,
      totalAmount: _toDouble(json['total_amount']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'trip_count': tripCount,
      'total_amount': totalAmount,
    };
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
