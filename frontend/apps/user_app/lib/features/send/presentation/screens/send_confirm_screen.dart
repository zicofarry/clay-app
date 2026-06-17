import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../providers/send_provider.dart';

class SendConfirmScreen extends ConsumerStatefulWidget {
  const SendConfirmScreen({super.key});

  @override
  ConsumerState<SendConfirmScreen> createState() => _SendConfirmScreenState();
}

class _SendConfirmScreenState extends ConsumerState<SendConfirmScreen> {
  late final TextEditingController _senderNameCtrl;
  late final TextEditingController _senderPhoneCtrl;
  late final TextEditingController _recipientNameCtrl;
  late final TextEditingController _recipientPhoneCtrl;
  final _promoController = TextEditingController();
  bool _showPromoInput = false;

  @override
  void initState() {
    super.initState();
    _senderNameCtrl = TextEditingController();
    _senderPhoneCtrl = TextEditingController();
    _recipientNameCtrl = TextEditingController();
    _recipientPhoneCtrl = TextEditingController();

    Future.microtask(() {
      final profileAsync = ref.read(profileProvider);
      final authState = ref.read(authStateProvider);

      profileAsync.whenData((profile) {
        final name = profile['full_name']?.toString() ?? '';
        if (name.isNotEmpty) _senderNameCtrl.text = name;
      });

      final phone = authState.authResponse?.user.phoneNumber ?? '';
      if (phone.isNotEmpty) _senderPhoneCtrl.text = phone;
    });
  }

  @override
  void dispose() {
    _senderNameCtrl.dispose();
    _senderPhoneCtrl.dispose();
    _recipientNameCtrl.dispose();
    _recipientPhoneCtrl.dispose();
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sendStateProvider);

    if (state.estimate == null) {
      return Scaffold(
        body: Center(child: Text('Estimasi belum tersedia', style: TextStyle(color: ClayColors.textSecondary))),
      );
    }

    final fare = state.estimate!['fare_after_promo'] as int;
    final breakdown = state.estimate!['breakdown'] as Map<String, dynamic>?;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Map preview ──
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(
                      ((state.pickupLat ?? 0) + (state.destLat ?? 0)) / 2,
                      ((state.pickupLng ?? 0) + (state.destLng ?? 0)) / 2,
                    ),
                    initialZoom: 13,
                    interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.clay.user_app',
                    ),
                    MarkerLayer(
                      markers: [
                        if (state.pickupLat != null)
                          Marker(
                            point: LatLng(state.pickupLat!, state.pickupLng!),
                            child: const Icon(Icons.radio_button_checked, color: Colors.green, size: 24),
                          ),
                        if (state.destLat != null)
                          Marker(
                            point: LatLng(state.destLat!, state.destLng!),
                            child: const Icon(Icons.location_on, color: Colors.red, size: 28),
                          ),
                      ],
                    ),
                    if (state.pickupLat != null && state.destLat != null)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: [
                              LatLng(state.pickupLat!, state.pickupLng!),
                              LatLng(state.destLat!, state.destLng!),
                            ],
                            color: ClayColors.primary,
                            strokeWidth: 3,
                          ),
                        ],
                      ),
                  ],
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 12,
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)],
                      ),
                      child: const Icon(Icons.arrow_back, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Content ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Route summary ──
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: ClayColors.muted,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(width: 10, height: 10, decoration: const BoxDecoration(color: ClayColors.green, shape: BoxShape.circle)),
                            const SizedBox(width: 10),
                            Expanded(child: Text(state.pickupAddress, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                        Padding(padding: const EdgeInsets.only(left: 4), child: Container(width: 2, height: 16, color: ClayColors.divider)),
                        Row(
                          children: [
                            Container(width: 10, height: 10, decoration: const BoxDecoration(color: ClayColors.accent, shape: BoxShape.circle)),
                            const SizedBox(width: 10),
                            Expanded(child: Text(state.destAddress, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Package summary ──
                  const Text('Detail Paket', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ClayColors.divider),
                    ),
                    child: Column(
                      children: [
                        _InfoRow('Kategori', _categoryLabel(state.packageCategory)),
                        _InfoRow('Ukuran', _sizeLabel(state.packageSize)),
                        if (state.packageWeight > 0)
                          _InfoRow('Berat', '${state.packageWeight} kg'),
                        if (state.isFragile)
                          _InfoRow('Rapuh', 'Ya'),
                        if (state.packageDescription.isNotEmpty)
                          _InfoRow('Deskripsi', state.packageDescription),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Sender info ──
                  const Text('Info Pengirim', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _senderNameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Nama pengirim',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _senderPhoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'No. telepon pengirim',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Recipient info ──
                  const Text('Info Penerima', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _recipientNameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Nama penerima',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _recipientPhoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'No. telepon penerima',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Payment method ──
                  const Text('Metode Pembayaran', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  _PaymentOption(
                    icon: Icons.account_balance_wallet,
                    label: 'ClayWallet',
                    isSelected: state.paymentMethod == 'clay_wallet',
                    onTap: () => ref.read(sendStateProvider.notifier).setPaymentMethod('clay_wallet'),
                  ),
                  const SizedBox(height: 8),
                  _PaymentOption(
                    icon: Icons.payments_outlined,
                    label: 'Cash',
                    isSelected: state.paymentMethod == 'cash',
                    onTap: () => ref.read(sendStateProvider.notifier).setPaymentMethod('cash'),
                  ),

                  const SizedBox(height: 20),

                  // ── Promo ──
                  GestureDetector(
                    onTap: () => setState(() => _showPromoInput = !_showPromoInput),
                    child: Row(
                      children: [
                        Icon(Icons.local_offer_outlined, size: 20, color: ClayColors.green),
                        const SizedBox(width: 8),
                        const Text('Punya kode promo?', style: TextStyle(fontSize: 14, color: ClayColors.green, fontWeight: FontWeight.w500)),
                        const Spacer(),
                        Icon(_showPromoInput ? Icons.expand_less : Icons.expand_more, color: ClayColors.green),
                      ],
                    ),
                  ),
                  if (_showPromoInput) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _promoController,
                            decoration: InputDecoration(
                              hintText: 'Masukkan kode promo',
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {
                            ref.read(sendStateProvider.notifier).setPromoCode(_promoController.text);
                          },
                          child: const Text('Pakai'),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 20),

                  // ── Fare breakdown ──
                  if (breakdown != null) ...[
                    const Text('Rincian Harga', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    _FareRow(label: 'Tarif dasar', amount: breakdown['base_fare'] as int),
                    _FareRow(label: 'Tarif jarak', amount: breakdown['distance_fare'] as int),
                    if ((breakdown['weight_surcharge'] as int) > 0)
                      _FareRow(label: 'Biaya berat', amount: breakdown['weight_surcharge'] as int),
                    if ((breakdown['insurance_fee'] as int) > 0)
                      _FareRow(label: 'Asuransi', amount: breakdown['insurance_fee'] as int),
                    _FareRow(label: 'Biaya platform', amount: breakdown['platform_fee'] as int),
                    if ((breakdown['promo_discount'] as int) > 0)
                      _FareRow(label: 'Diskon promo', amount: -(breakdown['promo_discount'] as int), isDiscount: true),
                    const Divider(height: 20),
                    _FareRow(label: 'Total', amount: breakdown['total'] as int, isBold: true),
                  ],

                  if (state.error != null) ...[
                    const SizedBox(height: 12),
                    Text(state.error!, style: const TextStyle(color: ClayColors.error, fontSize: 14)),
                  ],
                ],
              ),
            ),
          ),

          // ── Bottom confirm button ──
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))],
            ),
            child: ClayButton(
              label: 'Pesan ClaySend — Rp${_formatCurrency(fare)}',
              isLoading: state.isLoading,
              onPressed: state.isLoading ? null : _onConfirmOrder,
            ),
          ),
        ],
      ),
    );
  }

  void _onConfirmOrder() {
    final senderName = _senderNameCtrl.text.trim();
    final senderPhone = _senderPhoneCtrl.text.trim();
    final recipientName = _recipientNameCtrl.text.trim();
    final recipientPhone = _recipientPhoneCtrl.text.trim();

    if (senderName.isEmpty || senderPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi info pengirim'), backgroundColor: ClayColors.error),
      );
      return;
    }
    if (recipientName.isEmpty || recipientPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi info penerima'), backgroundColor: ClayColors.error),
      );
      return;
    }

    ref.read(sendStateProvider.notifier).setSenderInfo(senderName, senderPhone);
    ref.read(sendStateProvider.notifier).setRecipientInfo(recipientName, recipientPhone);
    ref.read(sendStateProvider.notifier).confirmOrder();

    ref.listenManual(sendStateProvider, (_, state) {
      if (state.orderStatus == 'finding_driver' && !state.isLoading) {
        context.go('/send/searching');
      }
    });
  }

  String _categoryLabel(String cat) {
    const map = {
      'document': 'Dokumen',
      'food': 'Makanan',
      'electronics': 'Elektronik',
      'clothing': 'Pakaian',
      'fragile': 'Barang Rapuh',
      'other': 'Lainnya',
    };
    return map[cat] ?? cat;
  }

  String _sizeLabel(String size) {
    const map = {'small': 'Kecil', 'medium': 'Sedang', 'large': 'Besar'};
    return map[size] ?? size;
  }

  String _formatCurrency(int amount) {
    final str = amount.abs().toString();
    final buffer = StringBuffer();
    var count = 0;
    for (var i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
      count++;
    }
    return buffer.toString().split('').reversed.join();
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: ClayColors.textSecondary)),
          Flexible(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500), textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentOption({required this.icon, required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? ClayColors.primary.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? ClayColors.primary : ClayColors.divider, width: isSelected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: isSelected ? ClayColors.primary : ClayColors.textSecondary),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal, color: isSelected ? ClayColors.primaryDark : ClayColors.textPrimary)),
            const Spacer(),
            if (isSelected) Icon(Icons.check_circle, color: ClayColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _FareRow extends StatelessWidget {
  final String label;
  final int amount;
  final bool isBold;
  final bool isDiscount;

  const _FareRow({required this.label, required this.amount, this.isBold = false, this.isDiscount = false});

  String _formatCurrency(int amount) {
    final str = amount.abs().toString();
    final buffer = StringBuffer();
    var count = 0;
    for (var i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
      count++;
    }
    return buffer.toString().split('').reversed.join();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isBold ? 15 : 13, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: isDiscount ? ClayColors.green : ClayColors.textPrimary)),
          Text('${isDiscount ? "-" : ""}Rp${_formatCurrency(amount.abs())}', style: TextStyle(fontSize: isBold ? 15 : 13, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: isDiscount ? ClayColors.green : ClayColors.textPrimary)),
        ],
      ),
    );
  }
}
