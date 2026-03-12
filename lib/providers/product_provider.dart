import 'package:flutter/foundation.dart';

import '../models/category_model.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class ProductProvider extends ChangeNotifier {
  ProductProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  List<Product> _products = <Product>[];
  List<AppCategory> _categories = <AppCategory>[];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  List<AppCategory> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Product> get featuredProducts =>
      _products.take(AppConstants.featuredProductsCount).toList();

  List<Product> get latestProducts {
    final List<Product> sorted = List<Product>.from(_products)
      ..sort((Product a, Product b) => b.id.compareTo(a.id));
    return sorted.take(AppConstants.latestProductsCount).toList();
  }

  Future<void> initialize() async {
    if (_products.isNotEmpty && _categories.isNotEmpty) {
      return;
    }
    await refresh();
  }

  Future<void> refresh() async {
    _setLoading(true);
    _error = null;

    try {
      final List<dynamic> responses = await Future.wait<dynamic>(<Future<dynamic>>[
        _apiService.fetchProducts(),
        _apiService.fetchCategories(),
      ]);

      _products = responses[0] as List<Product>;
      _categories = responses[1] as List<AppCategory>;
    } catch (e) {
      _error = 'Failed to load products. Please try again.';
    } finally {
      _setLoading(false);
    }
  }

  Future<Product?> fetchProductById(int id) async {
    try {
      return await _apiService.fetchProductById(id);
    } catch (_) {
      return null;
    }
  }

  Future<List<Product>> fetchProductsByCategory(String category) async {
    try {
      return await _apiService.fetchProductsByCategory(category);
    } catch (_) {
      return <Product>[];
    }
  }

  List<Product> searchProducts(String query) {
    final String normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return _products;
    }

    return _products
        .where(
          (Product product) =>
              product.title.toLowerCase().contains(normalizedQuery),
        )
        .toList();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
