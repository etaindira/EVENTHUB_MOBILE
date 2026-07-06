import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/event_model.dart';
import '../../providers/event_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_textfield.dart';
import '../../widgets/primary_button.dart';

class CreateEventScreen extends StatefulWidget {
  final EventModel? eventToEdit;

  const CreateEventScreen({super.key, this.eventToEdit});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final eventTypeController = TextEditingController();
  final venueNameController = TextEditingController();
  final venueAddressController = TextEditingController();
  final capacityController = TextEditingController();
  final dressCodeController = TextEditingController();

  File? selectedImage;
  DateTime? startDateTime;
  DateTime? endDateTime;
  DateTime? rsvpDeadline;

  bool get isEditMode => widget.eventToEdit != null;

  @override
  void initState() {
    super.initState();

    if (isEditMode) {
      final event = widget.eventToEdit!;

      titleController.text = event.title;
      descriptionController.text = event.description;
      eventTypeController.text = event.eventType;
      venueNameController.text = event.venueName;
      venueAddressController.text = event.venueAddress;
      capacityController.text = event.capacity?.toString() ?? '';
      dressCodeController.text = event.dressCode ?? '';

      startDateTime = DateTime.tryParse(event.startTime);
      endDateTime = event.endTime == null
          ? null
          : DateTime.tryParse(event.endTime!);
      rsvpDeadline = DateTime.tryParse(event.rsvpDeadline);
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    eventTypeController.dispose();
    venueNameController.dispose();
    venueAddressController.dispose();
    capacityController.dispose();
    dressCodeController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<DateTime?> pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDate: DateTime.now(),
    );

    if (date == null) return null;
    if (!mounted) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  String formatDateTime(DateTime? value) {
    if (value == null) return 'Select date and time';

    return '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')} '
        '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  }

  Future<void> handleSubmitEvent() async {
    if (!formKey.currentState!.validate()) return;

    if (startDateTime == null) {
      showMessage('Start time is required');
      return;
    }

    if (endDateTime == null) {
      showMessage('End time is required');
      return;
    }

    if (rsvpDeadline == null) {
      showMessage('RSVP deadline is required');
      return;
    }

    final eventProvider = Provider.of<EventProvider>(context, listen: false);

    final success = isEditMode
        ? await eventProvider.updateEvent(
            eventId: widget.eventToEdit!.id,
            imageFile: selectedImage,
            title: titleController.text.trim(),
            description: descriptionController.text.trim(),
            eventType: eventTypeController.text.trim(),
            startTime: startDateTime!.toIso8601String(),
            endTime: endDateTime!.toIso8601String(),
            venueName: venueNameController.text.trim(),
            venueAddress: venueAddressController.text.trim(),
            capacity: capacityController.text.trim().isEmpty
                ? null
                : int.tryParse(capacityController.text.trim()),
            rsvpDeadline: rsvpDeadline!.toIso8601String(),
            dressCode: dressCodeController.text.trim().isEmpty
                ? null
                : dressCodeController.text.trim(),
          )
        : await eventProvider.createEvent(
            imageFile: selectedImage,
            title: titleController.text.trim(),
            description: descriptionController.text.trim(),
            eventType: eventTypeController.text.trim(),
            startTime: startDateTime!.toIso8601String(),
            endTime: endDateTime!.toIso8601String(),
            venueName: venueNameController.text.trim(),
            venueAddress: venueAddressController.text.trim(),
            capacity: capacityController.text.trim().isEmpty
                ? null
                : int.tryParse(capacityController.text.trim()),
            rsvpDeadline: rsvpDeadline!.toIso8601String(),
            dressCode: dressCodeController.text.trim().isEmpty
                ? null
                : dressCodeController.text.trim(),
          );

    if (!mounted) return;

    if (success) {
      showMessage(
        isEditMode
            ? 'Event updated successfully'
            : 'Event created successfully',
      );

      if (isEditMode) {
        Navigator.pop(context);
      } else {
        clearForm();
      }
    } else {
      showMessage(
        eventProvider.errorMessage ??
            (isEditMode ? 'Failed to update event' : 'Failed to create event'),
      );
    }
  }

  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    eventTypeController.clear();
    venueNameController.clear();
    venueAddressController.clear();
    capacityController.clear();
    dressCodeController.clear();

    setState(() {
      selectedImage = null;
      startDateTime = null;
      endDateTime = null;
      rsvpDeadline = null;
    });
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget dateBox({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    final hasValue = value != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: hasValue ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_month_outlined,
              color: hasValue ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.bodySmall),
                  const SizedBox(height: 3),
                  Text(
                    formatDateTime(value),
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: hasValue
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget imagePickerCard() {
    return AppCard(
      onTap: pickImage,
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(18),
              image: selectedImage != null
                  ? DecorationImage(
                      image: FileImage(selectedImage!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: selectedImage == null
                ? const Icon(
                    Icons.add_a_photo_outlined,
                    color: AppColors.primary,
                    size: 30,
                  )
                : null,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Event Cover Photo', style: AppTextStyles.headingSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  selectedImage == null
                      ? 'Tap to upload an event image'
                      : 'Tap to change image',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textMuted),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditMode ? 'Edit Event' : 'Create Event',
                style: AppTextStyles.headingLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                isEditMode
                    ? 'Update your event details below.'
                    : 'Set up your event details and guest experience.',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),

              imagePickerCard(),

              const SizedBox(height: AppSpacing.xl),

              AppTextField(
                controller: titleController,
                label: 'Event Title',
                prefixIcon: Icons.title,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Title is required' : null,
              ),

              const SizedBox(height: AppSpacing.lg),

              AppTextField(
                controller: descriptionController,
                label: 'Event Description',
                prefixIcon: Icons.description_outlined,
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty
                    ? 'Description is required'
                    : null,
              ),

              const SizedBox(height: AppSpacing.lg),

              AppTextField(
                controller: eventTypeController,
                label: 'Event Type',
                prefixIcon: Icons.category_outlined,
                validator: (value) => value == null || value.isEmpty
                    ? 'Event type is required'
                    : null,
              ),

              const SizedBox(height: AppSpacing.lg),

              dateBox(
                label: 'Start Time',
                value: startDateTime,
                onTap: () async {
                  final picked = await pickDateTime();
                  if (picked != null) {
                    setState(() => startDateTime = picked);
                  }
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              dateBox(
                label: 'End Time',
                value: endDateTime,
                onTap: () async {
                  final picked = await pickDateTime();
                  if (picked != null) {
                    setState(() => endDateTime = picked);
                  }
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              AppTextField(
                controller: venueNameController,
                label: 'Venue Name',
                prefixIcon: Icons.location_city_outlined,
                validator: (value) => value == null || value.isEmpty
                    ? 'Venue name is required'
                    : null,
              ),

              const SizedBox(height: AppSpacing.lg),

              AppTextField(
                controller: venueAddressController,
                label: 'Venue Address',
                prefixIcon: Icons.location_on_outlined,
                validator: (value) => value == null || value.isEmpty
                    ? 'Venue address is required'
                    : null,
              ),

              const SizedBox(height: AppSpacing.lg),

              AppTextField(
                controller: capacityController,
                label: 'Capacity Optional',
                prefixIcon: Icons.groups_outlined,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: AppSpacing.lg),

              dateBox(
                label: 'RSVP Deadline',
                value: rsvpDeadline,
                onTap: () async {
                  final picked = await pickDateTime();
                  if (picked != null) {
                    setState(() => rsvpDeadline = picked);
                  }
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              AppTextField(
                controller: dressCodeController,
                label: 'Dress Code Optional',
                prefixIcon: Icons.checkroom_outlined,
              ),

              const SizedBox(height: AppSpacing.xl),

              PrimaryButton(
                text: isEditMode ? 'Update Event' : 'Create Event',
                icon: isEditMode ? Icons.save_outlined : Icons.add,
                isLoading: eventProvider.isLoading,
                onPressed: handleSubmitEvent,
              ),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
