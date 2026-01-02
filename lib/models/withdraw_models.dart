class WithdrawModel {
  final String ownerId;
  final String ownerName;
  final double totalShare;
  final double totalWithdrawn;
  final double availableBalance;

  WithdrawModel({
    required this.ownerId,
    required this.ownerName,
    required this.totalShare,
    required this.totalWithdrawn,
    required this.availableBalance,
  });

  factory WithdrawModel.fromJson(Map<String, dynamic> json) {
    return WithdrawModel(
      ownerId: json['owner_id'].toString(),
      ownerName: json['owner_name'],
      totalShare: double.parse(json['total_share'].toString()),
      totalWithdrawn: double.parse(json['total_withdrawn'].toString()),
      availableBalance: double.parse(json['available_balance'].toString()),
    );
  }
}