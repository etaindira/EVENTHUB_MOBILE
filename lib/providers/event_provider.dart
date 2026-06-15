import 'dart:io';

import 'package:flutter/material.dart';

import '../models/event_model.dart';
import '../repositories/event_repository.dart';

class EventProvider extends ChangeNotifier {
  final EventRepository _eventRepository = EventRepository();

  List<EventModel> _events = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<EventModel> get events => _events;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchEvents() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _events = await _eventRepository.getEvents();

      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<bool> createEvent({
    File? imageFile,
    required String title,
    required String description,
    required String eventType,
    required String startTime,
    String? endTime,
    required String venueName,
    required String venueAddress,
    int? capacity,
    required String rsvpDeadline,
    String? dressCode,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final newEvent = await _eventRepository.createEvent(
        imageFile: imageFile,
        title: title,
        description: description,
        eventType: eventType,
        startTime: startTime,
        endTime: endTime,
        venueName: venueName,
        venueAddress: venueAddress,
        capacity: capacity,
        rsvpDeadline: rsvpDeadline,
        dressCode: dressCode,
      );

      _events.insert(0, newEvent);

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
