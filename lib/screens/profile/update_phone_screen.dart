import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/auth_text_field.dart';

class UpdatePhoneScreen extends StatefulWidget {
  const UpdatePhoneScreen({super.key});

  @override
  State<UpdatePhoneScreen> createState() => _UpdatePhoneScreenState();
}

class _UpdatePhoneScreenState extends State<UpdatePhoneScreen> {
  final formKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final profile = Provider.of<ProfileProvider>(
      context,
      listen: false,
    ).profile;

    phoneController.text = profile?.phone ?? '';
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  Future<void> handleUpdatePhone() async {
    if (!formKey.currentState!.validate()) return;

    final provider = Provider.of<ProfileProvider>(context, listen: false);

    final success = await provider.updatePhoneNumber(
      phone: phoneController.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Phone number updated successfully'
              : provider.errorMessage ?? 'Failed to update phone number',
        ),
      ),
    );

    if (success) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfileProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textWhite,
        title: const Text('Update Phone Number'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                AuthTextField(
                  controller: phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Phone number is required'
                      : null,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: provider.isLoading ? null : handleUpdatePhone,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      provider.isLoading ? 'Saving...' : 'Save Phone Number',
                      style: const TextStyle(color: Colors.white),
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
