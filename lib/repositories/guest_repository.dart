import '../models/guest_model.dart';
import '../services/guest_service.dart';

class GuestRepository {
  final GuestService _guestService = GuestService();

  Future<List<GuestModel>> getGuestsByEvent(int eventId) async {
    final data = await _guestService.getGuestsByEvent(eventId);

    return data.map((json) {
      return GuestModel.fromJson(json);
    }).toList();
  }

  Future<GuestModel> addGuest({
    required int eventId,
    required String firstName,
    required String lastName,
    required String phone,
    String? email,
  }) async {
    final data = await _guestService.addGuest(
      eventId: eventId,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      email: email,
    );

    return GuestModel.fromJson(data);
  }

  Future<GuestModel> updateGuest({
    required int guestId,
    required String firstName,
    required String lastName,
    required String phone,
    String? email,
  }) async {
    final data = await _guestService.updateGuest(
      guestId: guestId,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      email: email,
    );

    return GuestModel.fromJson(data);
  }

  Future<void> deleteGuest(int guestId) async {
    await _guestService.deleteGuest(guestId);
  }
}
