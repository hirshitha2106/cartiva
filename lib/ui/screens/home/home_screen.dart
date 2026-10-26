import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/animations/page_transitions.dart';
import '../../../state/product_provider.dart';
import '../../../state/wishlist_provider.dart';
import '../../../state/theme_provider.dart';
import 'widgets/animated_hero_section.dart';
import 'widgets/category_strip.dart';
import 'widgets/flash_sale_banner.dart';
import 'widgets/trending_products_section.dart';
import 'widgets/search_and_filter_bar.dart';
import '../products/widgets/floating_product_card.dart';
import '../products/widgets/product_filter_sheet.dart';
import '../products/product_list_screen.dart';
import '../../widgets/ecommerce_footer.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onNavigateToCategories;
  final VoidCallback onNavigateToWishlist;
  final bool isDesktop;

  const HomeScreen({
    super.key,
    required this.onNavigateToCategories,
    required this.onNavigateToWishlist,
    this.isDesktop = false,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ProductFilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final productProvider = context.watch<ProductProvider>();
    final wishlist = context.watch<WishlistProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    final featured = productProvider.featuredProducts;
    final trending = productProvider.trendingProducts;
    final flashSale = productProvider.flashSaleProducts;
    final allProducts = productProvider.allProducts;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: widget.isDesktop
          ? null
          : AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: AppColors.brandGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.diamond_rounded, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Text(
              'CARTIVA',
              style: AppTypography.headingMedium.copyWith(
                letterSpacing: 2.0,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              size: 22,
            ),
            tooltip: 'Toggle Theme',
            onPressed: () => themeProvider.toggleTheme(),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.favorite_border_rounded, size: 22),
                tooltip: 'Wishlist',
                onPressed: widget.onNavigateToWishlist,
              ),
              if (wishlist.itemCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accentRose,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Center(
                      child: Text(
                        '${wishlist.itemCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: productProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => productProvider.loadData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1360),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),

                        // Search & Filter Bar (Mobile only, desktop uses header search)
                        if (!widget.isDesktop) ...[
                          SearchAndFilterBar(
                            controller: _searchController,
                            onChanged: (val) {
                              productProvider.setSearchQuery(val);
                              if (val.trim().isNotEmpty) {
                                Navigator.of(context).push(
                                  FadeScalePageRoute(
                                    page: const ProductListScreen(),
                                  ),
                                );
                              }
                            },
                            onFilterTap: _openFilterModal,
                            onClear: () {
                              _searchController.clear();
                              productProvider.setSearchQuery('');
                            },
                          ),
                          const SizedBox(height: 18),
                        ],

                    // Animated Hero Section
                    AnimatedHeroSection(featuredProducts: featured),
                    const SizedBox(height: 24),

                    // Category Strip
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'CATEGORIES',
                            style: AppTypography.badgeText.copyWith(
                              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                              letterSpacing: 1.0,
                            ),
                          ),
                          InkWell(
                            onTap: widget.onNavigateToCategories,
                            child: Text(
                              'See All',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.primaryLight,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const CategoryStrip(),
                    const SizedBox(height: 24),

                    // Flash Sale Banner & Live Countdown
                    FlashSaleBanner(
                      flashSaleProducts: flashSale,
                      onViewAll: () {
                        Navigator.of(context).push(
                          FadeScalePageRoute(page: const ProductListScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // Flash Sale Items horizontal scroll
                    SizedBox(
                      height: 330,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: flashSale.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 14),
                        itemBuilder: (context, index) {
                          return FloatingProductCard(
                            product: flashSale[index],
                            width: 210,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Trending Products Section
                    TrendingProductsSection(
                      title: 'Trending Drops',
                      subtitle: 'Most coveted picks this week',
                      products: trending,
                      onViewAll: () {
                        Navigator.of(context).push(
                          FadeScalePageRoute(page: const ProductListScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 28),

                    // Curated Catalog Grid
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Curated For You',
                                style: AppTypography.headingMedium.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Hand-picked luxury craftsmanship',
                                style: AppTypography.bodySmall.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextMuted
                                      : AppColors.lightTextMuted,
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                FadeScalePageRoute(page: const ProductListScreen()),
                              );
                            },
                            child: const Text('View All'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 2-Column Grid of All Products
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = constraints.maxWidth > 900
                            ? 4
                            : constraints.maxWidth > 600
                                ? 3
                                : 2;

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: 0.62,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                          ),
                          itemCount: allProducts.length,
                          itemBuilder: (context, index) {
                            return FloatingProductCard(
                              product: allProducts[index],
                              width: double.infinity,
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Luxury E-Commerce Footer
                    const EcommerceFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
    );
  }
}
