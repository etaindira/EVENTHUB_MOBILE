import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/auth_text_field.dart';

class UpdateProfileInfoScreen extends StatefulWidget {
  const UpdateProfileInfoScreen({super.key});

  @override
  State<UpdateProfileInfoScreen> createState() =>
      _UpdateProfileInfoScreenState();
}

class _UpdateProfileInfoScreenState extends State<UpdateProfileInfoScreen> {
  final formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final profile = Provider.of<ProfileProvider>(
      context,
      listen: false,
    ).profile;

    firstNameController.text = profile?.firstName ?? '';
    lastNameController.text = profile?.lastName ?? '';
    emailController.text = profile?.email ?? '';
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> handleUpdate() async {
    if (!formKey.currentState!.validate()) return;

    final provider = Provider.of<ProfileProvider>(context, listen: false);

    final success = await provider.updateProfileInfo(
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      email: emailController.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Profile updated successfully'
              : provider.errorMessage ?? 'Failed to update profile',
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
        title: const Text('Update Profile Info'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                AuthTextField(
                  controller: firstNameController,
                  label: 'First Name',
                  icon: Icons.person_outline,
                  validator: (value) => value == null || value.isEmpty
                      ? 'First name is required'
                      : null,
                ),
                const SizedBox(height: 14),
                AuthTextField(
                  controller: lastNameController,
                  label: 'Last Name',
                  icon: Icons.person_outline,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Last name is required'
                      : null,
                ),
                const SizedBox(height: 14),
                AuthTextField(
                  controller: emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Email is required'
                      : null,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: provider.isLoading ? null : handleUpdate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      provider.isLoading ? 'Saving...' : 'Save Changes',
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
