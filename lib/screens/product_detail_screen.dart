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
import '../widgets/loading_skeleton.dart';

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
    if (_product != null) {
      setState(() => _isLoading = false);
      return;
    }

    final Product? fetched =
        await context.read<ProductProvider>().fetchProductById(widget.productId);
    if (!mounted) {
      return;
    }

    setState(() {
      _product = fetched;
      _isLoading = false;
    });

    if (fetched != null) {
      await context.read<ReviewProvider>().loadReviews(fetched.id);
    }
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
    if (mounted) {
      setState(() {
        _rating = 4;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Product? product = _product;

    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: _isLoading
          ? ListView(
              padding: const EdgeInsets.all(16),
              children: const <Widget>[
                LoadingSkeleton(height: 250),
                SizedBox(height: 14),
                LoadingSkeleton(height: 24, width: 230),
                SizedBox(height: 8),
                LoadingSkeleton(height: 20, width: 90),
                SizedBox(height: 8),
                LoadingSkeleton(height: 84),
              ],
            )
          : product == null
              ? const Center(child: Text('Failed to load product details.'))
              : Consumer3<CartProvider, FavoriteProvider, ReviewProvider>(
                  builder: (
                    BuildContext context,
                    CartProvider cartProvider,
                    FavoriteProvider favoriteProvider,
                    ReviewProvider reviewProvider,
                    Widget? child,
                  ) {
                    final bool isFav = favoriteProvider.isFavorite(product.id);
                    final List<ReviewModel> reviews =
                        reviewProvider.reviewsFor(product.id);
                    final DateFormat dateFormat = DateFormat('MMM d, y');
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            width: double.infinity,
                            height: 260,
                            child: Hero(
                              tag: 'product-image-${product.id}',
                              child: CachedNetworkImage(
                                imageUrl: product.image,
                                fit: BoxFit.contain,
                                errorWidget: (
                                  BuildContext context,
                                  String url,
                                  Object error,
                                ) => const Icon(
                                  Icons.broken_image_rounded,
                                  size: 60,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            product.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F9D58),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: <Widget>[
                              Chip(label: Text(product.category)),
                              const SizedBox(width: 8),
                              Row(
                                children: <Widget>[
                                  const Icon(
                                    Icons.star_rounded,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${product.rating.rate} (${product.rating.count})',
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            product.description,
                            style: const TextStyle(height: 1.45),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    final messenger =
                                        ScaffoldMessenger.of(context);
                                    await cartProvider.addToCart(product);
                                    messenger.showSnackBar(
                                      const SnackBar(
                                        content: Text('Added to cart'),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.shopping_cart_checkout),
                                  label: const Text('Add to Cart'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              IconButton.filledTonal(
                                onPressed: () async {
                                  await favoriteProvider.toggleFavorite(product);
                                },
                                icon: Icon(
                                  isFav
                                      ? Icons.favorite
                                      : Icons.favorite_border_rounded,
                                  color: isFav ? Colors.red : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Reviews',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: <Widget>[
                              ...List<Widget>.generate(
                                5,
                                (int index) => IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _rating = index + 1.0;
                                    });
                                  },
                                  icon: Icon(
                                    Icons.star_rounded,
                                    color: _rating >= index + 1
                                        ? Colors.amber
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          TextField(
                            controller: _reviewController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              hintText: 'Write your review',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          FilledButton.tonal(
                            onPressed: () => _submitReview(product),
                            child: const Text('Add Review'),
                          ),
                          const SizedBox(height: 12),
                          if (reviews.isEmpty)
                            const Text('No reviews yet. Be the first to review.')
                          else
                            ...reviews.map(
                              (ReviewModel review) => Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  title: Text(review.username),
                                  subtitle: Text(review.text),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      Text(
                                        review.rating.toStringAsFixed(1),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        dateFormat.format(review.date),
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
