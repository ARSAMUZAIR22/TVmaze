import 'package:flutter/material.dart';
import 'package:tv_show_tracker/core/theme/app_colors.dart';

class RatingBadge extends StatelessWidget {
  const RatingBadge({super.key, required this.rating});

  final String rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.scrim,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 12, color: AppColors.star),
          const SizedBox(width: 2),
          Text(
            rating,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
