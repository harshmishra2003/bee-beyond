import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.name,
    required super.email,
    required super.phone,
    required super.studentId,
    super.avatarUrl,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      studentId: json['student_id'] ?? 'BEYOND-2025-884',
      avatarUrl: json['avatar_url'],
    );
  }
}
