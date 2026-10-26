import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../state/cart_provider.dart';
import '../../core/animations/page_transitions.dart';
import '../widgets/desktop_header.dart';
import 'home/home_screen.dart';
import 'categories/categories_screen.dart';
import 'products/product_list_screen.dart';
import 'cart/cart_screen.dart';
import 'wishlist/wishlist_screen.dart';
import 'profile/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _navigateToIndex(int index) {
    setState(() => _currentIndex = index);
  }

  void _openWishlist() {
    Navigator.of(context).push(
      SlideUpPageRoute(
        page: WishlistScreen(
          onExplore: () {
            Navigator.pop(context);
            _navigateToIndex(2);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cart = context.watch<CartProvider>();
    final isDesktop = MediaQuery.of(context).size.width >= 850;

    final List<Widget> screens = [
      HomeScreen(
        onNavigateToCategories: () => _navigateToIndex(1),
        onNavigateToWishlist: _openWishlist,
        isDesktop: isDesktop,
      ),
      const CategoriesScreen(),
      const ProductListScreen(),
      CartScreen(
        onContinueShopping: () => _navigateToIndex(0),
      ),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: Column(
        children: [
          // Desktop Luxury Header
          if (isDesktop)
            DesktopHeader(
              currentIndex: _currentIndex,
              onNavigate: _navigateToIndex,
              onOpenWishlist: _openWishlist,
            ),

          // Main View Content
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: screens,
            ),
          ),
        ],
      ),
      // Mobile / Tablet Bottom Navigation Bar
      bottomNavigationBar: isDesktop
          ? null
          : Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(isDark ? 50 : 20),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(
                        index: 0,
                        icon: Icons.home_rounded,
                        label: 'Home',
                        isDark: isDark,
                      ),
                      _buildNavItem(
                        index: 1,
                        icon: Icons.grid_view_rounded,
                        label: 'Categories',
                        isDark: isDark,
                      ),
                      _buildNavItem(
                        index: 2,
                        icon: Icons.explore_rounded,
                        label: 'Products',
                        isDark: isDark,
                      ),
                      _buildNavItem(
                        index: 3,
                        icon: Icons.shopping_bag_rounded,
                        label: 'Cart',
                        badgeCount: cart.itemCount,
                        isDark: isDark,
                      ),
                      _buildNavItem(
                        index: 4,
                        icon: Icons.person_rounded,
                        label: 'Profile',
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    int? badgeCount,
    required bool isDark,
  }) {
    final isSelected = _currentIndex == index;

    return InkWell(
      onTap: () => _navigateToIndex(index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withAlpha(isDark ? 40 : 25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                ),
                if (badgeCount != null && badgeCount > 0)
                  Positioned(
                    top: -4,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accentRose,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Center(
                        child: Text(
                          badgeCount > 99 ? '99+' : '$badgeCount',
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
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
