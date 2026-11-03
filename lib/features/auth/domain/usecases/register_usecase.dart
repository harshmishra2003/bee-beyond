import 'package:bee_beeyond/features/auth/domain/entities/user_entity.dart';
import 'package:bee_beeyond/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<UserEntity> call({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? dob,
    String? gender,
  }) async {
    return await repository.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
      dob: dob,
      gender: gender,
    );
  }
}
