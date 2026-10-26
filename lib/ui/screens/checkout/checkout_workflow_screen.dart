import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/order_model.dart';
import '../../../state/cart_provider.dart';
import '../../../state/checkout_provider.dart';
import 'steps/address_step.dart';
import 'steps/order_summary_step.dart';
import 'steps/payment_step.dart';
import 'order_confirmation_screen.dart';

class CheckoutWorkflowScreen extends StatefulWidget {
  final VoidCallback onContinueShopping;

  const CheckoutWorkflowScreen({
    super.key,
    required this.onContinueShopping,
  });

  @override
  State<CheckoutWorkflowScreen> createState() => _CheckoutWorkflowScreenState();
}

class _CheckoutWorkflowScreenState extends State<CheckoutWorkflowScreen> {
  // 0: Address, 1: Order Summary, 2: Payment
  int _currentStep = 0;
  bool _isProcessing = false;
  String _processingStatus = 'Validating address and credentials...';

  void _goToStep(int step) {
    setState(() => _currentStep = step);
  }

  void _executePayment({required String paymentMethod, required String paymentStatus}) async {
    setState(() {
      _isProcessing = true;
      _processingStatus = 'Connecting to mock gateway...';
    });

    final checkout = context.read<CheckoutProvider>();
    final cart = context.read<CartProvider>();

    // Step 1 simulation
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    // Check if simulated failure is triggered
    if (checkout.simulatePaymentFailure && paymentMethod != 'CASH_ON_DELIVERY') {
      setState(() => _isProcessing = false);
      _showPaymentFailureDialog();
      return;
    }

    // Step 2 simulation
    setState(() {
      _processingStatus = paymentMethod == 'CASH_ON_DELIVERY'
          ? 'Confirming cash on delivery booking...'
          : 'Authorizing simulated transaction ($paymentMethod)...';
    });
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    // Step 3: Create Order
    setState(() => _processingStatus = 'Generating verified order record...');
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    final OrderModel order = checkout.createOrder(
      items: cart.items,
      subtotal: cart.subtotal,
      discount: cart.discountAmount,
      baseShippingFee: cart.shippingFee,
      overridePaymentMethod: paymentMethod,
      overridePaymentStatus: paymentStatus,
    );

    // Clear cart after successful order creation
    cart.clearCart();

    setState(() => _isProcessing = false);

    // Navigate to Order Confirmation
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => OrderConfirmationScreen(
          order: order,
          onContinueShopping: widget.onContinueShopping,
        ),
      ),
    );
  }

  void _showPaymentFailureDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.error_outline_rounded, color: AppColors.accentRose, size: 28),
            SizedBox(width: 10),
            Text('Simulated Payment Failed', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mock Payment Gateway returned code: PAY_ERR_SIMULATION_ACTIVE.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Your card/UPI details were rejected by the mock testing gateway simulator. You can disable the simulation toggle or try another payment method.',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<CheckoutProvider>().setSimulatePaymentFailure(false);
            },
            child: const Text('Turn Off Simulation & Retry'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentRose),
            child: const Text('Retry Payment'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cart = context.watch<CartProvider>();
    final checkout = context.watch<CheckoutProvider>();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          _currentStep == 0
              ? 'Step 1: Delivery Address'
              : (_currentStep == 1 ? 'Step 2: Order Summary' : 'Step 3: Payment Options'),
          style: AppTypography.headingSmall,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Stepper Header Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                    ),
                  ),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Row(
                      children: [
                        _buildStepIndicator(
                          stepIndex: 0,
                          title: 'Address',
                          icon: Icons.location_on_rounded,
                          isDark: isDark,
                        ),
                        _buildStepConnector(0),
                        _buildStepIndicator(
                          stepIndex: 1,
                          title: 'Summary',
                          icon: Icons.receipt_long_rounded,
                          isDark: isDark,
                        ),
                        _buildStepConnector(1),
                        _buildStepIndicator(
                          stepIndex: 2,
                          title: 'Payment',
                          icon: Icons.payment_rounded,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Step Content Area
              Expanded(
                child: IndexedStack(
                  index: _currentStep,
                  children: [
                    AddressStep(
                      checkout: checkout,
                      onAddressConfirmed: () => _goToStep(1),
                    ),
                    OrderSummaryStep(
                      cart: cart,
                      checkout: checkout,
                      onEditAddress: () => _goToStep(0),
                      onProceedToPayment: () => _goToStep(2),
                      onBackToAddress: () => _goToStep(0),
                    ),
                    PaymentStep(
                      cart: cart,
                      checkout: checkout,
                      onBackToSummary: () => _goToStep(1),
                      onExecutePayment: _executePayment,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Processing Loading Overlay
          if (_isProcessing)
            Container(
              color: Colors.black.withAlpha(160),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(80),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 48,
                        height: 48,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Processing Order',
                        style: AppTypography.headingSmall.copyWith(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _processingStatus,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator({
    required int stepIndex,
    required String title,
    required IconData icon,
    required bool isDark,
  }) {
    final isCurrent = _currentStep == stepIndex;
    final isDone = _currentStep > stepIndex;

    return Expanded(
      child: InkWell(
        onTap: isDone ? () => setState(() => _currentStep = stepIndex) : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone
                    ? AppColors.accentEmerald
                    : (isCurrent ? AppColors.primary : Colors.grey.withAlpha(60)),
              ),
              child: Center(
                child: isDone
                    ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                    : Icon(icon, size: 14, color: Colors.white),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isCurrent || isDone ? FontWeight.bold : FontWeight.w500,
                  color: isCurrent
                      ? AppColors.primaryLight
                      : (isDone
                          ? AppColors.accentEmerald
                          : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepConnector(int stepIndex) {
    final isDone = _currentStep > stepIndex;
    return Container(
      width: 24,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: isDone ? AppColors.accentEmerald : Colors.grey.withAlpha(70),
    );
  }
}
