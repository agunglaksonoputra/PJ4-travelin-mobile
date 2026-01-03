class OwnerModel {
  final int id;
  final String name;
  final String? phone;
  final double sharesPercentage;
  final String? notes;
  final bool? isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  OwnerModel({
    required this.id,
    required this.name,
    this.phone,
    required this.sharesPercentage,
    this.notes,
    this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OwnerModel.fromJson(Map<String, dynamic> json) {
    return OwnerModel(
      id: int.parse(json['id'].toString()),
      name: json['name'].toString(),
      phone: json['phone']?.toString(),
      sharesPercentage: double.parse(json['shares_percentage'].toString()),
      notes: json['notes']?.toString(),
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'].toString()),
      updatedAt: DateTime.parse(json['updated_at'].toString()),
    );
  }

  /// 🔥 Helper
  String get shareLabel => "${sharesPercentage.toStringAsFixed(0)}%";
}
