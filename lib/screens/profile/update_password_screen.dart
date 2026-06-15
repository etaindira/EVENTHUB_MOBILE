import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/auth_text_field.dart';

class UpdatePasswordScreen extends StatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final formKey = GlobalKey<FormState>();

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> handleUpdatePassword() async {
    if (!formKey.currentState!.validate()) return;

    final provider = Provider.of<ProfileProvider>(context, listen: false);

    final success = await provider.updatePassword(
      currentPassword: currentPasswordController.text.trim(),
      newPassword: newPasswordController.text.trim(),
      confirmPassword: confirmPasswordController.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Password updated successfully'
              : provider.errorMessage ?? 'Failed to update password',
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
        title: const Text('Update Password'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                AuthTextField(
                  controller: currentPasswordController,
                  label: 'Current Password',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Current password is required'
                      : null,
                ),
                const SizedBox(height: 14),
                AuthTextField(
                  controller: newPasswordController,
                  label: 'New Password',
                  icon: Icons.lock_reset_outlined,
                  isPassword: true,
                  validator: (value) => value == null || value.isEmpty
                      ? 'New password is required'
                      : null,
                ),
                const SizedBox(height: 14),
                AuthTextField(
                  controller: confirmPasswordController,
                  label: 'Confirm New Password',
                  icon: Icons.lock_reset_outlined,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirm password is required';
                    }

                    if (value != newPasswordController.text.trim()) {
                      return 'Passwords do not match';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: provider.isLoading ? null : handleUpdatePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      provider.isLoading ? 'Saving...' : 'Update Password',
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
