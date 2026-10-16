import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.studentId,
    super.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handling nested user structures just in case
    final userData = json['user'] ?? json;

    return UserModel(
      id: userData['id']?.toString() ?? '',
      name: userData['name']?.toString() ?? '',
      email: userData['email']?.toString() ?? '',
      phone: userData['phone']?.toString() ?? '',
      studentId: userData['student_id']?.toString() ?? 'BB-1001',
      avatarUrl: userData['avatar_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'student_id': studentId,
      'avatar_url': avatarUrl,
    };
  }
}
