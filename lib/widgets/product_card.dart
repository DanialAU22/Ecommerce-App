import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/favorite_provider.dart';
import 'custom_button.dart';
import 'loading_skeleton.dart';
import 'price_tag.dart';
import 'rating_stars.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  final Product product;
  final VoidCallback onTap;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Consumer2<CartProvider, FavoriteProvider>(
      builder: (
        BuildContext context,
        CartProvider cartProvider,
        FavoriteProvider favoriteProvider,
        Widget? child,
      ) {
        final bool isFavorite = favoriteProvider.isFavorite(widget.product.id);

        return AnimatedScale(
          duration: const Duration(milliseconds: 130),
          scale: _pressed ? 0.98 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: scheme.surface,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: scheme.shadow.withValues(alpha: _pressed ? 0.05 : 0.09),
                  blurRadius: _pressed ? 10 : 18,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(color: scheme.outline.withValues(alpha: 0.12)),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: widget.onTap,
              onHighlightChanged: (bool value) {
                setState(() => _pressed = value);
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton.filledTonal(
                        visualDensity: VisualDensity.compact,
                        style: IconButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () async {
                          await favoriteProvider.toggleFavorite(widget.product);
                        },
                        icon: Icon(
                          isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isFavorite ? scheme.error : scheme.onSurface,
                          size: 18,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Hero(
                          tag: 'product-image-${widget.product.id}',
                          child: CachedNetworkImage(
                            imageUrl: widget.product.image,
                            fit: BoxFit.contain,
                            placeholder: (BuildContext context, String url) =>
                                const LoadingSkeleton(height: 90, width: 90),
                            errorWidget: (
                              BuildContext context,
                              String url,
                              Object error,
                            ) =>
                                const Icon(Icons.broken_image_rounded),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        Expanded(child: PriceTag(price: widget.product.price)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    RatingStars(
                      rating: widget.product.rating.rate,
                      count: widget.product.rating.count,
                      showCount: false,
                    ),
                    const SizedBox(height: 8),
                    CustomButton(
                      label: 'Add to Cart',
                      icon: Icons.add_shopping_cart_rounded,
                      expanded: true,
                      onPressed: () async {
                        final ScaffoldMessengerState messenger =
                            ScaffoldMessenger.of(context);
                        await cartProvider.addToCart(widget.product);
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('${widget.product.title} added to cart'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
