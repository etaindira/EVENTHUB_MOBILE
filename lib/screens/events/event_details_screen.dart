import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/guest_model.dart';
import '../../providers/guest_provider.dart';
import '../../widgets/auth_text_field.dart';

import '../../core/constants/app_colors.dart';
import '../../models/event_model.dart';
import '../../models/invitation_model.dart';
import '../../providers/invitation_provider.dart';
import '../../screens/invitations/create_invitation_screen.dart';

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
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textWhite,
          title: Text(event.title),
          bottom: const TabBar(
            indicatorColor: AppColors.lightBlue,
            labelColor: AppColors.lightBlue,
            unselectedLabelColor: AppColors.textGrey,
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

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<InvitationProvider>(
        context,
        listen: false,
      ).fetchInvitationsByEvent(event.id);
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
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

          const SizedBox(height: 10),

          Consumer<InvitationProvider>(
            builder: (context, invitationProvider, _) {
              final invitation = invitationProvider.latestInvitation;

              if (invitationProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
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

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
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
              icon: const Icon(Icons.design_services, color: Colors.white),
              label: const Text(
                'Create Invitation',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Consumer<InvitationProvider>(
            builder: (context, invitationProvider, _) {
              final invitation = invitationProvider.latestInvitation;

              return SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
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
                  icon: const Icon(Icons.send, color: Colors.white),
                  label: const Text(
                    'Share Invitation to Guest List',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 8),

          const Center(
            child: Text(
              'PAYMENT BYPASSED FOR TESTING',
              style: TextStyle(
                color: AppColors.textGrey,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget invitationPreviewCard({
    required BuildContext context,
    required InvitationModel invitation,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12, bottom: 14),
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
            'Saved Invitation',
            style: TextStyle(
              color: AppColors.lightBlue,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            invitation.title,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            invitation.message,
            style: const TextStyle(color: AppColors.textGrey, height: 1.4),
          ),

          const SizedBox(height: 12),

          Text(
            '${invitation.invitationTemplate ?? ''} • ${invitation.theme ?? ''} • ${invitation.colorPalette ?? ''}',
            style: const TextStyle(color: AppColors.textGrey),
          ),

          const SizedBox(height: 16),

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
                  icon: const Icon(Icons.edit, color: AppColors.lightBlue),
                  label: const Text(
                    'Edit',
                    style: TextStyle(color: AppColors.lightBlue),
                  ),
                ),
              ),

              const SizedBox(width: 10),

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
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  label: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.redAccent),
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
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.lightBlue),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
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
            left: 22,
            right: 22,
            top: 22,
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 22,
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
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 18),
                  AuthTextField(
                    controller: firstNameController,
                    label: 'First Name',
                    icon: Icons.person_outline,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'First name is required'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  AuthTextField(
                    controller: lastNameController,
                    label: 'Last Name',
                    icon: Icons.person_outline,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Last name is required'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  AuthTextField(
                    controller: phoneController,
                    label: 'Phone Number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Phone number is required'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  AuthTextField(
                    controller: emailController,
                    label: 'Email Optional',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        isEditing ? 'Update Guest' : 'Add Guest',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
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
          title: const Text('Delete Guest'),
          content: Text(
            'Are you sure you want to delete ${guest.firstName} ${guest.lastName}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
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
        backgroundColor: AppColors.primaryBlue,
        onPressed: () => showGuestForm(),
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Guest List (${guestProvider.guests.length})',
                style: const TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Add and manage guests for this event.',
                style: TextStyle(color: AppColors.textGrey),
              ),
              const SizedBox(height: 20),
              if (guestProvider.isLoading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (guestProvider.guests.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text(
                      'No guests added yet.',
                      style: TextStyle(color: AppColors.textGrey, fontSize: 16),
                    ),
                  ),
                )
              else
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => guestProvider.fetchGuests(widget.event.id),
                    child: ListView.separated(
                      itemCount: guestProvider.guests.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.inputFill,
            child: Text(
              guest.firstName.isNotEmpty
                  ? guest.firstName[0].toUpperCase()
                  : '?',
              style: const TextStyle(color: AppColors.lightBlue),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${guest.firstName} ${guest.lastName}',
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  guest.phone,
                  style: const TextStyle(color: AppColors.textGrey),
                ),
                if (guest.email != null && guest.email!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    guest.email!,
                    style: const TextStyle(color: AppColors.textGrey),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, color: AppColors.lightBlue),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          ),
        ],
      ),
    );
  }
}
