class GuestModel {
  final int id;
  final int eventId;
  final String firstName;
  final String lastName;
  final String phone;
  final String? email;

  GuestModel({
    required this.id,
    required this.eventId,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.email,
  });

  factory GuestModel.fromJson(Map<String, dynamic> json) {
    return GuestModel(
      id: json['id'],
      eventId: json['event_id'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
    );
  }
}
