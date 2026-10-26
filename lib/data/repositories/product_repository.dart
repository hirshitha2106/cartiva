import '../models/product_model.dart';
import '../models/category_model.dart';
import '../sample_data/sample_products.dart';

class ProductRepository {
  final List<Product> _products = List.from(SampleData.products);
  final List<CategoryModel> _categories = List.from(SampleData.categories);

  Future<List<Product>> getAllProducts() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _products;
  }

  Future<List<Product>> getFeaturedProducts() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _products.where((p) => p.isFeatured).toList();
  }

  Future<List<Product>> getTrendingProducts() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _products.where((p) => p.isTrending).toList();
  }

  Future<List<Product>> getFlashSaleProducts() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _products.where((p) => p.isFlashSale).toList();
  }

  Future<List<CategoryModel>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 80));
    return _categories;
  }

  Future<Product?> getProductById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<Product>> searchProducts({
    String query = '',
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    String sortBy = 'Popularity', // 'Popularity', 'Price: Low to High', 'Price: High to Low', 'Top Rated'
  }) async {
    await Future.delayed(const Duration(milliseconds: 120));
    var results = List<Product>.from(_products);

    if (query.trim().isNotEmpty) {
      final q = query.toLowerCase().trim();
      results = results.where((p) {
        return p.name.toLowerCase().contains(q) ||
            p.tagline.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q) ||
            p.tags.any((t) => t.toLowerCase().contains(q));
      }).toList();
    }

    if (categoryId != null && categoryId != 'cat_all') {
      final cat = _categories.firstWhere((c) => c.id == categoryId, orElse: () => _categories.first);
      results = results.where((p) => p.category == cat.name).toList();
    }

    if (minPrice != null) {
      results = results.where((p) => p.price >= minPrice).toList();
    }

    if (maxPrice != null) {
      results = results.where((p) => p.price <= maxPrice).toList();
    }

    if (sortBy == 'Price: Low to High') {
      results.sort((a, b) => a.price.compareTo(b.price));
    } else if (sortBy == 'Price: High to Low') {
      results.sort((a, b) => b.price.compareTo(a.price));
    } else if (sortBy == 'Top Rated') {
      results.sort((a, b) => b.rating.compareTo(a.rating));
    }

    return results;
  }
}
