class OwnerWithdrawalModel {
  final int id;
  final int ownerId;
  final double amount;
  final String method;
  final String? note;
  final DateTime withdrawnAt;

  OwnerWithdrawalModel({
    required this.id,
    required this.ownerId,
    required this.amount,
    required this.method,
    this.note,
    required this.withdrawnAt,
  });

  factory OwnerWithdrawalModel.fromJson(Map<String, dynamic> json) {
    return OwnerWithdrawalModel(
      id: int.parse(json['id'].toString()),
      ownerId: int.parse(json['owner_id'].toString()),
      amount: double.parse(json['amount'].toString()),
      method: json['method'].toString(),
      note: json['note']?.toString(),
      withdrawnAt: DateTime.parse(json['withdrawn_at'].toString()),
    );
  }
}
