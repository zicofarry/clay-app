import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import '../providers/food_provider.dart';
import 'package:user_app/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:user_app/features/home/presentation/screens/home_screen.dart';

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(walletStateProvider.notifier).loadWallet();
    });
  }

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
    final walletState = ref.watch(walletStateProvider);

    _addressController.text = state.selectedAddress ?? 'Jl. Sudirman No. 1, Jakarta';

    const deliveryFee = 10000;
    const serviceFee = 1000;
    final totalPayment = notifier.totalPrice + deliveryFee + serviceFee;

    ref.listen(foodStateProvider, (prev, state) {
      if (state.activeOrder != null &&
          prev?.activeOrder == null &&
          mounted) {
        ref.read(currentTabProvider.notifier).state = 1;
        context.go('/home');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pesanan berhasil dibuat! Silakan cek di tab Orders.'),
            backgroundColor: ClayColors.greenDark,
          ),
        );
      }
      if (state.error != null && prev?.error != state.error && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.error!),
            backgroundColor: ClayColors.error,
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: ClayColors.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
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
                                  'E-Wallet',
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
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: ClayColors.primary.withOpacity(0.15), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: ClayColors.primary.withOpacity(0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Image.network(
                                'https://upload.wikimedia.org/wikipedia/commons/a/a2/Logo_QRIS.svg',
                                height: 20,
                                errorBuilder: (_, __, ___) => const Text(
                                  'QRIS',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: ClayColors.primary,
                                  ),
                                ),
                              ),
                              const Text(
                                'CLAY WALLET',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: ClayColors.textSecondary,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: ClayColors.divider),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                'https://api.qrserver.com/v1/create-qr-code/?size=180x180&data=ClayFood-${DateTime.now().millisecondsSinceEpoch}',
                                width: 160,
                                height: 160,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 160,
                                    height: 160,
                                    color: Colors.grey.shade100,
                                    child: const Icon(Icons.qr_code_2, size: 64, color: Colors.grey),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: ClayColors.muted.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Image.network(
                                  'https://bwipjs-api.metafloor.com/?bcid=code128&text=CLAYPAY$totalPayment&scale=2&rotate=N&includeText=false&height=12',
                                  height: 40,
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const SizedBox(
                                      height: 40,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.linear_scale, color: ClayColors.textSecondary),
                                          SizedBox(width: 8),
                                          Text('Barcode Preview', style: TextStyle(fontSize: 12, color: ClayColors.textSecondary)),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'CLAYPAY$totalPayment',
                                  style: const TextStyle(
                                    fontFamily: 'Courier',
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2.0,
                                    color: ClayColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.info_outline, size: 14, color: ClayColors.textSecondary),
                              SizedBox(width: 6),
                              Text(
                                'Scan QRIS atau tunjukkan Barcode ke kasir/kurir',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: ClayColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
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
                                    'Clay E-Wallet',
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
                          Text(
                            'Rp ${walletState.balance}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: ClayColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (walletState.balance < totalPayment) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: ClayColors.error.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: ClayColors.error.withOpacity(0.15)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.error_outline, color: ClayColors.error, size: 16),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Saldo E-Wallet Anda tidak mencukupi untuk melakukan pesanan ini.',
                                style: TextStyle(color: ClayColors.error, fontSize: 11, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                    // Use cartItemDetails (persists across navigation) first, fall back to menuItems
                    final saved = state.cartItemDetails[e.key];
                    final fromMenu = state.menuItems.where((m) => m['id'] == e.key);
                    final name = saved?['name']?.toString()
                        ?? (fromMenu.isEmpty ? 'Menu Item' : fromMenu.first['name']?.toString() ?? 'Menu Item');
                    final price = saved?['price'] as int?
                        ?? (fromMenu.isEmpty ? 0 : (fromMenu.first['price'] as int? ?? 0));

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '$name x${e.value}',
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
            label: state.isLoading
                ? 'Memproses Pesanan...'
                : (_paymentMethod == 'claypay' && walletState.balance < totalPayment)
                    ? 'Saldo E-Wallet Tidak Cukup'
                    : 'Pesan Sekarang (Rp $totalPayment)',
            isLoading: state.isLoading,
            onPressed: (_paymentMethod == 'claypay' && walletState.balance < totalPayment)
                ? null
                : () {
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
