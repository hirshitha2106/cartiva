import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/order_model.dart';
import '../../../state/checkout_provider.dart';

class OrderHistoryScreen extends StatefulWidget {
  final VoidCallback? onContinueShopping;

  const OrderHistoryScreen({super.key, this.onContinueShopping});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  String _filterStatus = 'ALL';

  void _showOrderDetails(OrderModel order) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(80),
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
                    Text('Order Details', style: AppTypography.headingMedium),
                    const SizedBox(height: 2),
                    Text('ID: ${order.orderId}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryLight)),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const Divider(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Items list
                    Text('ORDERED ITEMS', style: AppTypography.badgeText),
                    const SizedBox(height: 10),
                    if (order.items.isNotEmpty)
                      ...order.items.map((item) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.black12,
                                ),
                                child: Image.network(
                                  item.product.primaryImage,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.image),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    Text('Qty: ${item.quantity} • ${item.selectedColor.name}', style: const TextStyle(fontSize: 11)),
                                  ],
                                ),
                              ),
                              Text(Formatters.currency(item.totalPrice), style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        );
                      })
                    else
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.headphones_rounded, color: AppColors.primaryLight),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text('${order.productName} (Qty: ${order.quantity})', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Text(Formatters.currency(order.totalAmount), style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Destination Info
                    Text('SHIPPING DESTINATION', style: AppTypography.badgeText),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Recipient: ${order.customerName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(order.deliveryAddress, style: const TextStyle(fontSize: 12)),
                          const SizedBox(height: 4),
                          Text('Estimated Delivery: ${order.estimatedDelivery}', style: const TextStyle(fontSize: 12, color: AppColors.accentGold, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Payment summary
                    Text('PAYMENT & BILLING', style: AppTypography.badgeText),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Payment Method:', style: TextStyle(fontSize: 12)),
                              Text(order.paymentMethod, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Payment Status:', style: TextStyle(fontSize: 12)),
                              Text(
                                order.paymentStatus,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: order.paymentStatus == 'SUCCESS' ? AppColors.accentEmerald : AppColors.accentGold,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Amount:', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(
                                Formatters.currency(order.totalAmount),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.accentEmerald),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final checkout = context.watch<CheckoutProvider>();
    final allOrders = checkout.orders;

    final filteredOrders = allOrders.where((order) {
      if (_filterStatus == 'ALL') return true;
      return order.orderStatus.toUpperCase() == _filterStatus;
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text('Order History', style: AppTypography.headingMedium),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(isDark ? 40 : 20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.storage_rounded, size: 14, color: AppColors.primaryLight),
                const SizedBox(width: 6),
                Text(
                  '${allOrders.length} Demo Orders',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryLight),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              // Filter Chips Strip
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    _buildFilterChip('ALL', 'All Orders (${allOrders.length})', isDark),
                    const SizedBox(width: 8),
                    _buildFilterChip('PLACED', 'Placed', isDark),
                    const SizedBox(width: 8),
                    _buildFilterChip('PROCESSING', 'Processing', isDark),
                    const SizedBox(width: 8),
                    _buildFilterChip('DELIVERED', 'Delivered', isDark),
                  ],
                ),
              ),

              // Orders List
              Expanded(
                child: filteredOrders.isEmpty
                    ? _buildEmptyOrders(isDark)
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                        itemCount: filteredOrders.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final order = filteredOrders[index];
                          return _buildOrderCard(order, isDark);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, bool isDark) {
    final isSelected = _filterStatus == value;
    return InkWell(
      onTap: () => setState(() => _filterStatus = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.darkCard : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order, bool isDark) {
    final isCOD = order.paymentMethod == 'CASH_ON_DELIVERY';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 30 : 10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: ID, Date, Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(isDark ? 40 : 20),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.receipt_rounded, size: 18, color: AppColors.primaryLight),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.orderId,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        Formatters.formatDate(order.orderDate),
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  // Payment Status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (isCOD ? AppColors.accentGold : AppColors.accentEmerald).withAlpha(30),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isCOD ? 'PAYMENT PENDING' : 'PAID (${order.paymentMethod})',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isCOD ? AppColors.accentGold : AppColors.accentEmerald,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Order Status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(30),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      order.statusDisplay.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 20),

          // Product & Customer Info
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.productName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Customer: ${order.customerName} • Qty: ${order.quantity}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ship to: ${order.deliveryCity} (Est: ${order.estimatedDelivery})',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                Formatters.currency(order.totalAmount),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: AppColors.accentEmerald,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _showOrderDetails(order),
                icon: const Icon(Icons.info_outline_rounded, size: 16),
                label: const Text('View Full Receipt'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyOrders(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No Orders Found',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 6),
            const Text(
              'Your demo orders list is currently empty. Place an order to see it appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (widget.onContinueShopping != null) {
                  widget.onContinueShopping!();
                } else {
                  Navigator.pop(context);
                }
              },
              child: const Text('Start Shopping'),
            ),
          ],
        ),
      ),
    );
  }
}
