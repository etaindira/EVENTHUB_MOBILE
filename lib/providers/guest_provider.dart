import 'package:flutter/material.dart';

import '../models/guest_model.dart';
import '../repositories/guest_repository.dart';

class GuestProvider extends ChangeNotifier {
  final GuestRepository _guestRepository = GuestRepository();

  List<GuestModel> _guests = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<GuestModel> get guests => _guests;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchGuests(int eventId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _guests = await _guestRepository.getGuestsByEvent(eventId);

      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<bool> addGuest({
    required int eventId,
    required String firstName,
    required String lastName,
    required String phone,
    String? email,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final newGuest = await _guestRepository.addGuest(
        eventId: eventId,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        email: email,
      );

      _guests.insert(0, newGuest);

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

  Future<bool> updateGuest({
    required int guestId,
    required String firstName,
    required String lastName,
    required String phone,
    String? email,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final updatedGuest = await _guestRepository.updateGuest(
        guestId: guestId,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        email: email,
      );

      final index = _guests.indexWhere((guest) => guest.id == guestId);

      if (index != -1) {
        _guests[index] = updatedGuest;
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

  Future<bool> deleteGuest(int guestId) async {
    try {
      await _guestRepository.deleteGuest(guestId);

      _guests.removeWhere((guest) => guest.id == guestId);
      notifyListeners();

      return true;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();

      return false;
    }
  }
}
