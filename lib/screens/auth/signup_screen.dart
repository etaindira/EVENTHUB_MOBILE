import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_textfield.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/responsive_page.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> handleSignup() async {
    if (!formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.signup(
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      password: passwordController.text.trim(),
      confirmPassword: confirmPasswordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushNamed(
        context,
        AppRoutes.verifyCode,
        arguments: emailController.text.trim(),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage ?? 'Signup failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      body: ResponsivePage(
        centerContent: true,
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.event_available_rounded,
                color: AppColors.primary,
                size: 54,
              ),
              const SizedBox(height: AppSpacing.sm),

              Text(
                'EventHub',
                style: AppTextStyles.headingLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              Text('Create your account', style: AppTextStyles.headingMedium),

              const SizedBox(height: AppSpacing.xs),

              Text(
                'Start managing events, guests, invitations and RSVPs.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium,
              ),

              const SizedBox(height: AppSpacing.xl),

              AppCard(
                child: Column(
                  children: [
                    AppTextField(
                      controller: firstNameController,
                      label: 'First Name',
                      prefixIcon: Icons.person_outline,
                      validator: (value) => value == null || value.isEmpty
                          ? 'First name is required'
                          : null,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    AppTextField(
                      controller: lastNameController,
                      label: 'Last Name',
                      prefixIcon: Icons.person_outline,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Last name is required'
                          : null,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    AppTextField(
                      controller: emailController,
                      label: 'Email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Email is required'
                          : null,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    AppTextField(
                      controller: phoneController,
                      label: 'Phone Number',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Phone number is required'
                          : null,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    AppTextField(
                      controller: passwordController,
                      label: 'Password',
                      prefixIcon: Icons.lock_outline,
                      obscureText: true,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Password is required'
                          : null,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    AppTextField(
                      controller: confirmPasswordController,
                      label: 'Confirm Password',
                      prefixIcon: Icons.lock_outline,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Confirm password is required';
                        }

                        if (value != passwordController.text.trim()) {
                          return 'Passwords do not match';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    PrimaryButton(
                      text: 'Create Account',
                      icon: Icons.person_add_alt_1_outlined,
                      isLoading: authProvider.isLoading,
                      onPressed: handleSignup,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                },
                child: Text(
                  'Already have an account? Login',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
