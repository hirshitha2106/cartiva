import 'package:flutter/material.dart';
import '../data/models/address_model.dart';
import '../data/models/payment_method_model.dart';
import '../data/models/order_model.dart';
import '../data/models/cart_item_model.dart';
import '../core/services/local_storage_service.dart';

class CheckoutProvider extends ChangeNotifier {
  final List<AddressModel> _addresses = [
    AddressModel.sampleRahulAddress,
    const AddressModel(
      id: 'addr_02',
      recipientName: 'Rahul Kumar',
      streetAddress: '100 Innovation Way',
      apartment: 'Suite 400',
      landmark: 'Tech Park',
      city: 'Hyderabad',
      state: 'Telangana',
      postalCode: '500081',
      country: 'India',
      phone: '9876543210',
      label: 'Office',
      isDefault: false,
    ),
  ];

  final List<PaymentMethodModel> _paymentMethods = [
    const PaymentMethodModel(
      id: 'pay_upi',
      type: PaymentType.wallet,
      title: 'UPI Payment',
      subtitle: 'rahul@demo • Instant verification',
      isDefault: true,
    ),
    const PaymentMethodModel(
      id: 'pay_card',
      type: PaymentType.creditCard,
      title: 'Credit / Debit Card',
      subtitle: '•••• 1111 (RAHUL KUMAR)',
      cardHolderName: 'RAHUL KUMAR',
      last4: '1111',
      cardBrand: 'Visa',
      expiry: '12/30',
      isDefault: false,
    ),
    const PaymentMethodModel(
      id: 'pay_cod',
      type: PaymentType.cashOnDelivery,
      title: 'Cash on Delivery',
      subtitle: 'Payment will be collected on delivery',
      isDefault: false,
    ),
  ];

  final List<OrderModel> _orders = [];

  late AddressModel _selectedAddress;
  late PaymentMethodModel _selectedPaymentMethod;
  String _selectedPaymentType = 'UPI'; // 'UPI', 'CARD', 'CASH_ON_DELIVERY'
  String _deliveryOption = 'standard'; // 'standard' ($0) or 'express' ($25)
  final double _walletBalance = 5000.00;

  // Mock Form inputs for test automation
  String _upiId = 'rahul@demo';
  String _cardHolder = 'RAHUL KUMAR';
  String _cardNumber = '4111111111111111';
  String _expiryDate = '12/30';
  String _cvv = '123';
  bool _simulatePaymentFailure = false;

  int _orderCounter = 10001;

  CheckoutProvider() {
    _selectedAddress = _addresses.first;
    _selectedPaymentMethod = _paymentMethods.first;
    _initStorage();
  }

  void _initStorage() async {
    try {
      final savedAddresses = await LocalStorageService.getAddresses();
      if (savedAddresses.isNotEmpty) {
        _addresses.clear();
        _addresses.addAll(savedAddresses);
        _selectedAddress = _addresses.firstWhere((a) => a.isDefault, orElse: () => _addresses.first);
      }

      final savedOrders = await LocalStorageService.getOrders();
      if (savedOrders.isNotEmpty) {
        _orders.clear();
        _orders.addAll(savedOrders);
        _orderCounter = 10001 + _orders.length;
      } else {
        // Add sample demo order for initial view
        final initialSampleOrder = OrderModel(
          orderId: 'ORD10001',
          customerName: 'Rahul Kumar',
          productName: 'Wireless Headphones',
          quantity: 1,
          totalAmount: 2499.0,
          subtotal: 2499.0,
          discount: 0.0,
          shippingFee: 0.0,
          orderDate: DateTime.now().subtract(const Duration(days: 2)),
          paymentMethod: 'UPI',
          paymentStatus: 'SUCCESS',
          orderStatus: 'PLACED',
          deliveryCity: 'Vijayawada',
          deliveryAddress: '12-4-56, MG Road, Near City Mall, Vijayawada, Andhra Pradesh - 520010, India',
          estimatedDelivery: '2026-10-30',
          trackingNumber: 'TRK-ORD10001',
        );
        _orders.add(initialSampleOrder);
        LocalStorageService.saveOrder(initialSampleOrder);
      }
      notifyListeners();
    } catch (_) {}
  }

  List<AddressModel> get addresses => List.unmodifiable(_addresses);
  List<PaymentMethodModel> get paymentMethods => List.unmodifiable(_paymentMethods);
  List<OrderModel> get orders => List.unmodifiable(_orders);

  AddressModel get selectedAddress => _selectedAddress;
  PaymentMethodModel get selectedPaymentMethod => _selectedPaymentMethod;
  String get selectedPaymentType => _selectedPaymentType;
  String get deliveryOption => _deliveryOption;
  double get deliveryFee => _deliveryOption == 'express' ? 99.00 : 0.00;
  double get walletBalance => _walletBalance;

  String get upiId => _upiId;
  String get cardHolder => _cardHolder;
  String get cardNumber => _cardNumber;
  String get expiryDate => _expiryDate;
  String get cvv => _cvv;
  bool get simulatePaymentFailure => _simulatePaymentFailure;

  void setSimulatePaymentFailure(bool value) {
    _simulatePaymentFailure = value;
    notifyListeners();
  }

  void selectPaymentType(String type) {
    _selectedPaymentType = type;
    if (type == 'UPI') {
      _selectedPaymentMethod = _paymentMethods.firstWhere(
        (p) => p.id == 'pay_upi',
        orElse: () => _paymentMethods.first,
      );
    } else if (type == 'CARD') {
      _selectedPaymentMethod = _paymentMethods.firstWhere(
        (p) => p.id == 'pay_card',
        orElse: () => _paymentMethods[1],
      );
    } else {
      _selectedPaymentMethod = _paymentMethods.firstWhere(
        (p) => p.id == 'pay_cod',
        orElse: () => _paymentMethods.last,
      );
    }
    notifyListeners();
  }

  void setUpiData({required String upiId}) {
    _upiId = upiId.trim();
    notifyListeners();
  }

  void setCardData({
    required String cardHolder,
    required String cardNumber,
    required String expiryDate,
    required String cvv,
  }) {
    _cardHolder = cardHolder.trim();
    _cardNumber = cardNumber.replaceAll(' ', '').trim();
    _expiryDate = expiryDate.trim();
    _cvv = cvv.trim();
    notifyListeners();
  }

  void fillDemoUpi() {
    _upiId = 'rahul@demo';
    notifyListeners();
  }

  void fillDemoCard() {
    _cardHolder = 'RAHUL KUMAR';
    _cardNumber = '4111111111111111';
    _expiryDate = '12/30';
    _cvv = '123';
    notifyListeners();
  }

  void selectAddress(AddressModel address) {
    _selectedAddress = address;
    notifyListeners();
  }

  void setSampleAddress() {
    final sample = AddressModel.sampleRahulAddress;
    final existingIdx = _addresses.indexWhere((a) => a.id == sample.id);
    if (existingIdx >= 0) {
      _addresses[existingIdx] = sample;
    } else {
      _addresses.insert(0, sample);
    }
    _selectedAddress = sample;
    LocalStorageService.saveAddresses(_addresses);
    notifyListeners();
  }

  void addAddress({
    required String recipientName,
    required String streetAddress,
    String apartment = '',
    String landmark = '',
    required String city,
    required String state,
    required String postalCode,
    String country = 'India',
    required String phone,
    String label = 'Home',
    bool setAsDefault = false,
  }) {
    final newId = 'addr_${DateTime.now().millisecondsSinceEpoch}';
    final newAddress = AddressModel(
      id: newId,
      recipientName: recipientName,
      streetAddress: streetAddress,
      apartment: apartment,
      landmark: landmark,
      city: city,
      state: state,
      postalCode: postalCode,
      country: country,
      phone: phone,
      label: label,
      isDefault: setAsDefault || _addresses.isEmpty,
    );

    if (setAsDefault) {
      for (int i = 0; i < _addresses.length; i++) {
        _addresses[i] = _addresses[i].copyWith(isDefault: false);
      }
      _selectedAddress = newAddress;
    }

    _addresses.add(newAddress);
    if (_addresses.length == 1) {
      _selectedAddress = newAddress;
    }
    LocalStorageService.saveAddresses(_addresses);
    notifyListeners();
  }

  void updateSelectedAddress(AddressModel address) {
    final index = _addresses.indexWhere((a) => a.id == address.id);
    if (index >= 0) {
      _addresses[index] = address;
    } else {
      _addresses.add(address);
    }
    _selectedAddress = address;
    LocalStorageService.saveAddresses(_addresses);
    notifyListeners();
  }

  void deleteAddress(String addressId) {
    _addresses.removeWhere((a) => a.id == addressId);
    if (_selectedAddress.id == addressId && _addresses.isNotEmpty) {
      _selectedAddress = _addresses.first;
    }
    LocalStorageService.saveAddresses(_addresses);
    notifyListeners();
  }

  void selectPaymentMethod(PaymentMethodModel method) {
    _selectedPaymentMethod = method;
    if (method.type == PaymentType.creditCard) {
      _selectedPaymentType = 'CARD';
    } else if (method.type == PaymentType.cashOnDelivery) {
      _selectedPaymentType = 'CASH_ON_DELIVERY';
    } else {
      _selectedPaymentType = 'UPI';
    }
    notifyListeners();
  }

  void addCreditCard({
    required String cardHolderName,
    required String cardNumber,
    required String expiryDate,
    required String cvv,
    bool setAsDefault = false,
  }) {
    final cleanNumber = cardNumber.replaceAll(' ', '');
    final last4 = cleanNumber.length >= 4 ? cleanNumber.substring(cleanNumber.length - 4) : '0000';

    String brand = 'Visa';
    if (cleanNumber.startsWith('5') || cleanNumber.startsWith('2')) {
      brand = 'Mastercard';
    } else if (cleanNumber.startsWith('3')) {
      brand = 'American Express';
    }

    final newMethod = PaymentMethodModel(
      id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
      type: PaymentType.creditCard,
      title: '$brand Platinum Card',
      subtitle: 'Ending in $last4',
      cardHolderName: cardHolderName.toUpperCase(),
      last4: last4,
      cardBrand: brand,
      expiry: expiryDate,
      isDefault: setAsDefault || _paymentMethods.isEmpty,
    );

    if (setAsDefault) {
      for (int i = 0; i < _paymentMethods.length; i++) {
        _paymentMethods[i] = _paymentMethods[i].copyWith(isDefault: false);
      }
      _selectedPaymentMethod = newMethod;
      _selectedPaymentType = 'CARD';
    }

    _paymentMethods.insert(0, newMethod);
    notifyListeners();
  }

  void setDeliveryOption(String option) {
    _deliveryOption = option;
    notifyListeners();
  }

  OrderModel createOrder({
    required List<CartItem> items,
    required double subtotal,
    required double discount,
    required double baseShippingFee,
    String? overridePaymentMethod,
    String? overridePaymentStatus,
  }) {
    final totalShipping = baseShippingFee + deliveryFee;
    final total = (subtotal - discount + totalShipping).clamp(0.0, double.infinity);

    final paymentMethodStr = overridePaymentMethod ?? _selectedPaymentType;
    final paymentStatusStr = overridePaymentStatus ??
        (paymentMethodStr == 'CASH_ON_DELIVERY' ? 'PENDING' : 'SUCCESS');

    final primaryProductName = items.isNotEmpty ? items.first.product.name : 'Wireless Headphones';
    final totalQty = items.fold(0, (sum, item) => sum + item.quantity);

    // Generate Order ID ORD10001, ORD10002, etc.
    final orderId = 'ORD${_orderCounter++}';

    // Format estimated delivery date (5 days ahead, e.g. 2026-10-30)
    final deliveryDate = DateTime.now().add(const Duration(days: 5));
    final estimatedDelivery =
        '${deliveryDate.year}-${deliveryDate.month.toString().padLeft(2, '0')}-${deliveryDate.day.toString().padLeft(2, '0')}';

    final newOrder = OrderModel(
      orderId: orderId,
      customerName: _selectedAddress.fullName.isNotEmpty ? _selectedAddress.fullName : 'Rahul Kumar',
      productName: primaryProductName,
      quantity: totalQty > 0 ? totalQty : 1,
      totalAmount: total > 0 ? total : 2499.0,
      subtotal: subtotal,
      discount: discount,
      shippingFee: totalShipping,
      orderDate: DateTime.now(),
      paymentMethod: paymentMethodStr,
      paymentStatus: paymentStatusStr,
      orderStatus: 'PLACED',
      deliveryCity: _selectedAddress.city.isNotEmpty ? _selectedAddress.city : 'Vijayawada',
      deliveryAddress: _selectedAddress.formattedAddress,
      estimatedDelivery: estimatedDelivery,
      trackingNumber: 'TRK-$orderId',
      items: List.from(items),
    );

    _orders.insert(0, newOrder);
    LocalStorageService.saveOrder(newOrder);
    notifyListeners();
    return newOrder;
  }
}
