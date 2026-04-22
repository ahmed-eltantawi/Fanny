import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

/// Shimmer skeleton for request card list.
class ShimmerRequestList extends StatelessWidget {
  final int count;
  const ShimmerRequestList({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSizes.md),
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
      itemBuilder: (_, __) => const _ShimmerCard(),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        height: AppSizes.requestCardHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        ),
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _box(40, 40, radius: AppSizes.radiusFull),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _box(16, double.infinity),
                      const SizedBox(height: 6),
                      _box(12, 120),
                    ],
                  ),
                ),
                _box(28, 70, radius: AppSizes.radiusFull),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            _box(12, double.infinity),
            const SizedBox(height: 6),
            _box(12, 180),
          ],
        ),
      ),
    );
  }

  Widget _box(double h, double w, {double radius = AppSizes.radiusSM}) => Container(
    height: h, width: w,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}

/// Generic shimmer box.
class ShimmerBox extends StatelessWidget {
  final double height;
  final double width;
  final double radius;

  const ShimmerBox({
    super.key,
    required this.height,
    this.width = double.infinity,
    this.radius = AppSizes.radiusMD,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        height: height, width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

/// Grid shimmer for category cards.
class ShimmerCategoryGrid extends StatelessWidget {
  const ShimmerCategoryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: AppSizes.sm,
        crossAxisSpacing: AppSizes.sm,
        childAspectRatio: 0.85,
      ),
      itemCount: 8,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: AppColors.shimmerBase,
        highlightColor: AppColors.shimmerHighlight,
        child: Column(
          children: [
            Container(
              height: AppSizes.categoryCardSize - 10,
              width: AppSizes.categoryCardSize - 10,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              ),
            ),
            const SizedBox(height: 6),
            Container(height: 10, width: 50, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
