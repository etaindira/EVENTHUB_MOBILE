import 'package:dio/dio.dart';
import '../core/network/api_client.dart';

class PublicInvitationService {
  final Dio _dio = ApiClient.dio;

  Future<Map<String, dynamic>> getPublicInvitation(String previewToken) async {
    final response = await _dio.get('/invite/$previewToken');
    return response.data;
  }
}
