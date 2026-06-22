import 'package:dio/dio.dart';

import '../core/network/api_client.dart';

class DashboardService {
  final Dio _dio = ApiClient.dio;

  Future<List<dynamic>> getDashboardEvents() async {
    final response = await _dio.get('/dashboard/events');
    return response.data['events'];
  }

  Future<Map<String, dynamic>> getEventAnalytics(int eventId) async {
    final response = await _dio.get('/dashboard/events/$eventId/analytics');
    return response.data;
  }

  Future<List<dynamic>> getEventCheckins(int eventId) async {
    final response = await _dio.get('/dashboard/events/$eventId/checkins');
    return response.data['checkins'];
  }

  Future<Map<String, dynamic>> getDashboardSummary() async {
    final response = await _dio.get('/dashboard/summary');
    return response.data;
  }
}
