class CashFlowSummary {
  final String month; // YYYY-MM
  final double totalProfit;
  final double totalCashIn;
  final double totalCashFlow;
  final int totalTransactions;

  CashFlowSummary({
    required this.month,
    required this.totalProfit,
    required this.totalCashIn,
    required this.totalCashFlow,
    required this.totalTransactions,
  });

  factory CashFlowSummary.fromJson(Map<String, dynamic> json) {
    return CashFlowSummary(
      month: json['month'] ?? "",
      totalProfit: (json['total_profit'] ?? 0).toDouble(),
      totalCashIn: (json['total_cash_in'] ?? 0).toDouble(),
      totalCashFlow: (json['total_cash_flow'] ?? 0).toDouble(),
      totalTransactions: (json['total_transactions'] ?? 0) as int,
    );
  }
}
