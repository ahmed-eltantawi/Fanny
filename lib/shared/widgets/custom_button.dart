import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

enum AppButtonStyle { primary, secondary, outline, ghost }

/// Reusable animated button used across the entire app.
class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final AppButtonStyle style;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const AppButton({
    super.key,
    required this.label,
    this.onTap,
    this.style = AppButtonStyle.primary,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  const AppButton.secondary({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.icon,
    this.width,
  }) : style = AppButtonStyle.secondary;

  const AppButton.outline({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.icon,
    this.width,
  }) : style = AppButtonStyle.outline;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _controller.reverse();
  void _onTapUp(_) => _controller.forward();
  void _onTapCancel() => _controller.forward();

  Color get _bgColor => switch (widget.style) {
    AppButtonStyle.primary   => AppColors.primary,
    AppButtonStyle.secondary => AppColors.accent,
    AppButtonStyle.outline   => Colors.transparent,
    AppButtonStyle.ghost     => Colors.transparent,
  };

  Color get _fgColor => switch (widget.style) {
    AppButtonStyle.primary   => Colors.white,
    AppButtonStyle.secondary => AppColors.textPrimary,
    AppButtonStyle.outline   => AppColors.primary,
    AppButtonStyle.ghost     => AppColors.primary,
  };

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onTap == null || widget.isLoading;

    return GestureDetector(
      onTapDown: isDisabled ? null : _onTapDown,
      onTapUp: isDisabled ? null : _onTapUp,
      onTapCancel: isDisabled ? null : _onTapCancel,
      onTap: isDisabled ? null : widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: AnimatedOpacity(
          opacity: isDisabled ? 0.6 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            width: widget.width ?? double.infinity,
            height: AppSizes.buttonHeight,
            decoration: BoxDecoration(
              color: _bgColor,
              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              border: widget.style == AppButtonStyle.outline
                  ? Border.all(color: AppColors.primary, width: 1.5)
                  : null,
              boxShadow: widget.style == AppButtonStyle.primary
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.28),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: widget.isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(_fgColor),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, color: _fgColor, size: 20),
                          const SizedBox(width: AppSizes.sm),
                        ],
                        Text(
                          widget.label,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: _fgColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

