import 'package:flutter/material.dart';
import '../data/models/product_model.dart';
import '../data/models/cart_item_model.dart';
import '../data/repositories/cart_repository.dart';

import '../core/services/local_storage_service.dart';

class CartProvider extends ChangeNotifier {
  final CartRepository _cartRepository;

  CartProvider({CartRepository? cartRepository})
      : _cartRepository = cartRepository ?? CartRepository() {
    _loadPersistedCart();
  }

  void _loadPersistedCart() async {
    try {
      final saved = await LocalStorageService.getCart();
      if (saved.isNotEmpty) {
        _items.clear();
        _items.addAll(saved);
        notifyListeners();
      }
    } catch (_) {}
  }

  void _persist() {
    LocalStorageService.saveCart(_items);
  }

  final List<CartItem> _items = [];
  String? _couponCode;
  double _couponDiscountRate = 0.0;
  double _couponFixedDiscount = 0.0;
  bool _couponFreeShipping = false;
  String? _couponMessage;

  List<CartItem> get items => List.unmodifiable(_items);
  String? get couponCode => _couponCode;
  String? get couponMessage => _couponMessage;
  bool get hasCoupon => _couponCode != null;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  static const double freeShippingThreshold = 300.0;

  bool get qualifiesForFreeShipping =>
      _couponFreeShipping || subtotal >= freeShippingThreshold;

  double get freeShippingProgress =>
      (subtotal / freeShippingThreshold).clamp(0.0, 1.0);

  double get amountNeededForFreeShipping =>
      (freeShippingThreshold - subtotal).clamp(0.0, freeShippingThreshold);

  double get shippingFee {
    if (_items.isEmpty) return 0.0;
    if (qualifiesForFreeShipping) return 0.0;
    return 15.00;
  }

  double get discountAmount {
    if (_items.isEmpty) return 0.0;
    double discount = 0.0;
    if (_couponDiscountRate > 0) {
      discount += subtotal * _couponDiscountRate;
    }
    if (_couponFixedDiscount > 0) {
      discount += _couponFixedDiscount;
    }
    return discount.clamp(0.0, subtotal);
  }

  double get totalAmount {
    if (_items.isEmpty) return 0.0;
    return (subtotal - discountAmount + shippingFee).clamp(0.0, double.infinity);
  }

  void addToCart(
    Product product, {
    ProductColor? color,
    String? size,
    int quantity = 1,
  }) {
    final selectedColor = color ?? product.colors.first;
    final selectedSize = size ?? (product.sizes.isNotEmpty ? product.sizes.first : 'Standard');

    // Check if an identical variant already exists in cart
    final existingIndex = _items.indexWhere(
      (item) =>
          item.product.id == product.id &&
          item.selectedColor.name == selectedColor.name &&
          item.selectedSize == selectedSize,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      final newItem = CartItem(
        id: 'cart_${DateTime.now().millisecondsSinceEpoch}_${product.id}',
        product: product,
        selectedColor: selectedColor,
        selectedSize: selectedSize,
        quantity: quantity,
      );
      _items.add(newItem);
    }
    _persist();
    notifyListeners();
  }

  void updateQuantity(String itemId, int delta) {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index >= 0) {
      final newQty = _items[index].quantity + delta;
      if (newQty <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = newQty;
      }
      _persist();
      notifyListeners();
    }
  }

  void removeItem(String itemId) {
    _items.removeWhere((item) => item.id == itemId);
    _persist();
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    removeCoupon();
    _persist();
    notifyListeners();
  }

  bool applyCoupon(String code) {
    final result = _cartRepository.validateCoupon(code);
    _couponMessage = result.message;

    if (result.isValid) {
      _couponCode = code.trim().toUpperCase();
      _couponDiscountRate = result.discountPercent;
      _couponFixedDiscount = result.fixedDiscount;
      _couponFreeShipping = result.freeShipping;
      notifyListeners();
      return true;
    } else {
      _couponCode = null;
      _couponDiscountRate = 0.0;
      _couponFixedDiscount = 0.0;
      _couponFreeShipping = false;
      notifyListeners();
      return false;
    }
  }

  void removeCoupon() {
    _couponCode = null;
    _couponDiscountRate = 0.0;
    _couponFixedDiscount = 0.0;
    _couponFreeShipping = false;
    _couponMessage = null;
    notifyListeners();
  }
}
