import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/product_model.dart';
import '../../../../state/cart_provider.dart';
import '../../../../state/wishlist_provider.dart';
import '../../../widgets/custom_badge.dart';
import '../../../widgets/rating_stars.dart';
import '../../product_details/product_details_screen.dart';
import '../../../../core/animations/page_transitions.dart';

class FloatingProductCard extends StatefulWidget {
  final Product product;
  final double width;
  final String? heroTag;

  const FloatingProductCard({
    super.key,
    required this.product,
    this.width = 220,
    this.heroTag,
  });

  @override
  State<FloatingProductCard> createState() => _FloatingProductCardState();
}

class _FloatingProductCardState extends State<FloatingProductCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final wishlistProvider = context.watch<WishlistProvider>();
    final cartProvider = context.read<CartProvider>();
    final isFavorite = wishlistProvider.isWishlisted(widget.product.id);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -8 : 0, 0),
        width: widget.width,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _isHovered
                ? AppColors.primaryLight.withAlpha(150)
                : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
            width: _isHovered ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? AppColors.primary.withAlpha(40)
                  : (isDark ? Colors.black.withAlpha(40) : Colors.grey.withAlpha(20)),
              blurRadius: _isHovered ? 24 : 12,
              offset: Offset(0, _isHovered ? 12 : 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              Navigator.of(context).push(
                FadeScalePageRoute(
                  page: ProductDetailsScreen(
                    product: widget.product,
                    heroTag: widget.heroTag,
                  ),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Media Area with Badges & Wishlist Button
                Stack(
                  children: [
                    // Product Image with optional Hero Transition
                    Container(
                      height: 175,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0F1522)
                            : const Color(0xFFF1F5F9),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(23),
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: widget.heroTag != null
                          ? Hero(
                              tag: widget.heroTag!,
                              child: AnimatedScale(
                                duration: const Duration(milliseconds: 250),
                                scale: _isHovered ? 1.05 : 1.0,
                                child: Image.network(
                                  widget.product.primaryImage,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Center(child: Icon(Icons.broken_image, size: 36)),
                                ),
                              ),
                            )
                          : AnimatedScale(
                              duration: const Duration(milliseconds: 250),
                              scale: _isHovered ? 1.05 : 1.0,
                              child: Image.network(
                                widget.product.primaryImage,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(child: Icon(Icons.broken_image, size: 36)),
                              ),
                            ),
                    ),

                    // Top Left Badges (Discount / Trending)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.product.hasDiscount) ...[
                            CustomBadge.discount(widget.product.discountPercent),
                            const SizedBox(height: 4),
                          ],
                          if (widget.product.isTrending && !widget.product.hasDiscount) ...[
                            CustomBadge.trending(),
                          ],
                        ],
                      ),
                    ),

                    // Top Right Wishlist Heart Button
                    Positioned(
                      top: 10,
                      right: 10,
                      child: _buildWishlistButton(
                        isFavorite: isFavorite,
                        isDark: isDark,
                        onTap: () {
                          wishlistProvider.toggleWishlist(widget.product);
                        },
                      ),
                    ),
                  ],
                ),

                // Card Content Area
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Tag & Color Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.product.category.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.badgeText.copyWith(
                                color: isDark
                                    ? AppColors.darkTextMuted
                                    : AppColors.lightTextMuted,
                                fontSize: 10,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Color dots preview
                          Row(
                            children: widget.product.colors.take(3).map((c) {
                              return Container(
                                margin: const EdgeInsets.only(left: 3),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: c.color,
                                  border: Border.all(
                                    color: isDark ? Colors.white24 : Colors.black12,
                                    width: 1,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Product Title
                      Text(
                        widget.product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.headingSmall.copyWith(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Rating
                      RatingStars(
                        rating: widget.product.rating,
                        reviewsCount: widget.product.reviewsCount,
                      ),
                      const SizedBox(height: 12),

                      // Price and Quick Add to Cart Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  Formatters.currency(widget.product.price),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.priceMedium.copyWith(
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary,
                                  ),
                                ),
                                if (widget.product.hasDiscount)
                                  Text(
                                    Formatters.currency(widget.product.originalPrice),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.bodySmall.copyWith(
                                      decoration: TextDecoration.lineThrough,
                                      color: isDark
                                          ? AppColors.darkTextMuted
                                          : AppColors.lightTextMuted,
                                      fontSize: 11,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Floating Quick Add Button
                          _buildCartButton(
                            isDark: isDark,
                            onTap: () {
                              cartProvider.addToCart(widget.product);
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.check_circle_rounded,
                                          color: AppColors.accentEmerald, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Added ${widget.product.name} to Cart',
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: const Color(0xFF1E293B),
                                  duration: const Duration(seconds: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWishlistButton({
    required bool isFavorite,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark
                ? Colors.black.withAlpha(160)
                : Colors.white.withAlpha(220),
            border: Border.all(
              color: isFavorite
                  ? AppColors.accentRose.withAlpha(160)
                  : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
            ),
          ),
          child: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            size: 18,
            color: isFavorite
                ? AppColors.accentRose
                : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
          ),
        ),
      ),
    );
  }

  Widget _buildCartButton({
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(80),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: const Padding(
            padding: EdgeInsets.all(10),
            child: Icon(
              Icons.add_shopping_cart_rounded,
              size: 18,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
