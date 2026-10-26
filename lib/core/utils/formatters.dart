import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: '₹',
    decimalDigits: 0,
  );

  static final NumberFormat _compactFormat = NumberFormat.compact();

  static String currency(double amount) {
    if (amount % 1 == 0) {
      return _currencyFormat.format(amount);
    }
    return NumberFormat.currency(symbol: '₹', decimalDigits: 2).format(amount);
  }

  static String compactNumber(int count) {
    return _compactFormat.format(count);
  }

  static int discountPercent(double originalPrice, double currentPrice) {
    if (originalPrice <= currentPrice || originalPrice <= 0) return 0;
    return (((originalPrice - currentPrice) / originalPrice) * 100).round();
  }

  static String formatDate(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy').format(dateTime);
  }
}
