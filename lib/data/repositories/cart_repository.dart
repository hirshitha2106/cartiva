class CouponValidationResult {
  final bool isValid;
  final double discountPercent;
  final double fixedDiscount;
  final bool freeShipping;
  final String message;

  const CouponValidationResult({
    required this.isValid,
    this.discountPercent = 0.0,
    this.fixedDiscount = 0.0,
    this.freeShipping = false,
    required this.message,
  });
}

class CartRepository {
  CouponValidationResult validateCoupon(String code) {
    final clean = code.trim().toUpperCase();
    if (clean == 'CARTIVA20') {
      return const CouponValidationResult(
        isValid: true,
        discountPercent: 0.20,
        message: '20% VIP Cartiva discount applied!',
      );
    } else if (clean == 'CARTIVA50') {
      return const CouponValidationResult(
        isValid: true,
        fixedDiscount: 50.0,
        message: '\$50 instant discount applied!',
      );
    } else if (clean == 'FREESHIP') {
      return const CouponValidationResult(
        isValid: true,
        freeShipping: true,
        message: 'Free express shipping unlocked!',
      );
    } else if (clean.isEmpty) {
      return const CouponValidationResult(
        isValid: false,
        message: 'Please enter a coupon code.',
      );
    } else {
      return const CouponValidationResult(
        isValid: false,
        message: 'Invalid or expired promotional code.',
      );
    }
  }
}
