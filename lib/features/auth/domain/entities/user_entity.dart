import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String studentId;
  final String? avatarUrl;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.studentId,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, name, email, phone, studentId, avatarUrl];
}
