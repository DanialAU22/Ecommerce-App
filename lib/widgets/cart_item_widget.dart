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
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: <Widget>[
            CachedNetworkImage(
              imageUrl: item.product.image,
              width: 62,
              height: 62,
              fit: BoxFit.contain,
              errorWidget: (
                BuildContext context,
                String url,
                Object error,
              ) =>
                  const Icon(Icons.broken_image_rounded),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${item.product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFF0F9D58),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: <Widget>[
                IconButton(
                  onPressed: onDecrease,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('${item.quantity}'),
                IconButton(
                  onPressed: onIncrease,
                  icon: const Icon(Icons.add_circle_outline),
                ),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
