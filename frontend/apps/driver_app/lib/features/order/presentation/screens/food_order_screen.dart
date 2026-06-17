import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import 'package:clay_shared/clay_shared.dart';
import 'package:dio/dio.dart';
import '../../../../shared/widgets.dart';
import '../providers/order_provider.dart';

final foodOrderProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, orderId) async {
  try {
    final response = await ClayApi.instance.dio.get('/food/orders/$orderId');
    final data = response.data as Map<String, dynamic>;
    return data['data'] as Map<String, dynamic>? ?? data;
  } on DioException catch (e) {
    final data = e.response?.data;
    final msg = data is Map
        ? (data['message']?.toString() ?? e.message ?? 'Gagal memuat detail order')
        : (e.message ?? 'Gagal memuat detail order');
    throw AppException(msg, statusCode: e.response?.statusCode);
  }
});

class FoodOrderScreen extends ConsumerStatefulWidget {
  final String orderId;
  const FoodOrderScreen({super.key, required this.orderId});

  @override
  ConsumerState<FoodOrderScreen> createState() => _FoodOrderScreenState();
}

class _FoodOrderScreenState extends ConsumerState<FoodOrderScreen> {
  bool _isActionLoading = false;
  Map<String, dynamic>? _orderOverride;

  Future<void> _confirmPickup() async {
    setState(() => _isActionLoading = true);
    try {
      final result = await ref.read(orderRepositoryProvider).foodPickup(widget.orderId);
      setState(() => _orderOverride = result);
      ref.invalidate(foodOrderProvider(widget.orderId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal konfirmasi pickup: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  Future<void> _confirmDeliver() async {
    setState(() => _isActionLoading = true);
    try {
      final result = await ref.read(orderRepositoryProvider).foodDeliver(widget.orderId);
      setState(() => _orderOverride = result);
      ref.invalidate(foodOrderProvider(widget.orderId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal konfirmasi antar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(foodOrderProvider(widget.orderId));

    return Scaffold(
      body: SafeArea(
        child: orderAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: ClayColors.accent),
                const SizedBox(height: 12),
                Text('Gagal memuat order', style: TextStyle(fontSize: 14, color: ClayColors.textSecondary)),
                const SizedBox(height: 4),
                Text(e.toString(), style: const TextStyle(fontSize: 12, color: ClayColors.textSecondary), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => ref.invalidate(foodOrderProvider(widget.orderId)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(color: ClayColors.primary, borderRadius: BorderRadius.circular(12)),
                    child: const Text('Coba Lagi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                  ),
                ),
              ],
            ),
          ),
          data: (apiOrder) {
            final order = _orderOverride ?? apiOrder;
            return _buildContent(context, order);
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Map<String, dynamic> order) {
    final merchantName = order['merchant_name']?.toString() ?? order['merchant']?['name']?.toString() ?? '-';
    final pickupAddress = order['pickup_address']?.toString() ?? order['merchant']?['address']?.toString() ?? '-';
    final deliveryAddress = order['delivery_address']?.toString() ?? order['customer_address']?.toString() ?? '-';
    final total = order['total'] ?? order['total_price'] ?? 0;
    final fare = order['driver_fare'] ?? order['fare'] ?? order['delivery_fee'] ?? 0;
    final status = order['status']?.toString() ?? 'pending';
    final items = order['items'] as List<dynamic>? ?? [];
    final customerName = order['customer_name']?.toString() ?? order['customer']?['name']?.toString() ?? '';

    final statusSteps = ['pending', 'confirmed', 'preparing', 'picked_up', 'delivered'];
    final statusLabels = {'pending': 'Menunggu', 'confirmed': 'Dikonfirmasi', 'preparing': 'Disiapkan', 'picked_up': 'Diambil', 'delivered': 'Diantar'};
    final currentIndex = statusSteps.indexOf(status);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              GestureDetector(onTap: () { if (Navigator.canPop(context)) { context.pop(); } else { context.go('/home'); } }, child: Container(width: 40, height: 40, decoration: softShadow(), child: const Center(child: Icon(Icons.arrow_back, size: 20, color: ClayColors.textPrimary)))),
              const SizedBox(width: 12),
              const Expanded(child: Text('Order Makanan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ClayColors.textPrimary))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(statusLabels[status] ?? status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: _statusColor(status))),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _buildStatusFlow(statusSteps, statusLabels, currentIndex),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: softShadow(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(width: 36, height: 36, decoration: BoxDecoration(color: ClayColors.warning.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.restaurant, size: 18, color: ClayColors.warning)),
                        const SizedBox(width: 10),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('Merchant', style: TextStyle(fontSize: 11, color: ClayColors.textSecondary)),
                          Text(merchantName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ClayColors.textPrimary)),
                        ])),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              if (items.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: softShadow(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Item Pesanan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: ClayColors.textPrimary)),
                      const SizedBox(height: 10),
                      ...items.map((item) {
                        final itemMap = item is Map<String, dynamic> ? item : {};
                        final name = itemMap['name']?.toString() ?? itemMap['menu_name']?.toString() ?? '-';
                        final qty = itemMap['quantity']?.toString() ?? itemMap['qty']?.toString() ?? '1';
                        final price = itemMap['price'] ?? itemMap['subtotal'] ?? 0;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(width: 24, height: 24, decoration: BoxDecoration(color: ClayColors.muted, borderRadius: BorderRadius.circular(6)), child: Center(child: Text('$qty', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: ClayColors.textPrimary)))),
                              const SizedBox(width: 8),
                              Expanded(child: Text(name, style: const TextStyle(fontSize: 13, color: ClayColors.textPrimary))),
                              Text('Rp $price', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: ClayColors.textSecondary)),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              Container(
                padding: const EdgeInsets.all(16),
                decoration: softShadow(),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(children: [
                      Container(width: 10, height: 10, decoration: BoxDecoration(color: ClayColors.green, shape: BoxShape.circle, boxShadow: [BoxShadow(color: ClayColors.green.withValues(alpha: 0.3), blurRadius: 4)])),
                      const SizedBox(height: 4),
                      Container(width: 2, height: 30, color: ClayColors.divider),
                      const SizedBox(height: 4),
                      Container(width: 10, height: 10, decoration: BoxDecoration(color: ClayColors.accent, shape: BoxShape.circle, boxShadow: [BoxShadow(color: ClayColors.accent.withValues(alpha: 0.3), blurRadius: 4)])),
                    ]),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Pickup', style: TextStyle(fontSize: 11, color: ClayColors.textSecondary)),
                      Text(pickupAddress, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: ClayColors.textPrimary)),
                      const SizedBox(height: 20),
                      const Text('Antar ke', style: TextStyle(fontSize: 11, color: ClayColors.textSecondary)),
                      Text(deliveryAddress, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: ClayColors.textPrimary)),
                      if (customerName.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(customerName, style: const TextStyle(fontSize: 11, color: ClayColors.textSecondary)),
                      ],
                    ])),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: softShadow(),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text('Total Pesanan', style: TextStyle(fontSize: 13, color: ClayColors.textSecondary)),
                        const Spacer(),
                        Text('Rp $total', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ClayColors.textPrimary)),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      children: [
                        const Text('Fare Driver', style: TextStyle(fontSize: 13, color: ClayColors.textSecondary)),
                        const Spacer(),
                        Text('Rp $fare', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: ClayColors.green)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              _buildActionButton(status),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusFlow(List<String> steps, Map<String, String> labels, int currentIndex) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: softShadow(),
      child: Row(
        children: List.generate(steps.length, (i) {
          final isActive = i <= currentIndex;
          final isCurrent = i == currentIndex;
          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    if (i > 0) Expanded(child: Container(height: 2, color: isActive ? ClayColors.primary : ClayColors.divider)),
                    Container(
                      width: isCurrent ? 14 : 10,
                      height: isCurrent ? 14 : 10,
                      decoration: BoxDecoration(
                        color: isActive ? ClayColors.primary : ClayColors.divider,
                        shape: BoxShape.circle,
                        boxShadow: isCurrent ? [BoxShadow(color: ClayColors.primary.withValues(alpha: 0.3), blurRadius: 6)] : null,
                      ),
                    ),
                    if (i < steps.length - 1) Expanded(child: Container(height: 2, color: i < currentIndex ? ClayColors.primary : ClayColors.divider)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  labels[steps[i]] ?? steps[i],
                  style: TextStyle(fontSize: 9, color: isActive ? ClayColors.primary : ClayColors.textSecondary, fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildActionButton(String status) {
    if (status == 'confirmed' || status == 'preparing') {
      return GestureDetector(
        onTap: _isActionLoading ? null : _confirmPickup,
        child: Container(
          width: double.infinity, height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(colors: [ClayColors.warning, ClayColors.warningDark]),
            boxShadow: [BoxShadow(color: ClayColors.warning.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: Center(
            child: _isActionLoading
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Konfirmasi Pickup', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 15)),
          ),
        ),
      );
    }

    if (status == 'picked_up') {
      return GestureDetector(
        onTap: _isActionLoading ? null : _confirmDeliver,
        child: Container(
          width: double.infinity, height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(colors: [ClayColors.green, ClayColors.greenDark]),
            boxShadow: [BoxShadow(color: ClayColors.green.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: Center(
            child: _isActionLoading
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Konfirmasi Antar', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 15)),
          ),
        ),
      );
    }

    if (status == 'delivered') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: ClayColors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 20, color: ClayColors.green),
            SizedBox(width: 8),
            Text('Order Selesai Diantar', style: TextStyle(fontWeight: FontWeight.w600, color: ClayColors.green)),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Color _statusColor(String status) {
    return switch (status) {
      'pending' => ClayColors.textSecondary,
      'confirmed' => ClayColors.primary,
      'preparing' => ClayColors.warning,
      'picked_up' => ClayColors.green,
      'delivered' => ClayColors.green,
      _ => ClayColors.textSecondary,
    };
  }
}
