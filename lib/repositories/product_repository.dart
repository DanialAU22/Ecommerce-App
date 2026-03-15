import '../models/category_model.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

class ProductRepository {
  ProductRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<List<Product>> fetchAllProducts() => _apiService.fetchProducts();

  Future<Product> fetchProductById(int id) => _apiService.fetchProductById(id);

  Future<List<AppCategory>> fetchCategories() => _apiService.fetchCategories();

  Future<List<Product>> fetchByCategory(String category) {
    return _apiService.fetchProductsByCategory(category);
  }

  Future<List<Product>> fetchPage({
    required int page,
    required int pageSize,
  }) async {
    final List<Product> all = await _apiService.fetchProducts();
    final int start = page * pageSize;
    if (start >= all.length) {
      return <Product>[];
    }
    final int end = (start + pageSize).clamp(0, all.length);
    return all.sublist(start, end);
  }
}
