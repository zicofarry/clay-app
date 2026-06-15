class UserModel {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String? email;
  final String? avatarUrl;
  final String? role;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    this.email,
    this.avatarUrl,
    this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? '',
      email: json['email']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
      role: json['role']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'email': email,
      'avatar_url': avatarUrl,
      'role': role,
    };
  }
}
