import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/helpers/debouncer.dart';
import '../core/widgets/empty_state_widget.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../providers/search_provider.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final Debouncer _debouncer = Debouncer();
  List<Product> _results = <Product>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.wait<void>(<Future<void>>[
        context.read<ProductProvider>().initialize(),
        context.read<SearchProvider>().loadRecentSearches(),
      ]);
      _search('');
    });
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _search(String value) {
    _debouncer.run(() {
      final ProductProvider provider = context.read<ProductProvider>();
      if (!mounted) {
        return;
      }
      setState(() {
        _results = provider.searchProducts(value);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final SearchProvider searchProvider = context.watch<SearchProvider>();
    final ProductProvider productProvider = context.watch<ProductProvider>();
    final String query = _controller.text.trim();
    final bool isIdle = query.isEmpty;

    final List<String> suggestions = productProvider.products
        .map((Product p) => p.title)
        .where((String title) => title.toLowerCase().contains(query.toLowerCase()))
        .take(6)
        .toList();

    final List<Product> popular = List<Product>.from(productProvider.products)
      ..sort((Product a, Product b) => b.rating.count.compareTo(a.rating.count));
    final int gridCount = MediaQuery.of(context).size.width >= 900
      ? 4
      : (MediaQuery.of(context).size.width >= 600 ? 3 : 2);
    final double gridAspect = MediaQuery.of(context).size.width >= 600 ? 0.64 : 0.58;

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _controller,
              onChanged: _search,
              onSubmitted: (String value) {
                context.read<SearchProvider>().addRecentSearch(value);
              },
              decoration: InputDecoration(
                hintText: 'Search products and brands',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: query.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _controller.clear();
                          _search('');
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: isIdle
                  ? ListView(
                      children: <Widget>[
                        if (searchProvider.recentSearches.isNotEmpty) ...<Widget>[
                          Text('Recent Searches', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: searchProvider.recentSearches
                                .map(
                                  (String item) => ActionChip(
                                    label: Text(item),
                                    avatar: const Icon(Icons.history_rounded, size: 16),
                                    onPressed: () {
                                      _controller.text = item;
                                      _search(item);
                                    },
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 20),
                        ],
                        Text('Popular Products', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 10),
                        GridView.builder(
                          itemCount: popular.take(4).length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: gridCount,
                            childAspectRatio: gridAspect,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            final Product product = popular[index];
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
                        ),
                      ],
                    )
                  : _results.isEmpty
                      ? const EmptyStateWidget(
                          icon: Icons.search_off_rounded,
                          title: 'No Results Found',
                          message: 'Try another keyword, category, or product name.',
                        )
                      : ListView(
                          children: <Widget>[
                            if (suggestions.isNotEmpty) ...<Widget>[
                              Text('Suggestions', style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  children: suggestions
                                      .map(
                                        (String title) => ListTile(
                                          dense: true,
                                          leading: const Icon(Icons.search_rounded),
                                          title: Text(title),
                                          onTap: () {
                                            _controller.text = title;
                                            _search(title);
                                            context
                                                .read<SearchProvider>()
                                                .addRecentSearch(title);
                                          },
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                            GridView.builder(
                              itemCount: _results.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: gridCount,
                                childAspectRatio: gridAspect,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemBuilder: (BuildContext context, int index) {
                                final Product product = _results[index];
                                return ProductCard(
                                  product: product,
                                  onTap: () {
                                    context
                                        .read<SearchProvider>()
                                        .addRecentSearch(_controller.text);
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
                            ),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
