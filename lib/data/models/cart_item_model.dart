import 'package:flutter/material.dart';
import 'product_model.dart';

class CartItem {
  final String id;
  final Product product;
  final ProductColor selectedColor;
  final String selectedSize;
  int quantity;

  CartItem({
    required this.id,
    required this.product,
    required this.selectedColor,
    required this.selectedSize,
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;

  CartItem copyWith({
    String? id,
    Product? product,
    ProductColor? selectedColor,
    String? selectedSize,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedSize: selectedSize ?? this.selectedSize,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'selectedColor': {
        'name': selectedColor.name,
        'value': selectedColor.color.toARGB32(),
      },
      'selectedSize': selectedSize,
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final colorMap = json['selectedColor'] as Map<String, dynamic>?;
    return CartItem(
      id: json['id'] as String? ?? 'item_${DateTime.now().millisecondsSinceEpoch}',
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      selectedColor: ProductColor(
        name: colorMap?['name'] as String? ?? 'Default',
        color: Color(colorMap?['value'] as int? ?? 0xFF000000),
      ),
      selectedSize: json['selectedSize'] as String? ?? 'Standard',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }
}
