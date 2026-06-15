import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';

import 'update_profile_info_screen.dart';
import 'update_phone_screen.dart';
import 'update_password_screen.dart';
import 'manage_storage_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final String baseUrl = 'http://localhost:5000';

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
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.lightBlue),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppColors.textGrey),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textGrey),
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
      body: SafeArea(
        child: profileProvider.isLoading && profile == null
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: profileProvider.fetchProfile,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Profile',
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 58,
                            backgroundColor: AppColors.surface,
                            backgroundImage: imageUrl != null
                                ? NetworkImage(imageUrl)
                                : null,
                            child: imageUrl == null
                                ? const Icon(
                                    Icons.person,
                                    color: AppColors.lightBlue,
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
                                  color: AppColors.primaryBlue,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.background,
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
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: deleteProfileImage,
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                          ),
                          label: const Text(
                            'Delete Profile Picture',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      Text(
                        '${profile?.firstName ?? ''} ${profile?.lastName ?? ''}',
                        style: const TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        profile?.email ?? '',
                        style: const TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 34),

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Settings',
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

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

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: handleLogout,
                          icon: const Icon(Icons.logout, color: Colors.white),
                          label: const Text(
                            'Logout',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
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
