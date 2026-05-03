import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../bloc/app_bloc.dart';
import '../../models/order.dart';
import '../../theme/app_theme.dart';

class OrdersView extends StatelessWidget {
  const OrdersView({super.key});

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.delivered: return AppTheme.success;
      case OrderStatus.cancelled: return AppTheme.error;
      case OrderStatus.onTheWay: return Colors.blue;
      default: return AppTheme.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<AppBloc>().orders;
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('My Orders')),
      body: orders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 72, color: Colors.grey[300]),
                  const SizedBox(height: 14),
                  const Text('No orders yet',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textGrey)),
                  const SizedBox(height: 6),
                  const Text('Order history will appear here',
                      style: TextStyle(color: AppTheme.textLight)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: orders.length,
              itemBuilder: (_, i) => _OrderCard(
                  order: orders[i],
                  statusColor: _statusColor(orders[i].status)),
            ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final Color statusColor;
  const _OrderCard(
      {required this.order, required this.statusColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10)
        ],
      ),
      child: ExpansionTile(
        tilePadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        childrenPadding:
            const EdgeInsets.fromLTRB(14, 0, 14, 14),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${order.id.length > 8 ? order.id.substring(0, 8).toUpperCase() : order.id}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('MMM dd, yyyy · hh:mm a')
                        .format(order.orderDate),
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textGrey),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(order.statusText,
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 4),
                Text('₱${order.totalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                        fontSize: 13)),
              ],
            ),
          ],
        ),
        children: [
          const Divider(color: AppTheme.divider, height: 12),
          ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.foodItem.imageUrl,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                            width: 40,
                            height: 40,
                            color: Colors.grey[200],
                            child: const Icon(Icons.fastfood,
                                size: 18)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(item.foodItem.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                    Text('x${item.quantity}',
                        style: const TextStyle(
                            color: AppTheme.textGrey,
                            fontSize: 11)),
                    const SizedBox(width: 8),
                    Text(
                        '₱${item.totalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12)),
                  ],
                ),
              )),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 13, color: AppTheme.textGrey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(order.deliveryAddress,
                    style: const TextStyle(
                        color: AppTheme.textGrey, fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
