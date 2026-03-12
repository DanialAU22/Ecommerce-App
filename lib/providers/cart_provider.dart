import 'package:flutter/foundation.dart';

import '../database/sqlite_helper.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';

class CartProvider extends ChangeNotifier {
  final Map<int, CartItem> _items = <int, CartItem>{};
  bool _isLoading = false;

  Map<int, CartItem> get items => _items;
  bool get isLoading => _isLoading;

  List<CartItem> get cartItems => _items.values.toList();

  int get itemCount =>
      _items.values.fold<int>(0, (int sum, CartItem item) => sum + item.quantity);

  double get totalPrice => _items.values.fold<double>(
        0,
        (double sum, CartItem item) => sum + item.lineTotal,
      );

  Future<void> loadCart() async {
    _setLoading(true);
    try {
      final List<Map<String, dynamic>> rows =
          await SQLiteHelper.instance.getCartItems();
      _items.clear();

      for (final Map<String, dynamic> row in rows) {
        final int quantity = (row['quantity'] as num?)?.toInt() ?? 1;
        final Product product = Product.fromDbMap(row);
        _items[product.id] = CartItem(product: product, quantity: quantity);
      }
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addToCart(Product product) async {
    final CartItem? existing = _items[product.id];
    final int quantity = (existing?.quantity ?? 0) + 1;

    _items[product.id] = CartItem(product: product, quantity: quantity);
    notifyListeners();

    await SQLiteHelper.instance.upsertCartItem({
      ...product.toDbMap(),
      'quantity': quantity,
    });
  }

  Future<void> removeFromCart(int productId) async {
    _items.remove(productId);
    notifyListeners();
    await SQLiteHelper.instance.removeCartItem(productId);
  }

  Future<void> updateQuantity(int productId, int quantity) async {
    final CartItem? item = _items[productId];
    if (item == null) {
      return;
    }

    if (quantity <= 0) {
      await removeFromCart(productId);
      return;
    }

    _items[productId] = item.copyWith(quantity: quantity);
    notifyListeners();
    await SQLiteHelper.instance.updateCartItemQuantity(productId, quantity);
  }

  Future<void> clearCart() async {
    _items.clear();
    notifyListeners();
    await SQLiteHelper.instance.clearCart();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
