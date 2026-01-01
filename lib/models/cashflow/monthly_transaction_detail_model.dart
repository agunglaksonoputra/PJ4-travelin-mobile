import 'package:travelin/models/payment_models.dart';

class MonthlyTransactionDetail {
  final int transactionId;
  final String tripCode;
  final String customerName;
  final String? customerPhone;
  final String? destination;

  /// Sudah gabungan: "Toyota HiAce Premio — B 1122 TLA"
  final String? vehicle;

  final String status;
  final double paidAmount;
  final double outstandingAmount;
  final double operationalCost;
  final double profit;
  final bool isClosed;

  final String? startDate;
  final String? endDate;

  /// ISO DateTime
  final String? createdDate;

  final List<PaymentModel> payments;

  MonthlyTransactionDetail({
    required this.transactionId,
    required this.tripCode,
    required this.customerName,
    this.customerPhone,
    this.destination,
    this.vehicle,
    required this.status,
    required this.paidAmount,
    required this.outstandingAmount,
    required this.operationalCost,
    required this.profit,
    required this.isClosed,
    this.startDate,
    this.endDate,
    this.createdDate,
    required this.payments,
  });

  factory MonthlyTransactionDetail.fromJson(Map<String, dynamic> json) {
    return MonthlyTransactionDetail(
      transactionId: int.parse(json['transaction_id'].toString()),
      tripCode: json['trip_code'],
      customerName: json['customer_name'],
      customerPhone: json['customer_phone'],
      destination: json['destination'],
      vehicle: json['vehicle'],
      status: json['status'],
      paidAmount: double.parse(json['paid_amount'].toString()),
      outstandingAmount: double.parse(json['outstanding_amount'].toString()),
      operationalCost: double.parse(json['operational_cost'].toString()),
      profit: double.parse(json['profit'].toString()),
      isClosed: json['isClosed'] ?? false,
      startDate: json['start_date'],
      endDate: json['end_date'],
      createdDate: json['date'],
      payments: (json['payments'] as List? ?? [])
          .map((p) => PaymentModel.fromJson(p))
          .toList(),
    );
  }
}
