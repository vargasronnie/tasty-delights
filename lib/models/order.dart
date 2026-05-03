import 'cart_item.dart';
import '../models/order.dart' as app_order;

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  onTheWay,
  delivered,
  cancelled
}

class Order {
  final String id;
  final List<CartItem> items;
  final double totalAmount;
  final DateTime orderDate;
  OrderStatus status;
  final String deliveryAddress;

  Order({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.orderDate,
    this.status = OrderStatus.pending,
    required this.deliveryAddress,
  });

  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.onTheWay:
        return 'On The Way';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'items': items.map((e) => e.toMap()).toList(),
      'totalAmount': totalAmount,
      'orderDate': orderDate.toIso8601String(),
      'status': status.index,
      'deliveryAddress': deliveryAddress,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return app_order.Order(
      id: map['id'],
      items: (map['items'] as List).map((e) => CartItem.fromMap(e)).toList(),
      totalAmount: map['totalAmount'],
      orderDate: DateTime.parse(map['orderDate']),
      status: OrderStatus.values[map['status']],
      deliveryAddress: map['deliveryAddress'],
    );
  }
}
