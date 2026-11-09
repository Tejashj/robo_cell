import 'package:flutter/material.dart';
import '../theme/design_system.dart';

enum SnackBarType { success, info, warning, error }

/// Floating Premium Toast / SnackBar helper.
class AppSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    String? title,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    IconData icon;
    Color iconColor;

    switch (type) {
      case SnackBarType.success:
        icon = Icons.check_circle_rounded;
        iconColor = AppColors.success;
        break;
      case SnackBarType.info:
        icon = Icons.info_rounded;
        iconColor = AppColors.primaryCyan;
        break;
      case SnackBarType.warning:
        icon = Icons.warning_amber_rounded;
        iconColor = AppColors.warning;
        break;
      case SnackBarType.error:
        icon = Icons.error_rounded;
        iconColor = AppColors.error;
        break;
    }

    final snackBar = SnackBar(
      duration: duration,
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.all(AppSpacing.lg),
      content: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: iconColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: AppShadows.cardElevation,
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null) ...[
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    message,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
