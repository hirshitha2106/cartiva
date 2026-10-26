import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../state/checkout_provider.dart';

class AddPaymentDialog extends StatefulWidget {
  const AddPaymentDialog({super.key});

  @override
  State<AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends State<AddPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _setAsDefault = true;

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  String _getCardBrand(String number) {
    final clean = number.replaceAll(' ', '');
    if (clean.startsWith('4')) return 'VISA';
    if (clean.startsWith('5') || clean.startsWith('2')) return 'MASTERCARD';
    if (clean.startsWith('3')) return 'AMEX';
    return 'CARD';
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      context.read<CheckoutProvider>().addCreditCard(
            cardHolderName: _nameController.text.trim(),
            cardNumber: _numberController.text.trim(),
            expiryDate: _expiryController.text.trim(),
            cvv: _cvvController.text.trim(),
            setAsDefault: _setAsDefault,
          );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment card added and verified!'),
          backgroundColor: AppColors.accentEmerald,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final nameText = _nameController.text.isEmpty ? 'CARDHOLDER NAME' : _nameController.text.toUpperCase();
    final numberText = _numberController.text.isEmpty ? '•••• •••• •••• ••••' : _numberController.text;
    final expiryText = _expiryController.text.isEmpty ? 'MM/YY' : _expiryController.text;
    final brand = _getCardBrand(_numberController.text);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
            width: 1,
          ),
        ),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Add Payment Card', style: AppTypography.headingMedium),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Interactive Visual Credit Card Preview
                Container(
                  height: 190,
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF1E1B4B),
                        Color(0xFF312E81),
                        Color(0xFF0F172A),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(90),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(color: Colors.white24, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Gold Chip Icon
                          Container(
                            width: 38,
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAB308),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.nfc_rounded, size: 20, color: Colors.black87),
                          ),
                          Text(
                            brand,
                            style: AppTypography.headingSmall.copyWith(
                              color: Colors.white,
                              letterSpacing: 2.0,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        numberText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          letterSpacing: 2.5,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CARDHOLDER',
                                style: TextStyle(
                                  color: Colors.white.withAlpha(160),
                                  fontSize: 9,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              Text(
                                nameText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'EXPIRES',
                                style: TextStyle(
                                  color: Colors.white.withAlpha(160),
                                  fontSize: 9,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              Text(
                                expiryText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Cardholder Name
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Cardholder Name *',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Enter name on card' : null,
                ),
                const SizedBox(height: 12),

                // Card Number
                TextFormField(
                  controller: _numberController,
                  keyboardType: TextInputType.number,
                  maxLength: 19,
                  decoration: const InputDecoration(
                    labelText: 'Card Number *',
                    prefixIcon: Icon(Icons.credit_card_rounded),
                    hintText: '4242 •••• •••• 4242',
                    counterText: '',
                  ),
                  onChanged: (text) {
                    setState(() {});
                  },
                  validator: (v) {
                    if (v == null || v.replaceAll(' ', '').length < 15) {
                      return 'Enter a valid 16-digit card number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Expiry & CVV
                Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: TextFormField(
                        controller: _expiryController,
                        keyboardType: TextInputType.datetime,
                        maxLength: 5,
                        decoration: const InputDecoration(
                          labelText: 'Expiry (MM/YY) *',
                          hintText: '12/28',
                          counterText: '',
                        ),
                        onChanged: (_) => setState(() {}),
                        validator: (v) => v == null || !v.contains('/') ? 'e.g. 09/28' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 5,
                      child: TextFormField(
                        controller: _cvvController,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        maxLength: 4,
                        decoration: const InputDecoration(
                          labelText: 'Security Code (CVV) *',
                          hintText: '•••',
                          counterText: '',
                        ),
                        validator: (v) => v == null || v.length < 3 ? '3-4 digits' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Set as Default switch
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Set as Default Payment Method', style: TextStyle(fontWeight: FontWeight.w600)),
                  value: _setAsDefault,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) => setState(() => _setAsDefault = val),
                ),
                const SizedBox(height: 20),

                // Save Card CTA
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _save,
                    child: const Text('Save & Authorize Card'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
