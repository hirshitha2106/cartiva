// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../state/cart_provider.dart';
import '../../../../state/checkout_provider.dart';
import '../../profile/widgets/add_address_dialog.dart';
import '../../profile/widgets/add_payment_dialog.dart';

class CheckoutSheet extends StatefulWidget {
  final VoidCallback onOrderCompleted;

  const CheckoutSheet({super.key, required this.onOrderCompleted});

  @override
  State<CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<CheckoutSheet> {
  int _currentStep = 0; // 0: Address, 1: Delivery, 2: Payment, 3: Review
  bool _isProcessing = false;

  void _openAddAddress() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const AddAddressDialog(),
    );
  }

  void _openAddPayment() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const AddPaymentDialog(),
    );
  }

  void _processOrder() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 1400));

    if (!mounted) return;
    final cart = context.read<CartProvider>();
    final checkout = context.read<CheckoutProvider>();

    final order = checkout.createOrder(
      items: cart.items,
      subtotal: cart.subtotal,
      discount: cart.discountAmount,
      baseShippingFee: cart.shippingFee,
    );

    cart.clearCart();
    setState(() => _isProcessing = false);
    Navigator.pop(context); // Close checkout sheet

    // Show celebration dialog
    _showOrderConfirmation(context, order);
  }

  void _showOrderConfirmation(BuildContext context, dynamic order) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.brandGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(120),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 44),
            ),
            const SizedBox(height: 20),
            Text(
              'Order Confirmed!',
              style: AppTypography.headingLarge.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Thank you, your bespoke order has been verified and dispatched to our logistics center.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Order Number:', style: AppTypography.bodySmall),
                      Text(order.orderId, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Paid:', style: AppTypography.bodySmall),
                      Text(
                        Formatters.currency(order.total),
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentEmerald,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tracking ID:', style: AppTypography.bodySmall),
                      Text(order.trackingNumber, style: AppTypography.bodySmall.copyWith(color: AppColors.primaryLight)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogCtx);
                  widget.onOrderCompleted();
                },
                child: const Text('Back to Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cart = context.watch<CartProvider>();
    final checkout = context.watch<CheckoutProvider>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: SafeArea(
        child: Column(
          children: [
            // Drag Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),

            // Header Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Express Checkout', style: AppTypography.headingMedium),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Step Progress Tabs
            Row(
              children: [
                _buildStepTab(0, 'Address', Icons.location_on_rounded),
                _buildStepDivider(),
                _buildStepTab(1, 'Delivery', Icons.local_shipping_rounded),
                _buildStepDivider(),
                _buildStepTab(2, 'Payment', Icons.credit_card_rounded),
                _buildStepDivider(),
                _buildStepTab(3, 'Review', Icons.receipt_long_rounded),
              ],
            ),
            const Divider(height: 28),

            // Body based on current step
            Expanded(
              child: SingleChildScrollView(
                child: _buildCurrentStepContent(cart, checkout, isDark),
              ),
            ),

            // Bottom Navigation Actions
            const SizedBox(height: 14),
            Row(
              children: [
                if (_currentStep > 0) ...[
                  OutlinedButton(
                    onPressed: _isProcessing ? null : () => setState(() => _currentStep--),
                    child: const Text('Back'),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isProcessing
                          ? null
                          : () {
                              if (_currentStep < 3) {
                                setState(() => _currentStep++);
                              } else {
                                _processOrder();
                              }
                            },
                      child: _isProcessing
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              _currentStep == 3
                                  ? 'Place Luxury Order • ${Formatters.currency(cart.totalAmount + checkout.deliveryFee)}'
                                  : 'Continue to ${_getStepTitle(_currentStep + 1)}',
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 1:
        return 'Delivery';
      case 2:
        return 'Payment';
      case 3:
        return 'Review';
      default:
        return 'Next';
    }
  }

  Widget _buildStepTab(int index, String label, IconData icon) {
    final isSelected = _currentStep == index;
    final isDone = _currentStep > index;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentStep = index),
        borderRadius: BorderRadius.circular(10),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? AppColors.primary
                    : (isDone ? AppColors.accentEmerald : Colors.grey.withAlpha(50)),
              ),
              child: Icon(
                isDone ? Icons.check_rounded : icon,
                size: 16,
                color: isSelected || isDone ? Colors.white : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primaryLight : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepDivider() {
    return Container(
      width: 16,
      height: 1.5,
      color: Colors.grey.withAlpha(80),
      margin: const EdgeInsets.only(bottom: 16),
    );
  }

  Widget _buildCurrentStepContent(CartProvider cart, CheckoutProvider checkout, bool isDark) {
    switch (_currentStep) {
      case 0:
        return _buildAddressStep(checkout, isDark);
      case 1:
        return _buildDeliveryStep(checkout, isDark);
      case 2:
        return _buildPaymentStep(checkout, isDark);
      case 3:
        return _buildReviewStep(cart, checkout, isDark);
      default:
        return const SizedBox.shrink();
    }
  }

  // STEP 0: ADDRESS
  Widget _buildAddressStep(CheckoutProvider checkout, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('SHIPPING DESTINATION', style: AppTypography.badgeText),
            TextButton.icon(
              onPressed: _openAddAddress,
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Add New Address'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...checkout.addresses.map((addr) {
          final isSelected = checkout.selectedAddress.id == addr.id;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.primary : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: RadioListTile<String>(
              value: addr.id,
              groupValue: checkout.selectedAddress.id,
              activeColor: AppColors.primary,
              onChanged: (_) => checkout.selectAddress(addr),
              title: Row(
                children: [
                  Text(addr.recipientName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(isDark ? 50 : 25),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(addr.label, style: const TextStyle(fontSize: 10, color: AppColors.primaryLight)),
                  ),
                ],
              ),
              subtitle: Text(
                addr.formattedAddress,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // STEP 1: DELIVERY SPEED
  Widget _buildDeliveryStep(CheckoutProvider checkout, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SELECT DELIVERY SERVICE', style: AppTypography.badgeText),
        const SizedBox(height: 14),
        _buildDeliveryOptionTile(
          checkout: checkout,
          value: 'standard',
          title: 'Standard Carbon-Neutral Delivery',
          subtitle: 'Estimated arrival in 3 - 5 business days',
          price: 'FREE',
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildDeliveryOptionTile(
          checkout: checkout,
          value: 'express',
          title: 'VIP Express Armored Courier',
          subtitle: 'Guaranteed Priority Next Morning Delivery',
          price: '\$25.00',
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildDeliveryOptionTile({
    required CheckoutProvider checkout,
    required String value,
    required String title,
    required String subtitle,
    required String price,
    required bool isDark,
  }) {
    final isSelected = checkout.deliveryOption == value;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.primary : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: RadioListTile<String>(
        value: value,
        groupValue: checkout.deliveryOption,
        activeColor: AppColors.primary,
        onChanged: (val) => checkout.setDeliveryOption(val!),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
            Text(price, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentEmerald)),
          ],
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  // STEP 2: PAYMENT METHOD
  Widget _buildPaymentStep(CheckoutProvider checkout, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('PAYMENT METHOD', style: AppTypography.badgeText),
            TextButton.icon(
              onPressed: _openAddPayment,
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Add New Card'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...checkout.paymentMethods.map((method) {
          final isSelected = checkout.selectedPaymentMethod.id == method.id;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.primary : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: RadioListTile<String>(
              value: method.id,
              groupValue: checkout.selectedPaymentMethod.id,
              activeColor: AppColors.primary,
              onChanged: (_) => checkout.selectPaymentMethod(method),
              secondary: Icon(method.icon, color: AppColors.primaryLight),
              title: Text(method.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(method.subtitle ?? '', style: const TextStyle(fontSize: 12)),
            ),
          );
        }),
      ],
    );
  }

  // STEP 3: REVIEW & CONFIRM
  Widget _buildReviewStep(CartProvider cart, CheckoutProvider checkout, bool isDark) {
    final finalShipping = cart.shippingFee + checkout.deliveryFee;
    final grandTotal = cart.subtotal - cart.discountAmount + finalShipping;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ORDER REVIEW & SUMMARY', style: AppTypography.badgeText),
        const SizedBox(height: 14),

        // Shipping to card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.pin_drop_rounded, color: AppColors.primaryLight, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ship to ${checkout.selectedAddress.recipientName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(checkout.selectedAddress.formattedAddress, style: const TextStyle(fontSize: 11)),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _currentStep = 0),
                child: const Text('Change'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Payment info card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(checkout.selectedPaymentMethod.icon, color: AppColors.accentEmerald, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(checkout.selectedPaymentMethod.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(checkout.selectedPaymentMethod.subtitle ?? '', style: const TextStyle(fontSize: 11)),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _currentStep = 2),
                child: const Text('Change'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Items preview row
        Text('ITEMS IN ORDER (${cart.itemCount})', style: AppTypography.badgeText),
        const SizedBox(height: 10),
        SizedBox(
          height: 60,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: cart.items.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final item = cart.items[index];
              return Container(
                width: 60,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(6),
                child: Image.network(item.product.primaryImage, fit: BoxFit.contain),
              );
            },
          ),
        ),
        const Divider(height: 28),

        // Price summary
        _buildReviewRow('Items Subtotal', Formatters.currency(cart.subtotal)),
        if (cart.discountAmount > 0) ...[
          const SizedBox(height: 8),
          _buildReviewRow('Promotional Discount', '- ${Formatters.currency(cart.discountAmount)}', isGreen: true),
        ],
        const SizedBox(height: 8),
        _buildReviewRow(
          'Shipping & Handling',
          finalShipping == 0 ? 'FREE' : Formatters.currency(finalShipping),
          isGreen: finalShipping == 0,
        ),
        const Divider(height: 20),
        _buildReviewRow('Total Due', Formatters.currency(grandTotal), isBold: true),
      ],
    );
  }

  Widget _buildReviewRow(String label, String value, {bool isGreen = false, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 17 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isGreen ? AppColors.accentEmerald : null,
          ),
        ),
      ],
    );
  }
}
