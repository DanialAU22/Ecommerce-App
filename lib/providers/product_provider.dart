import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../repositories/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  ProductProvider({ProductRepository? repository})
      : _repository = repository ?? ProductRepository();

  final ProductRepository _repository;

  List<Product> _products = <Product>[];
  List<AppCategory> _categories = <AppCategory>[];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 0;
  String? _error;

  List<Product> get products => _products;
  List<AppCategory> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
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
        _repository.fetchPage(page: 0, pageSize: AppConstants.pageSize),
        _repository.fetchCategories(),
      ]);

      _products = responses[0] as List<Product>;
      _categories = responses[1] as List<AppCategory>;
      _currentPage = 0;
      _hasMore = _products.length >= AppConstants.pageSize;
    } catch (e) {
      _error = 'Failed to load products. Please try again.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMoreProducts() async {
    if (_isLoading || _isLoadingMore || !_hasMore) {
      return;
    }

    _isLoadingMore = true;
    notifyListeners();

    try {
      final List<Product> nextPage = await _repository.fetchPage(
        page: _currentPage + 1,
        pageSize: AppConstants.pageSize,
      );

      if (nextPage.isEmpty) {
        _hasMore = false;
      } else {
        final Set<int> existingIds = _products.map((Product e) => e.id).toSet();
        final List<Product> unique = nextPage
            .where((Product item) => !existingIds.contains(item.id))
            .toList();

        _products = <Product>[..._products, ...unique];
        _currentPage += 1;
        _hasMore = nextPage.length >= AppConstants.pageSize;
      }
    } catch (_) {
      _hasMore = false;
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<Product?> fetchProductById(int id) async {
    try {
      return await _repository.fetchProductById(id);
    } catch (_) {
      return null;
    }
  }

  Future<List<Product>> fetchProductsByCategory(String category) async {
    try {
      return await _repository.fetchByCategory(category);
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
