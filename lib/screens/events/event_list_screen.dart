import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/event_model.dart';
import '../../providers/event_provider.dart';
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
          title: const Text(
            'Delete Event',
            style: TextStyle(color: AppColors.textWhite),
          ),
          content: Text(
            'Are you sure you want to delete "${event.title}"?',
            style: const TextStyle(color: AppColors.textGrey),
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
                style: TextStyle(color: Colors.redAccent),
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My Events',
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Tap an event to view details, create guest lists and invitation cards.',
                style: TextStyle(color: AppColors.textGrey),
              ),
              const SizedBox(height: 20),

              if (eventProvider.isLoading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (eventProvider.events.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text(
                      'No events created yet.',
                      style: TextStyle(color: AppColors.textGrey),
                    ),
                  ),
                )
              else
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: eventProvider.fetchEvents,
                    child: ListView.separated(
                      itemCount: eventProvider.events.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
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

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EventDetailsScreen(event: event)),
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderGrey),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.event, color: AppColors.lightBlue),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.eventType,
                    style: const TextStyle(color: AppColors.textGrey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.venueName,
                    style: const TextStyle(color: AppColors.textGrey),
                  ),
                ],
              ),
            ),

            PopupMenuButton<String>(
              color: AppColors.surface,
              icon: const Icon(Icons.more_vert, color: AppColors.textGrey),
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit();
                } else if (value == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: AppColors.lightBlue),
                      SizedBox(width: 10),
                      Text(
                        'Edit',
                        style: TextStyle(color: AppColors.textWhite),
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.redAccent),
                      SizedBox(width: 10),
                      Text('Delete', style: TextStyle(color: Colors.redAccent)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
