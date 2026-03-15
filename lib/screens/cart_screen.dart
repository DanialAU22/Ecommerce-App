import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import 'login_screen.dart';
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
                      onPressed: () async {
                        final AuthProvider auth = context.read<AuthProvider>();
                        final OrderProvider orderProvider =
                            context.read<OrderProvider>();
                        final ScaffoldMessengerState messenger =
                            ScaffoldMessenger.of(context);
                        final NavigatorState navigator = Navigator.of(context);

                        if (!auth.isLoggedIn) {
                          await navigator.push(
                            MaterialPageRoute<void>(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                          if (!mounted) {
                            return;
                          }
                          if (!auth.isLoggedIn) {
                            return;
                          }
                        }

                        await orderProvider.placeOrder(
                          provider.cartItems.map((e) => e.product).toList(),
                          provider.totalPrice,
                        );
                        await provider.clearCart();

                        if (!mounted) {
                          return;
                        }

                        messenger.showSnackBar(
                          const SnackBar(content: Text('Order placed successfully')),
                        );
                      },
                      child: const Text('Checkout & Place Order'),
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
