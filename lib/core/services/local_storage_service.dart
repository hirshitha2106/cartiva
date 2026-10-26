import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/order_model.dart';
import '../../data/models/address_model.dart';
import '../../data/models/cart_item_model.dart';

class LocalStorageService {
  static const String _keyOrders = 'cartiva_demo_orders';
  static const String _keyAddresses = 'cartiva_demo_addresses';
  static const String _keyCart = 'cartiva_demo_cart';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (_) {
      // In-memory fallback if platform plugin has issues
    }
  }

  // --- ORDERS ---
  static Future<List<OrderModel>> getOrders() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final data = _prefs?.getStringList(_keyOrders);
      if (data == null || data.isEmpty) return [];
      return data
          .map((item) => OrderModel.fromJson(jsonDecode(item) as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveOrder(OrderModel order) async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final current = await getOrders();
      // Insert new order at top
      current.insert(0, order);
      final jsonList = current.map((e) => jsonEncode(e.toJson())).toList();
      await _prefs?.setStringList(_keyOrders, jsonList);
    } catch (_) {}
  }

  // --- ADDRESSES ---
  static Future<List<AddressModel>> getAddresses() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final data = _prefs?.getStringList(_keyAddresses);
      if (data == null || data.isEmpty) {
        return [AddressModel.sampleRahulAddress];
      }
      return data
          .map((item) => AddressModel.fromJson(jsonDecode(item) as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [AddressModel.sampleRahulAddress];
    }
  }

  static Future<void> saveAddresses(List<AddressModel> addresses) async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final jsonList = addresses.map((e) => jsonEncode(e.toJson())).toList();
      await _prefs?.setStringList(_keyAddresses, jsonList);
    } catch (_) {}
  }

  // --- CART ---
  static Future<List<CartItem>> getCart() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final data = _prefs?.getStringList(_keyCart);
      if (data == null || data.isEmpty) return [];
      return data
          .map((item) => CartItem.fromJson(jsonDecode(item) as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveCart(List<CartItem> items) async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final jsonList = items.map((e) => jsonEncode(e.toJson())).toList();
      await _prefs?.setStringList(_keyCart, jsonList);
    } catch (_) {}
  }
}
