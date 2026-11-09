import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../theme/design_system.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/settings_tile.dart';
import '../../widgets/skeleton_loader.dart';
import 'login.dart';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic> user;

  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Map<String, dynamic> currentUser;
  bool savingLinkedin = false;
  final linkedinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    currentUser = widget.user;
    linkedinController.text = currentUser['linkedin'] ?? '';
  }

  Future<void> saveLinkedin() async {
    if (linkedinController.text.trim().isEmpty) {
      AppSnackBar.show(
        context,
        message: "Enter LinkedIn URL",
        type: SnackBarType.warning,
      );
      return;
    }

    setState(() {
      savingLinkedin = true;
    });

    try {
      await Supabase.instance.client
          .from('users')
          .update({
            'linkedin': linkedinController.text.trim(),
            'linkedin_locked': true,
          })
          .eq('id', currentUser['id']);

      currentUser['linkedin'] = linkedinController.text.trim();
      currentUser['linkedin_locked'] = true;

      setState(() {});

      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: "LinkedIn Saved Successfully",
        type: SnackBarType.success,
      );
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: e.toString(),
        type: SnackBarType.error,
      );
    }

    setState(() {
      savingLinkedin = false;
    });
  }

  Widget infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primaryEmerald.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.chip),
            ),
            child: Icon(icon, color: AppColors.primaryEmerald, size: 20),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final photo = currentUser['photo_url'];
    final linkedinLocked = currentUser['linkedin_locked'] == true;
    final isGuest =
        currentUser['role']?.toString().toUpperCase() == 'GUEST' ||
        currentUser['id'] == 'guest_user';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          "PROFILE & SETTINGS",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// LARGE PROFILE HEADER
            AppCard(
              isGlass: true,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryEmerald,
                        width: 2.5,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 56,
                      backgroundColor: AppColors.surface,
                      child: ClipOval(
                        child: photo != null && photo.toString().isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: photo.toString(),
                                width: 112,
                                height: 112,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    const SkeletonCircle(radius: 56),
                                errorWidget: (context, url, error) =>
                                    const Icon(
                                      Icons.person_rounded,
                                      size: 50,
                                      color: AppColors.primaryEmerald,
                                    ),
                              )
                            : const Icon(
                                Icons.person_rounded,
                                size: 50,
                                color: AppColors.primaryEmerald,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    currentUser['name'] ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryEmerald.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.chip),
                      border: Border.all(
                        color: AppColors.primaryEmerald.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      currentUser['role']
                          .toString()
                          .replaceAll('_', ' ')
                          .toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primaryEmerald,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Department of Robotics & Artificial Intelligence",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            /// MEMBER DETAILS
            const Text(
              "MEMBER DETAILS",
              style: TextStyle(
                color: AppColors.headingGold,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            infoCard(
              icon: Icons.badge_rounded,
              title: "USN",
              value: currentUser['usn'] ?? '',
            ),
            infoCard(
              icon: Icons.groups_rounded,
              title: "COMMITTEE",
              value: currentUser['committees']?['name'] ?? 'General Committee',
            ),
            infoCard(
              icon: Icons.email_rounded,
              title: "EMAIL",
              value: currentUser['email'] ?? '',
            ),

            if (!isGuest) ...[
              const SizedBox(height: AppSpacing.lg),

              /// LINKEDIN SECTION
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "LINKEDIN PROFILE",
                      style: TextStyle(
                        color: AppColors.headingGold,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (!linkedinLocked)
                      Column(
                        children: [
                          TextField(
                            controller: linkedinController,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                            ),
                            decoration: const InputDecoration(
                              hintText: "Enter LinkedIn URL",
                              prefixIcon: Icon(
                                Icons.link_rounded,
                                color: AppColors.primaryEmerald,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          AppButton(
                            text: "SAVE LINKEDIN",
                            width: double.infinity,
                            isLoading: savingLinkedin,
                            onPressed: savingLinkedin ? null : saveLinkedin,
                          ),
                        ],
                      )
                    else
                      Text(
                        currentUser['linkedin'] ?? 'No LinkedIn Added',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.xl),

            /// ABOUT & VERSION
            const Text(
              "ABOUT",
              style: TextStyle(
                color: AppColors.headingGold,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const SettingsTile(
              icon: Icons.info_outline_rounded,
              title: "Version",
              subtitle: "Robo Cell v1.0.1 (Build 5)",
            ),

            const SizedBox(height: AppSpacing.xxl),

            /// LOGOUT BUTTON
            AppButton(
              text: "LOGOUT",
              width: double.infinity,
              variant: AppButtonVariant.outlined,
              icon: Icons.logout_rounded,
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
                Hive.box('robo_cache').delete('logged_in_user');

                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),

            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }
}
