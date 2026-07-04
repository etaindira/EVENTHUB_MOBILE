import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/event_model.dart';
import '../../models/invitation_model.dart';
import '../../providers/invitation_provider.dart';
import '../../widgets/auth_text_field.dart';
import '../../widgets/invitations/invitation_canvas.dart';

class CreateInvitationScreen extends StatefulWidget {
  final EventModel event;
  final InvitationModel? invitationToEdit;

  const CreateInvitationScreen({
    super.key,
    required this.event,
    this.invitationToEdit,
  });

  @override
  State<CreateInvitationScreen> createState() => _CreateInvitationScreenState();
}

class _CreateInvitationScreenState extends State<CreateInvitationScreen> {
  final formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final messageController = TextEditingController();
  final dateTimeController = TextEditingController();
  final venueController = TextEditingController();
  final venueAddressController = TextEditingController();

  final rsvpFormTitleController = TextEditingController();
  final rsvpFormMessageController = TextEditingController();

  String selectedInvitationTemplate = 'Elegant Classic';
  String selectedTheme = 'Elegant';
  String selectedColorPalette = 'Blue and white';
  String selectedFontStyle = 'Modern';

  bool allowPlusOne = false;
  int maxPlusOnes = 1;

  final List<int> maxPlusOneOptions = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  final List<String> invitationTemplateOptions = [
    'Elegant Classic',
    'Modern Minimal',
    'Bold Celebration',
    'Luxury Gold',
    'Simple Formal',
  ];

  final List<String> themeOptions = [
    'Elegant',
    'Modern',
    'Luxury',
    'Fun',
    'Formal',
    'Traditional',
  ];

  final List<String> colorOptions = [
    'Blue and white',
    'Gold and white',
    'Black and gold',
    'Pink and white',
    'Green and cream',
  ];

  final List<String> fontOptions = [
    'Modern',
    'Serif',
    'Sans-serif',
    'Bold',
    'Script',
  ];

  bool get isEditing => widget.invitationToEdit != null;

  @override
  void initState() {
    super.initState();

    final invitation = widget.invitationToEdit;

    dateTimeController.text = widget.event.startTime;
    venueController.text = widget.event.venueName;
    venueAddressController.text = widget.event.venueAddress;

    if (invitation != null) {
      titleController.text = invitation.title;
      messageController.text = invitation.message;

      selectedInvitationTemplate =
          invitation.invitationTemplate ?? selectedInvitationTemplate;
      selectedTheme = invitation.theme ?? selectedTheme;
      selectedColorPalette = invitation.colorPalette ?? selectedColorPalette;
      selectedFontStyle = invitation.fontStyle ?? selectedFontStyle;

      allowPlusOne = invitation.allowPlusOne;
      maxPlusOnes = invitation.maxPlusOnes > 0 ? invitation.maxPlusOnes : 1;

      rsvpFormTitleController.text =
          invitation.rsvpFormTitle ?? 'RSVP Confirmation';
      rsvpFormMessageController.text =
          invitation.rsvpFormMessage ??
          'Please confirm whether you will attend.';
    } else {
      titleController.text = "You're Invited to ${widget.event.title}";
      messageController.text = widget.event.description;

      rsvpFormTitleController.text = 'RSVP Confirmation';
      rsvpFormMessageController.text =
          'Please confirm whether you will attend.';
    }

    titleController.addListener(refreshPreview);
    messageController.addListener(refreshPreview);
  }

  void refreshPreview() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    titleController.removeListener(refreshPreview);
    messageController.removeListener(refreshPreview);

    titleController.dispose();
    messageController.dispose();
    dateTimeController.dispose();
    venueController.dispose();
    venueAddressController.dispose();
    rsvpFormTitleController.dispose();
    rsvpFormMessageController.dispose();

    super.dispose();
  }

  Map<String, dynamic> buildTemplateData() {
    return {
      'eventTitle': widget.event.title,
      'description': messageController.text.trim(),
      'startTime': dateTimeController.text.trim(),
      'endTime': widget.event.endTime,
      'venue': venueController.text.trim(),
      'address': venueAddressController.text.trim(),
      'dressCode': widget.event.dressCode,
      'invitationTemplate': selectedInvitationTemplate,
      'theme': selectedTheme,
      'colorPalette': selectedColorPalette,
      'fontStyle': selectedFontStyle,
      'allowPlusOne': allowPlusOne,
      'maxPlusOnes': allowPlusOne ? maxPlusOnes : 0,
      'rsvpFormTitle': rsvpFormTitleController.text.trim(),
      'rsvpFormMessage': rsvpFormMessageController.text.trim(),
    };
  }

  Future<void> handleGenerateTemplates() async {
    final invitationProvider = Provider.of<InvitationProvider>(
      context,
      listen: false,
    );

    final success = await invitationProvider.generateAiTemplates(
      eventId: widget.event.id,
      mood: selectedTheme,
      colors: selectedColorPalette,
      tone: selectedInvitationTemplate,
      extraMessage: messageController.text.trim(),
    );

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            invitationProvider.errorMessage ?? 'Failed to generate templates',
          ),
        ),
      );
    }
  }

  void useGeneratedTemplate(dynamic template) {
    setState(() {
      titleController.text = template['title'] ?? titleController.text;
      messageController.text = template['message'] ?? messageController.text;

      selectedInvitationTemplate =
          template['invitation_template'] ?? selectedInvitationTemplate;
      selectedTheme = template['theme'] ?? selectedTheme;
      selectedColorPalette = template['color_palette'] ?? selectedColorPalette;
      selectedFontStyle = template['font_style'] ?? selectedFontStyle;
    });
  }

  Future<void> handleSaveInvitation() async {
    if (!formKey.currentState!.validate()) return;

    final invitationProvider = Provider.of<InvitationProvider>(
      context,
      listen: false,
    );

    final fullMessage =
        '${messageController.text.trim()}\n\n'
        'Date/Time: ${dateTimeController.text.trim()}\n'
        'Venue: ${venueController.text.trim()}\n'
        'Address: ${venueAddressController.text.trim()}';

    final finalMaxPlusOnes = allowPlusOne ? maxPlusOnes : 0;

    bool success;

    if (isEditing) {
      success = await invitationProvider.updateInvitation(
        invitationId: widget.invitationToEdit!.id,
        title: titleController.text.trim(),
        message: fullMessage,
        invitationTemplate: selectedInvitationTemplate,
        theme: selectedTheme,
        colorPalette: selectedColorPalette,
        fontStyle: selectedFontStyle,
        templateData: buildTemplateData(),
        status: 'draft',
        allowPlusOne: allowPlusOne,
        maxPlusOnes: finalMaxPlusOnes,
        rsvpFormTitle: rsvpFormTitleController.text.trim(),
        rsvpFormMessage: rsvpFormMessageController.text.trim(),
      );
    } else {
      success = await invitationProvider.saveInvitation(
        eventId: widget.event.id,
        title: titleController.text.trim(),
        message: fullMessage,
        invitationTemplate: selectedInvitationTemplate,
        theme: selectedTheme,
        colorPalette: selectedColorPalette,
        fontStyle: selectedFontStyle,
        templateData: buildTemplateData(),
        status: 'draft',
        allowPlusOne: allowPlusOne,
        maxPlusOnes: finalMaxPlusOnes,
        rsvpFormTitle: rsvpFormTitleController.text.trim(),
        rsvpFormMessage: rsvpFormMessageController.text.trim(),
      );
    }

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            invitationProvider.errorMessage ?? 'Failed to save invitation',
          ),
        ),
      );
    }
  }

  Widget buildGeneratedTemplates() {
    return Consumer<InvitationProvider>(
      builder: (context, provider, _) {
        if (provider.generatedTemplates.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Generated Templates',
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...provider.generatedTemplates.map((template) {
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 18),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.borderGrey),
                ),
                child: Column(
                  children: [
                    InvitationCanvas(
                      title: template['title'] ?? '',
                      message: template['message'] ?? '',
                      dateTime: dateTimeController.text,
                      venue: venueController.text,
                      address: venueAddressController.text,
                      dressCode: widget.event.dressCode,
                      rsvpDeadline: widget.event.rsvpDeadline,
                      template:
                          template['invitation_template'] ?? 'Elegant Classic',
                      theme: template['theme'] ?? selectedTheme,
                      colorPalette:
                          template['color_palette'] ?? selectedColorPalette,
                      fontStyle: template['font_style'] ?? selectedFontStyle,
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => useGeneratedTemplate(template),
                        icon: const Icon(Icons.check, color: Colors.white),
                        label: const Text(
                          'Use This Template',
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
                  ],
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget invitationPreviewCard() {
    return InvitationCanvas(
      title: titleController.text,
      message: messageController.text,
      dateTime: dateTimeController.text,
      venue: venueController.text,
      address: venueAddressController.text,
      dressCode: widget.event.dressCode,
      rsvpDeadline: widget.event.rsvpDeadline,
      template: selectedInvitationTemplate,
      theme: selectedTheme,
      colorPalette: selectedColorPalette,
      fontStyle: selectedFontStyle,
    );
  }

  Widget buildDropdown({
    required String label,
    required IconData icon,
    required String value,
    required List<String> options,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: AppColors.surface,
      style: const TextStyle(color: AppColors.textWhite),
      iconEnabledColor: AppColors.textGrey,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textGrey),
        prefixIcon: Icon(icon, color: AppColors.textGrey),
        filled: true,
        fillColor: AppColors.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderGrey),
        ),
      ),
      items: options.map((option) {
        return DropdownMenuItem<String>(value: option, child: Text(option));
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget readOnlyField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      style: const TextStyle(color: AppColors.textWhite),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textGrey),
        prefixIcon: Icon(icon, color: AppColors.textGrey),
        filled: true,
        fillColor: AppColors.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderGrey),
        ),
      ),
    );
  }

  Widget maxPlusOnesDropdown() {
    return DropdownButtonFormField<int>(
      value: maxPlusOnes,
      dropdownColor: AppColors.surface,
      style: const TextStyle(color: AppColors.textWhite),
      iconEnabledColor: AppColors.textGrey,
      decoration: InputDecoration(
        labelText: 'Maximum additional guests per invited guest',
        labelStyle: const TextStyle(color: AppColors.textGrey),
        prefixIcon: const Icon(
          Icons.group_add_outlined,
          color: AppColors.textGrey,
        ),
        filled: true,
        fillColor: AppColors.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderGrey),
        ),
      ),
      items: maxPlusOneOptions.map((number) {
        return DropdownMenuItem<int>(
          value: number,
          child: Text(number.toString()),
        );
      }).toList(),
      onChanged: (value) {
        if (value == null) return;
        setState(() {
          maxPlusOnes = value;
        });
      },
    );
  }

  Widget rsvpSettingsCard() {
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
            'RSVP Settings',
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            value: allowPlusOne,
            activeColor: AppColors.primaryBlue,
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Allow additional guests',
              style: TextStyle(
                color: AppColors.textWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: const Text(
              'Guests can select how many people they are bringing with them.',
              style: TextStyle(color: AppColors.textGrey),
            ),
            onChanged: (value) {
              setState(() {
                allowPlusOne = value;
                if (!allowPlusOne) {
                  maxPlusOnes = 1;
                }
              });
            },
          ),
          if (allowPlusOne) ...[
            const SizedBox(height: 14),
            maxPlusOnesDropdown(),
            const SizedBox(height: 8),
            Text(
              'Each invited guest can bring up to $maxPlusOnes additional guest${maxPlusOnes == 1 ? '' : 's'}.',
              style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
            ),
          ],
          const SizedBox(height: 14),
          AuthTextField(
            controller: rsvpFormTitleController,
            label: 'RSVP Form Title',
            icon: Icons.assignment_outlined,
            validator: (value) => value == null || value.isEmpty
                ? 'RSVP form title is required'
                : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: rsvpFormMessageController,
            maxLines: 3,
            minLines: 2,
            style: const TextStyle(color: AppColors.textWhite),
            validator: (value) => value == null || value.isEmpty
                ? 'RSVP form message is required'
                : null,
            decoration: InputDecoration(
              labelText: 'RSVP Form Message',
              labelStyle: const TextStyle(color: AppColors.textGrey),
              prefixIcon: const Icon(
                Icons.message_outlined,
                color: AppColors.textGrey,
              ),
              filled: true,
              fillColor: AppColors.inputFill,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.borderGrey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final invitationProvider = Provider.of<InvitationProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textWhite,
        title: Text(isEditing ? 'Edit Invitation' : 'Create Invitation'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                AuthTextField(
                  controller: titleController,
                  label: 'Invitation Title',
                  icon: Icons.title,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Title is required'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: messageController,
                  maxLines: 4,
                  minLines: 3,
                  style: const TextStyle(color: AppColors.textWhite),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Message is required'
                      : null,
                  decoration: InputDecoration(
                    labelText: 'Invitation Message',
                    labelStyle: const TextStyle(color: AppColors.textGrey),
                    prefixIcon: const Icon(
                      Icons.message_outlined,
                      color: AppColors.textGrey,
                    ),
                    filled: true,
                    fillColor: AppColors.inputFill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.borderGrey),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                readOnlyField(
                  controller: dateTimeController,
                  label: 'Date/Time',
                  icon: Icons.access_time,
                ),
                const SizedBox(height: 14),
                readOnlyField(
                  controller: venueController,
                  label: 'Venue',
                  icon: Icons.location_city_outlined,
                ),
                const SizedBox(height: 14),
                readOnlyField(
                  controller: venueAddressController,
                  label: 'Venue Address',
                  icon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 14),
                buildDropdown(
                  label: 'Invitation Template',
                  icon: Icons.design_services_outlined,
                  value: selectedInvitationTemplate,
                  options: invitationTemplateOptions,
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      selectedInvitationTemplate = value;
                    });
                  },
                ),
                const SizedBox(height: 14),
                buildDropdown(
                  label: 'Theme',
                  icon: Icons.palette_outlined,
                  value: selectedTheme,
                  options: themeOptions,
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      selectedTheme = value;
                    });
                  },
                ),
                const SizedBox(height: 14),
                buildDropdown(
                  label: 'Color Palette',
                  icon: Icons.color_lens_outlined,
                  value: selectedColorPalette,
                  options: colorOptions,
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      selectedColorPalette = value;
                    });
                  },
                ),
                const SizedBox(height: 14),
                buildDropdown(
                  label: 'Font Style',
                  icon: Icons.text_fields,
                  value: selectedFontStyle,
                  options: fontOptions,
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      selectedFontStyle = value;
                    });
                  },
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: invitationProvider.isGeneratingTemplates
                        ? null
                        : handleGenerateTemplates,
                    icon: const Icon(Icons.auto_awesome, color: Colors.white),
                    label: Text(
                      invitationProvider.isGeneratingTemplates
                          ? 'Generating...'
                          : 'Generate 3 AI Templates',
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                buildGeneratedTemplates(),
                const SizedBox(height: 18),
                rsvpSettingsCard(),
                const SizedBox(height: 24),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Template Preview',
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                invitationPreviewCard(),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: invitationProvider.isLoading
                        ? null
                        : handleSaveInvitation,
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: Text(
                      invitationProvider.isLoading
                          ? 'Saving...'
                          : isEditing
                          ? 'Update Invitation'
                          : 'Save Invitation',
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
