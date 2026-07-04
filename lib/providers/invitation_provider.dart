import 'package:flutter/material.dart';

import '../models/invitation_model.dart';
import '../repositories/invitation_repository.dart';

class InvitationProvider extends ChangeNotifier {
  final InvitationRepository _invitationRepository = InvitationRepository();

  List<InvitationModel> _invitations = [];
  List<dynamic> _generatedTemplates = [];

  bool _isLoading = false;
  bool _isGeneratingTemplates = false;

  String? _errorMessage;

  List<InvitationModel> get invitations => _invitations;
  List<dynamic> get generatedTemplates => _generatedTemplates;

  bool get isLoading => _isLoading;
  bool get isGeneratingTemplates => _isGeneratingTemplates;

  String? get errorMessage => _errorMessage;

  InvitationModel? get latestInvitation {
    if (_invitations.isEmpty) return null;
    return _invitations.first;
  }

  Future<void> fetchInvitationsByEvent(int eventId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _invitations = await _invitationRepository.getInvitationsByEvent(eventId);

      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<bool> generateAiTemplates({
    required int eventId,
    required String mood,
    required String colors,
    required String tone,
    String extraMessage = '',
  }) async {
    try {
      _isGeneratingTemplates = true;
      _errorMessage = null;
      notifyListeners();

      _generatedTemplates = await _invitationRepository.generateAiTemplates(
        eventId: eventId,
        mood: mood,
        colors: colors,
        tone: tone,
        extraMessage: extraMessage,
      );

      _isGeneratingTemplates = false;
      notifyListeners();

      return true;
    } catch (error) {
      _isGeneratingTemplates = false;
      _errorMessage = error.toString();
      notifyListeners();

      return false;
    }
  }

  void clearGeneratedTemplates() {
    _generatedTemplates.clear();
    notifyListeners();
  }

  Future<bool> saveInvitation({
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
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final invitation = await _invitationRepository.saveInvitation(
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

      _invitations.insert(0, invitation);

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (error) {
      _isLoading = false;
      _errorMessage = error.toString();
      notifyListeners();

      return false;
    }
  }

  Future<bool> updateInvitation({
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
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final updatedInvitation = await _invitationRepository.updateInvitation(
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

      final index = _invitations.indexWhere(
        (invitation) => invitation.id == invitationId,
      );

      if (index != -1) {
        _invitations[index] = updatedInvitation;
      }

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (error) {
      _isLoading = false;
      _errorMessage = error.toString();
      notifyListeners();

      return false;
    }
  }

  Future<bool> deleteInvitation(int invitationId) async {
    try {
      await _invitationRepository.deleteInvitation(invitationId);

      _invitations.removeWhere((invitation) => invitation.id == invitationId);

      notifyListeners();

      return true;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();

      return false;
    }
  }

  Future<bool> sendInvitationToGuests({
    required int eventId,
    required int invitationId,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _invitationRepository.sendInvitationToGuests(
        eventId: eventId,
        invitationId: invitationId,
      );

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (error) {
      _isLoading = false;
      _errorMessage = error.toString();
      notifyListeners();

      return false;
    }
  }
}
