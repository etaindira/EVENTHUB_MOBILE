import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/event_model.dart';
import '../../providers/event_provider.dart';
import '../../widgets/auth_text_field.dart';

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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderGrey),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_month_outlined,
              color: AppColors.textGrey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$label: ${formatDateTime(value)}',
                style: const TextStyle(color: AppColors.textWhite),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditMode ? 'Edit Event' : 'Create Event',
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isEditMode
                      ? 'Update the event details below.'
                      : 'Fill in the event details below.',
                  style: const TextStyle(color: AppColors.textGrey),
                ),
                const SizedBox(height: 24),

                Center(
                  child: GestureDetector(
                    onTap: pickImage,
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: AppColors.surface,
                      backgroundImage: selectedImage != null
                          ? FileImage(selectedImage!)
                          : null,
                      child: selectedImage == null
                          ? const Icon(
                              Icons.add_a_photo_outlined,
                              color: AppColors.lightBlue,
                              size: 34,
                            )
                          : null,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                AuthTextField(
                  controller: titleController,
                  label: 'Event Title',
                  icon: Icons.title,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Title is required'
                      : null,
                ),

                const SizedBox(height: 14),

                AuthTextField(
                  controller: descriptionController,
                  label: 'Event Description',
                  icon: Icons.description_outlined,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Description is required'
                      : null,
                ),

                const SizedBox(height: 14),

                AuthTextField(
                  controller: eventTypeController,
                  label: 'Event Type',
                  icon: Icons.category_outlined,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Event type is required'
                      : null,
                ),

                const SizedBox(height: 14),

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

                const SizedBox(height: 14),

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

                const SizedBox(height: 14),

                AuthTextField(
                  controller: venueNameController,
                  label: 'Venue Name',
                  icon: Icons.location_city_outlined,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Venue name is required'
                      : null,
                ),

                const SizedBox(height: 14),

                AuthTextField(
                  controller: venueAddressController,
                  label: 'Venue Address',
                  icon: Icons.location_on_outlined,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Venue address is required'
                      : null,
                ),

                const SizedBox(height: 14),

                AuthTextField(
                  controller: capacityController,
                  label: 'Capacity Optional',
                  icon: Icons.groups_outlined,
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 14),

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

                const SizedBox(height: 14),

                AuthTextField(
                  controller: dressCodeController,
                  label: 'Dress Code Optional',
                  icon: Icons.checkroom_outlined,
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: eventProvider.isLoading
                        ? null
                        : handleSubmitEvent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: eventProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            isEditMode ? 'Update Event' : 'Create Event',
                            style: const TextStyle(color: Colors.white),
                          ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
