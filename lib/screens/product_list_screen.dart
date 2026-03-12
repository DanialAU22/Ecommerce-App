import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../providers/product_provider.dart';
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
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
        _isLoading = false;
      });
      return;
    }

    if (widget.products != null) {
      setState(() {
        _products = widget.products!;
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
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
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
            : _products.isEmpty
                ? ListView(
                    children: const <Widget>[
                      SizedBox(height: 120),
                      Center(child: Text('No products found.')),
                    ],
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _products.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      final Product product = _products[index];
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
  }
}
