import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/models/address_model.dart';
import '../../../../state/checkout_provider.dart';

class AddressStep extends StatefulWidget {
  final CheckoutProvider checkout;
  final VoidCallback onAddressConfirmed;

  const AddressStep({
    super.key,
    required this.checkout,
    required this.onAddressConfirmed,
  });

  @override
  State<AddressStep> createState() => _AddressStepState();
}

class _AddressStepState extends State<AddressStep> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _houseController;
  late final TextEditingController _streetController;
  late final TextEditingController _landmarkController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _pinController;
  late final TextEditingController _countryController;

  @override
  void initState() {
    super.initState();
    final addr = widget.checkout.selectedAddress;
    _nameController = TextEditingController(text: addr.fullName);
    _phoneController = TextEditingController(text: addr.mobileNumber);
    _houseController = TextEditingController(text: addr.houseNumber);
    _streetController = TextEditingController(text: addr.street);
    _landmarkController = TextEditingController(text: addr.landmark);
    _cityController = TextEditingController(text: addr.city);
    _stateController = TextEditingController(text: addr.state);
    _pinController = TextEditingController(text: addr.pinCode);
    _countryController = TextEditingController(text: addr.country.isNotEmpty ? addr.country : 'India');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _houseController.dispose();
    _streetController.dispose();
    _landmarkController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pinController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _fillSampleAddress() {
    setState(() {
      _nameController.text = 'Rahul Kumar';
      _phoneController.text = '9876543210';
      _houseController.text = '12-4-56';
      _streetController.text = 'MG Road';
      _landmarkController.text = 'Near City Mall';
      _cityController.text = 'Vijayawada';
      _stateController.text = 'Andhra Pradesh';
      _pinController.text = '520010';
      _countryController.text = 'India';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Sample address (Rahul Kumar, Vijayawada) loaded successfully!'),
          ],
        ),
        backgroundColor: AppColors.accentEmerald,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _submitAddress() {
    if (_formKey.currentState?.validate() ?? false) {
      final updated = AddressModel(
        id: widget.checkout.selectedAddress.id,
        recipientName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        apartment: _houseController.text.trim(),
        streetAddress: _streetController.text.trim(),
        landmark: _landmarkController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        postalCode: _pinController.text.trim(),
        country: _countryController.text.trim(),
        label: widget.checkout.selectedAddress.label,
        isDefault: true,
      );

      widget.checkout.updateSelectedAddress(updated);
      widget.onAddressConfirmed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card with Sample Data Quick Action
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF1E1B4B), const Color(0xFF0F172A)]
                        : [const Color(0xFFEEF2FF), const Color(0xFFF8FAFC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withAlpha(isDark ? 80 : 50),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(isDark ? 50 : 25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_shipping_rounded,
                        color: AppColors.primaryLight,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Delivery Destination',
                            style: AppTypography.headingSmall.copyWith(
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Provide your shipping address or use test sample data.',
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _fillSampleAddress,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentEmerald,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      icon: const Icon(Icons.flash_on_rounded, size: 18),
                      label: const Text('Auto-Fill Sample Data'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Saved Addresses Selector
              if (widget.checkout.addresses.isNotEmpty) ...[
                Text(
                  'SAVED DESTINATIONS',
                  style: AppTypography.badgeText.copyWith(
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 110,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.checkout.addresses.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final addr = widget.checkout.addresses[index];
                      final isSelected = widget.checkout.selectedAddress.id == addr.id;

                      return InkWell(
                        onTap: () {
                          widget.checkout.selectAddress(addr);
                          setState(() {
                            _nameController.text = addr.fullName;
                            _phoneController.text = addr.mobileNumber;
                            _houseController.text = addr.houseNumber;
                            _streetController.text = addr.street;
                            _landmarkController.text = addr.landmark;
                            _cityController.text = addr.city;
                            _stateController.text = addr.state;
                            _pinController.text = addr.pinCode;
                            _countryController.text = addr.country;
                          });
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 250,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkCard : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: AppColors.primary.withAlpha(40),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isSelected ? Icons.check_circle_rounded : Icons.location_on_outlined,
                                    size: 16,
                                    color: isSelected ? AppColors.primary : Colors.grey,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      addr.fullName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withAlpha(30),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      addr.label,
                                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                addr.formattedAddress,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Address Form
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(isDark ? 40 : 15),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CONTACT & ADDRESS DETAILS',
                        style: AppTypography.badgeText.copyWith(
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Row 1: Full Name & Mobile Number
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildInputField(
                              controller: _nameController,
                              label: 'Full Name *',
                              hint: 'e.g. Rahul Kumar',
                              icon: Icons.person_rounded,
                              isDark: isDark,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Full name is required';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildInputField(
                              controller: _phoneController,
                              label: 'Mobile Number *',
                              hint: 'e.g. 9876543210',
                              icon: Icons.phone_rounded,
                              isDark: isDark,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Mobile number is required';
                                }
                                if (val.trim().length < 10) {
                                  return 'Enter a valid 10-digit number';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Row 2: House Number & Street
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildInputField(
                              controller: _houseController,
                              label: 'House / Flat / Block No. *',
                              hint: 'e.g. 12-4-56',
                              icon: Icons.home_rounded,
                              isDark: isDark,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'House number is required';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 3,
                            child: _buildInputField(
                              controller: _streetController,
                              label: 'Street / Area / Colony *',
                              hint: 'e.g. MG Road',
                              icon: Icons.signpost_rounded,
                              isDark: isDark,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Street address is required';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Row 3: Landmark
                      _buildInputField(
                        controller: _landmarkController,
                        label: 'Landmark (Optional)',
                        hint: 'e.g. Near City Mall',
                        icon: Icons.flag_rounded,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),

                      // Row 4: City, State, PIN Code
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildInputField(
                              controller: _cityController,
                              label: 'City *',
                              hint: 'e.g. Vijayawada',
                              icon: Icons.location_city_rounded,
                              isDark: isDark,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'City is required';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildInputField(
                              controller: _stateController,
                              label: 'State *',
                              hint: 'e.g. Andhra Pradesh',
                              icon: Icons.map_rounded,
                              isDark: isDark,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'State is required';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildInputField(
                              controller: _pinController,
                              label: 'PIN Code *',
                              hint: 'e.g. 520010',
                              icon: Icons.pin_drop_rounded,
                              isDark: isDark,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'PIN code is required';
                                }
                                if (val.trim().length != 6) {
                                  return 'Must be 6 digits';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Row 5: Country
                      _buildInputField(
                        controller: _countryController,
                        label: 'Country *',
                        hint: 'India',
                        icon: Icons.public_rounded,
                        isDark: isDark,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Country is required';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 28),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _submitAddress,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Save & Continue to Order Summary'),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          style: TextStyle(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 18, color: AppColors.primaryLight),
            filled: true,
            fillColor: isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.accentRose),
            ),
          ),
        ),
      ],
    );
  }
}
