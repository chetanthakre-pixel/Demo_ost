// lib/models/user.dart
import 'enums.dart';

class User {
  final String userId;
  final String name;
  final String email;
  final String? phone;
  final Role role;
  final String? departmentId;

  User({
    required this.userId,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.departmentId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      role: Role.fromJson(json['role'] as String),
      departmentId: json['department_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.value,
      'department_id': departmentId,
    };
  }
}
