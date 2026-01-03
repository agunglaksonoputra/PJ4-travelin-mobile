class OwnerBalanceModel {
  final int ownerId;
  final String ownerName;
  final double totalShare;
  final double totalWithdrawn;
  final double availableBalance;

  OwnerBalanceModel({
    required this.ownerId,
    required this.ownerName,
    required this.totalShare,
    required this.totalWithdrawn,
    required this.availableBalance,
  });

  factory OwnerBalanceModel.fromJson(Map<String, dynamic> json) {
    return OwnerBalanceModel(
      ownerId: int.parse(json['owner_id'].toString()),
      ownerName: json['owner_name'],
      totalShare: (json['total_share'] as num).toDouble(),
      totalWithdrawn: (json['total_withdrawn'] as num).toDouble(),
      availableBalance: (json['available_balance'] as num).toDouble(),
    );
  }
}
