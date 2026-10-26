import 'package:flutter/material.dart';
import '../data/models/product_model.dart';
import '../data/models/category_model.dart';
import '../data/repositories/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepository _repository;

  ProductProvider({ProductRepository? repository})
      : _repository = repository ?? ProductRepository() {
    loadData();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  List<Product> _featuredProducts = [];
  List<Product> _trendingProducts = [];
  List<Product> _flashSaleProducts = [];
  List<CategoryModel> _categories = [];

  String _selectedCategoryId = 'cat_all';
  String _searchQuery = '';
  String _sortBy = 'Popularity';
  double? _minPrice;
  double? _maxPrice;

  List<Product> get allProducts => _allProducts;
  List<Product> get filteredProducts => _filteredProducts;
  List<Product> get featuredProducts => _featuredProducts;
  List<Product> get trendingProducts => _trendingProducts;
  List<Product> get flashSaleProducts => _flashSaleProducts;
  List<CategoryModel> get categories => _categories;
  String get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final futures = await Future.wait([
        _repository.getAllProducts(),
        _repository.getFeaturedProducts(),
        _repository.getTrendingProducts(),
        _repository.getFlashSaleProducts(),
        _repository.getCategories(),
      ]);

      _allProducts = futures[0] as List<Product>;
      _featuredProducts = futures[1] as List<Product>;
      _trendingProducts = futures[2] as List<Product>;
      _flashSaleProducts = futures[3] as List<Product>;
      _categories = futures[4] as List<CategoryModel>;

      _applyFilters();
    } catch (e) {
      debugPrint('Error loading products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCategory(String categoryId) {
    if (_selectedCategoryId == categoryId) return;
    _selectedCategoryId = categoryId;
    _applyFilters();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    _applyFilters();
    notifyListeners();
  }

  void setPriceFilter(double? min, double? max) {
    _minPrice = min;
    _maxPrice = max;
    _applyFilters();
    notifyListeners();
  }

  void resetFilters() {
    _selectedCategoryId = 'cat_all';
    _searchQuery = '';
    _sortBy = 'Popularity';
    _minPrice = null;
    _maxPrice = null;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    var list = List<Product>.from(_allProducts);

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      list = list.where((p) {
        return p.name.toLowerCase().contains(q) ||
            p.tagline.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q) ||
            p.tags.any((t) => t.toLowerCase().contains(q));
      }).toList();
    }

    if (_selectedCategoryId != 'cat_all') {
      final selectedCategory = _categories.firstWhere(
        (c) => c.id == _selectedCategoryId,
        orElse: () => _categories.first,
      );
      list = list.where((p) => p.category == selectedCategory.name).toList();
    }

    if (_minPrice != null) {
      list = list.where((p) => p.price >= _minPrice!).toList();
    }

    if (_maxPrice != null) {
      list = list.where((p) => p.price <= _maxPrice!).toList();
    }

    if (_sortBy == 'Price: Low to High') {
      list.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortBy == 'Price: High to Low') {
      list.sort((a, b) => b.price.compareTo(a.price));
    } else if (_sortBy == 'Top Rated') {
      list.sort((a, b) => b.rating.compareTo(a.rating));
    }

    _filteredProducts = list;
  }
}
