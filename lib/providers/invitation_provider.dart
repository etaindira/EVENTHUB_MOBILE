import 'package:flutter/material.dart';

import '../models/invitation_model.dart';
import '../repositories/invitation_repository.dart';

class InvitationProvider extends ChangeNotifier {
  final InvitationRepository _invitationRepository = InvitationRepository();

  List<InvitationModel> _invitations = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<InvitationModel> get invitations => _invitations;
  bool get isLoading => _isLoading;
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

    // NEW RSVP SETTINGS
    bool allowPlusOne = false,
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

    // NEW RSVP SETTINGS
    bool allowPlusOne = false,
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
