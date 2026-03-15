import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/widgets/empty_state_widget.dart';
import '../providers/favorite_provider.dart';
import '../widgets/loading_skeleton.dart';
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
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 4,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.58,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (BuildContext context, int index) => const ProductCardSkeleton(),
          );
        }

        if (provider.favorites.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.favorite_outline_rounded,
            title: 'No Favorites Yet',
            message: 'Products you love will appear here for quick access.',
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.favorites.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width >= 900
                ? 4
                : (MediaQuery.of(context).size.width >= 600 ? 3 : 2),
            childAspectRatio: MediaQuery.of(context).size.width >= 600 ? 0.64 : 0.58,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
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
