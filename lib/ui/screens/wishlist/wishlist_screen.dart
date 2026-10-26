import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../state/wishlist_provider.dart';
import '../../../state/cart_provider.dart';
import '../products/widgets/floating_product_card.dart';

class WishlistScreen extends StatelessWidget {
  final VoidCallback? onExplore;

  const WishlistScreen({super.key, this.onExplore});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final wishlist = context.watch<WishlistProvider>();
    final cart = context.read<CartProvider>();
    final items = wishlist.items;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text('My Wishlist', style: AppTypography.headingMedium),
        actions: [
          if (items.isNotEmpty)
            TextButton(
              onPressed: () {
                for (var product in List.from(items)) {
                  wishlist.moveToCart(product, cart);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All items moved to Cart!'),
                    backgroundColor: AppColors.accentEmerald,
                  ),
                );
              },
              child: Text(
                'Move All to Cart',
                style: AppTypography.buttonText.copyWith(
                  color: AppColors.primaryLight,
                  fontSize: 13,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: items.isEmpty
          ? _buildEmptyWishlist(context, isDark)
          : LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 900
                    ? 4
                    : constraints.maxWidth > 600
                        ? 3
                        : 2;

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 0.62,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final product = items[index];
                    return FloatingProductCard(
                      product: product,
                      width: double.infinity,
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildEmptyWishlist(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.accentRose.withAlpha(isDark ? 30 : 15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                size: 60,
                color: AppColors.accentRose,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Your Wishlist is Empty',
              style: AppTypography.headingMedium.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Explore the collection and tap the heart icon on any piece you want to save for later.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (onExplore != null) {
                  onExplore!();
                }
              },
              child: const Text('Explore Drops'),
            ),
          ],
        ),
      ),
    );
  }
}
