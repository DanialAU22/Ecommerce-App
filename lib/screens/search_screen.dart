import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Product> _results = <Product>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<ProductProvider>().initialize();
      _search('');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search(String value) {
    final provider = context.read<ProductProvider>();
    setState(() {
      _results = provider.searchProducts(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool showEmptySearch = _controller.text.isEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Search Products')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _controller,
              onChanged: _search,
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
                  ? const Center(
                      child: Text('Start typing to search products.'),
                    )
                  : _results.isEmpty
                      ? const Center(child: Text('No matching products found.'))
                      : GridView.builder(
                          itemCount: _results.length,
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
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => ProductDetailScreen(
                                    productId: product.id,
                                    initialProduct: product,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
