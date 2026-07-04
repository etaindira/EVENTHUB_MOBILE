import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/public_rsvp_provider.dart';

class PublicRsvpScreen extends StatefulWidget {
  final String token;

  const PublicRsvpScreen({super.key, required this.token});

  @override
  State<PublicRsvpScreen> createState() => _PublicRsvpScreenState();
}

class _PublicRsvpScreenState extends State<PublicRsvpScreen> {
  String? selectedResponse;
  bool plusOne = false;
  int plusOneCount = 1;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<PublicRsvpProvider>(
        context,
        listen: false,
      ).fetchRsvpForm(widget.token);
    });
  }

  Future<void> submitRsvp() async {
    if (selectedResponse == null) {
      showMessage('Please select Yes or No');
      return;
    }

    final provider = Provider.of<PublicRsvpProvider>(context, listen: false);

    final success = await provider.submitRsvp(
      token: widget.token,
      response: selectedResponse!,
      plusOne: plusOne,
      plusOneCount: plusOne ? plusOneCount : 0,
    );

    if (!mounted) return;

    showMessage(
      success
          ? 'RSVP submitted successfully'
          : provider.errorMessage ?? 'Failed to submit RSVP',
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget responseButton({
    required String label,
    required String value,
    required IconData icon,
  }) {
    final isSelected = selectedResponse == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedResponse = value;

            if (value == 'no') {
              plusOne = false;
              plusOneCount = 1;
            }
          });
        },
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primaryBlue : AppColors.borderGrey,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
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
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.textWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget plusOneDropdown(int maxPlusOnes) {
    if (maxPlusOnes <= 0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        const Text(
          'How many extra people are you bringing?',
          style: TextStyle(
            color: AppColors.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<int>(
          value: plusOneCount,
          dropdownColor: AppColors.surface,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.background,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.borderGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primaryBlue),
            ),
          ),
          items: List.generate(maxPlusOnes, (index) {
            final value = index + 1;
            return DropdownMenuItem<int>(
              value: value,
              child: Text(
                '$value extra guest${value > 1 ? 's' : ''}',
                style: const TextStyle(color: AppColors.textWhite),
              ),
            );
          }),
          onChanged: (value) {
            setState(() {
              plusOneCount = value ?? 1;
            });
          },
        ),
        const SizedBox(height: 8),
        Text(
          'The organizer allows up to $maxPlusOnes extra guest${maxPlusOnes > 1 ? 's' : ''}.',
          style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PublicRsvpProvider>(context);
    final data = provider.rsvpData;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : provider.errorMessage != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Text(
                    provider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
              )
            : data == null
            ? const Center(
                child: Text(
                  'RSVP not found.',
                  style: TextStyle(color: AppColors.textGrey),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'EventHub',
                      style: TextStyle(
                        color: AppColors.lightBlue,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 24),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColors.borderGrey),
                      ),
                      child: Column(
                        children: [
                          Text(
                            data.invitation.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textWhite,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 14),

                          Text(
                            data.invitation.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textGrey,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 20),

                          infoRow(
                            'Guest',
                            '${data.guest.firstName} ${data.guest.lastName}',
                          ),
                          infoRow('Event', data.event.title),
                          infoRow('Venue', data.event.venueName ?? 'Not set'),
                          infoRow(
                            'Address',
                            data.event.venueAddress ?? 'Not set',
                          ),
                          infoRow('Date', data.event.startTime ?? 'Not set'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColors.borderGrey),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.rsvpSettings.rsvpFormTitle,
                            style: const TextStyle(
                              color: AppColors.textWhite,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            data.rsvpSettings.rsvpFormMessage,
                            style: const TextStyle(color: AppColors.textGrey),
                          ),

                          const SizedBox(height: 22),

                          Row(
                            children: [
                              responseButton(
                                label: 'Yes',
                                value: 'yes',
                                icon: Icons.check_circle_outline,
                              ),
                              const SizedBox(width: 12),
                              responseButton(
                                label: 'No',
                                value: 'no',
                                icon: Icons.cancel_outlined,
                              ),
                            ],
                          ),

                          if (data.rsvpSettings.allowPlusOne &&
                              selectedResponse == 'yes') ...[
                            const SizedBox(height: 18),
                            CheckboxListTile(
                              value: plusOne,
                              onChanged: (value) {
                                setState(() {
                                  plusOne = value ?? false;
                                  if (!plusOne) {
                                    plusOneCount = 1;
                                  }
                                });
                              },
                              activeColor: AppColors.primaryBlue,
                              title: const Text(
                                'I am bringing extra guests',
                                style: TextStyle(color: AppColors.textWhite),
                              ),
                              subtitle: Text(
                                'Maximum allowed: ${data.rsvpSettings.maxPlusOnes}',
                                style: const TextStyle(
                                  color: AppColors.textGrey,
                                ),
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                            ),

                            if (plusOne)
                              plusOneDropdown(data.rsvpSettings.maxPlusOnes),
                          ],

                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: provider.isSubmitting
                                  ? null
                                  : submitRsvp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                provider.isSubmitting
                                    ? 'Submitting...'
                                    : 'Submit RSVP',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),

                          if (provider.submitted || data.alreadySubmitted) ...[
                            const SizedBox(height: 16),
                            const Center(
                              child: Text(
                                'Your RSVP has been recorded.',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
