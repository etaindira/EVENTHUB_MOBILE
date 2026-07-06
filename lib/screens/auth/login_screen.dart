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
import '../app_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> handleLogin() async {
    if (!formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.login(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AppShell()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage ?? 'Login failed')),
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
                size: 58,
              ),
              const SizedBox(height: AppSpacing.sm),

              Text(
                'EventHub',
                style: AppTextStyles.headingLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              Text('Login', style: AppTextStyles.headingMedium),

              const SizedBox(height: AppSpacing.xs),

              Text(
                'Welcome back! Manage your events with ease.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium,
              ),

              const SizedBox(height: AppSpacing.xl),

              AppCard(
                child: Column(
                  children: [
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
                      controller: passwordController,
                      label: 'Password',
                      prefixIcon: Icons.lock_outline,
                      obscureText: true,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Password is required'
                          : null,
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.forgotPassword,
                          );
                        },
                        child: Text(
                          'Forgot Password?',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    PrimaryButton(
                      text: 'Login',
                      icon: Icons.login_outlined,
                      isLoading: authProvider.isLoading,
                      onPressed: handleLogin,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.signup);
                },
                child: Text(
                  "Don’t have an account? Sign Up",
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
