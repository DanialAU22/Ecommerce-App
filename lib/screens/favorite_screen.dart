import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/favorite_provider.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoriteProvider>().loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoriteProvider>(
      builder: (
        BuildContext context,
        FavoriteProvider provider,
        Widget? child,
      ) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.favorites.isEmpty) {
          return const Center(
            child: Text('No favorite products yet.'),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.favorites.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.72,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (BuildContext context, int index) {
            final product = provider.favorites[index];
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
        );
      },
    );
  }
}
