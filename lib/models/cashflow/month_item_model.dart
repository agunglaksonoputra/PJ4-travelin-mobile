class MonthItem {
  final String month;
  final double totalProfit;
  final double totalCashIn;
  final double totalCashFlow;
  final int totalTransactions;

  MonthItem({
    required this.month,
    required this.totalProfit,
    required this.totalCashIn,
    required this.totalCashFlow,
    required this.totalTransactions,
  });

  factory MonthItem.fromJson(Map<String, dynamic> json) {
    return MonthItem(
      month: json['month'] ?? "",
      totalProfit: (json['total_profit'] ?? 0).toDouble(),
      totalCashIn: (json['total_cash_in'] ?? 0).toDouble(),
      totalCashFlow: (json['total_cash_flow'] ?? 0).toDouble(),
      totalTransactions: (json['total_transactions'] ?? 0) as int,
    );
  }
}
