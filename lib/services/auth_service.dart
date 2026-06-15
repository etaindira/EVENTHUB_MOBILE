import 'package:dio/dio.dart';
import '../core/network/api_client.dart';

class AuthService {
  final Dio _dio = ApiClient.dio;

  Future<Map<String, dynamic>> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/signup',
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'phone': phone,
          'password': password,
          'confirm_password': confirmPassword,
        },
      );

      return response.data;
    } on DioException catch (error) {
      final message =
          error.response?.data['message'] ??
          error.response?.data['error'] ??
          error.message ??
          'Signup failed';

      throw Exception(message);
    }
  }

  Future<Map<String, dynamic>> verifyCode({
    required String email,
    required String code,
  }) async {
    final response = await _dio.post(
      '/auth/verify-code',
      data: {'email': email, 'code': code},
    );

    return response.data;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );

    return response.data;
  }

  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    try {
      final response = await _dio.post(
        '/auth/forgot-password',
        data: {'email': email},
      );

      return response.data;
    } on DioException catch (error) {
      final message =
          error.response?.data['message'] ??
          error.response?.data['error'] ??
          error.message ??
          'Forgot password failed';

      throw Exception(message);
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String code,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/reset-password',
        data: {
          'email': email,
          'code': code,
          'password': password,
          'confirm_password': confirmPassword,
        },
      );

      return response.data;
    } on DioException catch (error) {
      final message =
          error.response?.data['message'] ??
          error.response?.data['error'] ??
          error.message ??
          'Reset password failed';

      throw Exception(message);
    }
  }
}
