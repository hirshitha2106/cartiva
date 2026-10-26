import 'package:flutter/material.dart';

enum PaymentType { creditCard, applePay, googlePay, wallet, cashOnDelivery }

class PaymentMethodModel {
  final String id;
  final PaymentType type;
  final String title;
  final String? subtitle;
  final String? cardHolderName;
  final String? last4;
  final String? cardBrand; // 'Visa', 'Mastercard', 'Amex'
  final String? expiry;
  final bool isDefault;

  const PaymentMethodModel({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    this.cardHolderName,
    this.last4,
    this.cardBrand,
    this.expiry,
    this.isDefault = false,
  });

  IconData get icon {
    switch (type) {
      case PaymentType.creditCard:
        return Icons.credit_card_rounded;
      case PaymentType.applePay:
        return Icons.phone_iphone_rounded;
      case PaymentType.googlePay:
        return Icons.account_balance_wallet_rounded;
      case PaymentType.wallet:
        return Icons.stars_rounded;
      case PaymentType.cashOnDelivery:
        return Icons.local_atm_rounded;
    }
  }

  PaymentMethodModel copyWith({
    String? id,
    PaymentType? type,
    String? title,
    String? subtitle,
    String? cardHolderName,
    String? last4,
    String? cardBrand,
    String? expiry,
    bool? isDefault,
  }) {
    return PaymentMethodModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      last4: last4 ?? this.last4,
      cardBrand: cardBrand ?? this.cardBrand,
      expiry: expiry ?? this.expiry,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
