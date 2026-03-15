import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/cart_item_model.dart';

class CartItemWidget extends StatelessWidget {
  const CartItemWidget({
    super.key,
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  final CartItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 72,
            height: 72,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(14),
            ),
            child: CachedNetworkImage(
              imageUrl: item.product.image,
              fit: BoxFit.contain,
              errorWidget: (
                BuildContext context,
                String url,
                Object error,
              ) =>
                  const Icon(Icons.broken_image_rounded),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  '\$${item.product.price.toStringAsFixed(2)} each',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 6),
                Text(
                  '\$${item.lineTotal.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
          ),
          Column(
            children: <Widget>[
              IconButton(
                onPressed: onRemove,
                icon: Icon(Icons.delete_outline_rounded, color: scheme.error),
              ),
              Container(
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: onDecrease,
                      icon: const Icon(Icons.remove_rounded),
                    ),
                    Text(
                      '${item.quantity}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: onIncrease,
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
