import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/payment_provider.dart';

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

  Widget buildInfoRow(String label, String value) {
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
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontWeight: FontWeight.bold,
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
  }) {
    return DropdownButtonFormField<dynamic>(
      value: value,
      dropdownColor: AppColors.surface,
      style: const TextStyle(color: AppColors.textWhite),
      iconEnabledColor: AppColors.textGrey,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textGrey),
        filled: true,
        fillColor: AppColors.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.lightBlue),
        ),
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final paymentProvider = Provider.of<PaymentProvider>(context);
    final calculation = paymentProvider.calculation;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: paymentProvider.fetchPaymentEvents,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payments',
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Select an event, calculate invitation cost, and confirm payment.',
                  style: TextStyle(color: AppColors.textGrey),
                ),

                const SizedBox(height: 24),

                if (paymentProvider.isLoading &&
                    paymentProvider.paymentEvents.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else
                  buildDropdown(
                    label: 'Select Event',
                    value: selectedEvent,
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

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: paymentProvider.isLoading
                        ? null
                        : handleCalculatePayment,
                    icon: const Icon(Icons.calculate, color: Colors.white),
                    label: const Text(
                      'Calculate Payment',
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

                const SizedBox(height: 24),

                if (calculation != null)
                  Container(
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
                          'Payment Summary',
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 16),

                        buildInfoRow(
                          'Invitation Template',
                          calculation['invitationTemplate'].toString(),
                        ),

                        buildInfoRow(
                          'Template Cost',
                          '${calculation['unitPrice']} ${calculation['currency']}',
                        ),

                        buildInfoRow(
                          'Guest Count',
                          calculation['guestCount'].toString(),
                        ),

                        buildInfoRow(
                          'Price Per Guest',
                          '${calculation['unitPrice']} ${calculation['currency']}',
                        ),

                        buildInfoRow(
                          'Total Amount',
                          '${calculation['totalAmount']} ${calculation['currency']}',
                        ),
                        const SizedBox(height: 18),

                        buildDropdown(
                          label: 'Payment Method',
                          value: selectedPaymentMethod,
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

                        const SizedBox(height: 18),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: paymentProvider.isLoading
                                ? null
                                : handleConfirmPayment,
                            icon: const Icon(
                              Icons.verified,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Confirm Payment',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
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
