import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../bloc/app_bloc.dart';
import '../../models/food_item.dart';
import '../../theme/app_theme.dart';

class FoodDetailView extends StatelessWidget {
  final FoodItem food;
  const FoodDetailView({super.key, required this.food});

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<AppBloc>();
    final isFav = bloc.isFavorite(food.id);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // Image hero
          Stack(
            children: [
              SizedBox(
                height: size.height * 0.35,
                width: double.infinity,
                child: Image.network(
                  food.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.fastfood,
                        size: 64, color: Colors.grey),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      _CircleBtn(
                        icon: Icons.arrow_back,
                        onTap: () => Navigator.pop(context),
                      ),
                      _CircleBtn(
                        icon: isFav
                            ? Icons.favorite
                            : Icons.favorite_border,
                        iconColor:
                            isFav ? AppTheme.error : AppTheme.textDark,
                        onTap: () => bloc.toggleFavorite(food.id),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(food.name,
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textDark)),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '₱${food.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star,
                          size: 15, color: AppTheme.secondary),
                      const SizedBox(width: 4),
                      Text(
                          '${food.rating} (${food.reviewCount} reviews)',
                          style: const TextStyle(
                              color: AppTheme.textGrey,
                              fontSize: 12)),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color:
                              AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(food.category,
                            style: const TextStyle(
                                color: AppTheme.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(color: AppTheme.divider),
                  const SizedBox(height: 14),
                  const Text('Description',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark)),
                  const SizedBox(height: 6),
                  Text(food.description,
                      style: const TextStyle(
                          color: AppTheme.textGrey,
                          fontSize: 13,
                          height: 1.6)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: const [
                      _InfoChip(
                          icon: Icons.access_time,
                          label: '20-30 min'),
                      _InfoChip(
                          icon: Icons.local_fire_department,
                          label: '350 Cal'),
                      _InfoChip(
                          icon: Icons.delivery_dining,
                          label: 'Free Delivery'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      bloc.addToCart(food);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '${food.name} added to cart!'),
                          backgroundColor: AppTheme.success,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(
                        Icons.shopping_cart_outlined,
                        size: 18),
                    label: const Text('Add to Cart'),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  const _CircleBtn({
    required this.icon,
    required this.onTap,
    this.iconColor = AppTheme.textDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
            color: Colors.white, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppTheme.primary),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppTheme.textGrey)),
        ],
      ),
    );
  }
}
