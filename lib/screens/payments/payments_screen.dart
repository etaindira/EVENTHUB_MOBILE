import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/payment_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_card.dart';
import '../../widgets/primary_button.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  dynamic selectedEvent;
  String selectedPaymentMethod = 'Manual Confirmation';

  final List<String> paymentMethods = [
    'Manual Confirmation',
    'MTN Mobile Money',
    'Orange Money',
    'Bank Card',
  ];

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<PaymentProvider>(context, listen: false).fetchPaymentEvents();
    });
  }

  Future<void> handleCalculatePayment() async {
    if (selectedEvent == null) {
      showMessage('Please select an event first');
      return;
    }

    final paymentProvider = Provider.of<PaymentProvider>(
      context,
      listen: false,
    );

    final success = await paymentProvider.calculatePayment(
      eventId: selectedEvent['id'],
    );

    if (!mounted) return;

    if (!success) {
      showMessage(paymentProvider.errorMessage ?? 'Payment calculation failed');
    }
  }

  Future<void> handleConfirmPayment() async {
    final paymentProvider = Provider.of<PaymentProvider>(
      context,
      listen: false,
    );

    final calculation = paymentProvider.calculation;

    if (calculation == null) {
      showMessage('Please calculate payment first');
      return;
    }

    final success = await paymentProvider.confirmPayment(
      eventId: calculation['eventId'],
      invitationId: calculation['invitationId'],
      paymentMethod: selectedPaymentMethod,
    );

    if (!mounted) return;

    if (success) {
      showMessage('Payment confirmed successfully');
    } else {
      showMessage(
        paymentProvider.errorMessage ?? 'Payment confirmation failed',
      );
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget buildInfoRow(String label, String value, {bool highlighted = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.bodyMedium)),
          Text(
            value,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w800,
              color: highlighted ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDropdown({
    required String label,
    required dynamic value,
    required List<DropdownMenuItem<dynamic>> items,
    required void Function(dynamic) onChanged,
    IconData? icon,
  }) {
    return DropdownButtonFormField<dynamic>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon == null ? null : Icon(icon),
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  Widget emptyPaymentCard() {
    return AppCard(
      child: Column(
        children: [
          const Icon(
            Icons.payments_outlined,
            color: AppColors.primary,
            size: 48,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('No payment summary yet', style: AppTextStyles.headingSmall),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Select an event and calculate payment to see the invitation cost.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget paymentSummaryCard(Map<String, dynamic> calculation) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment Summary', style: AppTextStyles.headingSmall),
          const SizedBox(height: AppSpacing.lg),

          buildInfoRow(
            'Invitation Template',
            calculation['invitationTemplate'].toString(),
          ),
          buildInfoRow(
            'Template Cost',
            '${calculation['unitPrice']} ${calculation['currency']}',
          ),
          buildInfoRow('Guest Count', calculation['guestCount'].toString()),
          buildInfoRow(
            'Price Per Guest',
            '${calculation['unitPrice']} ${calculation['currency']}',
          ),

          const Divider(height: 28),

          buildInfoRow(
            'Total Amount',
            '${calculation['totalAmount']} ${calculation['currency']}',
            highlighted: true,
          ),

          const SizedBox(height: AppSpacing.lg),

          buildDropdown(
            label: 'Payment Method',
            value: selectedPaymentMethod,
            icon: Icons.account_balance_wallet_outlined,
            items: paymentMethods.map((method) {
              return DropdownMenuItem<dynamic>(
                value: method,
                child: Text(method),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedPaymentMethod = value;
              });
            },
          ),

          const SizedBox(height: AppSpacing.xl),

          PrimaryButton(
            text: 'Confirm Payment',
            icon: Icons.verified_outlined,
            isLoading: Provider.of<PaymentProvider>(context).isLoading,
            onPressed: handleConfirmPayment,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paymentProvider = Provider.of<PaymentProvider>(context);
    final calculation = paymentProvider.calculation;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: paymentProvider.fetchPaymentEvents,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Payments', style: AppTextStyles.headingLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Calculate invitation costs and confirm payment.',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),

              if (paymentProvider.isLoading &&
                  paymentProvider.paymentEvents.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else ...[
                buildDropdown(
                  label: 'Select Event',
                  value: selectedEvent,
                  icon: Icons.event_available_outlined,
                  items: paymentProvider.paymentEvents.map((event) {
                    return DropdownMenuItem<dynamic>(
                      value: event,
                      child: Text(
                        event['title'] ?? 'Untitled Event',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedEvent = value;
                    });

                    paymentProvider.clearCalculation();
                  },
                ),

                const SizedBox(height: AppSpacing.lg),

                PrimaryButton(
                  text: 'Calculate Payment',
                  icon: Icons.calculate_outlined,
                  isLoading: paymentProvider.isLoading,
                  onPressed: handleCalculatePayment,
                ),

                const SizedBox(height: AppSpacing.xl),

                if (calculation != null)
                  paymentSummaryCard(calculation)
                else
                  emptyPaymentCard(),
              ],

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
