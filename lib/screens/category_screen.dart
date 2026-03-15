import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/widgets/empty_state_widget.dart';
import '../providers/product_provider.dart';
import '../widgets/category_card.dart';
import '../widgets/loading_skeleton.dart';
import 'product_list_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (BuildContext context, ProductProvider provider, Widget? child) {
        if (provider.isLoading && provider.categories.isEmpty) {
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 6,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (BuildContext context, int index) =>
                const LoadingSkeleton(),
          );
        }

        if (provider.categories.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.grid_view_rounded,
            title: 'No Categories',
            message: 'Categories will appear here when data is available.',
          );
        }

        return RefreshIndicator(
          onRefresh: provider.refresh,
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (BuildContext context, int index) {
              final String category = provider.categories[index].name;
              return CategoryCard(
                title: category,
                onTap: () {
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
        );
      },
    );
  }
}
