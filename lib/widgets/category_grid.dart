import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../bloc/app_bloc.dart';
import '../theme/app_theme.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key});

  static const List<Map<String, String>> _categories = [
    {
      'name': 'Coffee',
      'image': 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=200',
    },
    {
      'name': 'Burgers',
      'image': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=200',
    },
    {
      'name': 'Desserts',
      'image': 'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=200',
    },
    {
      'name': 'Chicken',
      'image': 'https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?w=200',
    },
    {
      'name': 'Pizza',
      'image': 'https://images.unsplash.com/photo-1598023696416-0193a0bcd302?w=200',
    },
    {
      'name': 'Noodles',
      'image': 'https://images.unsplash.com/photo-1559314809-0d155014e29e?w=200',
    },
    {
      'name': 'BBQ',
      'image': 'https://images.unsplash.com/photo-1544025162-d76694265947?w=200',
    },
    {
      'name': 'Salads',
      'image': 'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=200',
    },
    {
      'name': 'Sushi',
      'image': 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=200',
    },
    {
      'name': 'Pasta',
      'image': 'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=200',
    },
    {
      'name': 'Soups',
      'image': 'https://images.unsplash.com/photo-1562802378-063ec186a863?w=200',
    },
    {
      'name': 'Others',
      'image': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=200',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<AppBloc>();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 8,
        childAspectRatio: 0.85,
      ),
      itemCount: _categories.length,
      itemBuilder: (_, i) {
        final cat = _categories[i];
        final name = cat['name']!;
        // Map category names to AppBloc categories
        final blocCat = name == 'Coffee' ? 'Snacks'
            : name == 'Others' ? 'All'
            : name;
        final isSelected = bloc.selectedCategory == blocCat;

        return GestureDetector(
          onTap: () => bloc.setCategory(blocCat),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? AppTheme.primary.withOpacity(0.15)
                      : const Color(0xFFF3F4F6),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primary
                        : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppTheme.primary.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
                        ],
                ),
                child: ClipOval(
                  child: Image.network(
                    cat['image']!,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFF3F4F6),
                      child: Icon(
                        Icons.fastfood,
                        size: 28,
                        color: isSelected
                            ? AppTheme.primary
                            : AppTheme.textLight,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                name,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: isSelected
                      ? AppTheme.primary
                      : AppTheme.textDark,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}
