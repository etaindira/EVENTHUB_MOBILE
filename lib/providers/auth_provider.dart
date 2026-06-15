import 'package:flutter/material.dart';
import '../core/storage/secure_storage_service.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isLoggedIn = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _isLoggedIn;

  Future<bool> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authRepository.signup(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        password: password,
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

  Future<bool> verifyCode({required String email, required String code}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authRepository.verifyCode(email: email, code: code);

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (error) {
      _isLoading = false;
      _errorMessage = 'Verification failed. Please check your code.';
      notifyListeners();

      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _authRepository.login(
        email: email,
        password: password,
      );

      await SecureStorageService.saveToken(result.token);
      await SecureStorageService.saveUserId(result.user.id.toString());

      _user = result.user;
      _isLoggedIn = true;

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (error) {
      _isLoading = false;
      _errorMessage = 'Login failed. Please check your email and password.';
      notifyListeners();

      return false;
    }
  }

  Future<void> checkLoginStatus() async {
    final token = await SecureStorageService.getToken();

    if (token != null && token.isNotEmpty) {
      _isLoggedIn = true;
    } else {
      _isLoggedIn = false;
    }

    notifyListeners();
  }

  Future<bool> forgotPassword({required String email}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authRepository.forgotPassword(email: email);

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

  Future<bool> resetPassword({
    required String email,
    required String code,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authRepository.resetPassword(
        email: email,
        code: code,
        password: password,
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

  Future<void> logout() async {
    await SecureStorageService.clearStorage();

    _user = null;
    _isLoggedIn = false;
    _errorMessage = null;

    notifyListeners();
  }
}
