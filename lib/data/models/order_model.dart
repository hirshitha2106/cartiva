import 'cart_item_model.dart';

enum OrderStatus { placed, processing, shipped, outForDelivery, delivered }

class OrderModel {
  final String orderId;
  final String customerName;
  final String productName;
  final int quantity;
  final double totalAmount;
  final List<CartItem> items;
  final double subtotal;
  final double discount;
  final double shippingFee;
  final DateTime orderDate;
  final String paymentMethod; // 'UPI', 'CARD', 'CASH_ON_DELIVERY'
  final String paymentStatus; // 'SUCCESS', 'PENDING', 'FAILED'
  final String orderStatus; // 'PLACED', 'PROCESSING', 'SHIPPED', 'DELIVERED'
  final String deliveryCity;
  final String deliveryAddress;
  final String estimatedDelivery; // '2026-10-30'
  final String trackingNumber;

  const OrderModel({
    required this.orderId,
    this.customerName = 'Rahul Kumar',
    this.productName = 'Wireless Headphones',
    this.quantity = 1,
    double? totalAmount,
    double? total,
    this.items = const [],
    this.subtotal = 0.0,
    this.discount = 0.0,
    this.shippingFee = 0.0,
    required this.orderDate,
    required this.paymentMethod,
    this.paymentStatus = 'SUCCESS',
    this.orderStatus = 'PLACED',
    OrderStatus? status,
    this.deliveryCity = 'Vijayawada',
    String? deliveryAddress,
    String? shippingAddress,
    this.estimatedDelivery = '2026-10-30',
    this.trackingNumber = '',
  })  : totalAmount = totalAmount ?? total ?? 0.0,
        deliveryAddress = deliveryAddress ?? shippingAddress ?? 'Vijayawada, India';

  // Backward compatibility alias
  double get total => totalAmount;
  String get shippingAddress => deliveryAddress;
  OrderStatus get status {
    switch (orderStatus.toUpperCase()) {
      case 'PLACED':
        return OrderStatus.placed;
      case 'PROCESSING':
        return OrderStatus.processing;
      case 'SHIPPED':
        return OrderStatus.shipped;
      case 'OUT_FOR_DELIVERY':
        return OrderStatus.outForDelivery;
      case 'DELIVERED':
        return OrderStatus.delivered;
      default:
        return OrderStatus.placed;
    }
  }

  bool get isCOD => paymentMethod == 'CASH_ON_DELIVERY';
  bool get isSuccessfulPayment => paymentStatus == 'SUCCESS';

  String get statusDisplay {
    switch (status) {
      case OrderStatus.placed:
        return 'Placed';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'customerName': customerName,
      'productName': productName,
      'quantity': quantity,
      'totalAmount': totalAmount,
      'subtotal': subtotal,
      'discount': discount,
      'shippingFee': shippingFee,
      'orderDate': orderDate.toIso8601String(),
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'orderStatus': orderStatus,
      'deliveryCity': deliveryCity,
      'deliveryAddress': deliveryAddress,
      'estimatedDelivery': estimatedDelivery,
      'trackingNumber': trackingNumber,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    List<CartItem> parsedItems = [];
    if (json['items'] != null && json['items'] is List) {
      try {
        parsedItems = (json['items'] as List)
            .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }

    return OrderModel(
      orderId: json['orderId'] as String? ?? 'ORD10001',
      customerName: json['customerName'] as String? ?? 'Rahul Kumar',
      productName: json['productName'] as String? ?? 'Wireless Headphones',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 2499.0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 2499.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      shippingFee: (json['shippingFee'] as num?)?.toDouble() ?? 0.0,
      orderDate: json['orderDate'] != null
          ? DateTime.tryParse(json['orderDate'] as String) ?? DateTime.now()
          : DateTime.now(),
      paymentMethod: json['paymentMethod'] as String? ?? 'UPI',
      paymentStatus: json['paymentStatus'] as String? ?? 'SUCCESS',
      orderStatus: json['orderStatus'] as String? ?? 'PLACED',
      deliveryCity: json['deliveryCity'] as String? ?? 'Vijayawada',
      deliveryAddress: json['deliveryAddress'] as String? ??
          json['shippingAddress'] as String? ??
          'Vijayawada, India',
      estimatedDelivery: json['estimatedDelivery'] as String? ?? '2026-10-30',
      trackingNumber: json['trackingNumber'] as String? ?? 'TRK-ORD10001',
      items: parsedItems,
    );
  }
}
