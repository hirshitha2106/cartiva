import '../models/order_model.dart';
import '../models/cart_item_model.dart';
import '../sample_data/sample_products.dart';

class OrderRepository {
  final List<OrderModel> _orders = [
    OrderModel(
      orderId: 'CRTV-89241',
      items: [
        CartItem(
          id: 'item_init_1',
          product: SampleData.products[0],
          selectedColor: SampleData.products[0].colors.first,
          selectedSize: SampleData.products[0].sizes.first,
          quantity: 1,
        ),
      ],
      subtotal: 349.00,
      discount: 30.00,
      shippingFee: 0.00,
      total: 319.00,
      orderDate: DateTime.now().subtract(const Duration(days: 3)),
      status: OrderStatus.shipped,
      trackingNumber: 'TRK-98328472US',
      shippingAddress: SampleData.currentUser.defaultAddress,
      paymentMethod: 'Apple Pay (•••• 4921)',
    ),
    OrderModel(
      orderId: 'CRTV-73419',
      items: [
        CartItem(
          id: 'item_init_2',
          product: SampleData.products[2],
          selectedColor: SampleData.products[2].colors.first,
          selectedSize: SampleData.products[2].sizes.first,
          quantity: 1,
        ),
      ],
      subtotal: 219.00,
      discount: 0.00,
      shippingFee: 15.00,
      total: 234.00,
      orderDate: DateTime.now().subtract(const Duration(days: 12)),
      status: OrderStatus.delivered,
      trackingNumber: 'TRK-10293847US',
      shippingAddress: SampleData.currentUser.defaultAddress,
      paymentMethod: 'Credit Card (•••• 8820)',
    ),
  ];

  Future<List<OrderModel>> getOrders() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List.unmodifiable(_orders);
  }

  Future<OrderModel> placeOrder({
    required List<CartItem> items,
    required double subtotal,
    required double discount,
    required double shippingFee,
    required double total,
    required String shippingAddress,
    required String paymentMethod,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final newOrder = OrderModel(
      orderId: 'CRTV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      items: List.from(items),
      subtotal: subtotal,
      discount: discount,
      shippingFee: shippingFee,
      total: total,
      orderDate: DateTime.now(),
      status: OrderStatus.processing,
      trackingNumber: 'TRK-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}US',
      shippingAddress: shippingAddress,
      paymentMethod: paymentMethod,
    );
    _orders.insert(0, newOrder);
    return newOrder;
  }
}
