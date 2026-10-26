import 'package:flutter/material.dart';
import '../data/models/product_model.dart';
import 'cart_provider.dart';

class WishlistProvider extends ChangeNotifier {
  final Set<Product> _items = {};

  List<Product> get items => _items.toList();
  int get itemCount => _items.length;

  bool isWishlisted(String productId) {
    return _items.any((p) => p.id == productId);
  }

  void toggleWishlist(Product product) {
    if (isWishlisted(product.id)) {
      _items.removeWhere((p) => p.id == product.id);
    } else {
      _items.add(product);
    }
    notifyListeners();
  }

  void removeFromWishlist(String productId) {
    _items.removeWhere((p) => p.id == productId);
    notifyListeners();
  }

  void moveToCart(Product product, CartProvider cartProvider) {
    cartProvider.addToCart(product);
    removeFromWishlist(product.id);
  }

  void clearWishlist() {
    _items.clear();
    notifyListeners();
  }
}
