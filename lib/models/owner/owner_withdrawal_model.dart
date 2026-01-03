import 'owner_model.dart';

class OwnerWithdrawalModel {
  final int id;
  final int ownerId;
  final double amount;
  final String method;
  final String? note;
  final String status;

  final DateTime withdrawnAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  final OwnerModel? owner;

  OwnerWithdrawalModel({
    required this.id,
    required this.ownerId,
    required this.amount,
    required this.method,
    this.note,
    required this.status,
    required this.withdrawnAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.owner,
  });

  factory OwnerWithdrawalModel.fromJson(Map<String, dynamic> json) {
    return OwnerWithdrawalModel(
      id: int.parse(json['id'].toString()),
      ownerId: int.parse(json['owner_id'].toString()),
      amount: double.parse(json['amount'].toString()),
      method: json['method'].toString(),
      note: json['note']?.toString(),
      status: json['status'].toString(),

      withdrawnAt: DateTime.parse(json['withdrawn_at'].toString()),
      createdAt: DateTime.parse(json['created_at'].toString()),
      updatedAt: DateTime.parse(json['updated_at'].toString()),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'].toString())
          : null,
      owner: json['owner'] != null
          ? OwnerModel.fromJson(json['owner'])
          : null,
    );
  }

  /// 🔥 Helper
  bool get isRefunded => status == "refunded";
  bool get isDeleted => deletedAt != null;
}
