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
      final formData = await _buildEventFormData(
        imageFile: imageFile,
        title: title,
        description: description,
        eventType: eventType,
        startTime: startTime,
        endTime: endTime,
        venueName: venueName,
        venueAddress: venueAddress,
        capacity: capacity,
        rsvpDeadline: rsvpDeadline,
        dressCode: dressCode,
      );

      final response = await _dio.post('/events', data: formData);

      return response.data;
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error, 'Failed to create event'));
    }
  }

  Future<Map<String, dynamic>> updateEvent({
    required int eventId,
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
      final formData = await _buildEventFormData(
        imageFile: imageFile,
        title: title,
        description: description,
        eventType: eventType,
        startTime: startTime,
        endTime: endTime,
        venueName: venueName,
        venueAddress: venueAddress,
        capacity: capacity,
        rsvpDeadline: rsvpDeadline,
        dressCode: dressCode,
      );

      final response = await _dio.put('/events/$eventId', data: formData);

      return response.data;
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error, 'Failed to update event'));
    }
  }

  Future<void> deleteEvent(int eventId) async {
    try {
      await _dio.delete('/events/$eventId');
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error, 'Failed to delete event'));
    }
  }

  Future<FormData> _buildEventFormData({
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
    return FormData.fromMap({
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
  }

  String _extractErrorMessage(DioException error, String fallback) {
    return error.response?.data['message'] ??
        error.response?.data['error'] ??
        error.message ??
        fallback;
  }
}
