class PaymentModel {
  PaymentModel({
    required this.id,
    required this.transactionId,
    required this.method,
    required this.amount,
    this.paidAt,
    this.note,
    this.transaction,
  });

  final int id;
  final int transactionId;
  final String method;
  final double amount;
  final DateTime? paidAt;
  final String? note;
  final TransactionSummary? transaction;

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: _parseInt(json['id']),
      transactionId: _parseInt(json['transaction_id']),
      method: (json['method'] ?? '').toString(),
      amount: _parseDouble(json['amount']),
      paidAt: _parseDate(json['paid_at']),
      note: json['note']?.toString(),
      transaction:
          json['transaction'] is Map<String, dynamic>
              ? TransactionSummary.fromJson(
                json['transaction'] as Map<String, dynamic>,
              )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'method': method,
      'amount': amount,
      'paid_at': paidAt?.toIso8601String(),
      'note': note,
      if (transaction != null) 'transaction': transaction!.toJson(),
    };
  }
}

class TransactionSummary {
  TransactionSummary({
    required this.id,
    required this.tripCode,
    required this.customerName,
    required this.vehicleId,
    this.totalCost,
    this.status,
  });

  final int id;
  final String tripCode;
  final String customerName;
  final int vehicleId;
  final double? totalCost;
  final String? status;

  factory TransactionSummary.fromJson(Map<String, dynamic> json) {
    return TransactionSummary(
      id: _parseInt(json['id']),
      tripCode: (json['trip_code'] ?? '').toString(),
      customerName: (json['customer_name'] ?? '').toString(),
      vehicleId: _parseInt(json['vehicle_id']),
      totalCost:
          json.containsKey('total_cost')
              ? _parseDouble(json['total_cost'])
              : null,
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trip_code': tripCode,
      'customer_name': customerName,
      'vehicle_id': vehicleId,
      'total_cost': totalCost,
      'status': status,
    };
  }
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? 0;
}

double _parseDouble(dynamic value) {
  if (value == null) return 0;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}
