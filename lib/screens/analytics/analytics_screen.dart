import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/dashboard_model.dart';
import '../../providers/dashboard_provider.dart';
import 'checkin_details_screen.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late DashboardProvider _dashboardProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
  }

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      _dashboardProvider.fetchDashboardEvents();
      _dashboardProvider.startAutoRefresh();
    });
  }

  @override
  void dispose() {
    _dashboardProvider.stopAutoRefresh();
    super.dispose();
  }

  Widget statCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.lightBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget sectionCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textGrey),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget progressBar({
    required String label,
    required int value,
    required int total,
  }) {
    final percentage = total > 0 ? value / total : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          infoRow(label, '$value / $total'),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 9,
              backgroundColor: AppColors.inputFill,
            ),
          ),
        ],
      ),
    );
  }

  Widget eventDropdown(DashboardProvider provider) {
    final Map<int, DashboardEventModel> uniqueEventMap = {};

    for (final event in provider.events) {
      uniqueEventMap[event.id] = event;
    }

    final events = uniqueEventMap.values.toList();

    final selectedEventId = provider.selectedEvent?.id;

    final bool selectedEventExists =
        selectedEventId != null &&
        events.any((event) => event.id == selectedEventId);

    return DropdownButtonFormField<int>(
      value: selectedEventExists ? selectedEventId : null,
      dropdownColor: AppColors.surface,
      style: const TextStyle(color: AppColors.textWhite),
      iconEnabledColor: AppColors.textGrey,
      decoration: InputDecoration(
        labelText: 'Select Event to View Analytics',
        labelStyle: const TextStyle(color: AppColors.textGrey),
        filled: true,
        fillColor: AppColors.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderGrey),
        ),
      ),
      items: events.map((event) {
        return DropdownMenuItem<int>(
          value: event.id,
          child: Text(event.title, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: (eventId) {
        if (eventId == null) return;

        final selectedEvent = events.firstWhere((event) => event.id == eventId);

        provider.selectEvent(selectedEvent);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);
    final analytics = provider.analytics;
    final summary = provider.summary;

    final guests = analytics?['guests'];
    final invitationStats = analytics?['invitationStats'];
    final payment = analytics?['payment'];
    final invitation = analytics?['invitation'];
    final rsvps = analytics?['rsvps'];
    final checkins = analytics?['checkins'];
    final countdown = analytics?['countdown'];
    final event = analytics?['event'];

    final totalGuests = guests?['total'] ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: provider.fetchDashboardEvents,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Analytics Dashboard',
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Select an event to view its analytics.',
                  style: TextStyle(color: AppColors.textGrey),
                ),
                const SizedBox(height: 22),

                if (provider.isLoading && provider.events.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else if (provider.events.isEmpty)
                  const Center(
                    child: Text(
                      'No events found.',
                      style: TextStyle(color: AppColors.textGrey),
                    ),
                  )
                else
                  eventDropdown(provider),

                const SizedBox(height: 22),

                if (analytics != null) ...[
                  sectionCard(
                    title: event?['title'] ?? 'Selected Event',
                    children: [
                      infoRow('Venue', event?['venue_name'] ?? 'Not set'),
                      infoRow('Address', event?['venue_address'] ?? 'Not set'),
                      infoRow('Start Time', event?['start_time'] ?? 'Not set'),
                      infoRow(
                        'Countdown',
                        countdown?['isPast'] == true
                            ? 'Event has passed'
                            : '${countdown?['days'] ?? 0}d ${countdown?['hours'] ?? 0}h ${countdown?['minutes'] ?? 0}m',
                      ),
                    ],
                  ),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.45,
                    children: [
                      statCard(
                        title: 'Total Guests',
                        value: totalGuests.toString(),
                        icon: Icons.groups_outlined,
                      ),
                      statCard(
                        title: 'Checked In',
                        value: '${checkins?['checkedIn'] ?? 0}',
                        icon: Icons.verified_user_outlined,
                      ),
                      statCard(
                        title: 'RSVP Yes',
                        value: '${rsvps?['confirmed'] ?? 0}',
                        icon: Icons.check_circle_outline,
                      ),
                      statCard(
                        title: 'RSVP Pending',
                        value: '${rsvps?['pending'] ?? 0}',
                        icon: Icons.pending_actions,
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  sectionCard(
                    title: 'Invitation Sending Statistics',
                    children: [
                      infoRow(
                        'Sent by Email',
                        '${invitationStats?['sentByEmail'] ?? 0}',
                      ),
                      infoRow(
                        'Sent by WhatsApp',
                        '${invitationStats?['sentByWhatsapp'] ?? 0}',
                      ),
                      infoRow(
                        'Sent by Both',
                        '${invitationStats?['sentByBoth'] ?? 0}',
                      ),
                      infoRow(
                        'Email Failed',
                        '${invitationStats?['emailFailed'] ?? 0}',
                      ),
                      infoRow(
                        'WhatsApp Failed',
                        '${invitationStats?['whatsappFailed'] ?? 0}',
                      ),
                      infoRow('Pending', '${invitationStats?['pending'] ?? 0}'),
                    ],
                  ),

                  sectionCard(
                    title: 'Template & Payment Summary',
                    children: [
                      infoRow(
                        'Invitation Template',
                        invitation?['invitation_template'] ?? 'No invitation',
                      ),
                      infoRow(
                        'Payment Status',
                        payment?['status'] == 'confirmed' ? 'Paid' : 'Not Paid',
                      ),
                      infoRow(
                        'Cost Statement',
                        payment?['status'] == 'confirmed'
                            ? 'Sharing this template to ${payment?['guest_count']} guests cost you ${payment?['total_amount']} FCFA'
                            : 'Payment has not been completed yet',
                      ),
                    ],
                  ),

                  sectionCard(
                    title: 'RSVP Analytics',
                    children: [
                      progressBar(
                        label: 'Confirmed',
                        value: rsvps?['confirmed'] ?? 0,
                        total: totalGuests,
                      ),
                      progressBar(
                        label: 'Declined',
                        value: rsvps?['declined'] ?? 0,
                        total: totalGuests,
                      ),
                      progressBar(
                        label: 'Pending',
                        value: rsvps?['pending'] ?? 0,
                        total: totalGuests,
                      ),
                    ],
                  ),

                  sectionCard(
                    title: 'Live Check-in Analytics',
                    children: [
                      progressBar(
                        label: 'Checked In',
                        value: checkins?['checkedIn'] ?? 0,
                        total: totalGuests,
                      ),
                      progressBar(
                        label: 'Not Checked In',
                        value: checkins?['notCheckedIn'] ?? 0,
                        total: totalGuests,
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CheckinDetailsScreen(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.list_alt,
                            color: AppColors.lightBlue,
                          ),
                          label: const Text(
                            'View Check-in Details',
                            style: TextStyle(color: AppColors.lightBlue),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                if (summary != null) ...[
                  const SizedBox(height: 8),
                  sectionCard(
                    title: 'Overall Summary',
                    children: [
                      infoRow('Total Events', '${summary['totalEvents'] ?? 0}'),
                      infoRow('Total Guests', '${summary['totalGuests'] ?? 0}'),
                      infoRow(
                        'Total Revenue',
                        '${summary['totalRevenue'] ?? 0} FCFA',
                      ),
                      infoRow(
                        'Total Invitations Sent',
                        '${summary['totalInvitationsSent'] ?? 0}',
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
