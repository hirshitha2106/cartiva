import 'package:flutter/material.dart';

class ProductColor {
  final String name;
  final Color color;

  const ProductColor({
    required this.name,
    required this.color,
  });
}

class Product {
  final String id;
  final String name;
  final String tagline;
  final String description;
  final double price;
  final double originalPrice;
  final double rating;
  final int reviewsCount;
  final String category;
  final String subCategory;
  final List<String> images;
  final List<ProductColor> colors;
  final List<String> sizes;
  final Map<String, String> specifications;
  final bool isFeatured;
  final bool isTrending;
  final bool isFlashSale;
  final int stockCount;
  final List<String> tags;

  const Product({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.price,
    required this.originalPrice,
    required this.rating,
    required this.reviewsCount,
    required this.category,
    required this.subCategory,
    required this.images,
    required this.colors,
    required this.sizes,
    required this.specifications,
    this.isFeatured = false,
    this.isTrending = false,
    this.isFlashSale = false,
    this.stockCount = 20,
    this.tags = const [],
  });

  bool get hasDiscount => originalPrice > price;

  int get discountPercent {
    if (originalPrice <= price || originalPrice <= 0) return 0;
    return (((originalPrice - price) / originalPrice) * 100).round();
  }

  String get primaryImage => images.isNotEmpty
      ? images.first
      : 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800&q=80';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tagline': tagline,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'category': category,
      'subCategory': subCategory,
      'images': images,
      'colors': colors.map((c) => {'name': c.name, 'value': c.color.toARGB32()}).toList(),
      'sizes': sizes,
      'specifications': specifications,
      'isFeatured': isFeatured,
      'isTrending': isTrending,
      'isFlashSale': isFlashSale,
      'stockCount': stockCount,
      'tags': tags,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String? ?? 'prod_001',
      name: json['name'] as String? ?? 'Wireless Headphones',
      tagline: json['tagline'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 2499.0,
      originalPrice: (json['originalPrice'] as num?)?.toDouble() ?? 3499.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      reviewsCount: (json['reviewsCount'] as num?)?.toInt() ?? 120,
      category: json['category'] as String? ?? 'Audio & Sound',
      subCategory: json['subCategory'] as String? ?? 'Headphones',
      images: (json['images'] as List?)?.map((e) => e.toString()).toList() ??
          ['https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800&q=80'],
      colors: (json['colors'] as List?)?.map((c) {
            final map = c as Map<String, dynamic>;
            return ProductColor(
              name: map['name'] as String? ?? 'Black',
              color: Color(map['value'] as int? ?? 0xFF000000),
            );
          }).toList() ??
          const [ProductColor(name: 'Default', color: Color(0xFF000000))],
      sizes: (json['sizes'] as List?)?.map((e) => e.toString()).toList() ?? ['Standard'],
      specifications: (json['specifications'] as Map?)?.map((k, v) => MapEntry(k.toString(), v.toString())) ?? {},
      isFeatured: json['isFeatured'] as bool? ?? false,
      isTrending: json['isTrending'] as bool? ?? false,
      isFlashSale: json['isFlashSale'] as bool? ?? false,
      stockCount: (json['stockCount'] as num?)?.toInt() ?? 20,
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
