import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../state/cart_provider.dart';
import '../../../../state/checkout_provider.dart';

class PaymentStep extends StatefulWidget {
  final CartProvider cart;
  final CheckoutProvider checkout;
  final VoidCallback onBackToSummary;
  final Function({required String paymentMethod, required String paymentStatus}) onExecutePayment;

  const PaymentStep({
    super.key,
    required this.cart,
    required this.checkout,
    required this.onBackToSummary,
    required this.onExecutePayment,
  });

  @override
  State<PaymentStep> createState() => _PaymentStepState();
}

class _PaymentStepState extends State<PaymentStep> {
  final _upiFormKey = GlobalKey<FormState>();
  final _cardFormKey = GlobalKey<FormState>();

  late final TextEditingController _upiController;
  late final TextEditingController _cardHolderController;
  late final TextEditingController _cardNumberController;
  late final TextEditingController _expiryController;
  late final TextEditingController _cvvController;

  @override
  void initState() {
    super.initState();
    _upiController = TextEditingController(text: widget.checkout.upiId);
    _cardHolderController = TextEditingController(text: widget.checkout.cardHolder);
    _cardNumberController = TextEditingController(text: widget.checkout.cardNumber);
    _expiryController = TextEditingController(text: widget.checkout.expiryDate);
    _cvvController = TextEditingController(text: widget.checkout.cvv);
  }

  @override
  void dispose() {
    _upiController.dispose();
    _cardHolderController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _fillDemoUpi() {
    setState(() {
      _upiController.text = 'rahul@demo';
    });
    widget.checkout.setUpiData(upiId: 'rahul@demo');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Demo UPI ID (rahul@demo) applied!'),
        backgroundColor: AppColors.accentEmerald,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _fillDemoCard() {
    setState(() {
      _cardHolderController.text = 'RAHUL KUMAR';
      _cardNumberController.text = '4111111111111111';
      _expiryController.text = '12/30';
      _cvvController.text = '123';
    });
    widget.checkout.setCardData(
      cardHolder: 'RAHUL KUMAR',
      cardNumber: '4111111111111111',
      expiryDate: '12/30',
      cvv: '123',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Demo Card details (Visa •••• 1111) applied!'),
        backgroundColor: AppColors.accentEmerald,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _handlePay() {
    final method = widget.checkout.selectedPaymentType;

    if (method == 'UPI') {
      if (!(_upiFormKey.currentState?.validate() ?? false)) return;
      widget.checkout.setUpiData(upiId: _upiController.text.trim());
    } else if (method == 'CARD') {
      if (!(_cardFormKey.currentState?.validate() ?? false)) return;
      widget.checkout.setCardData(
        cardHolder: _cardHolderController.text.trim(),
        cardNumber: _cardNumberController.text.trim(),
        expiryDate: _expiryController.text.trim(),
        cvv: _cvvController.text.trim(),
      );
    }

    final status = method == 'CASH_ON_DELIVERY' ? 'PENDING' : 'SUCCESS';
    widget.onExecutePayment(paymentMethod: method, paymentStatus: status);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final finalShipping = widget.cart.shippingFee + widget.checkout.deliveryFee;
    final grandTotal = (widget.cart.subtotal - widget.cart.discountAmount + finalShipping).clamp(0.0, double.infinity);
    final selectedMethod = widget.checkout.selectedPaymentType;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Payment Method',
                        style: AppTypography.headingMedium.copyWith(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Simulated sandbox payment environment (No real charges)',
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.accentEmerald.withAlpha(isDark ? 40 : 20),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.accentEmerald.withAlpha(80)),
                    ),
                    child: Text(
                      'Pay: ${Formatters.currency(grandTotal)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.accentEmerald,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Option Cards Row / Selector
              Row(
                children: [
                  _buildPaymentTab(
                    type: 'UPI',
                    title: 'UPI',
                    icon: Icons.qr_code_2_rounded,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 12),
                  _buildPaymentTab(
                    type: 'CARD',
                    title: 'Card Payment',
                    icon: Icons.credit_card_rounded,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 12),
                  _buildPaymentTab(
                    type: 'CASH_ON_DELIVERY',
                    title: 'Cash on Delivery',
                    icon: Icons.local_atm_rounded,
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Method Details Card
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
                      color: Colors.black.withAlpha(isDark ? 30 : 10),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (selectedMethod == 'UPI') _buildUpiSection(isDark),
                    if (selectedMethod == 'CARD') _buildCardSection(isDark),
                    if (selectedMethod == 'CASH_ON_DELIVERY') _buildCodSection(isDark),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Test Simulation Controls
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.science_rounded, size: 20, color: AppColors.accentGold),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Simulate Payment Failure (Testing)',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            'Toggle to test error handling and gateway retry messages',
                            style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: widget.checkout.simulatePaymentFailure,
                      activeColor: AppColors.accentRose,
                      onChanged: (val) => widget.checkout.setSimulatePaymentFailure(val),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: widget.onBackToSummary,
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: const Text('Back to Summary'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _handlePay,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedMethod == 'CASH_ON_DELIVERY'
                              ? AppColors.primary
                              : AppColors.accentEmerald,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              selectedMethod == 'CASH_ON_DELIVERY'
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.lock_outline_rounded,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              selectedMethod == 'CASH_ON_DELIVERY'
                                  ? 'Confirm Order with Cash on Delivery'
                                  : 'Pay & Confirm Order • ${Formatters.currency(grandTotal)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
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

  Widget _buildPaymentTab({
    required String type,
    required String title,
    required IconData icon,
    required bool isDark,
  }) {
    final isSelected = widget.checkout.selectedPaymentType == type;

    return Expanded(
      child: InkWell(
        onTap: () => widget.checkout.selectPaymentType(type),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withAlpha(isDark ? 50 : 25)
                : (isDark ? AppColors.darkCard : Colors.white),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected ? AppColors.primary : (isDark ? Colors.white60 : Colors.black54),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primaryLight
                      : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- SECTION A: UPI ---
  Widget _buildUpiSection(bool isDark) {
    return Form(
      key: _upiFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('OPTION A — UPI MOCK PAYMENT', style: AppTypography.badgeText),
                  const SizedBox(height: 4),
                  const Text('Enter Virtual Payment Address (VPA) / UPI ID', style: TextStyle(fontSize: 13)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _fillDemoUpi,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentEmerald,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                icon: const Icon(Icons.flash_on_rounded, size: 16),
                label: const Text('Use Demo UPI (rahul@demo)'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // UPI ID Input
          TextFormField(
            controller: _upiController,
            style: TextStyle(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              labelText: 'UPI ID / VPA *',
              hintText: 'e.g. rahul@demo',
              prefixIcon: const Icon(Icons.alternate_email_rounded, color: AppColors.primaryLight),
              helperText: 'Sample format: username@bank or rahul@demo',
              filled: true,
              fillColor: isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Please enter a UPI ID';
              }
              if (!val.contains('@') || val.trim().length < 4) {
                return 'Enter a valid UPI ID (e.g. rahul@demo)';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),

          // Mock Data Display Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primaryLight),
                    SizedBox(width: 8),
                    Text('Mock UPI Gateway Parameters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                SizedBox(height: 10),
                Text('• Payment Method: UPI', style: TextStyle(fontSize: 12, fontFamily: 'monospace')),
                Text('• Mock Transaction ID: MOCK_TXN_10001', style: TextStyle(fontSize: 12, fontFamily: 'monospace')),
                Text('• Simulated Payment Status: SUCCESS', style: TextStyle(fontSize: 12, fontFamily: 'monospace', color: AppColors.accentEmerald, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- SECTION B: CARD ---
  Widget _buildCardSection(bool isDark) {
    return Form(
      key: _cardFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('OPTION B — CARD MOCK DATA', style: AppTypography.badgeText),
                  const SizedBox(height: 4),
                  const Text('Enter mock credit/debit card credentials', style: TextStyle(fontSize: 13)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _fillDemoCard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentEmerald,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                icon: const Icon(Icons.flash_on_rounded, size: 16),
                label: const Text('Use Demo Card'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Card Holder Name
          TextFormField(
            controller: _cardHolderController,
            textCapitalization: TextCapitalization.characters,
            style: TextStyle(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              labelText: 'Card Holder Name *',
              hintText: 'RAHUL KUMAR',
              prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.primaryLight),
              filled: true,
              fillColor: isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Enter card holder name';
              return null;
            },
          ),
          const SizedBox(height: 14),

          // Card Number
          TextFormField(
            controller: _cardNumberController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
            ],
            style: TextStyle(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
            decoration: InputDecoration(
              labelText: 'Card Number (16 Digits) *',
              hintText: '4111111111111111',
              prefixIcon: const Icon(Icons.credit_card_rounded, color: AppColors.primaryLight),
              suffixIcon: const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.payment_rounded, color: Colors.blue),
              ),
              filled: true,
              fillColor: isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
            validator: (val) {
              if (val == null || val.trim().length < 16) {
                return 'Enter 16-digit card number';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),

          // Expiry & CVV
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _expiryController,
                  inputFormatters: [LengthLimitingTextInputFormatter(5)],
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Expiry Date (MM/YY) *',
                    hintText: '12/30',
                    prefixIcon: const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primaryLight),
                    filled: true,
                    fillColor: isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  validator: (val) {
                    if (val == null || !val.contains('/')) return 'Format: MM/YY';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TextFormField(
                  controller: _cvvController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    labelText: 'CVV *',
                    hintText: '123',
                    prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.primaryLight),
                    filled: true,
                    fillColor: isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().length < 3) return '3-digit CVV';
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Disclaimer
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withAlpha(isDark ? 30 : 20),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withAlpha(80)),
            ),
            child: const Row(
              children: [
                Icon(Icons.shield_outlined, size: 18, color: AppColors.accentGold),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Card values are strictly used as dummy form inputs in this simulated test flow. CVV is never stored.',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- SECTION C: CASH ON DELIVERY ---
  Widget _buildCodSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('OPTION C — CASH ON DELIVERY', style: AppTypography.badgeText),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.accentEmerald.withAlpha(isDark ? 30 : 15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.accentEmerald.withAlpha(80)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.verified_rounded, color: AppColors.accentEmerald, size: 22),
                  SizedBox(width: 10),
                  Text(
                    'Payment will be collected on delivery.',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.accentEmerald),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                '• Payment Status: PENDING\n• Order Status: PLACED\n• Exact cash or UPI at the doorstep is supported by the courier.',
                style: TextStyle(fontSize: 12, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
