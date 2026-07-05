import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/dashboard_model.dart';
import '../../providers/dashboard_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_card.dart';
import '../../widgets/stat_card.dart';
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

  String _formatValue(dynamic value) {
    if (value == null) return '0';
    return value.toString();
  }

  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Analytics', style: AppTextStyles.headingLarge),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Track your event performance in real time.',
          style: AppTextStyles.bodyMedium,
        ),
      ],
    );
  }

  Widget _eventDropdown(DashboardProvider provider) {
    final Map<int, DashboardEventModel> uniqueEventMap = {};

    for (final event in provider.events) {
      uniqueEventMap[event.id] = event;
    }

    final events = uniqueEventMap.values.toList();
    final selectedEventId = provider.selectedEvent?.id;

    final selectedEventExists =
        selectedEventId != null &&
        events.any((event) => event.id == selectedEventId);

    return DropdownButtonFormField<int>(
      value: selectedEventExists ? selectedEventId : null,
      decoration: const InputDecoration(
        labelText: 'Select Event',
        prefixIcon: Icon(Icons.event_available_outlined),
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

  Widget _eventHeroCard({
    required Map<String, dynamic>? event,
    required Map<String, dynamic>? countdown,
  }) {
    final title = event?['title'] ?? 'Selected Event';
    final venue = event?['venue_name'] ?? 'Venue not set';
    final address = event?['venue_address'] ?? 'Address not set';
    final startTime = event?['start_time'] ?? 'Start time not set';

    final countdownText = countdown?['isPast'] == true
        ? 'Event has passed'
        : '${countdown?['days'] ?? 0}d ${countdown?['hours'] ?? 0}h ${countdown?['minutes'] ?? 0}m left';

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Text(
              'Active Event',
              style: TextStyle(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(title, style: AppTextStyles.headingMedium),
          const SizedBox(height: AppSpacing.md),
          _miniInfo(Icons.location_on_outlined, venue),
          const SizedBox(height: AppSpacing.sm),
          _miniInfo(Icons.map_outlined, address),
          const SizedBox(height: AppSpacing.sm),
          _miniInfo(Icons.schedule_outlined, startTime),
          const SizedBox(height: AppSpacing.sm),
          _miniInfo(Icons.timer_outlined, countdownText),
        ],
      ),
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

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.bodyMedium)),
          Text(
            value,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressBar({
    required String label,
    required int value,
    required int total,
  }) {
    final percentage = total > 0 ? value / total : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow(label, '$value / $total'),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 10,
              backgroundColor: AppColors.surfaceSoft,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, required List<Widget> children}) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.headingSmall),
          const SizedBox(height: AppSpacing.lg),
          ...children,
        ],
      ),
    );
  }

  Widget _emptyState() {
    return AppCard(
      child: Column(
        children: [
          const Icon(
            Icons.analytics_outlined,
            color: AppColors.primary,
            size: 46,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('No events found', style: AppTextStyles.headingSmall),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Create an event first to start seeing analytics.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
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
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: provider.fetchDashboardEvents,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: AppSpacing.xl),

              if (provider.isLoading && provider.events.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else if (provider.events.isEmpty)
                _emptyState()
              else ...[
                _eventDropdown(provider),
                const SizedBox(height: AppSpacing.xl),
              ],

              if (analytics != null) ...[
                _eventHeroCard(event: event, countdown: countdown),
                const SizedBox(height: AppSpacing.xl),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: AppSpacing.lg,
                  mainAxisSpacing: AppSpacing.lg,
                  childAspectRatio: 1.15,
                  children: [
                    StatCard(
                      icon: Icons.groups_outlined,
                      value: _formatValue(totalGuests),
                      label: 'Total Guests',
                    ),
                    StatCard(
                      icon: Icons.verified_user_outlined,
                      value: _formatValue(checkins?['checkedIn']),
                      label: 'Checked In',
                    ),
                    StatCard(
                      icon: Icons.check_circle_outline,
                      value: _formatValue(rsvps?['confirmed']),
                      label: 'RSVP Yes',
                    ),
                    StatCard(
                      icon: Icons.pending_actions,
                      value: _formatValue(rsvps?['pending']),
                      label: 'RSVP Pending',
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                _sectionCard(
                  title: 'RSVP Analytics',
                  children: [
                    _progressBar(
                      label: 'Confirmed',
                      value: rsvps?['confirmed'] ?? 0,
                      total: totalGuests,
                    ),
                    _progressBar(
                      label: 'Declined',
                      value: rsvps?['declined'] ?? 0,
                      total: totalGuests,
                    ),
                    _progressBar(
                      label: 'Pending',
                      value: rsvps?['pending'] ?? 0,
                      total: totalGuests,
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                _sectionCard(
                  title: 'Invitation Statistics',
                  children: [
                    _infoRow(
                      'Sent by Email',
                      _formatValue(invitationStats?['sentByEmail']),
                    ),
                    _infoRow(
                      'Sent by WhatsApp',
                      _formatValue(invitationStats?['sentByWhatsapp']),
                    ),
                    _infoRow(
                      'Sent by Both',
                      _formatValue(invitationStats?['sentByBoth']),
                    ),
                    _infoRow(
                      'Email Failed',
                      _formatValue(invitationStats?['emailFailed']),
                    ),
                    _infoRow(
                      'WhatsApp Failed',
                      _formatValue(invitationStats?['whatsappFailed']),
                    ),
                    _infoRow(
                      'Pending',
                      _formatValue(invitationStats?['pending']),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                _sectionCard(
                  title: 'Template & Payment',
                  children: [
                    _infoRow(
                      'Invitation Template',
                      invitation?['invitation_template'] ?? 'No invitation',
                    ),
                    _infoRow(
                      'Payment Status',
                      payment?['status'] == 'confirmed' ? 'Paid' : 'Not Paid',
                    ),
                    _infoRow(
                      'Total Amount',
                      payment?['status'] == 'confirmed'
                          ? '${payment?['total_amount'] ?? 0} FCFA'
                          : 'Not completed',
                    ),
                    _infoRow(
                      'Guest Count',
                      '${payment?['guest_count'] ?? totalGuests}',
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                _sectionCard(
                  title: 'Live Check-in Analytics',
                  children: [
                    _progressBar(
                      label: 'Checked In',
                      value: checkins?['checkedIn'] ?? 0,
                      total: totalGuests,
                    ),
                    _progressBar(
                      label: 'Not Checked In',
                      value: checkins?['notCheckedIn'] ?? 0,
                      total: totalGuests,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CheckinDetailsScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.list_alt),
                        label: const Text('View Check-in Details'),
                      ),
                    ),
                  ],
                ),
              ],

              if (summary != null) ...[
                const SizedBox(height: AppSpacing.xl),
                _sectionCard(
                  title: 'Overall Summary',
                  children: [
                    _infoRow(
                      'Total Events',
                      _formatValue(summary['totalEvents']),
                    ),
                    _infoRow(
                      'Total Guests',
                      _formatValue(summary['totalGuests']),
                    ),
                    _infoRow(
                      'Total Revenue',
                      '${summary['totalRevenue'] ?? 0} FCFA',
                    ),
                    _infoRow(
                      'Total Invitations Sent',
                      _formatValue(summary['totalInvitationsSent']),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
