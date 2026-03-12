import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';
import '../widgets/loading_skeleton.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';
import 'product_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().initialize();
    });
  }

  Future<void> _refresh() async {
    await context.read<ProductProvider>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (BuildContext context, ProductProvider provider, Widget? child) {
        if (provider.isLoading && provider.products.isEmpty) {
          return _buildLoading();
        }

        if (provider.error != null && provider.products.isEmpty) {
          return _buildError(provider.error!);
        }

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              const Text(
                'Categories',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: provider.categories.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (BuildContext context, int index) {
                    final String category = provider.categories[index].name;
                    return ActionChip(
                      label: Text(category),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) => ProductListScreen(
                              title: category,
                              category: category,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              _sectionHeader('Featured Products', () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => ProductListScreen(
                      title: 'Featured Products',
                      products: provider.featuredProducts,
                    ),
                  ),
                );
              }),
              const SizedBox(height: 10),
              SizedBox(
                height: 235,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: provider.featuredProducts.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      const SizedBox(width: 10),
                  itemBuilder: (BuildContext context, int index) {
                    final product = provider.featuredProducts[index];
                    return SizedBox(
                      width: 165,
                      child: ProductCard(
                        product: product,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) => ProductDetailScreen(
                              productId: product.id,
                              initialProduct: product,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              _sectionHeader('Latest Products', () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => ProductListScreen(
                      title: 'Latest Products',
                      products: provider.latestProducts,
                    ),
                  ),
                );
              }),
              const SizedBox(height: 10),
              GridView.builder(
                itemCount: provider.latestProducts.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (BuildContext context, int index) {
                  final product = provider.latestProducts[index];
                  return ProductCard(
                    product: product,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => ProductDetailScreen(
                          productId: product.id,
                          initialProduct: product,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoading() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const <Widget>[
        LoadingSkeleton(height: 28, width: 140),
        SizedBox(height: 10),
        LoadingSkeleton(height: 46),
        SizedBox(height: 18),
        LoadingSkeleton(height: 28, width: 180),
        SizedBox(height: 10),
        LoadingSkeleton(height: 230),
      ],
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.error_outline, size: 42, color: Colors.redAccent),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _refresh,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, VoidCallback onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextButton(onPressed: onSeeAll, child: const Text('See all')),
      ],
    );
  }
}
