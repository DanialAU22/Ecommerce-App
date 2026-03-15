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

  TextSpan _highlightMatch(String title, String query) {
    if (query.trim().isEmpty) {
      return TextSpan(text: title);
    }

    final String lowerTitle = title.toLowerCase();
    final String lowerQuery = query.toLowerCase();
    final int start = lowerTitle.indexOf(lowerQuery);
    if (start < 0) {
      return TextSpan(text: title);
    }

    final int end = start + query.length;
    return TextSpan(
      children: <InlineSpan>[
        TextSpan(text: title.substring(0, start)),
        TextSpan(
          text: title.substring(start, end),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(text: title.substring(end)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool showEmptySearch = _controller.text.isEmpty;
    final SearchProvider searchProvider = context.watch<SearchProvider>();
    final List<String> suggestions = context
        .read<ProductProvider>()
        .products
        .map((Product p) => p.title)
        .where(
          (String title) => title
              .toLowerCase()
              .contains(_controller.text.trim().toLowerCase()),
        )
        .take(5)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Search Products')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _controller,
              onChanged: _search,
              onSubmitted: (String value) {
                context.read<SearchProvider>().addRecentSearch(value);
              },
              decoration: InputDecoration(
                hintText: 'Search by product title',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _controller.clear();
                          _search('');
                        },
                        icon: const Icon(Icons.clear),
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: showEmptySearch
                  ? ListView(
                      children: <Widget>[
                        const EmptyStateWidget(
                          message: 'Start typing to search products.',
                        ),
                        if (searchProvider.recentSearches.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 16),
                          const Text(
                            'Recent searches',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: searchProvider.recentSearches
                                .map(
                                  (String query) => ActionChip(
                                    label: Text(query),
                                    onPressed: () {
                                      _controller.text = query;
                                      _search(query);
                                    },
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ],
                    )
                  : _results.isEmpty
                      ? const EmptyStateWidget(message: 'No matching products found.')
                      : ListView(
                          children: <Widget>[
                            if (suggestions.isNotEmpty) ...<Widget>[
                              const Text(
                                'Suggestions',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 8),
                              ...suggestions.map(
                                (String title) => ListTile(
                                  dense: true,
                                  leading: const Icon(Icons.search_rounded),
                                  title: RichText(
                                    text: _highlightMatch(title, _controller.text.trim()),
                                  ),
                                  onTap: () {
                                    _controller.text = title;
                                    _search(title);
                                    context.read<SearchProvider>().addRecentSearch(title);
                                  },
                                ),
                              ),
                              const Divider(height: 18),
                            ],
                            GridView.builder(
                              itemCount: _results.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.72,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
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
