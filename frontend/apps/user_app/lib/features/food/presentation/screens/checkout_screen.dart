import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import '../providers/food_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _addressController = TextEditingController(text: 'Jl. Sudirman No. 1, Jakarta');
  final _notesController = TextEditingController();
  String _paymentMethod = 'qris'; // default selection

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(foodStateProvider);
    final notifier = ref.read(foodStateProvider.notifier);

    _addressController.text = state.selectedAddress ?? 'Jl. Sudirman No. 1, Jakarta';

    const deliveryFee = 10000;
    const serviceFee = 1000;
    final totalPayment = notifier.totalPrice + deliveryFee + serviceFee;

    ref.listen(foodStateProvider, (_, state) {
      if (state.activeOrder != null) {
        context.go('/home');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pesanan berhasil dibuat! Silakan cek di tab Orders.'),
            backgroundColor: ClayColors.greenDark,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: ClayColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: ClayColors.textPrimary),
        title: const Text(
          'Konfirmasi Pesanan',
          style: TextStyle(
            color: ClayColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Delivery Address Styled Card
            Container(
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: ClayColors.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.location_on, color: ClayColors.accent, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Alamat Pengiriman',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: ClayColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ClayColors.muted,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            state.selectedAddress ?? 'Jl. Sudirman No. 1, Jakarta',
                            style: const TextStyle(
                              fontSize: 13,
                              color: ClayColors.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.lock_outline,
                          color: ClayColors.textSecondary,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Order Notes for Restaurant Styled Card
            Container(
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: ClayColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.note_alt_outlined, color: ClayColors.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Catatan untuk Penjual',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: ClayColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notesController,
                    maxLines: 1,
                    style: const TextStyle(fontSize: 13, color: ClayColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Contoh: Pedas sedang, pisahkan kuah...',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      filled: true,
                      fillColor: ClayColors.muted,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Metode Pembayaran Styled Card
            Container(
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: ClayColors.greenDark.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.payment, color: ClayColors.greenDark, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Metode Pembayaran',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: ClayColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // QRIS option
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _paymentMethod = 'qris';
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                            decoration: BoxDecoration(
                              color: _paymentMethod == 'qris'
                                  ? ClayColors.primary.withOpacity(0.08)
                                  : ClayColors.muted,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _paymentMethod == 'qris'
                                    ? ClayColors.primary
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.qr_code,
                                  color: _paymentMethod == 'qris' ? ClayColors.primary : ClayColors.textSecondary,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'QRIS',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: _paymentMethod == 'qris' ? ClayColors.primary : ClayColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Cash / Tunai option
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _paymentMethod = 'cash';
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                            decoration: BoxDecoration(
                              color: _paymentMethod == 'cash'
                                  ? ClayColors.primary.withOpacity(0.08)
                                  : ClayColors.muted,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _paymentMethod == 'cash'
                                    ? ClayColors.primary
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.payments,
                                  color: _paymentMethod == 'cash' ? ClayColors.primary : ClayColors.textSecondary,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Tunai',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: _paymentMethod == 'cash' ? ClayColors.primary : ClayColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // ClayPay option
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _paymentMethod = 'claypay';
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                            decoration: BoxDecoration(
                              color: _paymentMethod == 'claypay'
                                  ? ClayColors.primary.withOpacity(0.08)
                                  : ClayColors.muted,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _paymentMethod == 'claypay'
                                    ? ClayColors.primary
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.account_balance_wallet,
                                  color: _paymentMethod == 'claypay' ? ClayColors.primary : ClayColors.textSecondary,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'ClayPay',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: _paymentMethod == 'claypay' ? ClayColors.primary : ClayColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_paymentMethod == 'qris') ...[
                    const SizedBox(height: 16),
                    Center(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ClayColors.background,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: ClayColors.divider),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'QRIS CLAY',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: ClayColors.textPrimary,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                'https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=ClayAppPayment',
                                width: 150,
                                height: 150,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 150,
                                    height: 150,
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.qr_code, size: 64, color: Colors.grey),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Pindai kode QR untuk melakukan pembayaran',
                              style: TextStyle(
                                fontSize: 11,
                                color: ClayColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else if (_paymentMethod == 'claypay') ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: ClayColors.greenDark.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: ClayColors.greenDark.withOpacity(0.15)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.account_balance_wallet, color: ClayColors.greenDark, size: 20),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'ClayPay E-Wallet',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: ClayColors.greenDark,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Saldo Aktif',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: ClayColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Text(
                            'Rp 150.000',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: ClayColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Review Items block Styled Card
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
                    'Detail Item',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: ClayColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(color: ClayColors.divider),
                  const SizedBox(height: 4),
                  ...state.cart.entries.map((e) {
                    final item = state.menuItems.firstWhere(
                      (m) => m['id'] == e.key,
                      orElse: () => {
                        'name': 'Menu Item',
                        'price': 15000,
                      },
                    );
                    final price = item['price'] as int;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item['name']} x${e.value}',
                              style: const TextStyle(fontSize: 13, color: ClayColors.textPrimary, fontWeight: FontWeight.w500),
                            ),
                          ),
                          Text(
                            'Rp ${price * e.value}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ClayColors.textPrimary),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Payment breakdown block Styled Card
            Container(
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
                    'Ringkasan Pembayaran',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: ClayColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: ClayColors.divider),
                  const SizedBox(height: 6),
                  _buildSummaryRow('Subtotal makanan', 'Rp ${notifier.totalPrice}'),
                  _buildSummaryRow('Ongkos kirim', 'Rp $deliveryFee'),
                  _buildSummaryRow('Biaya layanan', 'Rp $serviceFee'),
                  const Divider(color: ClayColors.divider, height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Tagihan',
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
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
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
            label: state.isLoading ? 'Memproses Pesanan...' : 'Pesan Sekarang (Rp $totalPayment)',
            isLoading: state.isLoading,
            onPressed: () {
              notifier.createOrder(
                merchantId: state.selectedMerchantId ?? '',
                address: _addressController.text,
                paymentMethod: _paymentMethod,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
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
