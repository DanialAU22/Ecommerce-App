// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:ecommerce_app/models/product_model.dart';

void main() {
  test('Product model parses JSON safely', () {
    const Map<String, dynamic> json = <String, dynamic>{
      'id': 1,
      'title': 'Test Product',
      'price': 19.99,
      'description': 'Description',
      'category': 'electronics',
      'image': 'https://example.com/product.png',
      'rating': <String, dynamic>{
        'rate': 4.5,
        'count': 120,
      },
    };

    final Product product = Product.fromJson(json);

    expect(product.id, 1);
    expect(product.title, 'Test Product');
    expect(product.price, 19.99);
    expect(product.rating.rate, 4.5);
    expect(product.rating.count, 120);
  });
}
