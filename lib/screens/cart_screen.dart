import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../widgets/cart_item_widget.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (BuildContext context, CartProvider provider, Widget? child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.cartItems.isEmpty) {
          return const Center(
            child: Text('Your cart is empty.'),
          );
        }

        return Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: provider.cartItems.length,
                itemBuilder: (BuildContext context, int index) {
                  final item = provider.cartItems[index];
                  return CartItemWidget(
                    item: item,
                    onIncrease: () =>
                        provider.updateQuantity(item.product.id, item.quantity + 1),
                    onDecrease: () =>
                        provider.updateQuantity(item.product.id, item.quantity - 1),
                    onRemove: () => provider.removeFromCart(item.product.id),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${provider.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F9D58),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Checkout is UI-only in this demo.'),
                          ),
                        );
                      },
                      child: const Text('Checkout'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
