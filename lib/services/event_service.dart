import 'dart:io';

import 'package:dio/dio.dart';

import '../core/network/api_client.dart';

class EventService {
  final Dio _dio = ApiClient.dio;

  Future<List<dynamic>> getEvents() async {
    final response = await _dio.get('/events');
    return response.data;
  }

  Future<Map<String, dynamic>> createEvent({
    File? imageFile,
    required String title,
    required String description,
    required String eventType,
    required String startTime,
    String? endTime,
    required String venueName,
    required String venueAddress,
    int? capacity,
    required String rsvpDeadline,
    String? dressCode,
  }) async {
    try {
      final formData = FormData.fromMap({
        if (imageFile != null)
          'image': await MultipartFile.fromFile(
            imageFile.path,
            filename: imageFile.path.split('/').last,
          ),
        'title': title,
        'description': description,
        'event_type': eventType,
        'start_time': startTime,
        'end_time': endTime,
        'venue_name': venueName,
        'venue_address': venueAddress,
        'capacity': capacity,
        'rsvp_deadline': rsvpDeadline,
        'dress_code': dressCode,
      });

      final response = await _dio.post('/events', data: formData);

      return response.data;
    } on DioException catch (error) {
      final message =
          error.response?.data['message'] ??
          error.response?.data['error'] ??
          error.message ??
          'Failed to create event';

      throw Exception(message);
    }
  }
}
