import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../state/cart_provider.dart';
import '../checkout/checkout_workflow_screen.dart';
import '../checkout/order_history_screen.dart';

class CartScreen extends StatefulWidget {
  final VoidCallback? onContinueShopping;

  const CartScreen({super.key, this.onContinueShopping});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _couponController = TextEditingController();

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  void _openCheckoutWorkflow(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CheckoutWorkflowScreen(
          onContinueShopping: () {
            Navigator.pop(context);
            if (widget.onContinueShopping != null) {
              widget.onContinueShopping!();
            }
          },
        ),
      ),
    );
  }

  void _openOrderHistory(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OrderHistoryScreen(
          onContinueShopping: () {
            Navigator.pop(context);
            if (widget.onContinueShopping != null) {
              widget.onContinueShopping!();
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text('Shopping Bag', style: AppTypography.headingMedium),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Order History',
            onPressed: () => _openOrderHistory(context),
          ),
          if (cart.items.isNotEmpty)
            TextButton(
              onPressed: () => cart.clearCart(),
              child: Text(
                'Clear All',
                style: AppTypography.buttonText.copyWith(
                  color: AppColors.accentRose,
                  fontSize: 13,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: cart.items.isEmpty
          ? _buildEmptyCart(isDark)
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: CustomScrollView(
                  slivers: [
                    // Free Shipping Progress Bar
                    SliverToBoxAdapter(
                      child: _buildFreeShippingBar(cart, isDark),
                    ),

                    // Cart Items List
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = cart.items[index];
                            return _buildCartItemTile(item, cart, isDark);
                          },
                          childCount: cart.items.length,
                        ),
                      ),
                    ),

                    // Coupon Box & Price Summary
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCouponSection(cart, isDark),
                            const SizedBox(height: 20),
                            _buildOrderSummary(cart, isDark),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      bottomSheet: cart.items.isNotEmpty ? _buildCheckoutBar(cart, isDark) : null,
    );
  }

  Widget _buildFreeShippingBar(CartProvider cart, bool isDark) {
    final progress = cart.freeShippingProgress;
    final qualifies = cart.qualifiesForFreeShipping;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                qualifies ? Icons.check_circle_rounded : Icons.local_shipping_rounded,
                color: qualifies ? AppColors.accentEmerald : AppColors.primaryLight,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  qualifies
                      ? 'You have unlocked Free Express Shipping!'
                      : 'Add ${Formatters.currency(cart.amountNeededForFreeShipping)} more for Free Express Shipping',
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: isDark ? AppColors.darkSurface : const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemTile(CartItem item, CartProvider cart, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image Thumbnail
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F1523) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(8),
            child: Image.network(
              item.product.primaryImage,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 28),
            ),
          ),
          const SizedBox(width: 14),

          // Details Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.headingSmall.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),

                // Selected Color & Size Chips
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: item.selectedColor.color,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.selectedColor.name,
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        fontSize: 11,
                      ),
                    ),
                    const Text(' • '),
                    Text(
                      item.selectedSize,
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Price & Stepper
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      Formatters.currency(item.totalPrice),
                      style: AppTypography.priceMedium.copyWith(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        fontSize: 16,
                      ),
                    ),
                    // Quantity Stepper
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () => cart.updateQuantity(item.id, -1),
                            borderRadius: BorderRadius.circular(12),
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(Icons.remove, size: 16),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '${item.quantity}',
                              style: AppTypography.badgeText.copyWith(
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => cart.updateQuantity(item.id, 1),
                            borderRadius: BorderRadius.circular(12),
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(Icons.add, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponSection(CartProvider cart, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HAVE A PROMO CODE?',
            style: AppTypography.badgeText.copyWith(
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 10),
          if (cart.hasCoupon) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.accentEmerald.withAlpha(isDark ? 40 : 25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accentEmerald.withAlpha(100)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.confirmation_num_rounded,
                      color: AppColors.accentEmerald, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cart.couponCode!,
                          style: AppTypography.badgeText.copyWith(
                            color: AppColors.accentEmerald,
                          ),
                        ),
                        if (cart.couponMessage != null)
                          Text(
                            cart.couponMessage!,
                            style: AppTypography.bodySmall.copyWith(
                              fontSize: 11,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    onPressed: () => cart.removeCoupon(),
                  ),
                ],
              ),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: TextField(
                      controller: _couponController,
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        hintText: 'Enter CARTIVA20 or FREESHIP',
                        hintStyle: AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                    ),
                    onPressed: () {
                      final success = cart.applyCoupon(_couponController.text);
                      if (success) {
                        _couponController.clear();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(cart.couponMessage ?? 'Invalid promo code'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    },
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderSummary(CartProvider cart, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ORDER SUMMARY',
            style: AppTypography.badgeText.copyWith(
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Subtotal', Formatters.currency(cart.subtotal), isDark),
          if (cart.discountAmount > 0) ...[
            const SizedBox(height: 10),
            _buildSummaryRow(
              'Promotion Savings',
              '- ${Formatters.currency(cart.discountAmount)}',
              isDark,
              textColor: AppColors.accentEmerald,
            ),
          ],
          const SizedBox(height: 10),
          _buildSummaryRow(
            'Shipping',
            cart.shippingFee == 0 ? 'FREE' : Formatters.currency(cart.shippingFee),
            isDark,
            textColor: cart.shippingFee == 0 ? AppColors.accentEmerald : null,
          ),
          const Divider(height: 28),
          _buildSummaryRow(
            'Estimated Total',
            Formatters.currency(cart.totalAmount),
            isDark,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    bool isDark, {
    Color? textColor,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? AppTypography.headingSmall.copyWith(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                )
              : AppTypography.bodySmall.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
        ),
        Text(
          value,
          style: isTotal
              ? AppTypography.priceLarge.copyWith(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                )
              : AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: textColor ??
                      (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                ),
        ),
      ],
    );
  }

  Widget _buildCheckoutBar(CartProvider cart, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
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
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => _openCheckoutWorkflow(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_rounded, size: 18),
                    const SizedBox(width: 8),
                    Text('Proceed to Checkout • ${Formatters.currency(cart.totalAmount)}'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCart(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(isDark ? 30 : 15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 60,
                color: AppColors.primaryLight,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Your Shopping Bag is Empty',
              style: AppTypography.headingMedium.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Looks like you haven\'t added any items yet. Discover exclusive drops in our curated collection.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (widget.onContinueShopping != null) {
                  widget.onContinueShopping!();
                }
              },
              child: const Text('Start Shopping'),
            ),
          ],
        ),
      ),
    );
  }
}
