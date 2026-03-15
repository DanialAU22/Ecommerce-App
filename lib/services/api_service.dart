import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants/app_constants.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Product>> fetchProducts() async {
    final uri = Uri.parse('${AppConstants.baseUrl}/products');
    final response = await _client.get(uri).timeout(AppConstants.apiTimeout);

    _throwIfNotSuccessful(response);

    final List<dynamic> decoded = jsonDecode(response.body) as List<dynamic>;
    return decoded
        .map((dynamic item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Product> fetchProductById(int id) async {
    final uri = Uri.parse('${AppConstants.baseUrl}/products/$id');
    final response = await _client.get(uri).timeout(AppConstants.apiTimeout);

    _throwIfNotSuccessful(response);

    final Map<String, dynamic> decoded =
        jsonDecode(response.body) as Map<String, dynamic>;
    return Product.fromJson(decoded);
  }

  Future<List<AppCategory>> fetchCategories() async {
    final uri = Uri.parse('${AppConstants.baseUrl}/products/categories');
    final response = await _client.get(uri).timeout(AppConstants.apiTimeout);

    _throwIfNotSuccessful(response);

    final List<dynamic> decoded = jsonDecode(response.body) as List<dynamic>;
    return decoded.map((dynamic item) => AppCategory.fromJson(item)).toList();
  }

  Future<List<Product>> fetchProductsByCategory(String category) async {
    final uri = Uri.parse(
      '${AppConstants.baseUrl}/products/category/${Uri.encodeComponent(category)}',
    );
    final response = await _client.get(uri).timeout(AppConstants.apiTimeout);

    _throwIfNotSuccessful(response);

    final List<dynamic> decoded = jsonDecode(response.body) as List<dynamic>;
    return decoded
        .map((dynamic item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  void _throwIfNotSuccessful(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw Exception(
      'Request failed with status ${response.statusCode}: ${response.reasonPhrase}',
    );
  }
}
