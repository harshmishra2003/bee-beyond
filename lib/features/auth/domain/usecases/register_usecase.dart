import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;
  RegisterUseCase(this.repository);

  Future<UserEntity> call(String name, String email, String phone, String password) async {
    return await repository.register(name, email, phone, password);
  }
}
