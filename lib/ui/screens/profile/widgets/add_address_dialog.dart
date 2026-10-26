import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../state/checkout_provider.dart';

class AddAddressDialog extends StatefulWidget {
  const AddAddressDialog({super.key});

  @override
  State<AddAddressDialog> createState() => _AddAddressDialogState();
}

class _AddAddressDialogState extends State<AddAddressDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _streetController = TextEditingController();
  final _aptController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _phoneController = TextEditingController();

  String _selectedLabel = 'Home';
  bool _setAsDefault = true;

  @override
  void dispose() {
    _nameController.dispose();
    _streetController.dispose();
    _aptController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      context.read<CheckoutProvider>().addAddress(
            recipientName: _nameController.text.trim(),
            streetAddress: _streetController.text.trim(),
            apartment: _aptController.text.trim(),
            city: _cityController.text.trim(),
            state: _stateController.text.trim().toUpperCase(),
            postalCode: _zipController.text.trim(),
            phone: _phoneController.text.trim(),
            label: _selectedLabel,
            setAsDefault: _setAsDefault,
          );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New shipping address saved successfully!'),
          backgroundColor: AppColors.accentEmerald,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                    Text('Add Shipping Address', style: AppTypography.headingMedium),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Label Chips
                Text('ADDRESS LABEL', style: AppTypography.badgeText),
                const SizedBox(height: 8),
                Row(
                  children: ['Home', 'Office', 'Penthouse', 'Other'].map((label) {
                    final isSelected = _selectedLabel == label;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(label),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        onSelected: (val) => setState(() => _selectedLabel = label),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Full Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name *',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Enter recipient name' : null,
                ),
                const SizedBox(height: 12),

                // Street Address
                TextFormField(
                  controller: _streetController,
                  decoration: const InputDecoration(
                    labelText: 'Street Address *',
                    prefixIcon: Icon(Icons.home_outlined),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Enter street address' : null,
                ),
                const SizedBox(height: 12),

                // Apt / Suite
                TextFormField(
                  controller: _aptController,
                  decoration: const InputDecoration(
                    labelText: 'Apartment, Suite, Unit (Optional)',
                    prefixIcon: Icon(Icons.meeting_room_outlined),
                  ),
                ),
                const SizedBox(height: 12),

                // City & State
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: TextFormField(
                        controller: _cityController,
                        decoration: const InputDecoration(labelText: 'City *'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Enter city' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 4,
                      child: TextFormField(
                        controller: _stateController,
                        decoration: const InputDecoration(labelText: 'State * (e.g. CA)'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Enter state' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ZIP & Phone
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: TextFormField(
                        controller: _zipController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'ZIP Code *'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Enter ZIP' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 6,
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number *',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Enter phone' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Set as Default switch
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Set as Default Address', style: TextStyle(fontWeight: FontWeight.w600)),
                  value: _setAsDefault,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) => setState(() => _setAsDefault = val),
                ),
                const SizedBox(height: 20),

                // Save CTA
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _save,
                    child: const Text('Save & Use Address'),
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
