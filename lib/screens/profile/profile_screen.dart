import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/constants/api_constants.dart';
import '../../core/constants/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_card.dart';

import 'manage_storage_screen.dart';
import 'update_password_screen.dart';
import 'update_phone_screen.dart';
import 'update_profile_info_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final String baseUrl = ApiConstants.baseUrl;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<ProfileProvider>(context, listen: false).fetchProfile();
    });
  }

  Future<void> pickProfileImage() async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile == null) return;
    if (!mounted) return;

    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );

    final success = await profileProvider.uploadProfileImage(
      imageFile: File(pickedFile.path),
    );

    if (!mounted) return;

    showMessage(
      success
          ? 'Profile picture updated successfully'
          : profileProvider.errorMessage ?? 'Failed to upload image',
    );
  }

  Future<void> deleteProfileImage() async {
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );

    final success = await profileProvider.deleteProfileImage();

    if (!mounted) return;

    showMessage(
      success
          ? 'Profile picture deleted successfully'
          : profileProvider.errorMessage ?? 'Failed to delete image',
    );
  }

  Future<void> handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    await authProvider.logout();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget settingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: AppCard(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyLarge),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final profile = profileProvider.profile;

    String? imageUrl;

    if (profile?.profileImage != null && profile!.profileImage!.isNotEmpty) {
      imageUrl = '$baseUrl${profile.profileImage}';
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: profileProvider.isLoading && profile == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: profileProvider.fetchProfile,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Profile', style: AppTextStyles.headingLarge),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Manage your account and preferences.',
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 58,
                                backgroundColor: AppColors.primaryLight,
                                backgroundImage: imageUrl != null
                                    ? NetworkImage(imageUrl)
                                    : null,
                                child: imageUrl == null
                                    ? const Icon(
                                        Icons.person,
                                        color: AppColors.primary,
                                        size: 60,
                                      )
                                    : null,
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: GestureDetector(
                                  onTap: pickProfileImage,
                                  child: Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.surface,
                                        width: 3,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          if (imageUrl != null) ...[
                            const SizedBox(height: AppSpacing.sm),
                            TextButton.icon(
                              onPressed: deleteProfileImage,
                              icon: const Icon(
                                Icons.delete_outline,
                                color: AppColors.error,
                              ),
                              label: const Text(
                                'Delete Profile Picture',
                                style: TextStyle(color: AppColors.error),
                              ),
                            ),
                          ],

                          const SizedBox(height: AppSpacing.lg),

                          Text(
                            '${profile?.firstName ?? ''} ${profile?.lastName ?? ''}',
                            style: AppTextStyles.headingMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            profile?.email ?? '',
                            style: AppTextStyles.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    Text('Settings', style: AppTextStyles.headingSmall),
                    const SizedBox(height: AppSpacing.lg),

                    settingTile(
                      icon: Icons.person_outline,
                      title: 'Update Profile Info',
                      subtitle: 'Change your name and email',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const UpdateProfileInfoScreen(),
                          ),
                        );
                      },
                    ),

                    settingTile(
                      icon: Icons.phone_outlined,
                      title: 'Update Phone Number',
                      subtitle: profile?.phone ?? 'No phone number',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const UpdatePhoneScreen(),
                          ),
                        );
                      },
                    ),

                    settingTile(
                      icon: Icons.lock_outline,
                      title: 'Update Password',
                      subtitle: 'Change your account password',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const UpdatePasswordScreen(),
                          ),
                        );
                      },
                    ),

                    settingTile(
                      icon: Icons.storage_outlined,
                      title: 'Manage Storage',
                      subtitle: 'View app storage and clear cache',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ManageStorageScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: AppSpacing.md),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: handleLogout,
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
    );
  }
}
