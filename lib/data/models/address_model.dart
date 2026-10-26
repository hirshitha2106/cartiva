class AddressModel {
  final String id;
  final String recipientName; // fullName
  final String streetAddress; // street
  final String apartment; // houseNumber
  final String landmark;
  final String city;
  final String state;
  final String postalCode; // pinCode
  final String country;
  final String phone; // mobileNumber
  final String label; // 'Home', 'Office', 'Villa'
  final bool isDefault;

  const AddressModel({
    required this.id,
    required this.recipientName,
    required this.streetAddress,
    this.apartment = '',
    this.landmark = '',
    required this.city,
    required this.state,
    required this.postalCode,
    this.country = 'India',
    required this.phone,
    this.label = 'Home',
    this.isDefault = false,
  });

  // Aliases for user specification format
  String get fullName => recipientName;
  String get mobileNumber => phone;
  String get houseNumber => apartment;
  String get street => streetAddress;
  String get pinCode => postalCode;

  String get formattedAddress {
    final parts = <String>[];
    if (apartment.isNotEmpty) parts.add(apartment);
    if (streetAddress.isNotEmpty) parts.add(streetAddress);
    if (landmark.isNotEmpty) parts.add(landmark);
    parts.add(city);
    parts.add('$state - $postalCode');
    if (country.isNotEmpty) parts.add(country);
    return parts.join(', ');
  }

  static AddressModel get sampleRahulAddress => const AddressModel(
        id: 'addr_sample_rahul',
        recipientName: 'Rahul Kumar',
        phone: '9876543210',
        apartment: '12-4-56',
        streetAddress: 'MG Road',
        landmark: 'Near City Mall',
        city: 'Vijayawada',
        state: 'Andhra Pradesh',
        postalCode: '520010',
        country: 'India',
        label: 'Home',
        isDefault: true,
      );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': recipientName,
      'recipientName': recipientName,
      'mobileNumber': phone,
      'phone': phone,
      'houseNumber': apartment,
      'apartment': apartment,
      'street': streetAddress,
      'streetAddress': streetAddress,
      'landmark': landmark,
      'city': city,
      'state': state,
      'pinCode': postalCode,
      'postalCode': postalCode,
      'country': country,
      'label': label,
      'isDefault': isDefault,
    };
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as String? ?? 'addr_${DateTime.now().millisecondsSinceEpoch}',
      recipientName: json['fullName'] as String? ?? json['recipientName'] as String? ?? '',
      phone: json['mobileNumber'] as String? ?? json['phone'] as String? ?? '',
      apartment: json['houseNumber'] as String? ?? json['apartment'] as String? ?? '',
      streetAddress: json['street'] as String? ?? json['streetAddress'] as String? ?? '',
      landmark: json['landmark'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      postalCode: json['pinCode'] as String? ?? json['postalCode'] as String? ?? '',
      country: json['country'] as String? ?? 'India',
      label: json['label'] as String? ?? 'Home',
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  AddressModel copyWith({
    String? id,
    String? recipientName,
    String? streetAddress,
    String? apartment,
    String? landmark,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    String? phone,
    String? label,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      recipientName: recipientName ?? this.recipientName,
      streetAddress: streetAddress ?? this.streetAddress,
      apartment: apartment ?? this.apartment,
      landmark: landmark ?? this.landmark,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      phone: phone ?? this.phone,
      label: label ?? this.label,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
