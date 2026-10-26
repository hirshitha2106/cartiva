import 'package:flutter/material.dart';
import '../../core/theme/app_typography.dart';

class AnnouncementBar extends StatelessWidget {
  const AnnouncementBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF4F46E5),
            Color(0xFF7C3AED),
            Color(0xFFC026D3),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bolt_rounded, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'CARTIVA PRIVATE SALE: USE CODE CARTIVA20 FOR 20% OFF • COMPLIMENTARY GLOBAL EXPRESS SHIPPING OVER \$300',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.badgeText.copyWith(
                color: Colors.white,
                fontSize: 10.5,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.bolt_rounded, size: 14, color: Colors.white),
        ],
      ),
    );
  }
}
