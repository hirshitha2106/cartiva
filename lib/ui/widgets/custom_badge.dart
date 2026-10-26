import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class CustomBadge extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Gradient? gradient;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsetsGeometry padding;

  const CustomBadge({
    super.key,
    required this.text,
    this.icon,
    this.gradient,
    this.backgroundColor,
    this.textColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  });

  factory CustomBadge.discount(int percent) {
    return CustomBadge(
      text: '-$percent%',
      icon: Icons.local_fire_department_rounded,
      gradient: const LinearGradient(
        colors: [Color(0xFFF43F5E), Color(0xFFE11D48)],
      ),
    );
  }

  factory CustomBadge.trending() {
    return const CustomBadge(
      text: 'TRENDING',
      icon: Icons.bolt_rounded,
      gradient: AppColors.brandGradient,
    );
  }

  factory CustomBadge.featured() {
    return const CustomBadge(
      text: 'FEATURED',
      icon: Icons.auto_awesome_rounded,
      gradient: AppColors.cyberGradient,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient ?? (backgroundColor == null ? AppColors.brandGradient : null),
        color: gradient == null ? (backgroundColor ?? AppColors.primary) : null,
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: (textColor ?? Colors.white).withAlpha(40),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 11,
              color: textColor ?? Colors.white,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: AppTypography.badgeText.copyWith(
              color: textColor ?? Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
