import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class EcommerceFooter extends StatefulWidget {
  const EcommerceFooter({super.key});

  @override
  State<EcommerceFooter> createState() => _EcommerceFooterState();
}

class _EcommerceFooterState extends State<EcommerceFooter> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _subscribe() {
    if (_emailController.text.trim().isNotEmpty && _emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.stars_rounded, color: AppColors.accentGold),
              const SizedBox(width: 8),
              Text('Welcome to the Cartiva VIP Circle, ${_emailController.text.trim()}!'),
            ],
          ),
          backgroundColor: const Color(0xFF1E1B4B),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _emailController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      color: isDark ? const Color(0xFF070B12) : const Color(0xFFF1F5F9),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        children: [
          // 4 Luxury Pillars
          Wrap(
            spacing: 24,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              _buildPillar(
                icon: Icons.verified_user_rounded,
                title: 'Authenticity Guaranteed',
                subtitle: 'Independently certified luxury craftsmanship',
                isDark: isDark,
              ),
              _buildPillar(
                icon: Icons.support_agent_rounded,
                title: '24/7 VIP Concierge',
                subtitle: 'Dedicated private client assistance',
                isDark: isDark,
              ),
              _buildPillar(
                icon: Icons.flight_takeoff_rounded,
                title: 'Insured Global Express',
                subtitle: 'Carbon-neutral tracked courier delivery',
                isDark: isDark,
              ),
              _buildPillar(
                icon: Icons.published_with_changes_rounded,
                title: '30-Day Compliant Returns',
                subtitle: 'Zero-cost concierge pickup & exchanges',
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 36),
          const Divider(),
          const SizedBox(height: 36),

          // VIP Newsletter Sign-up Box
          Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF161F30), const Color(0xFF0F172A)]
                    : [Colors.white, const Color(0xFFF8FAFC)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
              ),
            ),
            child: Column(
              children: [
                const Icon(Icons.mail_lock_rounded, size: 28, color: AppColors.primaryLight),
                const SizedBox(height: 8),
                Text(
                  'Join The Cartiva Private Circle',
                  style: AppTypography.headingSmall.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Receive confidential invitations to exclusive drops, private showcases, and limited releases.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: TextField(
                          controller: _emailController,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 13,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Enter your luxury email...',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _subscribe,
                        child: const Text('Subscribe'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),

          // Bottom Trademark & Payment Icons
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 20,
            runSpacing: 12,
            children: [
              Text(
                '© 2026 CARTIVA MAISON DE LUXE • ALL RIGHTS RESERVED',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.0,
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPaymentLogo('VISA', isDark),
                  const SizedBox(width: 8),
                  _buildPaymentLogo('MASTERCARD', isDark),
                  const SizedBox(width: 8),
                  _buildPaymentLogo('AMEX', isDark),
                  const SizedBox(width: 8),
                  _buildPaymentLogo('APPLE PAY', isDark),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPillar({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return SizedBox(
      width: 250,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withAlpha(isDark ? 40 : 20),
            ),
            child: Icon(icon, size: 20, color: AppColors.primaryLight),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentLogo(String name, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        name,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
          color: isDark ? Colors.white70 : Colors.black54,
        ),
      ),
    );
  }
}
