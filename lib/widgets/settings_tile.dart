import 'package:flutter/material.dart';
import '../theme/design_system.dart';

/// Reusable Settings Tile Component.
class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool? value;
  final ValueChanged<bool>? onChanged;
  final VoidCallback? onTap;
  final Color? iconColor;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.value,
    this.onChanged,
    this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget trailingWidget;
    if (onChanged != null && value != null) {
      trailingWidget = Switch.adaptive(
        value: value!,
        onChanged: onChanged,
        activeThumbColor: AppColors.primaryCyan,
        activeTrackColor: AppColors.primaryCyan.withValues(alpha: 0.3),
        inactiveThumbColor: AppColors.textMuted,
        inactiveTrackColor: AppColors.surfaceElevated,
      );
    } else if (trailing != null) {
      trailingWidget = trailing!;
    } else if (onTap != null) {
      trailingWidget = const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textMuted,
      );
    } else {
      trailingWidget = const SizedBox.shrink();
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        splashColor: AppColors.primaryCyan.withValues(alpha: 0.08),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.borderSubtle, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.primaryCyan).withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? AppColors.primaryCyan,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              trailingWidget,
            ],
          ),
        ),
      ),
    );
  }
}
