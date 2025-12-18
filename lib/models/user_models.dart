class UserModel {
  final String id;
  final String name;
  final String username;
  final String role;
  final bool? isActive;
  final String? email;

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.role,
    this.isActive,
    this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      role: json['role'] ?? '',
      isActive: json['is_active'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'role': role,
      if (email != null) 'email': email,
      if (isActive != null) 'is_active': isActive,
    };
  }
}
