import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/models/order_model.dart';

class OrderTrackingModal extends StatelessWidget {
  final OrderModel order;

  const OrderTrackingModal({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final steps = [
      {'title': 'Order Confirmed', 'desc': 'Payment authorized and receipt dispatched', 'done': true},
      {'title': 'Cleanroom Quality Inspection', 'desc': 'Serial numbers registered and packaged', 'done': true},
      {'title': 'Dispatched via Air Courier', 'desc': 'Handed over to FedEx Luxury Priority', 'done': order.status != OrderStatus.processing},
      {'title': 'In Transit to Destination Hub', 'desc': 'Cleared through customs & regional sort', 'done': order.status == OrderStatus.outForDelivery || order.status == OrderStatus.delivered},
      {'title': 'Out for Courier Delivery', 'desc': 'Driver en route with secure biometric verification', 'done': order.status == OrderStatus.delivered},
      {'title': 'Delivered & Signed', 'desc': 'Package delivered to recipient residence', 'done': order.status == OrderStatus.delivered},
    ];

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        child: Column(
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Package Live Tracking', style: AppTypography.headingSmall),
                    const SizedBox(height: 2),
                    Text('Order ID: ${order.orderId}', style: TextStyle(fontSize: 12, color: AppColors.primaryLight)),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Carrier Card with Copy Tracking Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(isDark ? 40 : 20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.local_shipping_rounded, color: AppColors.primaryLight),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'FedEx Armored Air Express',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Text(
                          'Tracking: ${order.trackingNumber}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tracking ID copied to clipboard!')),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Copy ID',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Steps Timeline
            Text('TRACKING TIMELINE', style: AppTypography.badgeText),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: steps.length,
                itemBuilder: (context, index) {
                  final step = steps[index];
                  final isDone = step['done'] as bool;
                  final isLast = index == steps.length - 1;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Circle & Vertical Line
                      Column(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDone ? AppColors.accentEmerald : Colors.grey.withAlpha(50),
                            ),
                            child: Icon(
                              isDone ? Icons.check_rounded : Icons.circle,
                              size: isDone ? 14 : 8,
                              color: isDone ? Colors.white : Colors.grey,
                            ),
                          ),
                          if (!isLast)
                            Container(
                              width: 2,
                              height: 38,
                              color: isDone ? AppColors.accentEmerald.withAlpha(150) : Colors.grey.withAlpha(50),
                            ),
                        ],
                      ),
                      const SizedBox(width: 14),

                      // Text Info
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step['title'] as String,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: isDone
                                      ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                                      : Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                step['desc'] as String,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
