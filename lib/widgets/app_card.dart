import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/design_system.dart';

/// Reusable Standardized Container Card with 18px radius for Robo Cell 2.0.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool isGlass;
  final Border? border;
  final Color? backgroundColor;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.isGlass = false,
    this.border,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? const EdgeInsets.all(AppSpacing.lg);
    final effectiveBorder =
        border ?? Border.all(color: AppColors.borderSubtle, width: 1);
    final effectiveBg =
        backgroundColor ??
        (isGlass ? AppColors.surfaceGlass : AppColors.surface);

    Widget content = Container(
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: effectiveBorder,
        boxShadow: AppShadows.cardElevation,
      ),
      child: child,
    );

    if (isGlass) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: content,
        ),
      );
    }

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.card),
          onTap: onTap,
          child: content,
        ),
      );
    }

    return content;
  }
}
