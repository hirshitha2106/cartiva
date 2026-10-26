import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../state/cart_provider.dart';
import '../../state/wishlist_provider.dart';
import '../../state/theme_provider.dart';
import '../../state/product_provider.dart';
import '../screens/checkout/order_history_screen.dart';

class DesktopHeader extends StatefulWidget {
  final int currentIndex;
  final Function(int) onNavigate;
  final VoidCallback onOpenWishlist;

  const DesktopHeader({
    super.key,
    required this.currentIndex,
    required this.onNavigate,
    required this.onOpenWishlist,
  });

  @override
  State<DesktopHeader> createState() => _DesktopHeaderState();
}

class _DesktopHeaderState extends State<DesktopHeader> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedCurrency = 'USD (\$)';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _triggerSearch(String query) {
    if (query.trim().isEmpty) return;
    context.read<ProductProvider>().setSearchQuery(query.trim());
    widget.onNavigate(2); // Navigate to Products Catalog
  }

  void _copyPromoCode() {
    Clipboard.setData(const ClipboardData(text: 'CARTIVA20'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Promo code CARTIVA20 copied to clipboard! (20% OFF)'),
          ],
        ),
        backgroundColor: AppColors.accentEmerald,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cart = context.watch<CartProvider>();
    final wishlist = context.watch<WishlistProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Top Luxury Utility Bar
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
          decoration: BoxDecoration(
            gradient: isDark
                ? const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF0F172A)],
                  )
                : const LinearGradient(
                    colors: [Color(0xFFF1F5F9), Color(0xFFE2E8F0), Color(0xFFF1F5F9)],
                  ),
            border: Border(
              bottom: BorderSide(
                color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                width: 0.8,
              ),
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1360),
              child: Row(
                children: [
                  // VIP perks ticker
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'VIP PRIVILEGE',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            'Complimentary Armored Express Delivery on all orders over \$150',
                            style: AppTypography.bodySmall.copyWith(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                        InkWell(
                          onTap: _copyPromoCode,
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accentGold.withAlpha(isDark ? 50 : 35),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.accentGold.withAlpha(120)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.confirmation_number_rounded,
                                    size: 12, color: AppColors.accentGold),
                                const SizedBox(width: 4),
                                Text(
                                  'CARTIVA20 (-20%)',
                                  style: AppTypography.badgeText.copyWith(
                                    color: isDark ? AppColors.accentGold : const Color(0xFF92400E),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.copy_rounded, size: 10, color: AppColors.accentGold),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right currency & support
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '24/7 Concierge Support',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCurrency,
                          isDense: true,
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 16,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                          dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                          items: const [
                            DropdownMenuItem(value: 'USD (\$)', child: Text('USD (\$)')),
                            DropdownMenuItem(value: 'EUR (€)', child: Text('EUR (€)')),
                            DropdownMenuItem(value: 'GBP (£)', child: Text('GBP (£)')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedCurrency = val);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // 2. Main Luxury Desktop Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBackground : Colors.white,
            border: Border(
              bottom: BorderSide(
                color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 40 : 15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1360),
              child: Row(
                children: [
                  // Logo
                  InkWell(
                    onTap: () => widget.onNavigate(0),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: AppColors.brandGradient,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withAlpha(80),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.diamond_rounded, size: 20, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CARTIVA',
                                style: AppTypography.headingMedium.copyWith(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2.5,
                                  fontSize: 20,
                                ),
                              ),
                              Text(
                                'LUXURY ATELIER',
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2.2,
                                  color: AppColors.accentCyan,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 28),

                  // Navigation Links
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDesktopNavLink(0, 'Home', isDark),
                      _buildDesktopNavLink(1, 'Collections', isDark),
                      _buildDesktopNavLink(2, 'Catalog', isDark),
                      _buildQuickFilterLink('Flash Deals', 'cat_watches', isDark),
                      _buildQuickFilterLink('Trending', 'cat_audio', isDark),
                    ],
                  ),

                  const SizedBox(width: 24),

                  // Global Search Field
                  Expanded(
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                        ),
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        onSubmitted: _triggerSearch,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search luxury timepieces, kicks, audio, optics...',
                          hintStyle: TextStyle(
                            fontSize: 12.5,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            size: 18,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                          suffixIcon: _searchCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 16),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    context.read<ProductProvider>().setSearchQuery('');
                                    setState(() {});
                                  },
                                )
                              : IconButton(
                                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                                  tooltip: 'Search',
                                  onPressed: () => _triggerSearch(_searchCtrl.text),
                                ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 24),

                  // Right Action Buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Theme Toggle
                      IconButton(
                        tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                        icon: Icon(
                          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                          size: 20,
                        ),
                        onPressed: () => themeProvider.toggleTheme(),
                      ),

                      const SizedBox(width: 6),

                      // Order History Button
                      IconButton(
                        tooltip: 'Order History',
                        icon: const Icon(Icons.history_rounded, size: 21),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const OrderHistoryScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(width: 6),

                      // Wishlist Button with Badge
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          IconButton(
                            tooltip: 'Saved Wishlist',
                            icon: const Icon(Icons.favorite_border_rounded, size: 21),
                            onPressed: widget.onOpenWishlist,
                          ),
                          if (wishlist.itemCount > 0)
                            Positioned(
                              top: 4,
                              right: 4,
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

                      const SizedBox(width: 6),

                      // Cart Button with live amount preview
                      InkWell(
                        onTap: () => widget.onNavigate(3),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            gradient: widget.currentIndex == 3
                                ? AppColors.brandGradient
                                : null,
                            color: widget.currentIndex == 3
                                ? null
                                : (isDark ? AppColors.darkCard : const Color(0xFFF1F5F9)),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: widget.currentIndex == 3
                                  ? Colors.transparent
                                  : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
                            ),
                          ),
                          child: Row(
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Icon(
                                    Icons.shopping_bag_rounded,
                                    size: 19,
                                    color: widget.currentIndex == 3
                                        ? Colors.white
                                        : AppColors.primary,
                                  ),
                                  if (cart.itemCount > 0)
                                    Positioned(
                                      top: -5,
                                      right: -6,
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.accentRose,
                                        ),
                                        constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                                        child: Center(
                                          child: Text(
                                            '${cart.itemCount}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 8.5,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'My Bag',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: widget.currentIndex == 3
                                          ? Colors.white70
                                          : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                                    ),
                                  ),
                                  Text(
                                    Formatters.currency(cart.subtotal),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: widget.currentIndex == 3
                                          ? Colors.white
                                          : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 14),

                      // User Account Avatar
                      InkWell(
                        onTap: () => widget.onNavigate(4),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: widget.currentIndex == 4
                                ? AppColors.primary.withAlpha(isDark ? 50 : 25)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: widget.currentIndex == 4
                                  ? AppColors.primary
                                  : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: AppColors.primary,
                                child: const Text(
                                  'KH',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Hirshitha',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: isDark
                                              ? AppColors.darkTextPrimary
                                              : AppColors.lightTextPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.verified_rounded,
                                          size: 13, color: AppColors.accentCyan),
                                    ],
                                  ),
                                  Text(
                                    'VIP Member',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.accentGold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopNavLink(int index, String label, bool isDark) {
    final isSelected = widget.currentIndex == index;

    return InkWell(
      onTap: () => widget.onNavigate(index),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primaryLight
                    : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 2,
              width: isSelected ? 20 : 0,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryLight : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickFilterLink(String label, String categoryId, bool isDark) {
    return InkWell(
      onTap: () {
        context.read<ProductProvider>().selectCategory(categoryId);
        widget.onNavigate(2);
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (label == 'Flash Deals')
                  const Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Icon(Icons.bolt_rounded, size: 14, color: AppColors.accentGold),
                  ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}
