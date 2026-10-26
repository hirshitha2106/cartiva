import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/animations/page_transitions.dart';
import '../../../../data/models/product_model.dart';
import '../../product_details/product_details_screen.dart';
import '../../../widgets/custom_badge.dart';

class AnimatedHeroSection extends StatefulWidget {
  final List<Product> featuredProducts;

  const AnimatedHeroSection({
    super.key,
    required this.featuredProducts,
  });

  @override
  State<AnimatedHeroSection> createState() => _AnimatedHeroSectionState();
}

class _AnimatedHeroSectionState extends State<AnimatedHeroSection> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoTimer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) return;
      if (widget.featuredProducts.isEmpty) return;
      int nextPage = (_currentPage + 1) % widget.featuredProducts.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.featuredProducts.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        SizedBox(
          height: 250,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemCount: widget.featuredProducts.length,
            itemBuilder: (context, index) {
              final product = widget.featuredProducts[index];
              return _buildHeroCard(product, isDark);
            },
          ),
        ),
        const SizedBox(height: 12),

        // Animated Page Dots Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.featuredProducts.length, (index) {
            final isSelected = _currentPage == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: isSelected ? 24 : 6,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildHeroCard(Product product, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF1E1B4B),
                  const Color(0xFF0F172A),
                  const Color(0xFF090D16),
                ]
              : [
                  const Color(0xFFEEF2FF),
                  const Color(0xFFF8FAFC),
                  const Color(0xFFFFFFFF),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(isDark ? 50 : 25),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background ambient aura
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withAlpha(isDark ? 80 : 50),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Content Layout
          Padding(
            padding: const EdgeInsets.all(22),
            child: Row(
              children: [
                // Left Column: Text & CTA
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          CustomBadge.featured(),
                          const SizedBox(width: 8),
                          Text(
                            product.category.toUpperCase(),
                            style: AppTypography.badgeText.copyWith(
                              color: AppColors.accentCyan,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.headingLarge.copyWith(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        product.tagline,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            FadeScalePageRoute(
                              page: ProductDetailsScreen(
                                product: product,
                                heroTag: 'hero_featured_${product.id}',
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: AppColors.brandGradient,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withAlpha(90),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Explore 3D View',
                                style: AppTypography.buttonText.copyWith(
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.view_in_ar_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Right Column: Product Image
                Expanded(
                  flex: 4,
                  child: Center(
                    child: Hero(
                      tag: 'hero_featured_${product.id}',
                      child: Image.network(
                        product.primaryImage,
                        fit: BoxFit.contain,
                        height: 160,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, size: 48),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
