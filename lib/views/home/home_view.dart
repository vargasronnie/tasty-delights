import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../bloc/app_bloc.dart';
import '../../theme/app_theme.dart';
import '../../widgets/food_card.dart';
import '../../widgets/special_offer_banner.dart';
import '../../widgets/category_grid.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<AppBloc>();
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 360;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/Logo.png',
                      width: isSmall ? 36 : 42,
                      height: isSmall ? 36 : 42,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hi, ${bloc.currentUser?.name.split(' ').first ?? 'Guest'} 👋',
                            style: TextStyle(
                                fontSize: isSmall ? 11 : 12,
                                color: AppTheme.textGrey),
                          ),
                          Text(
                            'Tasty Delights',
                            style: TextStyle(
                              fontSize: isSmall ? 17 : 19,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8)
                          ],
                        ),
                        child: const Icon(Icons.favorite_border,
                            color: AppTheme.primary, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Search ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: bloc.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Search for food...',
                    prefixIcon: const Icon(Icons.search,
                        color: AppTheme.textGrey, size: 20),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 16),
                            onPressed: () {
                              _searchCtrl.clear();
                              bloc.setSearchQuery('');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                ),
              ),
            ),

            // ── Special Offers Header ────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Special Offers',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark)),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero),
                      child: const Text('See All',
                          style: TextStyle(
                              color: AppTheme.primary, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),

            // ── Auto-scroll Banner ───────────────────────────
            const SliverToBoxAdapter(
              child: SpecialOfferBanner(),
            ),

            // ── Category Section Header ──────────────────────
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 18, 16, 10),
                child: Text(
                  'Categories',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark),
                ),
              ),
            ),

            // ── Circular Category Grid ───────────────────────
            const SliverToBoxAdapter(
              child: CategoryGrid(),
            ),

            // ── Menu Header ──────────────────────────────────
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 18, 16, 6),
                child: Text('Menu',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark)),
              ),
            ),

            // ── Food Grid ────────────────────────────────────
            bloc.filteredFoods.isEmpty
                ? const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(Icons.search_off,
                                size: 48, color: AppTheme.textLight),
                            SizedBox(height: 8),
                            Text('No food found',
                                style: TextStyle(
                                    color: AppTheme.textGrey)),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverPadding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    sliver: SliverGrid(
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio:
                            size.width < 360 ? 0.65 : 0.70,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (_, i) =>
                            FoodCard(food: bloc.filteredFoods[i]),
                        childCount: bloc.filteredFoods.length,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
