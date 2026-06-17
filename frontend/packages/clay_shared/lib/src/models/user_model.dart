class UserModel {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String? username;
  final String? email;
  final String? avatarUrl;
  final String? role;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    this.username,
    this.email,
    this.avatarUrl,
    this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? '',
      username: json['username']?.toString(),
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
      'username': username,
      'email': email,
      'avatar_url': avatarUrl,
      'role': role,
    };
  }
}
