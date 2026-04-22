import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Animated gold star rating widget.
class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final bool showValue;
  final Color activeColor;
  final Color inactiveColor;

  const StarRating({
    super.key,
    required this.rating,
    this.size = 16,
    this.showValue = true,
    this.activeColor = AppColors.accent,
    this.inactiveColor = AppColors.divider,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (i) {
          final filled = i < rating.floor();
          final half = !filled && (i < rating) && (rating - i >= 0.5);
          return Icon(
            half ? Icons.star_half_rounded : filled ? Icons.star_rounded : Icons.star_outline_rounded,
            color: (filled || half) ? activeColor : inactiveColor,
            size: size,
          );
        }),
        if (showValue) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size - 2,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ],
    );
  }
}
