import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/widgets/empty_state_widget.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../viewmodels/product_filter_viewmodel.dart';
import '../widgets/loading_skeleton.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({
    super.key,
    required this.title,
    this.category,
    this.products,
  });

  final String title;
  final String? category;
  final List<Product>? products;

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> _products = <Product>[];
  List<Product> _visibleProducts = <Product>[];
  bool _isLoading = true;
  late final ScrollController _scrollController;
  ProductFilterViewModel _filter = const ProductFilterViewModel();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _loadProducts();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || widget.products != null || widget.category != null) {
      return;
    }

    final ProductProvider provider = context.read<ProductProvider>();
    final double threshold = _scrollController.position.maxScrollExtent - 240;
    if (_scrollController.position.pixels >= threshold) {
      provider.loadMoreProducts();
    }
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    if (widget.category != null) {
      final List<Product> byCategory =
          await context.read<ProductProvider>().fetchProductsByCategory(
                widget.category!,
              );
      if (!mounted) {
        return;
      }
      setState(() {
        _products = byCategory;
        _applyFilters();
        _isLoading = false;
      });
      return;
    }

    if (widget.products != null) {
      setState(() {
        _products = widget.products!;
        _applyFilters();
        _isLoading = false;
      });
      return;
    }

    final provider = context.read<ProductProvider>();
    await provider.initialize();
    if (!mounted) {
      return;
    }
    setState(() {
      _products = provider.products;
      _applyFilters();
      _isLoading = false;
    });
  }

  void _applyFilters() {
    List<Product> filtered = _products.where((Product product) {
      final bool inPrice = product.price >= _filter.minPrice &&
          product.price <= _filter.maxPrice;
      final bool inRating = product.rating.rate >= _filter.minRating;
      final bool inCategory = _filter.category == null ||
          _filter.category == 'All' ||
          product.category == _filter.category;
      return inPrice && inRating && inCategory;
    }).toList();

    switch (_filter.sortOption) {
      case ProductSortOption.priceLowToHigh:
        filtered.sort((Product a, Product b) => a.price.compareTo(b.price));
      case ProductSortOption.priceHighToLow:
        filtered.sort((Product a, Product b) => b.price.compareTo(a.price));
      case ProductSortOption.rating:
        filtered.sort((Product a, Product b) => b.rating.rate.compareTo(a.rating.rate));
      case ProductSortOption.none:
        break;
    }

    _visibleProducts = filtered;
  }

  Future<void> _openFilters(ProductProvider provider) async {
    double min = _filter.minPrice;
    double max = _filter.maxPrice;
    double minRating = _filter.minRating;
    String selectedCategory = _filter.category ?? 'All';
    ProductSortOption sort = _filter.sortOption;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final List<String> categories = <String>[
              'All',
              ...provider.categories.map((e) => e.name),
            ];

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('Filters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Text('Price: \$${min.round()} - \$${max.round()}'),
                  RangeSlider(
                    min: 0,
                    max: 1000,
                    values: RangeValues(min, max),
                    onChanged: (RangeValues values) {
                      setModalState(() {
                        min = values.start;
                        max = values.end;
                      });
                    },
                  ),
                  Text('Minimum rating: ${minRating.toStringAsFixed(1)}'),
                  Slider(
                    min: 0,
                    max: 5,
                    divisions: 10,
                    value: minRating,
                    onChanged: (double value) {
                      setModalState(() {
                        minRating = value;
                      });
                    },
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: categories
                        .map((String c) => DropdownMenuItem<String>(
                              value: c,
                              child: Text(c),
                            ))
                        .toList(),
                    onChanged: (String? value) {
                      if (value == null) {
                        return;
                      }
                      setModalState(() {
                        selectedCategory = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<ProductSortOption>(
                    initialValue: sort,
                    decoration: const InputDecoration(labelText: 'Sort by'),
                    items: const <DropdownMenuItem<ProductSortOption>>[
                      DropdownMenuItem(value: ProductSortOption.none, child: Text('Default')),
                      DropdownMenuItem(value: ProductSortOption.priceLowToHigh, child: Text('Price: Low to High')),
                      DropdownMenuItem(value: ProductSortOption.priceHighToLow, child: Text('Price: High to Low')),
                      DropdownMenuItem(value: ProductSortOption.rating, child: Text('Rating')),
                    ],
                    onChanged: (ProductSortOption? value) {
                      if (value == null) {
                        return;
                      }
                      setModalState(() {
                        sort = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () {
                      setState(() {
                        _filter = _filter.copyWith(
                          minPrice: min,
                          maxPrice: max,
                          minRating: minRating,
                          category: selectedCategory == 'All' ? null : selectedCategory,
                          sortOption: sort,
                        );
                        _applyFilters();
                      });
                      Navigator.of(context).pop();
                    },
                    child: const Text('Apply'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (BuildContext context, ProductProvider provider, Widget? child) {
        if (!_isLoading && widget.products == null && widget.category == null) {
          _products = provider.products;
          _applyFilters();
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            actions: <Widget>[
              IconButton(
                onPressed: () => _openFilters(provider),
                icon: const Icon(Icons.filter_alt_outlined),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _loadProducts,
            child: _isLoading
                ? GridView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: 6,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (BuildContext context, int index) =>
                        const LoadingSkeleton(),
                  )
                : _visibleProducts.isEmpty
                    ? ListView(
                        children: const <Widget>[
                          SizedBox(height: 120),
                          EmptyStateWidget(message: 'No products match current filters.'),
                        ],
                      )
                    : GridView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _visibleProducts.length +
                            ((widget.products == null && widget.category == null && provider.isLoadingMore)
                                ? 1
                                : 0),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          if (index >= _visibleProducts.length) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          final Product product = _visibleProducts[index];
                          return ProductCard(
                            product: product,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (BuildContext context) =>
                                    ProductDetailScreen(
                                  productId: product.id,
                                  initialProduct: product,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        );
      },
    );
  }
}
