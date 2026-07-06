class EventModel {
  final int id;
  final int? userId;
  final String? imageUrl;
  final String title;
  final String description;
  final String eventType;
  final String startTime;
  final String? endTime;
  final String venueName;
  final String venueAddress;
  final int? capacity;
  final String rsvpDeadline;
  final String? dressCode;
  final String? status;
  final String? scannerCode;

  EventModel({
    required this.id,
    this.userId,
    this.imageUrl,
    required this.title,
    required this.description,
    required this.eventType,
    required this.startTime,
    this.endTime,
    required this.venueName,
    required this.venueAddress,
    this.capacity,
    required this.rsvpDeadline,
    this.dressCode,
    this.status,
    this.scannerCode,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      userId: json['user_id'],
      imageUrl: json['image_url'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      eventType: json['event_type'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'],
      venueName: json['venue_name'] ?? '',
      venueAddress: json['venue_address'] ?? '',
      capacity: json['capacity'],
      rsvpDeadline: json['rsvp_deadline'] ?? '',
      dressCode: json['dress_code'],
      status: json['status'],
      scannerCode: json['scanner_code'],
    );
  }
}
