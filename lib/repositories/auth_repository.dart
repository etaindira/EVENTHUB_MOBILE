import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _authService = AuthService();

  Future<void> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    await _authService.signup(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      password: password,
      confirmPassword: confirmPassword,
    );
  }

  Future<void> verifyCode({required String email, required String code}) async {
    await _authService.verifyCode(email: email, code: code);
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final data = await _authService.login(email: email, password: password);

    final token = data['token'];
    final userJson = data['user'];

    if (token == null || userJson == null) {
      throw Exception('Invalid login response from server');
    }

    return AuthResult(token: token, user: UserModel.fromJson(userJson));
  }

  Future<void> forgotPassword({required String email}) async {
    await _authService.forgotPassword(email: email);
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
    required String confirmPassword,
  }) async {
    await _authService.resetPassword(
      email: email,
      code: code,
      password: password,
      confirmPassword: confirmPassword,
    );
  }
}

class AuthResult {
  final String token;
  final UserModel user;

  AuthResult({required this.token, required this.user});
}
