import 'package:flutter/material.dart';

import '../models/public_rsvp_model.dart';
import '../repositories/public_rsvp_repository.dart';

class PublicRsvpProvider extends ChangeNotifier {
  final PublicRsvpRepository _repository = PublicRsvpRepository();

  PublicRsvpModel? _rsvpData;
  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _submitted = false;
  String? _errorMessage;

  PublicRsvpModel? get rsvpData => _rsvpData;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  bool get submitted => _submitted;
  String? get errorMessage => _errorMessage;

  Future<void> fetchRsvpForm(String token) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _rsvpData = await _repository.getRsvpForm(token: token);

      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<bool> submitRsvp({
    required String token,
    required String response,
    required bool plusOne,
    required int plusOneCount,
    String? note,
  }) async {
    try {
      _isSubmitting = true;
      _errorMessage = null;
      notifyListeners();

      await _repository.submitRsvp(
        token: token,
        response: response,
        plusOne: plusOne,
        plusOneCount: plusOneCount,
        note: note,
      );

      _submitted = true;
      _isSubmitting = false;
      notifyListeners();

      return true;
    } catch (error) {
      _isSubmitting = false;
      _errorMessage = error.toString();
      notifyListeners();

      return false;
    }
  }
}
