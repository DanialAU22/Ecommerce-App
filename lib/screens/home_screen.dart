import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/widgets/empty_state_widget.dart';
import '../core/widgets/network_error_screen.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../widgets/category_chip.dart';
import '../widgets/loading_skeleton.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedCategory;

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
          return NetworkErrorScreen(
            message: provider.error!,
            onRetry: _refresh,
          );
        }

        if (provider.products.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.storefront_outlined,
            title: 'No Products Yet',
            message: 'Pull down to refresh and load products.',
          );
        }

        final List<Product> base = _selectedCategory == null
            ? provider.products
            : provider.products
                .where((Product product) => product.category == _selectedCategory)
                .toList();

        final List<Product> trending = base.take(6).toList();
        final List<Product> bestSelling = List<Product>.from(base)
          ..sort((Product a, Product b) => b.rating.count.compareTo(a.rating.count));
        final List<Product> recommended = List<Product>.from(base)
          ..sort((Product a, Product b) => b.rating.rate.compareTo(a.rating.rate));

        final List<String> categoryNames = provider.categories.map((e) => e.name).toList();

        return RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: _SearchEntry(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const SearchScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _PromoCarousel(products: provider.featuredProducts),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                  child: SizedBox(
                    height: 42,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categoryNames.length + 1,
                      separatorBuilder: (BuildContext context, int index) => const SizedBox(width: 8),
                      itemBuilder: (BuildContext context, int index) {
                        if (index == 0) {
                          return CategoryChip(
                            label: 'All',
                            selected: _selectedCategory == null,
                            onTap: () => setState(() => _selectedCategory = null),
                          );
                        }
                        final String category = categoryNames[index - 1];
                        return CategoryChip(
                          label: category,
                          selected: _selectedCategory == category,
                          onTap: () => setState(() => _selectedCategory = category),
                        );
                      },
                    ),
                  ),
                ),
              ),
              _SectionHeaderSliver(title: 'Trending Products'),
              _ProductGridSliver(products: trending),
              _SectionHeaderSliver(title: 'Best Selling'),
              _ProductGridSliver(products: bestSelling.take(4).toList()),
              _SectionHeaderSliver(title: 'Recommended For You'),
              _ProductGridSliver(products: recommended.take(4).toList()),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoading() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        const LoadingSkeleton(height: 54, borderRadius: 16),
        const SizedBox(height: 16),
        const LoadingSkeleton(height: 168, borderRadius: 20),
        const SizedBox(height: 14),
        const CategoryListSkeleton(),
        const SizedBox(height: 18),
        GridView.builder(
          itemCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.58,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (BuildContext context, int index) => const ProductCardSkeleton(),
        ),
      ],
    );
  }
}

class _SearchEntry extends StatelessWidget {
  const _SearchEntry({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: <Widget>[
              const Icon(Icons.search_rounded),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Search products, categories, brands',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const Icon(Icons.tune_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromoCarousel extends StatelessWidget {
  const _PromoCarousel({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const LoadingSkeleton(height: 168, borderRadius: 20);
    }

    final List<Color> colors = <Color>[
      const Color(0xFF5B67F6),
      const Color(0xFF18C29C),
      const Color(0xFFFF8A65),
      const Color(0xFF7B61FF),
    ];

    return CarouselSlider.builder(
      itemCount: products.length,
      options: CarouselOptions(
        height: 168,
        autoPlay: true,
        viewportFraction: 1,
        enlargeCenterPage: false,
      ),
      itemBuilder: (BuildContext context, int index, int realIndex) {
        final Product product = products[index];
        final Color color = colors[index % colors.length];

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: <Color>[color, color.withValues(alpha: 0.75)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'FLASH DEAL',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                product.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                    ),
              ),
              const Spacer(),
              Text(
                'Up to 30% OFF',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeaderSliver extends StatelessWidget {
  const _SectionHeaderSliver({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}

class _ProductGridSliver extends StatelessWidget {
  const _ProductGridSliver({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final int crossAxisCount = width >= 900 ? 4 : (width >= 600 ? 3 : 2);
    final double aspect = width >= 600 ? 0.64 : 0.58;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: aspect,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final Product product = products[index];
            return ProductCard(
              product: product,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ProductDetailScreen(
                      productId: product.id,
                      initialProduct: product,
                    ),
                  ),
                );
              },
            );
          },
          childCount: products.length,
        ),
      ),
    );
  }
}
