import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/design_system.dart';

/// Modern Standardized Modal Dialog container.
class AppDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;
  final IconData? titleIcon;

  const AppDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
    this.titleIcon,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    List<Widget>? actions,
    IconData? titleIcon,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      transitionDuration: AppDurations.normal,
      pageBuilder: (ctx, anim1, anim2) => AppDialog(
        title: title,
        content: content,
        actions: actions,
        titleIcon: titleIcon,
      ),
      transitionBuilder: (ctx, anim1, anim2, child) {
        final curve = CurvedAnimation(parent: anim1, curve: AppCurves.easeOut);
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(curve),
            child: FadeTransition(opacity: curve, child: child),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(AppSpacing.xl),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.borderSubtle, width: 1.5),
          boxShadow: AppShadows.cardElevation,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (titleIcon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.primaryCyan.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(
                      titleIcon,
                      color: AppColors.primaryCyan,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                IconButton(
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.textMuted,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Flexible(child: SingleChildScrollView(child: content)),
            if (actions != null && actions!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xl),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: actions!),
            ],
          ],
        ),
      ),
    );
  }
}
