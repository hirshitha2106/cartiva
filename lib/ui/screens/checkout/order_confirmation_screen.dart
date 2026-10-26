import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/order_model.dart';
import 'order_history_screen.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final OrderModel order;
  final VoidCallback onContinueShopping;

  const OrderConfirmationScreen({
    super.key,
    required this.order,
    required this.onContinueShopping,
  });

  @override
  State<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final order = widget.order;
    final isCOD = order.paymentMethod == 'CASH_ON_DELIVERY';

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Order Status'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            tooltip: 'Home',
            onPressed: widget.onContinueShopping,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: [
                // Celebration Icon with Scale Animation
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isCOD
                          ? const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF6366F1)])
                          : const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                      boxShadow: [
                        BoxShadow(
                          color: (isCOD ? AppColors.primary : AppColors.accentEmerald).withAlpha(140),
                          blurRadius: 32,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      isCOD ? Icons.hourglass_top_rounded : Icons.check_rounded,
                      color: Colors.white,
                      size: 54,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Success Heading (Exact Prompt Wording)
                Text(
                  isCOD
                      ? '🎉 Order Placed Successfully — Payment Pending'
                      : '🎉 Your Order Has Been Placed Successfully!',
                  textAlign: TextAlign.center,
                  style: AppTypography.headingLarge.copyWith(
                    fontSize: 24,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  'Thank you for shopping with us!',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 28),

                // Order Receipt Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(isDark ? 40 : 15),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildReceiptRow(
                        label: 'Order ID:',
                        value: order.orderId,
                        isDark: isDark,
                        isBold: true,
                        valueColor: AppColors.primaryLight,
                      ),
                      const Divider(height: 20),
                      _buildReceiptRow(
                        label: 'Payment Status:',
                        value: isCOD ? 'Pending' : 'Successful',
                        isDark: isDark,
                        badgeColor: isCOD ? AppColors.accentGold : AppColors.accentEmerald,
                      ),
                      const SizedBox(height: 12),
                      _buildReceiptRow(
                        label: 'Order Status:',
                        value: 'Placed',
                        isDark: isDark,
                        badgeColor: AppColors.primary,
                      ),
                      const SizedBox(height: 12),
                      _buildReceiptRow(
                        label: 'Payment Method:',
                        value: order.paymentMethod,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildReceiptRow(
                        label: 'Customer Name:',
                        value: order.customerName,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildReceiptRow(
                        label: 'Product Ordered:',
                        value: '${order.productName} (Qty: ${order.quantity})',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildReceiptRow(
                        label: 'Delivery City:',
                        value: order.deliveryCity,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildReceiptRow(
                        label: 'Estimated Delivery:',
                        value: order.estimatedDelivery,
                        isDark: isDark,
                        valueColor: AppColors.accentGold,
                        isBold: true,
                      ),
                      const Divider(height: 24),
                      _buildReceiptRow(
                        label: 'Total Amount:',
                        value: Formatters.currency(order.totalAmount),
                        isDark: isDark,
                        isLargeTotal: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Delivery Destination Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.pin_drop_rounded, color: AppColors.accentRose, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Shipping Destination:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              order.deliveryAddress,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Actions: View Order History & Continue Shopping
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => OrderHistoryScreen(
                                onContinueShopping: widget.onContinueShopping,
                              ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        icon: const Icon(Icons.receipt_long_rounded, size: 18),
                        label: const Text('View in Order History'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: widget.onContinueShopping,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                        label: const Text('Continue Shopping'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow({
    required String label,
    required String value,
    required bool isDark,
    bool isBold = false,
    bool isLargeTotal = false,
    Color? valueColor,
    Color? badgeColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isLargeTotal ? 16 : 13,
            fontWeight: isLargeTotal ? FontWeight.bold : FontWeight.w500,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        if (badgeColor != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor.withAlpha(35),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: badgeColor.withAlpha(90)),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: badgeColor,
              ),
            ),
          )
        else
          Text(
            value,
            style: TextStyle(
              fontSize: isLargeTotal ? 20 : (isBold ? 14 : 13),
              fontWeight: isLargeTotal || isBold ? FontWeight.bold : FontWeight.w600,
              color: isLargeTotal
                  ? AppColors.accentEmerald
                  : (valueColor ?? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
            ),
          ),
      ],
    );
  }
}
