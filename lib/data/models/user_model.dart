class UserModel {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final String memberTier;
  final double walletBalance;
  final String phone;
  final String defaultAddress;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.memberTier,
    required this.walletBalance,
    required this.phone,
    required this.defaultAddress,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? memberTier,
    double? walletBalance,
    String? phone,
    String? defaultAddress,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      memberTier: memberTier ?? this.memberTier,
      walletBalance: walletBalance ?? this.walletBalance,
      phone: phone ?? this.phone,
      defaultAddress: defaultAddress ?? this.defaultAddress,
    );
  }
}
