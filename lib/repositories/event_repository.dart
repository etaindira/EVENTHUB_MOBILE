import 'dart:io';

import '../models/event_model.dart';
import '../services/event_service.dart';

class EventRepository {
  final EventService _eventService = EventService();

  Future<List<EventModel>> getEvents() async {
    final data = await _eventService.getEvents();

    return data.map((eventJson) {
      return EventModel.fromJson(eventJson);
    }).toList();
  }

  Future<EventModel> createEvent({
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
    final data = await _eventService.createEvent(
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

    return EventModel.fromJson(data);
  }

  Future<EventModel> updateEvent({
    required int eventId,
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
    final data = await _eventService.updateEvent(
      eventId: eventId,
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

    return EventModel.fromJson(data);
  }

  Future<void> deleteEvent(int eventId) async {
    await _eventService.deleteEvent(eventId);
  }
}
