import 'package:flutter/foundation.dart';

import '../database/sqlite_helper.dart';
import '../models/product_model.dart';

class FavoriteProvider extends ChangeNotifier {
  final List<Product> _favorites = <Product>[];
  bool _isLoading = false;

  List<Product> get favorites => _favorites;
  bool get isLoading => _isLoading;

  bool isFavorite(int productId) {
    return _favorites.any((Product product) => product.id == productId);
  }

  Future<void> loadFavorites() async {
    _setLoading(true);
    try {
      final List<Map<String, dynamic>> rows =
          await SQLiteHelper.instance.getFavorites();
      _favorites
        ..clear()
        ..addAll(rows.map(Product.fromDbMap));
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleFavorite(Product product) async {
    if (isFavorite(product.id)) {
      _favorites.removeWhere((Product item) => item.id == product.id);
      notifyListeners();
      await SQLiteHelper.instance.removeFavorite(product.id);
      return;
    }

    _favorites.insert(0, product);
    notifyListeners();
    await SQLiteHelper.instance.insertFavorite(product.toDbMap());
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
