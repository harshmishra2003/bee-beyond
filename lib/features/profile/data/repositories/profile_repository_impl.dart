import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_ds.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<ProfileEntity> getProfile() async {
    return await remoteDataSource.getProfile();
  }

  @override
  Future<ProfileEntity> updateProfile(ProfileEntity profile) async {
    final model = ProfileModel(
      name: profile.name,
      email: profile.email,
      phone: profile.phone,
      studentId: profile.studentId,
      avatarUrl: profile.avatarUrl,
    );
    return await remoteDataSource.updateProfile(model);
  }

  @override
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    return await remoteDataSource.changePassword(currentPassword, newPassword);
  }
}
