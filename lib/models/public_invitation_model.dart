class PublicInvitationResponse {
  final String? guestToken;
  final PublicInvitation invitation;
  final PublicEvent event;
  final PublicOrganizer organizer;

  PublicInvitationResponse({
    this.guestToken,
    required this.invitation,
    required this.event,
    required this.organizer,
  });

  factory PublicInvitationResponse.fromJson(Map<String, dynamic> json) {
    return PublicInvitationResponse(
      guestToken: json['guestToken'],
      invitation: PublicInvitation.fromJson(json['invitation']),
      event: PublicEvent.fromJson(json['event']),
      organizer: PublicOrganizer.fromJson(json['organizer']),
    );
  }
}

class PublicInvitation {
  final int id;
  final int eventId;
  final String? title;
  final String? message;
  final String? invitationTemplate;
  final String? theme;
  final String? colorPalette;
  final String? fontStyle;
  final dynamic templateData;
  final String? previewToken;
  final bool allowPlusOne;
  final int maxPlusOnes;
  final String? rsvpFormTitle;
  final String? rsvpFormMessage;

  PublicInvitation({
    required this.id,
    required this.eventId,
    this.title,
    this.message,
    this.invitationTemplate,
    this.theme,
    this.colorPalette,
    this.fontStyle,
    this.templateData,
    this.previewToken,
    required this.allowPlusOne,
    required this.maxPlusOnes,
    this.rsvpFormTitle,
    this.rsvpFormMessage,
  });

  factory PublicInvitation.fromJson(Map<String, dynamic> json) {
    return PublicInvitation(
      id: json['id'],
      eventId: json['event_id'],
      title: json['title'],
      message: json['message'],
      invitationTemplate: json['invitation_template'],
      theme: json['theme'],
      colorPalette: json['color_palette'],
      fontStyle: json['font_style'],
      templateData: json['template_data'],
      previewToken: json['preview_token'],
      allowPlusOne: json['allow_plus_one'] ?? false,
      maxPlusOnes: json['max_plus_ones'] ?? 0,
      rsvpFormTitle: json['rsvp_form_title'],
      rsvpFormMessage: json['rsvp_form_message'],
    );
  }
}

class PublicEvent {
  final int id;
  final String title;
  final String? description;
  final String? eventType;
  final String? startTime;
  final String? endTime;
  final String? venueName;
  final String? venueAddress;
  final String? rsvpDeadline;
  final String? dressCode;
  final String? imageUrl;

  PublicEvent({
    required this.id,
    required this.title,
    this.description,
    this.eventType,
    this.startTime,
    this.endTime,
    this.venueName,
    this.venueAddress,
    this.rsvpDeadline,
    this.dressCode,
    this.imageUrl,
  });

  factory PublicEvent.fromJson(Map<String, dynamic> json) {
    return PublicEvent(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      eventType: json['event_type'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      venueName: json['venue_name'],
      venueAddress: json['venue_address'],
      rsvpDeadline: json['rsvp_deadline'],
      dressCode: json['dress_code'],
      imageUrl: json['image_url'],
    );
  }
}

class PublicOrganizer {
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;

  PublicOrganizer({this.firstName, this.lastName, this.email, this.phone});

  factory PublicOrganizer.fromJson(Map<String, dynamic> json) {
    return PublicOrganizer(
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phone: json['phone'],
    );
  }
}
