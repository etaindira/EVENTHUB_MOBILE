import 'package:dio/dio.dart';

import '../core/network/api_client.dart';

class PublicRsvpService {
  final Dio _dio = ApiClient.dio;

  Future<Map<String, dynamic>> getRsvpForm({required String token}) async {
    final response = await _dio.get('/rsvp/form/$token');
    return response.data;
  }

  Future<Map<String, dynamic>> submitRsvp({
    required String token,
    required String response,
    required bool plusOne,
    required int plusOneCount,
    String? note,
  }) async {
    final result = await _dio.post(
      '/rsvp/form/$token',
      data: {
        'response': response,
        'additional_guests': plusOne ? plusOneCount : 0,
        'note': note,
      },
    );

    return result.data;
  }
}
