import 'package:flutter/material.dart';
import '../theme/design_system.dart';
import 'app_button.dart';

enum AppStateStatus { empty, offline, timeout, error, permission }

/// Standardized Empty and Error State Card with Action / Retry button.
class AppEmptyState extends StatelessWidget {
  final AppStateStatus status;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onRetry;
  final IconData? customIcon;

  const AppEmptyState({
    super.key,
    this.status = AppStateStatus.empty,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onRetry,
    this.customIcon,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color iconColor;

    switch (status) {
      case AppStateStatus.empty:
        icon = customIcon ?? Icons.inbox_rounded;
        iconColor = AppColors.primaryCyan;
        break;
      case AppStateStatus.offline:
        icon = Icons.wifi_off_rounded;
        iconColor = AppColors.warning;
        break;
      case AppStateStatus.timeout:
        icon = Icons.timer_off_rounded;
        iconColor = AppColors.warning;
        break;
      case AppStateStatus.error:
        icon = Icons.error_outline_rounded;
        iconColor = AppColors.error;
        break;
      case AppStateStatus.permission:
        icon = Icons.security_rounded;
        iconColor = AppColors.accentPurple;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: iconColor.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, size: 36, color: iconColor),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            description,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              text: actionLabel ?? "Try Again",
              onPressed: onRetry,
              variant: AppButtonVariant.primary,
              icon: Icons.refresh_rounded,
            ),
          ],
        ],
      ),
    );
  }
}
