import 'package:flutter/material.dart';

class PriceTag extends StatelessWidget {
  const PriceTag({
    super.key,
    required this.price,
    this.large = false,
  });

  final double price;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 14 : 10,
        vertical: large ? 8 : 6,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: scheme.primary.withValues(alpha: 0.12),
      ),
      child: Text(
        '\$${price.toStringAsFixed(2)}',
        style: (large
                ? Theme.of(context).textTheme.titleLarge
                : Theme.of(context).textTheme.titleMedium)
            ?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}