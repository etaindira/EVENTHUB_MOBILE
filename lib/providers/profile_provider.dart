import 'dart:io';

import 'package:flutter/material.dart';

import '../models/profile_model.dart';
import '../repositories/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _profileRepository = ProfileRepository();

  ProfileModel? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  ProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchProfile() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _profile = await _profileRepository.getMyProfile();

      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<bool> updateProfileInfo({
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _profile = await _profileRepository.updateProfileInfo(
        firstName: firstName,
        lastName: lastName,
        email: email,
      );

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (error) {
      _isLoading = false;
      _errorMessage = error.toString();
      notifyListeners();

      return false;
    }
  }

  Future<bool> updatePhoneNumber({required String phone}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _profile = await _profileRepository.updatePhoneNumber(phone: phone);

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (error) {
      _isLoading = false;
      _errorMessage = error.toString();
      notifyListeners();

      return false;
    }
  }

  Future<bool> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _profileRepository.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (error) {
      _isLoading = false;
      _errorMessage = error.toString();
      notifyListeners();

      return false;
    }
  }

  Future<bool> uploadProfileImage({required File imageFile}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _profile = await _profileRepository.uploadProfileImage(
        imageFile: imageFile,
      );

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (error) {
      _isLoading = false;
      _errorMessage = error.toString();
      notifyListeners();

      return false;
    }
  }

  Future<bool> deleteProfileImage() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _profile = await _profileRepository.deleteProfileImage();

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (error) {
      _isLoading = false;
      _errorMessage = error.toString();
      notifyListeners();

      return false;
    }
  }
}
