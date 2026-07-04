import '../models/public_rsvp_model.dart';
import '../services/public_rsvp_service.dart';

class PublicRsvpRepository {
  final PublicRsvpService _service = PublicRsvpService();

  Future<PublicRsvpModel> getRsvpForm({required String token}) async {
    final data = await _service.getRsvpForm(token: token);
    return PublicRsvpModel.fromJson(data);
  }

  Future<Map<String, dynamic>> submitRsvp({
    required String token,
    required String response,

    // Whether guest is bringing extra guests
    required bool plusOne,

    // Number of additional guests
    required int plusOneCount,

    String? note,
  }) async {
    return await _service.submitRsvp(
      token: token,
      response: response,
      plusOne: plusOne,
      plusOneCount: plusOneCount,
      note: note,
    );
  }
}
