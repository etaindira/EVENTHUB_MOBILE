import 'package:dio/dio.dart';

import '../models/public_invitation_model.dart';

class PublicInvitationService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://eventhub-backend-lgpa.onrender.com/api',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  Future<PublicInvitationResponse> getInvitationByToken({
    required String previewToken,
    String? guestToken,
  }) async {
    final response = await _dio.get(
      '/invitations/public/$previewToken',
      queryParameters: {
        if (guestToken != null && guestToken.isNotEmpty) 'guest': guestToken,
      },
    );

    return PublicInvitationResponse.fromJson(response.data);
  }
}
