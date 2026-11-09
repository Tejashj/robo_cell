import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/design_system.dart';

enum AppButtonVariant { primary, secondary, outlined, text }

/// Modernized Standardized Button for Robo Cell 2.0.
class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = AppSpacing.buttonHeight,
    this.padding,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppDurations.fast);
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: AppCurves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onPressed != null && !widget.isLoading;

    Color bg;
    Color fg;
    BorderSide border = BorderSide.none;

    switch (widget.variant) {
      case AppButtonVariant.primary:
        bg = isEnabled ? AppColors.primaryEmerald : AppColors.surfaceElevated;
        fg = isEnabled ? Colors.black : AppColors.textMuted;
        break;
      case AppButtonVariant.secondary:
        bg = AppColors.surfaceElevated;
        fg = isEnabled ? AppColors.textPrimary : AppColors.textMuted;
        border = const BorderSide(color: AppColors.borderSubtle);
        break;
      case AppButtonVariant.outlined:
        bg = Colors.transparent;
        fg = isEnabled ? AppColors.primaryEmerald : AppColors.textMuted;
        border = BorderSide(
          color: isEnabled ? AppColors.primaryEmerald : AppColors.borderSubtle,
          width: 1.5,
        );
        break;
      case AppButtonVariant.text:
        bg = Colors.transparent;
        fg = isEnabled ? AppColors.primaryEmerald : AppColors.textMuted;
        break;
    }

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.button),
            boxShadow: (widget.variant == AppButtonVariant.primary && isEnabled)
                ? AppShadows.primaryGlow
                : null,
          ),
          child: Material(
            color: bg,
            borderRadius: BorderRadius.circular(AppRadius.button),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.button),
              onTap: isEnabled
                  ? () {
                      HapticFeedback.lightImpact();
                      widget.onPressed!();
                    }
                  : null,
              child: Container(
                padding:
                    widget.padding ??
                    const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.button),
                  border: Border.fromBorderSide(border),
                ),
                child: Center(
                  child: widget.isLoading
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(fg),
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (widget.icon != null) ...[
                              Icon(widget.icon, size: 20, color: fg),
                              const SizedBox(width: AppSpacing.sm),
                            ],
                            Text(
                              widget.text,
                              style: TextStyle(
                                color: fg,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
