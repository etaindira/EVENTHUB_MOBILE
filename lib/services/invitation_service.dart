import 'package:dio/dio.dart';

import '../core/network/api_client.dart';

class InvitationService {
  final Dio _dio = ApiClient.dio;

  Future<List<dynamic>> getInvitationsByEvent(int eventId) async {
    final response = await _dio.get('/events/$eventId/invitations');
    return response.data;
  }

  Future<List<dynamic>> generateAiTemplates({
    required int eventId,
    required String mood,
    required String colors,
    required String tone,
    String extraMessage = '',
  }) async {
    try {
      final response = await _dio.post(
        '/events/$eventId/invitations/generate-ai',
        data: {
          'mood': mood,
          'colors': colors,
          'tone': tone,
          'extra_message': extraMessage,
        },
      );

      return response.data['templates'];
    } on DioException catch (error) {
      throw Exception(
        error.response?.data['message'] ??
            error.response?.data['error'] ??
            error.message ??
            'Failed to generate invitation templates',
      );
    }
  }

  Future<Map<String, dynamic>> saveInvitation({
    required int eventId,
    required String title,
    required String message,
    required String invitationTemplate,
    required String theme,
    required String colorPalette,
    required String fontStyle,
    dynamic templateData,
    String status = 'draft',
    bool allowPlusOne = false,
    int maxPlusOnes = 0,
    String rsvpFormTitle = 'RSVP Confirmation',
    String rsvpFormMessage = 'Please confirm whether you will attend.',
  }) async {
    try {
      final response = await _dio.post(
        '/events/$eventId/invitations',
        data: {
          'title': title,
          'message': message,
          'invitation_template': invitationTemplate,
          'theme': theme,
          'color_palette': colorPalette,
          'font_style': fontStyle,
          'template_data': templateData ?? {},
          'status': status,
          'allow_plus_one': allowPlusOne,
          'max_plus_ones': allowPlusOne ? maxPlusOnes : 0,
          'rsvp_form_title': rsvpFormTitle,
          'rsvp_form_message': rsvpFormMessage,
        },
      );

      return response.data['invitation'];
    } on DioException catch (error) {
      throw Exception(
        error.response?.data['message'] ??
            error.response?.data['error'] ??
            error.message ??
            'Failed to save invitation',
      );
    }
  }

  Future<Map<String, dynamic>> updateInvitation({
    required int invitationId,
    required String title,
    required String message,
    required String invitationTemplate,
    required String theme,
    required String colorPalette,
    required String fontStyle,
    dynamic templateData,
    String status = 'draft',
    bool allowPlusOne = false,
    int maxPlusOnes = 0,
    String rsvpFormTitle = 'RSVP Confirmation',
    String rsvpFormMessage = 'Please confirm whether you will attend.',
  }) async {
    try {
      final response = await _dio.put(
        '/invitations/$invitationId',
        data: {
          'title': title,
          'message': message,
          'invitation_template': invitationTemplate,
          'theme': theme,
          'color_palette': colorPalette,
          'font_style': fontStyle,
          'template_data': templateData ?? {},
          'status': status,
          'allow_plus_one': allowPlusOne,
          'max_plus_ones': allowPlusOne ? maxPlusOnes : 0,
          'rsvp_form_title': rsvpFormTitle,
          'rsvp_form_message': rsvpFormMessage,
        },
      );

      return response.data['invitation'];
    } on DioException catch (error) {
      throw Exception(
        error.response?.data['message'] ??
            error.response?.data['error'] ??
            error.message ??
            'Failed to update invitation',
      );
    }
  }

  Future<void> deleteInvitation(int invitationId) async {
    try {
      await _dio.delete('/invitations/$invitationId');
    } on DioException catch (error) {
      throw Exception(
        error.response?.data['message'] ??
            error.response?.data['error'] ??
            error.message ??
            'Failed to delete invitation',
      );
    }
  }

  Future<Map<String, dynamic>> sendInvitationToGuests({
    required int eventId,
    required int invitationId,
  }) async {
    try {
      final response = await _dio.post(
        '/events/$eventId/invitations/$invitationId/send',
      );

      return response.data;
    } on DioException catch (error) {
      throw Exception(
        error.response?.data['message'] ??
            error.response?.data['error'] ??
            error.message ??
            'Failed to send invitation',
      );
    }
  }
}
