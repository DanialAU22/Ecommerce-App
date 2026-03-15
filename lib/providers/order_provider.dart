import 'package:flutter/foundation.dart';

import '../models/order_model.dart';
import '../models/product_model.dart';
import '../repositories/order_repository.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider({OrderRepository? orderRepository})
      : _orderRepository = orderRepository ?? OrderRepository();

  final OrderRepository _orderRepository;

  final List<OrderModel> _orders = <OrderModel>[];
  bool _isLoading = false;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;

  Future<void> loadOrders() async {
    _setLoading(true);
    try {
      final List<OrderModel> loaded = await _orderRepository.getOrders();
      _orders
        ..clear()
        ..addAll(loaded);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> placeOrder(List<Product> products, double totalPrice) async {
    final OrderModel order = OrderModel(
      id: null,
      items: products,
      totalPrice: totalPrice,
      date: DateTime.now(),
    );

    await _orderRepository.placeOrder(order);
    await loadOrders();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
