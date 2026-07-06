import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/socket_service.dart';

import '../../models/event_model.dart';
import '../../models/guest_model.dart';
import '../../models/invitation_model.dart';
import '../../providers/guest_provider.dart';
import '../../providers/invitation_provider.dart';
import '../../screens/invitations/create_invitation_screen.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_textfield.dart';
import '../../widgets/invitations/invitation_canvas.dart';
import '../../widgets/primary_button.dart';

class EventDetailsScreen extends StatelessWidget {
  final EventModel event;

  const EventDetailsScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(event.title),
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textMuted,
            tabs: [
              Tab(text: 'Details'),
              Tab(text: 'Guests'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            EventDetailsTab(event: event),
            EventGuestsTab(event: event),
          ],
        ),
      ),
    );
  }
}

class EventDetailsTab extends StatefulWidget {
  final EventModel event;

  const EventDetailsTab({super.key, required this.event});

  @override
  State<EventDetailsTab> createState() => _EventDetailsTabState();
}

class _EventDetailsTabState extends State<EventDetailsTab> {
  EventModel get event => widget.event;

  Timer? _timer;
  Duration _remaining = Duration.zero;

  late SocketService _socketService;
  bool _socketReady = false;

  @override
  void initState() {
    super.initState();

    _updateCountdown();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateCountdown();
    });

    Future.microtask(() {
      Provider.of<InvitationProvider>(
        context,
        listen: false,
      ).fetchInvitationsByEvent(event.id);

      _socketService = Provider.of<SocketService>(context, listen: false);

      _socketService.connect();
      _socketService.joinEventRoom(event.id);
      _socketReady = true;

      _socketService.listenToRsvpUpdates((data) {
        debugPrint("RSVP Updated: $data");
      });

      _socketService.listenToInvitationStatusUpdates((data) {
        debugPrint("Invitation Status Updated: $data");

        Provider.of<InvitationProvider>(
          context,
          listen: false,
        ).fetchInvitationsByEvent(event.id);
      });

      _socketService.listenToCheckInUpdates((data) {
        debugPrint("Check-In Updated: $data");
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();

    if (_socketReady) {
      _socketService.leaveEventRoom(event.id);
    }

    super.dispose();
  }

  void _updateCountdown() {
    final eventDate = DateTime.tryParse(event.startTime);

    if (eventDate == null) return;

    final now = DateTime.now();
    final difference = eventDate.difference(now);

    if (!mounted) return;

    setState(() {
      _remaining = difference.isNegative ? Duration.zero : difference;
    });
  }

  Future<void> refreshInvitations() async {
    await Provider.of<InvitationProvider>(
      context,
      listen: false,
    ).fetchInvitationsByEvent(event.id);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _eventHeroCard(),

          const SizedBox(height: AppSpacing.xl),

          detailCard(
            title: 'Description',
            value: event.description,
            icon: Icons.description_outlined,
          ),
          detailCard(
            title: 'Event Type',
            value: event.eventType,
            icon: Icons.category_outlined,
          ),
          detailCard(
            title: 'Start Time',
            value: event.startTime,
            icon: Icons.access_time,
          ),
          detailCard(
            title: 'End Time',
            value: event.endTime ?? 'Not set',
            icon: Icons.timelapse,
          ),
          detailCard(
            title: 'Venue',
            value: '${event.venueName}\n${event.venueAddress}',
            icon: Icons.location_on_outlined,
          ),
          detailCard(
            title: 'Capacity',
            value: event.capacity?.toString() ?? 'Not specified',
            icon: Icons.groups_outlined,
          ),
          detailCard(
            title: 'RSVP Deadline',
            value: event.rsvpDeadline,
            icon: Icons.event_available_outlined,
          ),
          detailCard(
            title: 'Dress Code',
            value: event.dressCode ?? 'Not specified',
            icon: Icons.checkroom_outlined,
          ),

          if (event.scannerCode != null && event.scannerCode!.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Event Scanner Code",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.scannerCode!,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Give this code only to authorized scanner staff. They will use it in the EventHub Scanner App to verify and check in RSVP guests for this event only.",
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),

          const SizedBox(height: AppSpacing.lg),

          Consumer<InvitationProvider>(
            builder: (context, invitationProvider, _) {
              final invitation = invitationProvider.latestInvitation;

              if (invitationProvider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (invitation == null) {
                return const SizedBox.shrink();
              }

              return invitationPreviewCard(
                context: context,
                invitation: invitation,
              );
            },
          ),

          const SizedBox(height: AppSpacing.xl),

          PrimaryButton(
            text: 'Create Invitation',
            icon: Icons.design_services_outlined,
            onPressed: () async {
              final created = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateInvitationScreen(event: event),
                ),
              );

              if (created == true && mounted) {
                await refreshInvitations();

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Invitation saved successfully'),
                  ),
                );
              }
            },
          ),

          const SizedBox(height: AppSpacing.lg),

          Consumer<InvitationProvider>(
            builder: (context, invitationProvider, _) {
              final invitation = invitationProvider.latestInvitation;

              return PrimaryButton(
                text: 'Share Invitation to Guest List',
                icon: Icons.send_outlined,
                onPressed: invitation == null
                    ? null
                    : () async {
                        final success = await invitationProvider
                            .sendInvitationToGuests(
                              eventId: event.id,
                              invitationId: invitation.id,
                            );

                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? 'Invitations sent successfully'
                                  : invitationProvider.errorMessage ??
                                        'Failed to send invitations',
                            ),
                          ),
                        );
                      },
              );
            },
          ),

          const SizedBox(height: AppSpacing.sm),

          Center(
            child: Text(
              'PAYMENT BYPASSED FOR TESTING',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _eventHeroCard() {
    final days = _remaining.inDays;
    final hours = _remaining.inHours % 24;
    final minutes = _remaining.inMinutes % 60;
    final seconds = _remaining.inSeconds % 60;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_available_outlined,
              color: AppColors.primary,
              size: 42,
            ),
          ),
          const SizedBox(width: AppSpacing.xl),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: AppTextStyles.headingMedium),
                const SizedBox(height: AppSpacing.xs),
                Text('Coming in', style: AppTextStyles.bodyMedium),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _countdownItem(days, 'Days'),
                    _countdownItem(hours, 'Hours'),
                    _countdownItem(minutes, 'Minutes'),
                    _countdownItem(seconds, 'Seconds'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _countdownItem(int value, String label) {
    return Column(
      children: [
        Text(
          value.toString().padLeft(2, '0'),
          style: AppTextStyles.headingMedium.copyWith(
            color: AppColors.primary,
            fontSize: 26,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }

  Widget _miniInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget invitationPreviewCard({
    required BuildContext context,
    required InvitationModel invitation,
  }) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Saved Invitation',
            style: AppTextStyles.headingSmall.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          InvitationCanvas(
            title: invitation.title,
            message: invitation.message,
            dateTime: event.startTime,
            venue: event.venueName,
            address: event.venueAddress,
            dressCode: event.dressCode,
            rsvpDeadline: event.rsvpDeadline,
            template: invitation.invitationTemplate ?? "Elegant Classic",
            theme: invitation.theme ?? "",
            colorPalette: invitation.colorPalette ?? "",
            fontStyle: invitation.fontStyle ?? "",
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreateInvitationScreen(
                          event: event,
                          invitationToEdit: invitation,
                        ),
                      ),
                    );

                    if (updated == true && mounted) {
                      await refreshInvitations();
                    }
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final provider = Provider.of<InvitationProvider>(
                      context,
                      listen: false,
                    );

                    final success = await provider.deleteInvitation(
                      invitation.id,
                    );

                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Invitation deleted successfully'
                              : provider.errorMessage ??
                                    'Failed to delete invitation',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                  ),
                  label: const Text(
                    'Delete',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget detailCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: AppCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodySmall),
                  const SizedBox(height: AppSpacing.xs),
                  Text(value, style: AppTextStyles.bodyLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EventGuestsTab extends StatefulWidget {
  final EventModel event;

  const EventGuestsTab({super.key, required this.event});

  @override
  State<EventGuestsTab> createState() => _EventGuestsTabState();
}

class _EventGuestsTabState extends State<EventGuestsTab> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<GuestProvider>(
        context,
        listen: false,
      ).fetchGuests(widget.event.id);
    });
  }

  void showGuestForm({GuestModel? guest}) {
    final firstNameController = TextEditingController(
      text: guest?.firstName ?? '',
    );
    final lastNameController = TextEditingController(
      text: guest?.lastName ?? '',
    );
    final phoneController = TextEditingController(text: guest?.phone ?? '');
    final emailController = TextEditingController(text: guest?.email ?? '');

    final formKey = GlobalKey<FormState>();
    final isEditing = guest != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            top: AppSpacing.xl,
            bottom:
                MediaQuery.of(bottomSheetContext).viewInsets.bottom +
                AppSpacing.xl,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEditing ? 'Edit Guest' : 'Add Guest',
                    style: AppTextStyles.headingMedium,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    controller: firstNameController,
                    label: 'First Name',
                    prefixIcon: Icons.person_outline,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'First name is required'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    controller: lastNameController,
                    label: 'Last Name',
                    prefixIcon: Icons.person_outline,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Last name is required'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    controller: phoneController,
                    label: 'Phone Number',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Phone number is required'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    controller: emailController,
                    label: 'Email Optional',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  PrimaryButton(
                    text: isEditing ? 'Update Guest' : 'Add Guest',
                    icon: isEditing ? Icons.save_outlined : Icons.person_add,
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;

                      final guestProvider = Provider.of<GuestProvider>(
                        context,
                        listen: false,
                      );

                      bool success;

                      if (isEditing) {
                        success = await guestProvider.updateGuest(
                          guestId: guest.id,
                          firstName: firstNameController.text.trim(),
                          lastName: lastNameController.text.trim(),
                          phone: phoneController.text.trim(),
                          email: emailController.text.trim().isEmpty
                              ? null
                              : emailController.text.trim(),
                        );
                      } else {
                        success = await guestProvider.addGuest(
                          eventId: widget.event.id,
                          firstName: firstNameController.text.trim(),
                          lastName: lastNameController.text.trim(),
                          phone: phoneController.text.trim(),
                          email: emailController.text.trim().isEmpty
                              ? null
                              : emailController.text.trim(),
                        );
                      }

                      if (!mounted) return;

                      if (success) {
                        Navigator.pop(bottomSheetContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isEditing
                                  ? 'Guest updated successfully'
                                  : 'Guest added successfully',
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              guestProvider.errorMessage ??
                                  'Failed to save guest',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).whenComplete(() {
      firstNameController.dispose();
      lastNameController.dispose();
      phoneController.dispose();
      emailController.dispose();
    });
  }

  Future<void> confirmDeleteGuest(GuestModel guest) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text('Delete Guest', style: AppTextStyles.headingSmall),
          content: Text(
            'Are you sure you want to delete ${guest.firstName} ${guest.lastName}?',
            style: AppTextStyles.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Delete',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;
    if (!mounted) return;

    final guestProvider = Provider.of<GuestProvider>(context, listen: false);
    final success = await guestProvider.deleteGuest(guest.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Guest deleted successfully'
              : guestProvider.errorMessage ?? 'Failed to delete guest',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final guestProvider = Provider.of<GuestProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => showGuestForm(),
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Guest List (${guestProvider.guests.length})',
              style: AppTextStyles.headingMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Add and manage guests for this event.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            if (guestProvider.isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (guestProvider.guests.isEmpty)
              Expanded(
                child: Center(
                  child: AppCard(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.group_add_outlined,
                          color: AppColors.primary,
                          size: 48,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'No guests yet',
                          style: AppTextStyles.headingSmall,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Tap the add button to add your first guest.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => guestProvider.fetchGuests(widget.event.id),
                  child: ListView.separated(
                    itemCount: guestProvider.guests.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.lg),
                    itemBuilder: (context, index) {
                      final guest = guestProvider.guests[index];

                      return GuestCard(
                        guest: guest,
                        onEdit: () => showGuestForm(guest: guest),
                        onDelete: () => confirmDeleteGuest(guest),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class GuestCard extends StatelessWidget {
  final GuestModel guest;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const GuestCard({
    super.key,
    required this.guest,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primaryLight,
            child: Text(
              guest.firstName.isNotEmpty
                  ? guest.firstName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${guest.firstName} ${guest.lastName}',
                  style: AppTextStyles.headingSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(guest.phone, style: AppTextStyles.bodyMedium),
                if (guest.email != null && guest.email!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(guest.email!, style: AppTextStyles.bodySmall),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
          ),
        ],
      ),
    );
  }
}
