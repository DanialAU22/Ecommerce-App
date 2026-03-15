import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import 'login_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _step = 0;
  bool _processing = false;

  Future<void> _confirmOrder() async {
    if (_processing) {
      return;
    }

    final AuthProvider auth = context.read<AuthProvider>();
    final CartProvider cart = context.read<CartProvider>();
    final OrderProvider orders = context.read<OrderProvider>();

    if (!auth.isLoggedIn) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      );
      if (!mounted || !auth.isLoggedIn) {
        return;
      }
    }

    setState(() => _processing = true);

    await orders.placeOrder(
      cart.cartItems.map((e) => e.product).toList(),
      cart.totalPrice,
    );
    await cart.clearCart();

    if (!mounted) {
      return;
    }

    setState(() {
      _step = 2;
      _processing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order placed successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final CartProvider cart = context.watch<CartProvider>();
    final double subtotal = cart.totalPrice;
    const double shipping = 12;
    final double total = subtotal + shipping;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _StepIndicator(currentStep: _step),
          const SizedBox(height: 18),
          _CheckoutCard(
            title: '1. Shipping',
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('John Customer'),
                SizedBox(height: 4),
                Text('123 Main Street, Apt 4B'),
                SizedBox(height: 4),
                Text('New York, NY 10001'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _CheckoutCard(
            title: '2. Payment',
            child: const Row(
              children: <Widget>[
                Icon(Icons.credit_card_rounded),
                SizedBox(width: 8),
                Text('Visa •••• 2424'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _CheckoutCard(
            title: '3. Confirmation',
            child: Column(
              children: <Widget>[
                _line('Subtotal', subtotal),
                const SizedBox(height: 8),
                _line('Shipping', shipping),
                const Divider(height: 20),
                _line('Total', total, bold: true),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _step == 2 || _processing
                ? null
                : () async {
                    if (_step < 1) {
                      setState(() => _step += 1);
                      return;
                    }
                    await _confirmOrder();
                  },
            icon: _processing
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(_step < 1 ? Icons.arrow_forward_rounded : Icons.check_circle),
            label: Text(_step < 1 ? 'Continue' : 'Place Order'),
          ),
        ],
      ),
    );
  }

  Widget _line(String label, double value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          label,
          style: bold
              ? Theme.of(context).textTheme.titleMedium
              : Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: bold
              ? Theme.of(context).textTheme.titleMedium
              : Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _CheckoutCard extends StatelessWidget {
  const _CheckoutCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final List<String> labels = <String>['Shipping', 'Payment', 'Confirmation'];

    return Row(
      children: List<Widget>.generate(
        labels.length,
        (int index) {
          final bool active = index <= currentStep;
          return Expanded(
            child: Row(
              children: <Widget>[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: active
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: active
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    labels[index],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
