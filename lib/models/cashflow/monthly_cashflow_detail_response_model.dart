import 'monthly_transaction_detail_model.dart';

class MonthlyCashFlowDetailResponse {
  final String month;
  final int count;
  final List<MonthlyTransactionDetail> transactions;

  MonthlyCashFlowDetailResponse({
    required this.month,
    required this.count,
    required this.transactions,
  });

  factory MonthlyCashFlowDetailResponse.fromJson(Map<String, dynamic> json) {
    return MonthlyCashFlowDetailResponse(
      month: json['month'],
      count: json['count'] ?? 0,
      transactions: (json['data'] as List)
          .map((e) => MonthlyTransactionDetail.fromJson(e))
          .toList(),
    );
  }
}
