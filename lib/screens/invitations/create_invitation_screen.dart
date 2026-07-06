import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/event_model.dart';
import '../../models/invitation_model.dart';
import '../../providers/invitation_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_textfield.dart';
import '../../widgets/invitations/invitation_canvas.dart';
import '../../widgets/primary_button.dart';

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
  String selectedColorPalette = 'Green and cream';
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
    'Green and cream',
    'Blue and white',
    'Gold and white',
    'Black and gold',
    'Pink and white',
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

    final fullMessage = messageController.text.trim();

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

  Widget buildDropdown({
    required String label,
    required IconData icon,
    required String value,
    required List<String> options,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
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
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
    );
  }

  Widget maxPlusOnesDropdown() {
    return DropdownButtonFormField<int>(
      value: maxPlusOnes,
      decoration: const InputDecoration(
        labelText: 'Maximum additional guests per invited guest',
        prefixIcon: Icon(Icons.group_add_outlined),
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

  Widget buildGeneratedTemplates() {
    return Consumer<InvitationProvider>(
      builder: (context, provider, _) {
        if (provider.generatedTemplates.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Generated Templates', style: AppTextStyles.headingSmall),
            const SizedBox(height: AppSpacing.lg),
            ...provider.generatedTemplates.map((template) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: AppCard(
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
                            template['invitation_template'] ??
                            'Elegant Classic',
                        theme: template['theme'] ?? selectedTheme,
                        colorPalette:
                            template['color_palette'] ?? selectedColorPalette,
                        fontStyle: template['font_style'] ?? selectedFontStyle,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      PrimaryButton(
                        text: 'Use This Template',
                        icon: Icons.check,
                        onPressed: () => useGeneratedTemplate(template),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget invitationPreviewCard() {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: InvitationCanvas(
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
      ),
    );
  }

  Widget rsvpSettingsCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('RSVP Settings', style: AppTextStyles.headingSmall),
          const SizedBox(height: AppSpacing.lg),
          SwitchListTile(
            value: allowPlusOne,
            activeColor: AppColors.primary,
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Allow additional guests',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            subtitle: Text(
              'Guests can select how many people they are bringing.',
              style: AppTextStyles.bodyMedium,
            ),
            onChanged: (value) {
              setState(() {
                allowPlusOne = value;
                if (!allowPlusOne) maxPlusOnes = 1;
              });
            },
          ),
          if (allowPlusOne) ...[
            const SizedBox(height: AppSpacing.lg),
            maxPlusOnesDropdown(),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Each invited guest can bring up to $maxPlusOnes additional guest${maxPlusOnes == 1 ? '' : 's'}.',
              style: AppTextStyles.bodySmall,
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: rsvpFormTitleController,
            label: 'RSVP Form Title',
            prefixIcon: Icons.assignment_outlined,
            validator: (value) => value == null || value.isEmpty
                ? 'RSVP form title is required'
                : null,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: rsvpFormMessageController,
            label: 'RSVP Form Message',
            prefixIcon: Icons.message_outlined,
            maxLines: 3,
            validator: (value) => value == null || value.isEmpty
                ? 'RSVP form message is required'
                : null,
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
        title: Text(isEditing ? 'Edit Invitation' : 'Create Invitation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Edit Invitation' : 'Create Invitation',
                style: AppTextStyles.headingLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Customize the invitation design, RSVP settings, and preview.',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),

              AppTextField(
                controller: titleController,
                label: 'Invitation Title',
                prefixIcon: Icons.title,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: AppSpacing.lg),

              AppTextField(
                controller: messageController,
                label: 'Invitation Message',
                prefixIcon: Icons.message_outlined,
                maxLines: 4,
                validator: (value) => value == null || value.isEmpty
                    ? 'Message is required'
                    : null,
              ),
              const SizedBox(height: AppSpacing.lg),

              readOnlyField(
                controller: dateTimeController,
                label: 'Date/Time',
                icon: Icons.access_time,
              ),
              const SizedBox(height: AppSpacing.lg),

              readOnlyField(
                controller: venueController,
                label: 'Venue',
                icon: Icons.location_city_outlined,
              ),
              const SizedBox(height: AppSpacing.lg),

              readOnlyField(
                controller: venueAddressController,
                label: 'Venue Address',
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: AppSpacing.xl),

              Text('Design Options', style: AppTextStyles.headingSmall),
              const SizedBox(height: AppSpacing.lg),

              buildDropdown(
                label: 'Invitation Template',
                icon: Icons.design_services_outlined,
                value: selectedInvitationTemplate,
                options: invitationTemplateOptions,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => selectedInvitationTemplate = value);
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              buildDropdown(
                label: 'Theme',
                icon: Icons.palette_outlined,
                value: selectedTheme,
                options: themeOptions,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => selectedTheme = value);
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              buildDropdown(
                label: 'Color Palette',
                icon: Icons.color_lens_outlined,
                value: selectedColorPalette,
                options: colorOptions,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => selectedColorPalette = value);
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              buildDropdown(
                label: 'Font Style',
                icon: Icons.text_fields,
                value: selectedFontStyle,
                options: fontOptions,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => selectedFontStyle = value);
                },
              ),

              const SizedBox(height: AppSpacing.xl),

              PrimaryButton(
                text: invitationProvider.isGeneratingTemplates
                    ? 'Generating...'
                    : 'Generate 3 AI Templates',
                icon: Icons.auto_awesome,
                isLoading: invitationProvider.isGeneratingTemplates,
                onPressed: handleGenerateTemplates,
              ),

              const SizedBox(height: AppSpacing.xl),

              buildGeneratedTemplates(),

              rsvpSettingsCard(),

              const SizedBox(height: AppSpacing.xl),

              Text('Template Preview', style: AppTextStyles.headingSmall),
              const SizedBox(height: AppSpacing.lg),
              invitationPreviewCard(),

              const SizedBox(height: AppSpacing.xl),

              PrimaryButton(
                text: invitationProvider.isLoading
                    ? 'Saving...'
                    : isEditing
                    ? 'Update Invitation'
                    : 'Save Invitation',
                icon: Icons.save_outlined,
                isLoading: invitationProvider.isLoading,
                onPressed: handleSaveInvitation,
              ),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
