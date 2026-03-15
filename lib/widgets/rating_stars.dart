import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.rating,
    this.count,
    this.size = 14,
    this.showCount = true,
  });

  final double rating;
  final int? count;
  final double size;
  final bool showCount;

  @override
  Widget build(BuildContext context) {
    final int full = rating.floor().clamp(0, 5);
    final bool hasHalf = (rating - full) >= 0.5 && full < 5;
    final int empty = 5 - full - (hasHalf ? 1 : 0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ...List<Widget>.generate(
          full,
          (_) => Icon(Icons.star_rounded, color: AppColors.star, size: size),
        ),
        if (hasHalf)
          Icon(
            Icons.star_half_rounded,
            color: AppColors.star,
            size: size,
          ),
        ...List<Widget>.generate(
          empty,
          (_) => Icon(
            Icons.star_outline_rounded,
            color: Theme.of(context).colorScheme.outline,
            size: size,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          showCount && count != null
              ? '${rating.toStringAsFixed(1)} ($count)'
              : rating.toStringAsFixed(1),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}