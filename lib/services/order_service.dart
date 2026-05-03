import 'package:uuid/uuid.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import 'local_db_service.dart';

class OrderService {
  final LocalDbService _localDb = LocalDbService();
  final _uuid = const Uuid();

  Future<Order> placeOrder(List<CartItem> cartItems, String deliveryAddress) async {
    final order = Order(
      id: _uuid.v4(),
      items: List.from(cartItems),
      totalAmount: cartItems.fold(0, (sum, item) => sum + item.totalPrice),
      orderDate: DateTime.now(),
      status: OrderStatus.confirmed,
      deliveryAddress: deliveryAddress,
    );

    await _localDb.saveOrder(order);
    await _localDb.clearCart();
    return order;
  }

  Future<List<Order>> getOrders() async {
    return await _localDb.getOrders();
  }
}
