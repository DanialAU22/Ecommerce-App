import 'dart:convert';

import 'product_model.dart';

class OrderModel {
  const OrderModel({
    required this.id,
    required this.items,
    required this.totalPrice,
    required this.date,
  });

  final int? id;
  final List<Product> items;
  final double totalPrice;
  final DateTime date;

  Map<String, dynamic> toDbMap() {
    return {
      if (id != null) 'id': id,
      'products_json': jsonEncode(items.map((Product e) => e.toJson()).toList()),
      'total_price': totalPrice,
      'order_date': date.toIso8601String(),
    };
  }

  factory OrderModel.fromDbMap(Map<String, dynamic> map) {
    final List<dynamic> decoded =
        jsonDecode(map['products_json']?.toString() ?? '[]') as List<dynamic>;

    return OrderModel(
      id: (map['id'] as num?)?.toInt(),
      items: decoded
          .map((dynamic item) => Product.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalPrice: (map['total_price'] as num?)?.toDouble() ?? 0,
      date: DateTime.tryParse(map['order_date']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
