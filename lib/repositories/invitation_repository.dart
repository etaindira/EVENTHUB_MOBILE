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

  Future<List<dynamic>> generateAiTemplates({
    required int eventId,
    required String mood,
    required String colors,
    required String tone,
    String extraMessage = '',
  }) async {
    return await _invitationService.generateAiTemplates(
      eventId: eventId,
      mood: mood,
      colors: colors,
      tone: tone,
      extraMessage: extraMessage,
    );
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
    bool allowPlusOne = false,
    int maxPlusOnes = 0,
    String rsvpFormTitle = 'RSVP Confirmation',
    String rsvpFormMessage = 'Please confirm whether you will attend.',
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
      allowPlusOne: allowPlusOne,
      maxPlusOnes: maxPlusOnes,
      rsvpFormTitle: rsvpFormTitle,
      rsvpFormMessage: rsvpFormMessage,
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
    bool allowPlusOne = false,
    int maxPlusOnes = 0,
    String rsvpFormTitle = 'RSVP Confirmation',
    String rsvpFormMessage = 'Please confirm whether you will attend.',
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
      allowPlusOne: allowPlusOne,
      maxPlusOnes: maxPlusOnes,
      rsvpFormTitle: rsvpFormTitle,
      rsvpFormMessage: rsvpFormMessage,
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
