import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../state/cart_provider.dart';
import '../../../../state/checkout_provider.dart';

class OrderSummaryStep extends StatelessWidget {
  final CartProvider cart;
  final CheckoutProvider checkout;
  final VoidCallback onEditAddress;
  final VoidCallback onProceedToPayment;
  final VoidCallback onBackToAddress;

  const OrderSummaryStep({
    super.key,
    required this.cart,
    required this.checkout,
    required this.onEditAddress,
    required this.onProceedToPayment,
    required this.onBackToAddress,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final finalShipping = cart.shippingFee + checkout.deliveryFee;
    final grandTotal = (cart.subtotal - cart.discountAmount + finalShipping).clamp(0.0, double.infinity);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order Summary & Review',
                    style: AppTypography.headingMedium.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentEmerald.withAlpha(isDark ? 50 : 25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${cart.itemCount} ${cart.itemCount == 1 ? "Item" : "Items"} in Bag',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accentEmerald,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 1. Delivery Address Card
              Container(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(isDark ? 40 : 20),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.location_on_rounded, color: AppColors.primaryLight, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'DELIVERY ADDRESS',
                              style: AppTypography.badgeText.copyWith(
                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: onEditAddress,
                          icon: const Icon(Icons.edit_rounded, size: 16),
                          label: const Text('Change Address'),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                checkout.selectedAddress.fullName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                checkout.selectedAddress.formattedAddress,
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.4,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.phone_rounded, size: 14, color: AppColors.primaryLight),
                                  const SizedBox(width: 6),
                                  Text(
                                    checkout.selectedAddress.mobileNumber,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            checkout.selectedAddress.city,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2. Selected Products List
              Container(
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
                      'PURCHASED ITEMS',
                      style: AppTypography.badgeText.copyWith(
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: cart.items.length,
                      separatorBuilder: (context, index) => const Divider(height: 24),
                      itemBuilder: (context, index) {
                        final item = cart.items[index];
                        return Row(
                          children: [
                            // Product Image
                            Container(
                              width: 64,
                              height: 64,
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF0F1522) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Image.network(
                                item.product.primaryImage,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.headphones_rounded),
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Variant: ${item.selectedColor.name} • ${item.selectedSize}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Qty: ${item.quantity} × ${Formatters.currency(item.product.price)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Price
                            Text(
                              Formatters.currency(item.totalPrice),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 3. Delivery Speed Choice
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SHIPPING METHOD',
                        style: AppTypography.badgeText.copyWith(
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 12),
                      RadioListTile<String>(
                        value: 'standard',
                        groupValue: checkout.deliveryOption,
                        activeColor: AppColors.primary,
                        onChanged: (val) => checkout.setDeliveryOption(val!),
                        title: const Text('Standard Delivery (3-5 Days)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: const Text('Complimentary standard insured delivery', style: TextStyle(fontSize: 12)),
                        secondary: const Text('FREE', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentEmerald)),
                      ),
                      const Divider(height: 12),
                      RadioListTile<String>(
                        value: 'express',
                        groupValue: checkout.deliveryOption,
                        activeColor: AppColors.primary,
                        onChanged: (val) => checkout.setDeliveryOption(val!),
                        title: const Text('Express Courier Delivery (Next Day)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: const Text('Priority handling & real-time telemetry', style: TextStyle(fontSize: 12)),
                        secondary: Text(Formatters.currency(99.00), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 4. Financial Price Breakdown
              Container(
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
                      'PRICE DETAILS',
                      style: AppTypography.badgeText.copyWith(
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildRow('Bag Subtotal (${cart.itemCount} items)', Formatters.currency(cart.subtotal), isDark),
                    const SizedBox(height: 10),
                    if (cart.discountAmount > 0) ...[
                      _buildRow('Promotional Coupon Discount', '- ${Formatters.currency(cart.discountAmount)}', isDark, isGreen: true),
                      const SizedBox(height: 10),
                    ],
                    _buildRow(
                      'Delivery Charges',
                      finalShipping == 0 ? 'FREE' : Formatters.currency(finalShipping),
                      isDark,
                      isGreen: finalShipping == 0,
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Payable Amount',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        Text(
                          Formatters.currency(grandTotal),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppColors.accentEmerald,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: onBackToAddress,
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: const Text('Back to Address'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: onProceedToPayment,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.payment_rounded, size: 18),
                            const SizedBox(width: 8),
                            Text('Proceed to Payment • ${Formatters.currency(grandTotal)}'),
                          ],
                        ),
                      ),
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

  Widget _buildRow(String label, String value, bool isDark, {bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isGreen
                ? AppColors.accentEmerald
                : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          ),
        ),
      ],
    );
  }
}
