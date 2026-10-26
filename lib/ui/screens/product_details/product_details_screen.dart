import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/product_model.dart';
import '../../../state/cart_provider.dart';
import '../../../state/wishlist_provider.dart';
import '../../widgets/interactive_3d_viewer.dart';
import '../../widgets/rating_stars.dart';
import '../../widgets/custom_badge.dart';
import '../../widgets/announcement_bar.dart';
import '../../widgets/ecommerce_footer.dart';
import '../cart/cart_screen.dart';

class ProductReview {
  final String author;
  final double rating;
  final String date;
  final String title;
  final String comment;
  final bool isVerified;
  int helpfulCount;

  ProductReview({
    required this.author,
    required this.rating,
    required this.date,
    required this.title,
    required this.comment,
    this.isVerified = true,
    this.helpfulCount = 18,
  });
}

class ProductDetailsScreen extends StatefulWidget {
  final Product product;
  final String? heroTag;

  const ProductDetailsScreen({
    super.key,
    required this.product,
    this.heroTag,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late ProductColor _selectedColor;
  late String _selectedSize;
  int _selectedImageIndex = 0;
  int _quantity = 1;
  bool _is3DMode = true;

  late List<ProductReview> _reviews;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.product.colors.first;
    _selectedSize = widget.product.sizes.isNotEmpty ? widget.product.sizes.first : 'Standard';

    _reviews = [
      ProductReview(
        author: 'Marcus Vance',
        rating: 5.0,
        date: 'October 18, 2026',
        title: 'Beyond expectations in craftsmanship and fidelity',
        comment:
            'The industrial design and materials are exceptional. Rotating the 3D model gave me high expectations and the physical unit in hand is even more impressive. Worth every penny.',
        isVerified: true,
        helpfulCount: 34,
      ),
      ProductReview(
        author: 'Elena Rostova',
        rating: 5.0,
        date: 'October 12, 2026',
        title: 'Exquisite luxury feel, arrived next morning',
        comment:
            'Ordered via VIP Armored Courier and received it within 18 hours in Beverly Hills. Unboxing is like opening a Swiss timepiece. Highly recommended.',
        isVerified: true,
        helpfulCount: 21,
      ),
    ];
  }

  void _openWriteReviewDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    double newRating = 5.0;
    final nameCtrl = TextEditingController(text: 'K. Hirshitha');
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Write a Client Review', style: AppTypography.headingSmall),
                    const SizedBox(height: 14),

                    // Star Selector
                    Text('OVERALL RATING', style: AppTypography.badgeText),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(5, (index) {
                        final starValue = index + 1.0;
                        return IconButton(
                          icon: Icon(
                            starValue <= newRating ? Icons.star_rounded : Icons.star_outline_rounded,
                            color: AppColors.accentGold,
                            size: 32,
                          ),
                          onPressed: () => setModalState(() => newRating = starValue),
                        );
                      }),
                    ),
                    const SizedBox(height: 14),

                    // Author Name
                    TextFormField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Your Name *'),
                    ),
                    const SizedBox(height: 12),

                    // Headline
                    TextFormField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(labelText: 'Review Headline (e.g. Masterpiece design)'),
                    ),
                    const SizedBox(height: 12),

                    // Comment
                    TextFormField(
                      controller: bodyCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Detailed Experience *',
                        hintText: 'Share insights on craftsmanship, materials, battery, and daily use...',
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Submit CTA
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (nameCtrl.text.isNotEmpty && bodyCtrl.text.isNotEmpty) {
                            setState(() {
                              _reviews.insert(
                                0,
                                ProductReview(
                                  author: nameCtrl.text.trim(),
                                  rating: newRating,
                                  date: 'Just now',
                                  title: titleCtrl.text.isEmpty ? 'Verified Luxury Purchase' : titleCtrl.text.trim(),
                                  comment: bodyCtrl.text.trim(),
                                  isVerified: true,
                                  helpfulCount: 1,
                                ),
                              );
                            });
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Thank you! Your verified review has been published.'),
                                backgroundColor: AppColors.accentEmerald,
                              ),
                            );
                          }
                        },
                        child: const Text('Submit Verified Review'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddedToCartDrawer(CartProvider cart) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(50),
              blurRadius: 30,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F1523) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Image.network(widget.product.primaryImage, fit: BoxFit.contain),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: AppColors.accentEmerald, size: 18),
                            const SizedBox(width: 6),
                            Text('Added to Bag', style: AppTypography.badgeText.copyWith(color: AppColors.accentEmerald)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(widget.product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 2),
                        Text(
                          '${_selectedColor.name} • $_selectedSize • Qty: $_quantity',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Keep Shopping'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const CartScreen()),
                        );
                      },
                      child: const Text('View Bag & Checkout'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final wishlist = context.watch<WishlistProvider>();
    final isFavorite = wishlist.isWishlisted(widget.product.id);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(widget.product.name, style: AppTypography.headingSmall),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFavorite ? AppColors.accentRose : null,
            ),
            onPressed: () => wishlist.toggleWishlist(widget.product),
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Product link copied to clipboard')),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1320),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AnnouncementBar(),
                    const SizedBox(height: 12),

                // Top Mode Switch: 3D Interactive vs 2D Studio Photos
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildModeChip(
                        title: '3D Interactive Model',
                        icon: Icons.view_in_ar_rounded,
                        isActive: _is3DMode,
                        isDark: isDark,
                        onTap: () => setState(() => _is3DMode = true),
                      ),
                      const SizedBox(width: 12),
                      _buildModeChip(
                        title: 'Studio Gallery',
                        icon: Icons.photo_library_rounded,
                        isActive: !_is3DMode,
                        isDark: isDark,
                        onTap: () => setState(() => _is3DMode = false),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Main Viewer Area (3D or 2D Gallery)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _is3DMode
                      ? Interactive3DViewer(product: widget.product, height: 380)
                      : _build2DGalleryView(isDark),
                ),
                const SizedBox(height: 20),

                // Image Gallery Thumbnails
                if (!_is3DMode && widget.product.images.length > 1)
                  SizedBox(
                    height: 70,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.product.images.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final isSelected = _selectedImageIndex == index;
                        return InkWell(
                          onTap: () => setState(() => _selectedImageIndex = index),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: 70,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkCard : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Image.network(
                              widget.product.images[index],
                              fit: BoxFit.contain,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 20),

                // Product Details Container
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category & Badges Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${widget.product.category.toUpperCase()} • ${widget.product.subCategory.toUpperCase()}',
                            style: AppTypography.badgeText.copyWith(
                              color: AppColors.accentCyan,
                              letterSpacing: 1.0,
                            ),
                          ),
                          if (widget.product.hasDiscount)
                            CustomBadge.discount(widget.product.discountPercent),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Title
                      Text(
                        widget.product.name,
                        style: AppTypography.headingLarge.copyWith(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Tagline
                      Text(
                        widget.product.tagline,
                        style: AppTypography.bodyMedium.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Price and Rating Row
                      Row(
                        children: [
                          Text(
                            Formatters.currency(widget.product.price),
                            style: AppTypography.priceLarge.copyWith(
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                          if (widget.product.hasDiscount) ...[
                            const SizedBox(width: 10),
                            Text(
                              Formatters.currency(widget.product.originalPrice),
                              style: AppTypography.bodyMedium.copyWith(
                                decoration: TextDecoration.lineThrough,
                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                              ),
                            ),
                          ],
                          const Spacer(),
                          RatingStars(
                            rating: widget.product.rating,
                            reviewsCount: widget.product.reviewsCount + _reviews.length - 2,
                            starSize: 18,
                          ),
                        ],
                      ),
                      const Divider(height: 36),

                      // Color Options Selector
                      Text(
                        'SELECT COLOR: ${_selectedColor.name}',
                        style: AppTypography.badgeText.copyWith(
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: widget.product.colors.map((c) {
                          final isSelected = _selectedColor.name == c.name;
                          return InkWell(
                            onTap: () => setState(() => _selectedColor = c),
                            borderRadius: BorderRadius.circular(100),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: c.color,
                                  boxShadow: [
                                    BoxShadow(
                                      color: c.color.withAlpha(80),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Size / Configuration Selector
                      if (widget.product.sizes.isNotEmpty) ...[
                        Text(
                          'CONFIGURATION / SIZE',
                          style: AppTypography.badgeText.copyWith(
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: widget.product.sizes.map((size) {
                            final isSelected = _selectedSize == size;
                            return ChoiceChip(
                              label: Text(size),
                              selected: isSelected,
                              selectedColor: AppColors.primary,
                              backgroundColor:
                                  isDark ? AppColors.darkCard : const Color(0xFFF1F5F9),
                              labelStyle: AppTypography.bodySmall.copyWith(
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary),
                              ),
                              side: BorderSide(
                                color: isSelected
                                    ? AppColors.primaryLight
                                    : (isDark
                                        ? AppColors.darkCardBorder
                                        : AppColors.lightCardBorder),
                              ),
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() => _selectedSize = size);
                                }
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Description
                      Text(
                        'OVERVIEW',
                        style: AppTypography.badgeText.copyWith(
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.product.description,
                        style: AppTypography.bodyMedium.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Specifications Grid
                      Text(
                        'TECHNICAL SPECIFICATIONS',
                        style: AppTypography.badgeText.copyWith(
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                          ),
                        ),
                        child: Column(
                          children: widget.product.specifications.entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    entry.key,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: isDark
                                          ? AppColors.darkTextMuted
                                          : AppColors.lightTextMuted,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    entry.value,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.lightTextPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Interactive Client Reviews Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('CLIENT REVIEWS', style: AppTypography.badgeText),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  RatingStars(rating: widget.product.rating, starSize: 18),
                                  const SizedBox(width: 8),
                                  Text('${widget.product.rating} out of 5', style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                          OutlinedButton.icon(
                            onPressed: _openWriteReviewDialog,
                            icon: const Icon(Icons.rate_review_outlined, size: 16),
                            label: const Text('Write a Review'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // List of Reviews
                      ..._reviews.map((r) => _buildReviewCard(r, isDark)),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Footer
                const EcommerceFooter(),
              ],
            ),
          ),
        ),
      ),

          // Floating Bottom Sticky Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildFloatingBottomBar(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(ProductReview review, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      review.author.substring(0, 1),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(review.author, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(width: 6),
                  if (review.isVerified)
                    const Icon(Icons.verified_rounded, size: 14, color: AppColors.accentEmerald),
                ],
              ),
              Text(
                review.date,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          RatingStars(rating: review.rating, starSize: 13, showText: false),
          const SizedBox(height: 6),
          Text(review.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            review.comment,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.5,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              InkWell(
                onTap: () {
                  setState(() => review.helpfulCount++);
                },
                child: Row(
                  children: [
                    const Icon(Icons.thumb_up_alt_outlined, size: 13, color: AppColors.primaryLight),
                    const SizedBox(width: 4),
                    Text(
                      'Helpful (${review.helpfulCount})',
                      style: const TextStyle(fontSize: 11, color: AppColors.primaryLight, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeChip({
    required String title,
    required IconData icon,
    required bool isActive,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary
              : (isDark ? AppColors.darkCard : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isActive
                ? AppColors.primaryLight
                : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive
                  ? Colors.white
                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive
                    ? Colors.white
                    : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _build2DGalleryView(bool isDark) {
    return Container(
      height: 380,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F1523) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: widget.heroTag != null
            ? Hero(
                tag: widget.heroTag!,
                child: Image.network(
                  widget.product.images[_selectedImageIndex],
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, size: 60),
                ),
              )
            : Image.network(
                widget.product.images[_selectedImageIndex],
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 60),
              ),
      ),
    );
  }

  Widget _buildFloatingBottomBar(bool isDark) {
    final cart = context.read<CartProvider>();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface.withAlpha(240)
            : Colors.white.withAlpha(240),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1320),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                // Quantity Stepper
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 18),
                        onPressed: () {
                          if (_quantity > 1) {
                            setState(() => _quantity--);
                          }
                        },
                      ),
                      Text(
                        '$_quantity',
                        style: AppTypography.headingSmall.copyWith(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 18),
                        onPressed: () {
                          setState(() => _quantity++);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),

                // Add to Cart Button
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        cart.addToCart(
                          widget.product,
                          color: _selectedColor,
                          size: _selectedSize,
                          quantity: _quantity,
                        );
                        _showAddedToCartDrawer(cart);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.shopping_bag_outlined, size: 20),
                          const SizedBox(width: 8),
                          Text('Add to Bag • ${Formatters.currency(widget.product.price * _quantity)}'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
