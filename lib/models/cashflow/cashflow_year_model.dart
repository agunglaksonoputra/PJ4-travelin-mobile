import 'month_item_model.dart';

class CashFlowYear {
  final String year;
  final List<MonthItem> months;

  CashFlowYear({
    required this.year,
    required this.months,
  });

  factory CashFlowYear.fromJson(Map<String, dynamic> json) {
    return CashFlowYear(
      year: json['year'],
      months: (json['months'] as List)
          .map((item) => MonthItem.fromJson(item))
          .toList(),
    );
  }
}
