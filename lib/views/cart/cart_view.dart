import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../bloc/app_bloc.dart';
import '../../models/cart_item.dart';
import '../../models/order.dart' as app_order;
import '../../theme/app_theme.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  void _showCheckout(BuildContext context) {
    final bloc = context.read<AppBloc>();
    final address = bloc.currentUser?.address ?? '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _CheckoutSheet(address: address),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<AppBloc>();
    final items = bloc.cartItems;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('My Cart'),
        actions: [
          if (items.isNotEmpty)
            TextButton(
              onPressed: () => bloc.clearCart(),
              child: const Text('Clear All',
                  style: TextStyle(color: AppTheme.error, fontSize: 13)),
            ),
        ],
      ),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 72, color: Colors.grey[300]),
                  const SizedBox(height: 14),
                  const Text('Your cart is empty',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textGrey)),
                  const SizedBox(height: 6),
                  const Text('Add some delicious food!',
                      style: TextStyle(color: AppTheme.textLight)),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(14),
                    itemCount: items.length,
                    itemBuilder: (_, i) => _CartItemTile(item: items[i]),
                  ),
                ),
                _OrderSummary(
                    items: items, onCheckout: () => _showCheckout(context)),
              ],
            ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;
  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AppBloc>();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              item.foodItem.imageUrl,
              width: 62,
              height: 62,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                  width: 62,
                  height: 62,
                  color: Colors.grey[200],
                  child: const Icon(Icons.fastfood, size: 24)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.foodItem.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                        fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text('₱${item.foodItem.price.toStringAsFixed(0)} each',
                    style: const TextStyle(
                        color: AppTheme.textGrey, fontSize: 11)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _QtyBtn(
                      icon: Icons.remove,
                      onTap: () => bloc.updateCartQuantity(
                          item.foodItem.id, item.quantity - 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text('${item.quantity}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                    ),
                    _QtyBtn(
                      icon: Icons.add,
                      onTap: () => bloc.updateCartQuantity(
                          item.foodItem.id, item.quantity + 1),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₱${item.totalPrice.toStringAsFixed(0)}',
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppTheme.primary),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => bloc.removeFromCart(item.foodItem.id),
                child: const Icon(Icons.delete_outline,
                    color: AppTheme.error, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(icon, size: 14, color: AppTheme.primary),
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  final List<CartItem> items;
  final VoidCallback onCheckout;
  const _OrderSummary({required this.items, required this.onCheckout});

  @override
  Widget build(BuildContext context) {
    final subtotal = items.fold(0.0, (s, i) => s + i.totalPrice);
    const deliveryFee = 49.0;
    final total = subtotal + deliveryFee;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Row('Subtotal', '₱${subtotal.toStringAsFixed(0)}'),
          const SizedBox(height: 5),
          _Row('Delivery Fee', '₱${deliveryFee.toStringAsFixed(0)}'),
          const Divider(height: 18),
          _Row('Total', '₱${total.toStringAsFixed(0)}', bold: true),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                onPressed: onCheckout,
                child: const Text('Proceed to Checkout')),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String l, v;
  final bool bold;
  const _Row(this.l, this.v, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    final s = TextStyle(
        fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
        fontSize: bold ? 15 : 13,
        color: bold ? AppTheme.textDark : AppTheme.textGrey);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(l, style: s),
        Text(v, style: s.copyWith(color: bold ? AppTheme.primary : null))
      ],
    );
  }
}

class _CheckoutSheet extends StatefulWidget {
  final String address;
  const _CheckoutSheet({required this.address});

  @override
  State<_CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<_CheckoutSheet> {
  late TextEditingController _addrCtrl;
  bool _placing = false;

  @override
  void initState() {
    super.initState();
    _addrCtrl = TextEditingController(text: widget.address);
  }

  @override
  void dispose() {
    _addrCtrl.dispose();
    super.dispose();
  }

  Future<void> _place() async {
    if (_addrCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter a delivery address'),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    setState(() => _placing = true);

    app_order.Order? order;
    try {
      order = await context
          .read<AppBloc>()
          .placeOrder(_addrCtrl.text.trim())
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      order = null;
    }

    if (!mounted) return;
    setState(() => _placing = false);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(order != null
            ? 'Order placed successfully! 🎉'
            : 'Order saved! Check Orders tab.'),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          left: 24,
          right: 24,
          top: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Confirm Order',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          const Text('Delivery Address',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textGrey,
                  fontSize: 13)),
          const SizedBox(height: 8),
          TextField(
            controller: _addrCtrl,
            decoration: const InputDecoration(
              hintText: 'Enter delivery address',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _placing ? null : _place,
              child: _placing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Place Order'),
            ),
          ),
        ],
      ),
    );
  }
}
