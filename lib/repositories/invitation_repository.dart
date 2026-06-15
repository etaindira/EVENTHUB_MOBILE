import '../models/invitation_model.dart';
import '../services/invitation_service.dart';

class InvitationRepository {
  final InvitationService _invitationService = InvitationService();

  Future<List<InvitationModel>> getInvitationsByEvent(int eventId) async {
    final data = await _invitationService.getInvitationsByEvent(eventId);

    return data.map((json) {
      return InvitationModel.fromJson(json);
    }).toList();
  }

  Future<InvitationModel> saveInvitation({
    required int eventId,
    required String title,
    required String message,
    required String invitationTemplate,
    required String theme,
    required String colorPalette,
    required String fontStyle,
    dynamic templateData,
    String status = 'draft',
  }) async {
    final data = await _invitationService.saveInvitation(
      eventId: eventId,
      title: title,
      message: message,
      invitationTemplate: invitationTemplate,
      theme: theme,
      colorPalette: colorPalette,
      fontStyle: fontStyle,
      templateData: templateData,
      status: status,
    );

    return InvitationModel.fromJson(data);
  }

  Future<InvitationModel> updateInvitation({
    required int invitationId,
    required String title,
    required String message,
    required String invitationTemplate,
    required String theme,
    required String colorPalette,
    required String fontStyle,
    dynamic templateData,
    String status = 'draft',
  }) async {
    final data = await _invitationService.updateInvitation(
      invitationId: invitationId,
      title: title,
      message: message,
      invitationTemplate: invitationTemplate,
      theme: theme,
      colorPalette: colorPalette,
      fontStyle: fontStyle,
      templateData: templateData,
      status: status,
    );

    return InvitationModel.fromJson(data);
  }

  Future<void> deleteInvitation(int invitationId) async {
    await _invitationService.deleteInvitation(invitationId);
  }

  Future<Map<String, dynamic>> sendInvitationToGuests({
    required int eventId,
    required int invitationId,
  }) async {
    return await _invitationService.sendInvitationToGuests(
      eventId: eventId,
      invitationId: invitationId,
    );
  }
}
