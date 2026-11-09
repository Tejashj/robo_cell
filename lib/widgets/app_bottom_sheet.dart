import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/design_system.dart';

/// Modern Standardized Bottom Sheet modal.
class AppBottomSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget Function(BuildContext context) builder,
    String? title,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (ctx) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.lg,
              top: AppSpacing.md,
              left: AppSpacing.lg,
              right: AppSpacing.lg,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.xl),
              ),
              border: Border(
                top: BorderSide(color: AppColors.borderSubtle, width: 1.5),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Drag indicator handle
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textMuted.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(AppRadius.circular),
                    ),
                  ),
                  if (title != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  Flexible(child: builder(ctx)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
