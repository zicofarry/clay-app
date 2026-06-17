import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import '../providers/send_provider.dart';

class SendCompleteScreen extends ConsumerWidget {
  const SendCompleteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sendStateProvider);
    final fareBreakdown = state.fareBreakdown;
    final order = state.activeOrder;
    final fareFinal = (order?['fare_final'] as num?)?.round() ?? fareBreakdown?['total'] as int? ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // ── Success icon ──
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: ClayColors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle, color: ClayColors.green, size: 60),
              ),

              const SizedBox(height: 24),

              const Text(
                'Paket Terkirim!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: ClayColors.textPrimary),
              ),
              const SizedBox(height: 8),
              const Text(
                'Paket kamu sudah sampai di tujuan',
                style: TextStyle(fontSize: 15, color: ClayColors.textSecondary),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // ── Fare summary ──
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: ClayColors.muted,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text('Total Ongkir', style: TextStyle(fontSize: 14, color: ClayColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text(
                      'Rp${_formatCurrency(fareFinal)}',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: ClayColors.primaryDark),
                    ),

                    if (fareBreakdown != null) ...[
                      const Divider(height: 24),
                      _FareRow('Tarif dasar', fareBreakdown['base_fare'] as int),
                      _FareRow('Tarif jarak', fareBreakdown['distance_fare'] as int),
                      if ((fareBreakdown['weight_surcharge'] as int) > 0)
                        _FareRow('Biaya berat', fareBreakdown['weight_surcharge'] as int),
                      if ((fareBreakdown['insurance_fee'] as int) > 0)
                        _FareRow('Asuransi', fareBreakdown['insurance_fee'] as int),
                      _FareRow('Biaya platform', fareBreakdown['platform_fee'] as int),
                      if ((fareBreakdown['promo_discount'] as int) > 0)
                        _FareRow('Diskon promo', -(fareBreakdown['promo_discount'] as int), isDiscount: true),
                    ],
                  ],
                ),
              ),

              const Spacer(),

              // ── Actions ──
              ClayButton(
                label: 'Beri Rating',
                onPressed: () => context.push('/send/rating'),
              ),
              const SizedBox(height: 12),
              ClayButton(
                label: 'Kembali ke Beranda',
                outlined: true,
                onPressed: () {
                  ref.read(sendStateProvider.notifier).resetSend();
                  context.go('/home');
                },
              ),
            ],
          ),
        ),
      ),
    );
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

class _FareRow extends StatelessWidget {
  final String label;
  final int amount;
  final bool isDiscount;

  const _FareRow(this.label, this.amount, {this.isDiscount = false});

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
          Text(label, style: TextStyle(fontSize: 13, color: isDiscount ? ClayColors.green : ClayColors.textSecondary)),
          Text(
            '${isDiscount ? "-" : ""}Rp${_formatCurrency(amount.abs())}',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isDiscount ? ClayColors.green : ClayColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
