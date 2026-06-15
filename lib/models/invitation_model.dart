class InvitationModel {
  final int id;
  final int eventId;
  final int userId;
  final String title;
  final String message;
  final String? invitationTemplate;
  final String? theme;
  final String? colorPalette;
  final String? fontStyle;
  final dynamic templateData;
  final String? previewToken;
  final String? shareUrl;
  final String? status;

  InvitationModel({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.title,
    required this.message,
    this.invitationTemplate,
    this.theme,
    this.colorPalette,
    this.fontStyle,
    this.templateData,
    this.previewToken,
    this.shareUrl,
    this.status,
  });

  factory InvitationModel.fromJson(Map<String, dynamic> json) {
    return InvitationModel(
      id: json['id'],
      eventId: json['event_id'],
      userId: json['user_id'],
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      invitationTemplate: json['invitation_template'],
      theme: json['theme'],
      colorPalette: json['color_palette'],
      fontStyle: json['font_style'],
      templateData: json['template_data'],
      previewToken: json['preview_token'],
      shareUrl: json['share_url'],
      status: json['status'],
    );
  }
}
