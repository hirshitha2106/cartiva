import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final int? reviewsCount;
  final double starSize;
  final bool showText;

  const RatingStars({
    super.key,
    required this.rating,
    this.reviewsCount,
    this.starSize = 14,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.star_rounded,
          color: AppColors.accentGold,
          size: starSize,
        ),
        const SizedBox(width: 4),
        if (showText) ...[
          Text(
            rating.toStringAsFixed(1),
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.accentGold,
            ),
          ),
          if (reviewsCount != null) ...[
            const SizedBox(width: 4),
            Text(
              '($reviewsCount)',
              style: AppTypography.bodySmall.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextMuted
                    : AppColors.lightTextMuted,
              ),
            ),
          ],
        ],
      ],
    );
  }
}
