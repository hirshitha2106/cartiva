import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/models/product_model.dart';

class FlashSaleBanner extends StatefulWidget {
  final List<Product> flashSaleProducts;
  final VoidCallback onViewAll;

  const FlashSaleBanner({
    super.key,
    required this.flashSaleProducts,
    required this.onViewAll,
  });

  @override
  State<FlashSaleBanner> createState() => _FlashSaleBannerState();
}

class _FlashSaleBannerState extends State<FlashSaleBanner> {
  late Duration _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = const Duration(hours: 4, minutes: 32, seconds: 15);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_remaining.inSeconds > 0) {
          _remaining = _remaining - const Duration(seconds: 1);
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hours = _twoDigits(_remaining.inHours);
    final minutes = _twoDigits(_remaining.inMinutes.remainder(60));
    final seconds = _twoDigits(_remaining.inSeconds.remainder(60));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentRose.withAlpha(isDark ? 50 : 25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  color: AppColors.accentRose,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Flash Drops',
                    style: AppTypography.headingMedium.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        'Ends in: ',
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                      _buildTimerPill(hours, isDark),
                      const Text(' : ', style: TextStyle(fontWeight: FontWeight.bold)),
                      _buildTimerPill(minutes, isDark),
                      const Text(' : ', style: TextStyle(fontWeight: FontWeight.bold)),
                      _buildTimerPill(seconds, isDark),
                    ],
                  ),
                ],
              ),
            ],
          ),
          TextButton(
            onPressed: widget.onViewAll,
            child: Row(
              children: [
                Text(
                  'View All',
                  style: AppTypography.buttonText.copyWith(
                    color: AppColors.primaryLight,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primaryLight),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerPill(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: AppTypography.badgeText.copyWith(
          color: AppColors.accentRose,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
