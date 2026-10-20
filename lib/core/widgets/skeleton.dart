import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tv_show_tracker/core/theme/app_colors.dart';

class SkeletonShimmer extends StatelessWidget {
  const SkeletonShimmer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceHigh,
      highlightColor: AppColors.shimmerHighlight,
      child: child,
    );
  }
}

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({super.key, this.width, this.height, this.radius = 12});

  final double? width;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
