import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/event_model.dart';
import '../../providers/event_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_card.dart';
import 'create_event_screen.dart';
import 'event_details_screen.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<EventProvider>(context, listen: false).fetchEvents();
    });
  }

  Future<void> _confirmDelete(EventModel event) async {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text('Delete Event', style: AppTextStyles.headingSmall),
          content: Text(
            'Are you sure you want to delete "${event.title}"?',
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

    final success = await eventProvider.deleteEvent(event.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Event deleted successfully'
              : eventProvider.errorMessage ?? 'Failed to delete event',
        ),
      ),
    );
  }

  void _goToEditEvent(EventModel event) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CreateEventScreen(eventToEdit: event)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My Events', style: AppTextStyles.headingLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Manage events, guests, invitations and RSVPs.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),

            if (eventProvider.isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (eventProvider.events.isEmpty)
              const Expanded(child: _EmptyEventsState())
            else
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: eventProvider.fetchEvents,
                  child: ListView.separated(
                    itemCount: eventProvider.events.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.lg),
                    itemBuilder: (context, index) {
                      final event = eventProvider.events[index];

                      return EventCard(
                        event: event,
                        onEdit: () => _goToEditEvent(event),
                        onDelete: () => _confirmDelete(event),
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

class _EmptyEventsState extends StatelessWidget {
  const _EmptyEventsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.event_available_outlined,
              color: AppColors.primary,
              size: 48,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('No events yet', style: AppTextStyles.headingSmall),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Create your first event and start inviting guests.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EventCard({
    super.key,
    required this.event,
    required this.onEdit,
    required this.onDelete,
  });

  String get _dateText {
    if (event.startTime.isEmpty) return 'Date not set';

    try {
      final date = DateTime.parse(event.startTime);
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return event.startTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EventDetailsScreen(event: event)),
        );
      },
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.event_rounded,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: AppTextStyles.headingSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  event.eventType,
                  style: AppTextStyles.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 15,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.venueName,
                        style: AppTextStyles.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _dateText,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          PopupMenuButton<String>(
            color: AppColors.surface,
            icon: const Icon(Icons.more_vert, color: AppColors.textMuted),
            onSelected: (value) {
              if (value == 'edit') {
                onEdit();
              } else if (value == 'delete') {
                onDelete();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, color: AppColors.primary),
                    SizedBox(width: 10),
                    Text('Edit'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: AppColors.error),
                    SizedBox(width: 10),
                    Text('Delete', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
