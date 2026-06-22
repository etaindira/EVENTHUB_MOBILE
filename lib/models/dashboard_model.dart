class DashboardEventModel {
  final int id;
  final String title;
  final String? eventType;
  final String? startTime;
  final String? venueName;
  final String? venueAddress;

  DashboardEventModel({
    required this.id,
    required this.title,
    this.eventType,
    this.startTime,
    this.venueName,
    this.venueAddress,
  });

  factory DashboardEventModel.fromJson(Map<String, dynamic> json) {
    return DashboardEventModel(
      id: json['id'],
      title: json['title'] ?? '',
      eventType: json['event_type'],
      startTime: json['start_time'],
      venueName: json['venue_name'],
      venueAddress: json['venue_address'],
    );
  }
}

class CheckinGuestModel {
  final int guestId;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? email;
  final String? checkedInAt;

  CheckinGuestModel({
    required this.guestId,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.email,
    this.checkedInAt,
  });

  factory CheckinGuestModel.fromJson(Map<String, dynamic> json) {
    return CheckinGuestModel(
      guestId: json['guest_id'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      phone: json['phone'],
      email: json['email'],
      checkedInAt: json['checked_in_at'],
    );
  }
}
