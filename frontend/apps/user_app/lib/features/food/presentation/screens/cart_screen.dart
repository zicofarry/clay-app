import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import '../providers/food_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(foodStateProvider);
    final notifier = ref.read(foodStateProvider.notifier);
    final merchantName = state.selectedMerchantName ?? 'Resto Terpilih';

    const deliveryFee = 10000;
    const serviceFee = 1000;
    final totalPayment = notifier.totalPrice + deliveryFee + serviceFee;

    return Scaffold(
      backgroundColor: ClayColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: ClayColors.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Keranjang Belanja',
          style: TextStyle(
            color: ClayColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: state.cart.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: ClayColors.muted,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.shopping_basket_outlined,
                        size: 72,
                        color: ClayColors.textSecondary.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Keranjang Belanja Kosong',
                      style: TextStyle(
                        color: ClayColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Cari makanan lezat favoritmu untuk mulai memesan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ClayColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 200,
                      child: ClayButton(
                        label: 'Cari Makanan',
                        onPressed: () => context.push('/food'),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Merchant Name Banner (Styled Card)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: ClayColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.storefront, color: ClayColors.primary, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                merchantName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: ClayColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Pengiriman Instant • Jarak ~1.5 km',
                                style: TextStyle(
                                  color: ClayColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Delivery Address Styled Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: ClayColors.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.location_on, color: ClayColors.accent, size: 24),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Alamat Pengiriman',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: ClayColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Jl. Sudirman No. 1, Jakarta (Kantor Clay)',
                                style: TextStyle(
                                  color: ClayColors.textSecondary,
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Order Summary Card with Interactive Quantity Controls
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ringkasan Pesanan',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: ClayColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: ClayColors.divider),
                        const SizedBox(height: 4),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.cart.length,
                          separatorBuilder: (_, __) => const Divider(color: ClayColors.divider, height: 16),
                          itemBuilder: (context, i) {
                            final entry = state.cart.entries.elementAt(i);
                            final item = state.menuItems.firstWhere(
                              (m) => m['id'] == entry.key,
                              orElse: () => {
                                'id': entry.key,
                                'name': 'Menu Item',
                                'price': 15000,
                              },
                            );
                            final itemPrice = item['price'] as int;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Interactive Quantity Control inside Cart
                                  Container(
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: ClayColors.muted,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: ClayColors.border),
                                    ),
                                    child: Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () => notifier.addToCart(item['id'], -1),
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 8),
                                            child: Icon(Icons.remove, size: 14, color: ClayColors.primary),
                                          ),
                                        ),
                                        Text(
                                          '${entry.value}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: ClayColors.textPrimary,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => notifier.addToCart(item['id'], 1),
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 8),
                                            child: Icon(Icons.add, size: 14, color: ClayColors.primary),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['name'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: ClayColors.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          'Rp $itemPrice',
                                          style: const TextStyle(
                                            color: ClayColors.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Rp ${itemPrice * entry.value}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: ClayColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Payment Breakdown Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rincian Pembayaran',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: ClayColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: ClayColors.divider),
                        const SizedBox(height: 6),
                        _buildPaymentRow('Subtotal makanan', 'Rp ${notifier.totalPrice}'),
                        _buildPaymentRow('Ongkos kirim', 'Rp $deliveryFee'),
                        _buildPaymentRow('Biaya jasa & layanan', 'Rp $serviceFee'),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(color: ClayColors.divider),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Pembayaran',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: ClayColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Rp $totalPayment',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: ClayColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100), // Spacing for sticky bottom bar
                ],
              ),
            ),
      bottomNavigationBar: state.cart.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 15,
                    offset: const Offset(0, -4),
                  ),
                ],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                child: ClayButton(
                  label: 'Lanjut ke Pembayaran',
                  onPressed: () => context.push('/food/checkout'),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildPaymentRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: ClayColors.textSecondary, fontSize: 13),
          ),
          Text(
            value,
            style: const TextStyle(color: ClayColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
