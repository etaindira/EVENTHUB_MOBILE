import 'dart:io';

import 'package:dio/dio.dart';

import '../core/network/api_client.dart';

class ProfileService {
  final Dio _dio = ApiClient.dio;

  Future<Map<String, dynamic>> getMyProfile() async {
    final response = await _dio.get('/users/me');
    return response.data['user'];
  }

  Future<Map<String, dynamic>> updateProfileInfo({
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    final response = await _dio.put(
      '/users/me',
      data: {'first_name': firstName, 'last_name': lastName, 'email': email},
    );

    return response.data['user'];
  }

  Future<Map<String, dynamic>> updatePhoneNumber({
    required String phone,
  }) async {
    final response = await _dio.put('/users/me/phone', data: {'phone': phone});

    return response.data['user'];
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await _dio.put(
      '/users/me/password',
      data: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      },
    );
  }

  Future<Map<String, dynamic>> uploadProfileImage({
    required File imageFile,
  }) async {
    final formData = FormData.fromMap({
      'profile_image': await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.path.split('/').last,
      ),
    });

    final response = await _dio.post('/users/me/profile-image', data: formData);

    return response.data['user'];
  }

  Future<Map<String, dynamic>> deleteProfileImage() async {
    final response = await _dio.delete('/users/me/profile-image');
    return response.data['user'];
  }
}
