import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../services/public_invitation_service.dart';
import '../../widgets/invitations/invitation_canvas.dart';
import '../rsvp/public_rsvp_screen.dart';

class PublicInvitationScreen extends StatefulWidget {
  final String previewToken;
  final String? guestToken;

  const PublicInvitationScreen({
    super.key,
    required this.previewToken,
    this.guestToken,
  });

  @override
  State<PublicInvitationScreen> createState() => _PublicInvitationScreenState();
}

class _PublicInvitationScreenState extends State<PublicInvitationScreen> {
  final PublicInvitationService _service = PublicInvitationService();

  bool isLoading = true;
  String? errorMessage;
  Map<String, dynamic>? invitationData;

  @override
  void initState() {
    super.initState();
    fetchInvitation();
  }

  Future<void> fetchInvitation() async {
    try {
      final data = await _service.getPublicInvitation(widget.previewToken);

      if (!mounted) return;

      setState(() {
        invitationData = data;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = error.toString();
        isLoading = false;
      });
    }
  }

  void goToRsvp() {
    if (widget.guestToken == null || widget.guestToken!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('RSVP link is missing. Please contact the organizer.'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PublicRsvpScreen(token: widget.guestToken!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null || invitationData == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Text(
              errorMessage ?? 'Invitation not found',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textWhite),
            ),
          ),
        ),
      );
    }

    final data = invitationData!;

    final organizerName =
        '${data['organizer_first_name'] ?? ''} ${data['organizer_last_name'] ?? ''}'
            .trim();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              const Text(
                'EventHub',
                style: TextStyle(
                  color: AppColors.lightBlue,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                "You're Invited!",
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 22),

              InvitationCanvas(
                title: data['title'] ?? data['event_title'] ?? '',
                message: data['message'] ?? data['event_description'] ?? '',
                dateTime: data['start_time'] ?? '',
                venue: data['venue_name'] ?? '',
                address: data['venue_address'] ?? '',
                dressCode: data['dress_code'],
                rsvpDeadline: data['rsvp_deadline'] ?? '',
                template: data['invitation_template'] ?? 'Elegant Classic',
                theme: data['theme'] ?? 'Elegant',
                colorPalette: data['color_palette'] ?? 'Gold and white',
                fontStyle: data['font_style'] ?? 'Script',
              ),

              const SizedBox(height: 24),

              organizerCard(
                organizerName: organizerName.isEmpty
                    ? 'Organizer'
                    : organizerName,
                phone: data['organizer_phone'],
                email: data['organizer_email'],
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: goToRsvp,
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                  label: const Text(
                    'Accept Invitation / RSVP',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              TextButton(
                onPressed: goToRsvp,
                child: const Text(
                  'Decline or respond another way',
                  style: TextStyle(color: AppColors.textGrey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget organizerCard({
    required String organizerName,
    required dynamic phone,
    required dynamic email,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Need Help?',
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Contact Organizer',
            style: TextStyle(color: AppColors.textGrey),
          ),

          const SizedBox(height: 16),

          contactRow(icon: Icons.person_outline, label: organizerName),

          if (phone != null && phone.toString().trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            contactRow(icon: Icons.phone_outlined, label: phone.toString()),
          ],

          if (email != null && email.toString().trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            contactRow(icon: Icons.email_outlined, label: email.toString()),
          ],
        ],
      ),
    );
  }

  Widget contactRow({required IconData icon, required String label}) {
    return Row(
      children: [
        Icon(icon, color: AppColors.lightBlue, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textWhite, fontSize: 15),
          ),
        ),
      ],
    );
  }
}
