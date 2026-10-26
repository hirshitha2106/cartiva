import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final IconData icon;
  final String image;
  final int itemCount;
  final Color accentColor;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.image,
    required this.itemCount,
    required this.accentColor,
  });
}
