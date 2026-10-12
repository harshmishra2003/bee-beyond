import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String name;
  final String email;
  final String phone;
  final String studentId;
  final String? avatarUrl;

  const ProfileEntity({
    required this.name,
    required this.email,
    required this.phone,
    required this.studentId,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [name, email, phone, studentId, avatarUrl];
}
