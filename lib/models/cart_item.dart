import 'food_item.dart';

class CartItem {
  final FoodItem foodItem;
  int quantity;

  CartItem({
    required FoodItem food,
    this.quantity = 1,
  }) : foodItem = food;

  double get totalPrice => foodItem.price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'foodItem': foodItem.toMap(),
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      food: FoodItem.fromMap(map['foodItem']),
      quantity: map['quantity'],
    );
  }
}
