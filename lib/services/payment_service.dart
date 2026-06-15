import 'package:dio/dio.dart';

import '../core/network/api_client.dart';

class PaymentService {
  final Dio _dio = ApiClient.dio;

  Future<List<dynamic>> getPaymentEvents() async {
    final response = await _dio.get('/payments/events');
    return response.data;
  }

  Future<Map<String, dynamic>> calculatePayment({required int eventId}) async {
    try {
      final response = await _dio.post(
        '/payments/calculate',
        data: {'eventId': eventId},
      );

      return response.data;
    } on DioException catch (error) {
      throw Exception(
        error.response?.data['message'] ??
            error.response?.data['error'] ??
            error.message ??
            'Failed to calculate payment',
      );
    }
  }

  Future<Map<String, dynamic>> confirmPayment({
    required int eventId,
    required int invitationId,
    required String paymentMethod,
  }) async {
    try {
      final response = await _dio.post(
        '/payments/confirm',
        data: {
          'eventId': eventId,
          'invitationId': invitationId,
          'paymentMethod': paymentMethod,
        },
      );

      return response.data['payment'];
    } on DioException catch (error) {
      throw Exception(
        error.response?.data['message'] ??
            error.response?.data['error'] ??
            error.message ??
            'Failed to confirm payment',
      );
    }
  }

  Future<Map<String, dynamic>> getPaymentStatus({required int eventId}) async {
    final response = await _dio.get('/payments/status/$eventId');
    return response.data;
  }
}
