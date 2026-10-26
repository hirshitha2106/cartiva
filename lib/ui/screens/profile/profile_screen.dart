import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../state/auth_provider.dart';
import '../../../state/theme_provider.dart';
import '../../../state/checkout_provider.dart';
import '../../../data/models/order_model.dart';
import 'widgets/add_address_dialog.dart';
import 'widgets/add_payment_dialog.dart';
import 'widgets/order_tracking_modal.dart';
import '../checkout/order_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _showAddressDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Consumer<CheckoutProvider>(
        builder: (context, checkout, child) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Saved Shipping Addresses', style: AppTypography.headingSmall),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: checkout.addresses.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final addr = checkout.addresses[index];
                      final isSelected = checkout.selectedAddress.id == addr.id;

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppColors.primaryLight : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              addr.label == 'Office'
                                  ? Icons.business_rounded
                                  : Icons.home_rounded,
                              color: AppColors.primaryLight,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '${addr.recipientName} (${addr.label})',
                                        style: AppTypography.bodySmall.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: isDark
                                              ? AppColors.darkTextPrimary
                                              : AppColors.lightTextPrimary,
                                        ),
                                      ),
                                      if (addr.isDefault) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withAlpha(40),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text('DEFAULT',
                                              style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primaryLight)),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    addr.formattedAddress,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: isDark
                                          ? AppColors.darkTextMuted
                                          : AppColors.lightTextMuted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isSelected
                                    ? Icons.check_circle_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                color: isSelected ? AppColors.accentEmerald : Colors.grey,
                              ),
                              onPressed: () => checkout.selectAddress(addr),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const AddAddressDialog(),
                      );
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add New Address'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showPaymentDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Consumer<CheckoutProvider>(
        builder: (context, checkout, child) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Payment Methods', style: AppTypography.headingSmall),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: checkout.paymentMethods.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final method = checkout.paymentMethods[index];
                      final isSelected =
                          checkout.selectedPaymentMethod.id == method.id;

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppColors.primaryLight : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(method.icon, color: AppColors.accentEmerald),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    method.title,
                                    style: AppTypography.bodySmall.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.lightTextPrimary,
                                    ),
                                  ),
                                  if (method.subtitle != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      method.subtitle!,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: isDark
                                            ? AppColors.darkTextMuted
                                            : AppColors.lightTextMuted,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isSelected
                                    ? Icons.check_circle_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                color: isSelected ? AppColors.accentEmerald : Colors.grey,
                              ),
                              onPressed: () => checkout.selectPaymentMethod(method),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const AddPaymentDialog(),
                      );
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add New Payment Card'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final checkout = context.watch<CheckoutProvider>();
    final user = auth.currentUser;
    final orders = checkout.orders;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text('My Profile', style: AppTypography.headingMedium),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              children: [
                // User Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          const Color(0xFF1E1B4B),
                          const Color(0xFF161F30),
                        ]
                      : [
                          const Color(0xFFEEF2FF),
                          const Color(0xFFFFFFFF),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                ),
              ),
              child: Row(
                children: [
                  // Avatar with status ring
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryLight, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(80),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.network(
                        user?.avatarUrl ??
                            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&q=80',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.person, size: 36),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Name & Tier Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'K. Hirshitha',
                          style: AppTypography.headingMedium.copyWith(
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? 'hirshitha@cartiva.luxury',
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: AppColors.goldGradient,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.workspace_premium_rounded,
                                  size: 13, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                user?.memberTier ?? 'Platinum VIP Member',
                                style: AppTypography.badgeText.copyWith(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Wallet & Rewards Mini Dashboard
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    title: 'Cartiva Wallet',
                    value: Formatters.currency(checkout.walletBalance),
                    icon: Icons.account_balance_wallet_rounded,
                    accentColor: AppColors.primaryLight,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    title: 'VIP Reward Points',
                    value: '8,420 pts',
                    icon: Icons.stars_rounded,
                    accentColor: AppColors.accentGold,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Orders Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'RECENT ORDERS',
                  style: AppTypography.badgeText.copyWith(
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    letterSpacing: 1.0,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const OrderHistoryScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.history_rounded, size: 16),
                  label: Text(
                    'View All (${orders.length})',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Order History Cards
            ...orders.map((order) => _buildOrderTile(order, isDark)),

            const SizedBox(height: 24),

            // Settings & Preferences Section Header
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'PREFERENCES & APP SETTINGS',
                style: AppTypography.badgeText.copyWith(
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Settings Menu Container
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                  // Dark Mode Switch
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(isDark ? 40 : 20),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        themeProvider.isDarkMode
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        color: AppColors.primaryLight,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      'Dark Theme (Luxury Mode)',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    subtitle: Text(
                      themeProvider.isDarkMode ? 'Enabled' : 'Disabled',
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                    trailing: Switch(
                      value: themeProvider.isDarkMode,
                      activeThumbColor: AppColors.primary,
                      onChanged: (val) => themeProvider.toggleTheme(),
                    ),
                  ),
                  const Divider(height: 1),

                  // Addresses
                  ListTile(
                    onTap: () => _showAddressDialog(context),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accentCyan.withAlpha(isDark ? 40 : 20),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.location_on_rounded,
                          color: AppColors.accentCyan, size: 20),
                    ),
                    title: Text(
                      'Saved Shipping Addresses',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    subtitle: Text(
                      '${checkout.addresses.length} Addresses • Default: ${checkout.selectedAddress.label}',
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  ),
                  const Divider(height: 1),

                  // Payment Methods
                  ListTile(
                    onTap: () => _showPaymentDialog(context),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accentEmerald.withAlpha(isDark ? 40 : 20),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.credit_card_rounded,
                          color: AppColors.accentEmerald, size: 20),
                    ),
                    title: Text(
                      'Payment Methods',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    subtitle: Text(
                      '${checkout.paymentMethods.length} Methods • Active: ${checkout.selectedPaymentMethod.title}',
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  ),
                  const Divider(height: 1),

                  // VIP Concierge
                  ListTile(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('VIP Luxury Concierge is available 24/7. Connecting...'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accentGold.withAlpha(isDark ? 40 : 20),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.headset_mic_rounded,
                          color: AppColors.accentGold, size: 20),
                    ),
                    title: Text(
                      '24/7 VIP Concierge Support',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'Instant dedicated client assistance',
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  ),
                ],
              ),
            ),
          ),
          ],
        ),
      ),
    ),
  ),
);
}

  Widget _buildMetricTile({
    required String title,
    required String value,
    required IconData icon,
    required Color accentColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accentColor, size: 24),
          const SizedBox(height: 10),
          Text(
            value,
            style: AppTypography.headingMedium.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTile(OrderModel order, bool isDark) {
    final title = order.items.isNotEmpty
        ? order.items.first.product.name
        : (order.productName.isNotEmpty ? order.productName : 'Wireless Headphones');

    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (ctx) => OrderTrackingModal(order: order),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.orderId,
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: order.status == OrderStatus.delivered
                        ? AppColors.accentEmerald.withAlpha(isDark ? 40 : 25)
                        : AppColors.accentCyan.withAlpha(isDark ? 40 : 25),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    order.statusDisplay,
                    style: AppTypography.badgeText.copyWith(
                      color: order.status == OrderStatus.delivered
                          ? AppColors.accentEmerald
                          : AppColors.accentCyan,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '$title • ${Formatters.currency(order.total)}',
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.qr_code_rounded, size: 14, color: AppColors.primaryLight),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Tracking: ${order.trackingNumber} • Tap for live status',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primaryLight,
                      fontSize: 11,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.primaryLight),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
