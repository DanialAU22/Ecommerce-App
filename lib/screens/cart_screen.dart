import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/widgets/empty_state_widget.dart';
import '../providers/cart_provider.dart';
import 'checkout_screen.dart';
import '../widgets/cart_item_widget.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  static const double _shipping = 12;

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
          return const EmptyStateWidget(
            icon: Icons.shopping_cart_outlined,
            title: 'Your Cart Is Empty',
            message: 'Add products to start your checkout journey.',
          );
        }

        final double subtotal = provider.totalPrice;
        final double total = subtotal + _shipping;

        return Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.14),
                  ),
                ),
              ),
              child: Column(
                children: <Widget>[
                  _SummaryRow(label: 'Subtotal', value: subtotal),
                  const SizedBox(height: 8),
                  const _SummaryRow(label: 'Shipping', value: _shipping),
                  const SizedBox(height: 8),
                  _SummaryRow(
                    label: 'Total',
                    value: total,
                    emphasis: true,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const CheckoutScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.payment_rounded),
                      label: const Text('Proceed to Checkout'),
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

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasis = false,
  });

  final String label;
  final double value;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = emphasis
        ? Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)
        : Theme.of(context).textTheme.bodyMedium;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(label, style: style),
        Text('\$${value.toStringAsFixed(2)}', style: style),
      ],
    );
  }
}
