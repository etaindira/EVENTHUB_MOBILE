import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/dashboard_provider.dart';

class CheckinDetailsScreen extends StatelessWidget {
  const CheckinDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    final checkins = dashboardProvider.checkins;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textWhite,
        title: const Text('Check-in Details'),
      ),
      body: SafeArea(
        child: checkins.isEmpty
            ? const Center(
                child: Text(
                  'No guests checked in yet.',
                  style: TextStyle(color: AppColors.textGrey, fontSize: 16),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(22),
                itemCount: checkins.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final guest = checkins[index];

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
                                'Checked in: ${guest.checkedInAt ?? 'Unknown time'}',
                                style: const TextStyle(
                                  color: AppColors.textGrey,
                                ),
                              ),

                              if (guest.email != null &&
                                  guest.email!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  guest.email!,
                                  style: const TextStyle(
                                    color: AppColors.textGrey,
                                  ),
                                ),
                              ],

                              if (guest.phone != null &&
                                  guest.phone!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  guest.phone!,
                                  style: const TextStyle(
                                    color: AppColors.textGrey,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        const Icon(Icons.verified, color: Colors.green),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
