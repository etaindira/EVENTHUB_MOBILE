import 'dart:io';

import '../models/profile_model.dart';
import '../services/profile_service.dart';

class ProfileRepository {
  final ProfileService _profileService = ProfileService();

  Future<ProfileModel> getMyProfile() async {
    final data = await _profileService.getMyProfile();
    return ProfileModel.fromJson(data);
  }

  Future<ProfileModel> updateProfileInfo({
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    final data = await _profileService.updateProfileInfo(
      firstName: firstName,
      lastName: lastName,
      email: email,
    );

    return ProfileModel.fromJson(data);
  }

  Future<ProfileModel> updatePhoneNumber({required String phone}) async {
    final data = await _profileService.updatePhoneNumber(phone: phone);
    return ProfileModel.fromJson(data);
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await _profileService.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }

  Future<ProfileModel> uploadProfileImage({required File imageFile}) async {
    final data = await _profileService.uploadProfileImage(imageFile: imageFile);

    return ProfileModel.fromJson(data);
  }

  Future<ProfileModel> deleteProfileImage() async {
    final data = await _profileService.deleteProfileImage();
    return ProfileModel.fromJson(data);
  }
}
