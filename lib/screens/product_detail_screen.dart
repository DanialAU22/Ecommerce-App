import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../models/review_model.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/product_provider.dart';
import '../providers/review_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/loading_skeleton.dart';
import '../widgets/price_tag.dart';
import '../widgets/product_card.dart';
import '../widgets/rating_stars.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    super.key,
    required this.productId,
    this.initialProduct,
  });

  final int productId;
  final Product? initialProduct;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _product;
  bool _isLoading = true;
  bool _expandedDescription = false;
  final TextEditingController _reviewController = TextEditingController();
  double _rating = 4;

  @override
  void initState() {
    super.initState();
    _product = widget.initialProduct;
    _load();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (_product == null) {
      _product = await context.read<ProductProvider>().fetchProductById(widget.productId);
      if (!mounted) {
        return;
      }
    }

    if (_product != null) {
      await context.read<ReviewProvider>().loadReviews(_product!.id);
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _submitReview(Product product) async {
    final String text = _reviewController.text.trim();
    if (text.isEmpty) {
      return;
    }

    final AuthProvider auth = context.read<AuthProvider>();
    final ReviewModel review = ReviewModel(
      productId: product.id,
      username: auth.isLoggedIn ? auth.displayName : 'Guest',
      text: text,
      rating: _rating,
      date: DateTime.now(),
    );

    await context.read<ReviewProvider>().addReview(review);
    _reviewController.clear();
    if (!mounted) {
      return;
    }

    setState(() {
      _rating = 4;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Product? product = _product;

    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      bottomNavigationBar: _isLoading || product == null
          ? null
          : _BottomActions(
              product: product,
            ),
      body: _isLoading
          ? const ProductDetailSkeleton()
          : product == null
              ? const Center(child: Text('Failed to load product details.'))
              : Consumer2<FavoriteProvider, ReviewProvider>(
                  builder: (
                    BuildContext context,
                    FavoriteProvider favoriteProvider,
                    ReviewProvider reviewProvider,
                    Widget? child,
                  ) {
                    final bool isFav = favoriteProvider.isFavorite(product.id);
                    final List<ReviewModel> reviews = reviewProvider.reviewsFor(product.id);
                    final DateFormat dateFormat = DateFormat('MMM d, y');

                    final List<Product> recommended = context
                        .watch<ProductProvider>()
                        .products
                        .where((Product item) => item.id != product.id)
                        .take(4)
                        .toList();
                    final int gridCount = MediaQuery.of(context).size.width >= 900
                      ? 4
                      : (MediaQuery.of(context).size.width >= 600 ? 3 : 2);
                    final double gridAspect =
                      MediaQuery.of(context).size.width >= 600 ? 0.64 : 0.58;

                    return ListView(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
                      children: <Widget>[
                        _ImageGallery(product: product),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                product.title,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            IconButton.filledTonal(
                              onPressed: () async {
                                await favoriteProvider.toggleFavorite(product);
                              },
                              icon: Icon(
                                isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                color: isFav ? Theme.of(context).colorScheme.error : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        RatingStars(
                          rating: product.rating.rate,
                          count: product.rating.count,
                          size: 18,
                        ),
                        const SizedBox(height: 10),
                        PriceTag(price: product.price, large: true),
                        const SizedBox(height: 18),
                        _ExpandableDescription(
                          text: product.description,
                          expanded: _expandedDescription,
                          onToggle: () {
                            setState(() => _expandedDescription = !_expandedDescription);
                          },
                        ),
                        const SizedBox(height: 20),
                        Text('Review Preview', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 10),
                        if (reviews.isEmpty)
                          _ReviewCard(
                            title: 'No reviews yet',
                            subtitle: 'Be the first customer to share an opinion.',
                          )
                        else
                          ...reviews.take(2).map(
                                (ReviewModel review) => _ReviewCard(
                                  title: review.username,
                                  subtitle: review.text,
                                  trailing: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      RatingStars(
                                        rating: review.rating,
                                        showCount: false,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        dateFormat.format(review.date),
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _reviewController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: 'Write a quick review',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Slider(
                                min: 1,
                                max: 5,
                                divisions: 4,
                                value: _rating,
                                label: _rating.toStringAsFixed(1),
                                onChanged: (double value) {
                                  setState(() => _rating = value);
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(_rating.toStringAsFixed(1)),
                          ],
                        ),
                        CustomButton(
                          label: 'Submit Review',
                          onPressed: () => _submitReview(product),
                          expanded: false,
                        ),
                        const SizedBox(height: 22),
                        Text(
                          'Recommended Products',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 10),
                        GridView.builder(
                          itemCount: recommended.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: gridCount,
                            childAspectRatio: gridAspect,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            final Product recommendedProduct = recommended[index];
                            return ProductCard(
                              product: recommendedProduct,
                              onTap: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute<void>(
                                    builder: (_) => ProductDetailScreen(
                                      productId: recommendedProduct.id,
                                      initialProduct: recommendedProduct,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
    );
  }
}

class _ImageGallery extends StatefulWidget {
  const _ImageGallery({required this.product});

  final Product product;

  @override
  State<_ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<_ImageGallery> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final List<String> images = <String>[
      widget.product.image,
      widget.product.image,
      widget.product.image,
    ];

    return Column(
      children: <Widget>[
        SizedBox(
          height: 300,
          child: PageView.builder(
            itemCount: images.length,
            onPageChanged: (int value) => setState(() => _index = value),
            itemBuilder: (BuildContext context, int index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.3),
                ),
                child: Hero(
                  tag: 'product-image-${widget.product.id}',
                  child: CachedNetworkImage(
                    imageUrl: images[index],
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List<Widget>.generate(
            images.length,
            (int index) => AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: index == _index ? 16 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: index == _index
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ExpandableDescription extends StatelessWidget {
  const _ExpandableDescription({
    required this.text,
    required this.expanded,
    required this.onToggle,
  });

  final String text;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 220),
      crossFadeState: expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      firstChild: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            text,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          TextButton(
            onPressed: onToggle,
            child: const Text('Read more'),
          ),
        ],
      ),
      secondChild: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(text, style: Theme.of(context).textTheme.bodyLarge),
          TextButton(
            onPressed: onToggle,
            child: const Text('Show less'),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          if (trailing != null) ...<Widget>[
            const SizedBox(width: 10),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class _BottomActions extends StatefulWidget {
  const _BottomActions({required this.product});

  final Product product;

  @override
  State<_BottomActions> createState() => _BottomActionsState();
}

class _BottomActionsState extends State<_BottomActions>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      lowerBound: 1,
      upperBound: 1.06,
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _addToCart() async {
    final CartProvider cartProvider = context.read<CartProvider>();
    await cartProvider.addToCart(widget.product);
    await _controller.forward();
    await _controller.reverse();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Added to cart')),
    );
  }

  Future<void> _buyNow() async {
    await _addToCart();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.14),
            ),
          ),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: CustomButton(
                label: 'Add to Cart',
                icon: Icons.add_shopping_cart_rounded,
                style: CustomButtonStyle.secondary,
                onPressed: _addToCart,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ScaleTransition(
                scale: _scale,
                child: CustomButton(
                  label: 'Buy Now',
                  icon: Icons.flash_on_rounded,
                  onPressed: _buyNow,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
