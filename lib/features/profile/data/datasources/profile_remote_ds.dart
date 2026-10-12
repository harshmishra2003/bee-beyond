import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();
  Future<ProfileModel> updateProfile(ProfileModel model);
  Future<bool> changePassword(String currentPassword, String newPassword);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  @override
  Future<ProfileModel> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const ProfileModel(
      name: 'Aarav Sharma',
      email: 'aarav.sharma@example.com',
      phone: '+91 98765 43210',
      studentId: 'BEYOND-2025-884',
    );
  }

  @override
  Future<ProfileModel> updateProfile(ProfileModel model) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return model;
  }

  @override
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }
}
