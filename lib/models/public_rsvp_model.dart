class PublicRsvpModel {
  final PublicGuest guest;
  final PublicEvent event;
  final PublicInvitation invitation;
  final PublicRsvpSettings rsvpSettings;
  final bool alreadySubmitted;

  PublicRsvpModel({
    required this.guest,
    required this.event,
    required this.invitation,
    required this.rsvpSettings,
    required this.alreadySubmitted,
  });

  factory PublicRsvpModel.fromJson(Map<String, dynamic> json) {
    return PublicRsvpModel(
      guest: PublicGuest.fromJson(json['guest']),
      event: PublicEvent.fromJson(json['event']),
      invitation: PublicInvitation.fromJson(json['invitation']),
      rsvpSettings: PublicRsvpSettings.fromJson(json['rsvpSettings']),
      alreadySubmitted: json['alreadySubmitted'] ?? false,
    );
  }
}

class PublicGuest {
  final int id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;

  PublicGuest({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
  });

  factory PublicGuest.fromJson(Map<String, dynamic> json) {
    return PublicGuest(
      id: json['id'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'],
      phone: json['phone'],
    );
  }
}

class PublicEvent {
  final int id;
  final String title;
  final String description;
  final String? startTime;
  final String? endTime;
  final String? venueName;
  final String? venueAddress;
  final String? dressCode;
  final String? rsvpDeadline;

  PublicEvent({
    required this.id,
    required this.title,
    required this.description,
    this.startTime,
    this.endTime,
    this.venueName,
    this.venueAddress,
    this.dressCode,
    this.rsvpDeadline,
  });

  factory PublicEvent.fromJson(Map<String, dynamic> json) {
    return PublicEvent(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startTime: json['start_time'],
      endTime: json['end_time'],
      venueName: json['venue_name'],
      venueAddress: json['venue_address'],
      dressCode: json['dress_code'],
      rsvpDeadline: json['rsvp_deadline'],
    );
  }
}

class PublicInvitation {
  final int id;
  final String title;
  final String message;
  final String? invitationTemplate;

  PublicInvitation({
    required this.id,
    required this.title,
    required this.message,
    this.invitationTemplate,
  });

  factory PublicInvitation.fromJson(Map<String, dynamic> json) {
    return PublicInvitation(
      id: json['id'],
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      invitationTemplate: json['invitation_template'],
    );
  }
}

class PublicRsvpSettings {
  final bool allowPlusOne;
  final String rsvpFormTitle;
  final String rsvpFormMessage;

  PublicRsvpSettings({
    required this.allowPlusOne,
    required this.rsvpFormTitle,
    required this.rsvpFormMessage,
  });

  factory PublicRsvpSettings.fromJson(Map<String, dynamic> json) {
    return PublicRsvpSettings(
      allowPlusOne: json['allow_plus_one'] ?? false,
      rsvpFormTitle: json['rsvp_form_title'] ?? 'RSVP Confirmation',
      rsvpFormMessage:
          json['rsvp_form_message'] ??
          'Please confirm whether you will attend.',
    );
  }
}
