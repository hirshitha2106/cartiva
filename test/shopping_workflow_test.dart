import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cartiva/data/sample_data/sample_products.dart';
import 'package:cartiva/data/models/address_model.dart';
import 'package:cartiva/state/cart_provider.dart';
import 'package:cartiva/state/checkout_provider.dart';
import 'package:cartiva/core/services/local_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.init();
  });

  group('Cartiva Complete Shopping Workflow Tests', () {
    test('1. Product Listing: Verify Wireless Headphones exists at ₹2499 with discount', () {
      final wirelessHeadphones = SampleData.products.firstWhere(
        (p) => p.name == 'Wireless Headphones',
      );
      expect(wirelessHeadphones, isNotNull);
      expect(wirelessHeadphones.price, equals(2499.0));
      expect(wirelessHeadphones.originalPrice, equals(3499.0));
      expect(wirelessHeadphones.hasDiscount, isTrue);
      expect(wirelessHeadphones.discountPercent, greaterThan(25));
    });

    test('2. Shopping Cart: Add to cart, update quantity, compute total', () {
      final cart = CartProvider();
      final product = SampleData.products.firstWhere((p) => p.name == 'Wireless Headphones');

      // Add to cart
      cart.addToCart(product, quantity: 1);
      expect(cart.items.length, equals(1));
      expect(cart.itemCount, equals(1));
      expect(cart.subtotal, equals(2499.0));

      // Increase quantity
      final itemId = cart.items.first.id;
      cart.updateQuantity(itemId, 1);
      expect(cart.itemCount, equals(2));
      expect(cart.subtotal, equals(4998.0));

      // Decrease quantity back to 1
      cart.updateQuantity(itemId, -1);
      expect(cart.itemCount, equals(1));
      expect(cart.subtotal, equals(2499.0));

      // Qualifies for free express shipping (> threshold)
      expect(cart.qualifiesForFreeShipping, isTrue);
      expect(cart.shippingFee, equals(0.0));
      expect(cart.totalAmount, equals(2499.0));
    });

    test('3. Address Page: Validate Rahul Kumar sample address test data', () {
      final sample = AddressModel.sampleRahulAddress;
      expect(sample.fullName, equals('Rahul Kumar'));
      expect(sample.mobileNumber, equals('9876543210'));
      expect(sample.houseNumber, equals('12-4-56'));
      expect(sample.street, equals('MG Road'));
      expect(sample.landmark, equals('Near City Mall'));
      expect(sample.city, equals('Vijayawada'));
      expect(sample.state, equals('Andhra Pradesh'));
      expect(sample.pinCode, equals('520010'));
      expect(sample.country, equals('India'));
      expect(sample.formattedAddress, contains('Vijayawada'));
    });

    test('4. Order Summary: Validate items, delivery address, and final total', () {
      final cart = CartProvider();
      final checkout = CheckoutProvider();
      final product = SampleData.products.firstWhere((p) => p.name == 'Wireless Headphones');

      cart.addToCart(product, quantity: 1);
      checkout.setSampleAddress();

      expect(checkout.selectedAddress.fullName, equals('Rahul Kumar'));
      expect(checkout.selectedAddress.city, equals('Vijayawada'));

      final finalShipping = cart.shippingFee + checkout.deliveryFee;
      final finalAmount = cart.subtotal - cart.discountAmount + finalShipping;

      expect(cart.subtotal, equals(2499.0));
      expect(finalShipping, equals(0.0)); // standard free delivery
      expect(finalAmount, equals(2499.0));
    });

    test('5. Payment Options: UPI Mock Option A verification', () {
      final checkout = CheckoutProvider();
      checkout.selectPaymentType('UPI');
      checkout.fillDemoUpi();

      expect(checkout.selectedPaymentType, equals('UPI'));
      expect(checkout.upiId, equals('rahul@demo'));
    });

    test('6. Payment Options: Card Mock Option B verification', () {
      final checkout = CheckoutProvider();
      checkout.selectPaymentType('CARD');
      checkout.fillDemoCard();

      expect(checkout.selectedPaymentType, equals('CARD'));
      expect(checkout.cardHolder, equals('RAHUL KUMAR'));
      expect(checkout.cardNumber, equals('4111111111111111'));
      expect(checkout.expiryDate, equals('12/30'));
      expect(checkout.cvv, equals('123'));
    });

    test('7. Payment Options: Cash on Delivery Option C verification', () {
      final checkout = CheckoutProvider();
      checkout.selectPaymentType('CASH_ON_DELIVERY');

      expect(checkout.selectedPaymentType, equals('CASH_ON_DELIVERY'));
    });

    test('8. Order Processing & Order Confirmation: Simulated Payment and Order Creation', () {
      final cart = CartProvider();
      final checkout = CheckoutProvider();
      final product = SampleData.products.firstWhere((p) => p.name == 'Wireless Headphones');

      cart.addToCart(product, quantity: 1);
      checkout.setSampleAddress();
      checkout.selectPaymentType('UPI');

      // Create Order
      final order = checkout.createOrder(
        items: cart.items,
        subtotal: cart.subtotal,
        discount: cart.discountAmount,
        baseShippingFee: cart.shippingFee,
        overridePaymentMethod: 'UPI',
        overridePaymentStatus: 'SUCCESS',
      );

      // Verify prompt's exact sample order fields:
      expect(order.customerName, equals('Rahul Kumar'));
      expect(order.productName, equals('Wireless Headphones'));
      expect(order.quantity, equals(1));
      expect(order.totalAmount, equals(2499.0));
      expect(order.paymentMethod, equals('UPI'));
      expect(order.paymentStatus, equals('SUCCESS'));
      expect(order.orderStatus, equals('PLACED'));
      expect(order.deliveryCity, equals('Vijayawada'));
      expect(order.isCOD, isFalse);
      expect(order.isSuccessfulPayment, isTrue);

      // Clear cart on completion
      cart.clearCart();
      expect(cart.items.isEmpty, isTrue);
    });

    test('9. Order History: Saved orders persisted and retrievable locally', () async {
      final cart = CartProvider();
      final checkout = CheckoutProvider();
      final product = SampleData.products.firstWhere((p) => p.name == 'Wireless Headphones');

      cart.addToCart(product, quantity: 1);
      checkout.setSampleAddress();

      final createdOrder = checkout.createOrder(
        items: cart.items,
        subtotal: cart.subtotal,
        discount: 0.0,
        baseShippingFee: 0.0,
      );

      expect(checkout.orders, isNotEmpty);
      expect(checkout.orders.first.orderId, equals(createdOrder.orderId));

      await Future.delayed(const Duration(milliseconds: 50));
      final storedOrders = await LocalStorageService.getOrders();
      expect(storedOrders.any((o) => o.orderId == createdOrder.orderId), isTrue);
    });
  });
}
