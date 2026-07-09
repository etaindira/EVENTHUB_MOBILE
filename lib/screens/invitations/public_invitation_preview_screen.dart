import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/public_invitation_model.dart';
import '../../services/public_invitation_service.dart';
import '../../widgets/invitations/invitation_canvas.dart';

class PublicInvitationPreviewScreen extends StatefulWidget {
  final String previewToken;
  final String? guestToken;

  const PublicInvitationPreviewScreen({
    super.key,
    required this.previewToken,
    this.guestToken,
  });

  @override
  State<PublicInvitationPreviewScreen> createState() =>
      _PublicInvitationPreviewScreenState();
}

class _PublicInvitationPreviewScreenState
    extends State<PublicInvitationPreviewScreen> {
  final PublicInvitationService _service = PublicInvitationService();

  bool isLoading = true;
  String? errorMessage;
  PublicInvitationResponse? publicInvitation;

  @override
  void initState() {
    super.initState();
    loadInvitation();
  }

  Future<void> loadInvitation() async {
    try {
      final data = await _service.getInvitationByToken(
        previewToken: widget.previewToken,
        guestToken: widget.guestToken,
      );

      if (!mounted) return;

      setState(() {
        publicInvitation = data;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'Unable to load invitation.';
        isLoading = false;
      });
    }
  }

  String formatDate(String? value) {
    if (value == null || value.isEmpty) return 'Not specified';

    try {
      return DateFormat(
        'EEEE, MMMM d, yyyy • h:mm a',
      ).format(DateTime.parse(value));
    } catch (_) {
      return value;
    }
  }

  Color getAccentColor(String? palette) {
    final value = palette?.toLowerCase() ?? '';

    if (value.contains('green') || value.contains('emerald')) {
      return const Color(0xFF059669);
    }

    if (value.contains('gold') || value.contains('cream')) {
      return const Color(0xFFB45309);
    }

    if (value.contains('pink') || value.contains('rose')) {
      return const Color(0xFFE11D48);
    }

    if (value.contains('blue')) {
      return const Color(0xFF2563EB);
    }

    return const Color(0xFF059669);
  }

  String getFontFamily(String? fontStyle) {
    final value = fontStyle?.toLowerCase() ?? '';

    if (value.contains('serif')) return 'serif';
    if (value.contains('bold')) return 'sans-serif';
    return 'sans-serif';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (errorMessage != null || publicInvitation == null) {
      return Scaffold(
        body: Center(child: Text(errorMessage ?? 'Invitation not found.')),
      );
    }

    final data = publicInvitation!;
    final invitation = data.invitation;
    final event = data.event;
    final accentColor = getAccentColor(invitation.colorPalette);

    final templateData = invitation.templateData is Map
        ? Map<String, dynamic>.from(invitation.templateData)
        : <String, dynamic>{};

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                children: [
                  InvitationCanvas(
                    title: invitation.title ?? event.title,
                    message: invitation.message ?? event.description ?? '',
                    dateTime:
                        templateData['startTime'] ?? event.startTime ?? '',
                    venue:
                        templateData['venue'] ??
                        event.venueName ??
                        'Not specified',
                    address:
                        templateData['address'] ??
                        event.venueAddress ??
                        'Not specified',
                    dressCode: templateData['dressCode'] ?? event.dressCode,
                    rsvpDeadline: event.rsvpDeadline ?? '',
                    template:
                        templateData['invitationTemplate'] ??
                        invitation.invitationTemplate ??
                        'Elegant Classic',
                    theme:
                        templateData['theme'] ?? invitation.theme ?? 'Elegant',
                    colorPalette:
                        templateData['colorPalette'] ??
                        invitation.colorPalette ??
                        'Gold and white',
                    fontStyle:
                        templateData['fontStyle'] ??
                        invitation.fontStyle ??
                        'Serif',
                  ),
                  const SizedBox(height: 24),
                  _RsvpSection(
                    title: invitation.rsvpFormTitle ?? 'RSVP Confirmation',
                    message:
                        invitation.rsvpFormMessage ??
                        'Please confirm whether you will attend.',
                    eventId: event.id,
                    guestToken: widget.guestToken,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Powered by EventHub',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RsvpSection extends StatelessWidget {
  final String title;
  final String message;
  final int eventId;
  final String? guestToken;

  const _RsvpSection({
    required this.title,
    required this.message,
    required this.eventId,
    required this.guestToken,
  });

  @override
  Widget build(BuildContext context) {
    if (guestToken == null || guestToken!.isEmpty) {
      return const SizedBox.shrink();
    }

    final yesUrl =
        'https://eventhub-backend-lgpa.onrender.com/api/events/$eventId/rsvp?token=$guestToken&response=yes';
    final noUrl =
        'https://eventhub-backend-lgpa.onrender.com/api/events/$eventId/rsvp?token=$guestToken&response=no';

    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        const SizedBox(height: 8),
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            // We will connect this properly in the RSVP step.
          },
          child: const Text('Yes, I will attend'),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            // We will connect this properly in the RSVP step.
          },
          child: const Text('No, I cannot attend'),
        ),
      ],
    );
  }
}
