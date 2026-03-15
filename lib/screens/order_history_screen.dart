import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/widgets/empty_state_widget.dart';
import '../providers/order_provider.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('MMM d, y • h:mm a');

    return Scaffold(
      appBar: AppBar(title: const Text('Order History')),
      body: Consumer<OrderProvider>(
        builder: (BuildContext context, OrderProvider provider, Widget? child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.orders.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.receipt_long_outlined,
              title: 'No Orders Yet',
              message: 'Your confirmed purchases will appear here.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.orders.length,
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(height: 10),
            itemBuilder: (BuildContext context, int index) {
              final order = provider.orders[index];
              return Card(
                child: ExpansionTile(
                  title: Text(
                    'Order #${order.id ?? index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(formatter.format(order.date)),
                  trailing: Text('\$${order.totalPrice.toStringAsFixed(2)}'),
                  children: order.items
                      .map(
                        (item) => ListTile(
                          dense: true,
                          title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text('Qty: 1'),
                          trailing: Text('\$${item.price.toStringAsFixed(2)}'),
                        ),
                      )
                      .toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
