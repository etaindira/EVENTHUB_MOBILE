import 'package:dio/dio.dart';

import '../core/network/api_client.dart';

class GuestService {
  final Dio _dio = ApiClient.dio;

  Future<List<dynamic>> getGuestsByEvent(int eventId) async {
    try {
      final response = await _dio.get('/events/$eventId/guests');
      return response.data;
    } on DioException catch (error) {
      throw Exception(
        error.response?.data['message'] ??
            error.response?.data['error'] ??
            error.message ??
            'Failed to load guests',
      );
    }
  }

  Future<Map<String, dynamic>> addGuest({
    required int eventId,
    required String firstName,
    required String lastName,
    required String phone,
    String? email,
  }) async {
    try {
      final response = await _dio.post(
        '/events/$eventId/guests',
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
          'email': email,
        },
      );

      return response.data['guest'];
    } on DioException catch (error) {
      throw Exception(
        error.response?.data['message'] ??
            error.response?.data['error'] ??
            error.message ??
            'Failed to add guest',
      );
    }
  }

  Future<Map<String, dynamic>> updateGuest({
    required int guestId,
    required String firstName,
    required String lastName,
    required String phone,
    String? email,
  }) async {
    try {
      final response = await _dio.put(
        '/guests/$guestId',
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
          'email': email,
        },
      );

      return response.data['guest'];
    } on DioException catch (error) {
      throw Exception(
        error.response?.data['message'] ??
            error.response?.data['error'] ??
            error.message ??
            'Failed to update guest',
      );
    }
  }

  Future<void> deleteGuest(int guestId) async {
    try {
      await _dio.delete('/guests/$guestId');
    } on DioException catch (error) {
      throw Exception(
        error.response?.data['message'] ??
            error.response?.data['error'] ??
            error.message ??
            'Failed to delete guest',
      );
    }
  }
}
