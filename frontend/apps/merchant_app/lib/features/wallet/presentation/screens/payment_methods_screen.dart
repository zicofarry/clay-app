import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import '../providers/payment_provider.dart';

class PaymentMethodsScreen extends ConsumerStatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  ConsumerState<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends ConsumerState<PaymentMethodsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(paymentProvider.notifier).reloadPaymentMethods());
  }

  static const _addableTypes = [
    {'type': 'clay_wallet', 'label': 'Clay Wallet', 'icon': Icons.account_balance_wallet_outlined},
    {'type': 'credit_card', 'label': 'Kartu Kredit', 'icon': Icons.credit_card},
    {'type': 'debit_card', 'label': 'Kartu Debit', 'icon': Icons.credit_card},
    {'type': 'bank_transfer', 'label': 'Transfer Bank', 'icon': Icons.account_balance_outlined},
    {'type': 'gopay', 'label': 'GoPay', 'icon': Icons.phone_android},
    {'type': 'ovo', 'label': 'OVO', 'icon': Icons.phone_android},
    {'type': 'dana', 'label': 'DANA', 'icon': Icons.phone_android},
  ];

  String _methodLabel(String type) {
    const map = {
      'clay_wallet': 'Clay Wallet',
      'credit_card': 'Kartu Kredit',
      'debit_card': 'Kartu Debit',
      'bank_transfer': 'Transfer Bank',
      'gopay': 'GoPay',
      'ovo': 'OVO',
      'dana': 'DANA',
      'cod': 'COD',
    };
    return map[type] ?? type;
  }

  IconData _methodIcon(String type) {
    switch (type) {
      case 'clay_wallet':
        return Icons.account_balance_wallet_outlined;
      case 'credit_card':
      case 'debit_card':
        return Icons.credit_card;
      case 'bank_transfer':
        return Icons.account_balance_outlined;
      case 'gopay':
      case 'ovo':
      case 'dana':
        return Icons.phone_android;
      default:
        return Icons.payment;
    }
  }

  Color _methodColor(String type) {
    switch (type) {
      case 'clay_wallet':
        return ClayColors.primary;
      case 'credit_card':
      case 'debit_card':
        return ClayColors.purple;
      case 'gopay':
        return Colors.green;
      case 'ovo':
        return Colors.deepPurple;
      case 'dana':
        return Colors.blue;
      case 'bank_transfer':
        return Colors.teal;
      default:
        return ClayColors.textSecondary;
    }
  }

  Future<void> _showAddDialog() async {
    String? selectedType;
    bool setAsDefault = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tambah Metode Pembayaran',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ..._addableTypes.map((t) {
                    final isSelected = selectedType == t['type'];
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedType = t['type'] as String),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? ClayColors.primary.withValues(alpha: 0.08) : ClayColors.muted,
                          border: Border.all(
                            color: isSelected ? ClayColors.primary : Colors.transparent,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(t['icon'] as IconData,
                                color: isSelected
                                    ? ClayColors.primaryDark
                                    : ClayColors.textSecondary),
                            const SizedBox(width: 12),
                            Text(
                              t['label'] as String,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                            const Spacer(),
                            if (isSelected)
                              const Icon(Icons.check_circle, color: ClayColors.primary, size: 20),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    value: setAsDefault,
                    onChanged: (v) => setModalState(() => setAsDefault = v ?? false),
                    title: const Text('Jadikan default'),
                    contentPadding: EdgeInsets.zero,
                    activeColor: ClayColors.primary,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: selectedType == null
                          ? null
                          : () async {
                              Navigator.pop(ctx);
                              final ok = await ref
                                  .read(paymentProvider.notifier)
                                  .addPaymentMethod(
                                    type: selectedType!,
                                    setAsDefault: setAsDefault,
                                  );
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(ok
                                        ? 'Metode pembayaran berhasil ditambahkan'
                                        : ref.read(paymentProvider).actionError ?? 'Gagal'),
                                    backgroundColor: ok ? Colors.green : Colors.red,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ClayColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Tambahkan', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(String methodId, String label) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Metode Pembayaran?'),
        content: Text('Hapus "$label" dari daftar metode pembayaran?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok == true) {
      final success = await ref.read(paymentProvider.notifier).deletePaymentMethod(methodId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? '$label dihapus' : ref.read(paymentProvider).actionError ?? 'Gagal'),
            backgroundColor: success ? null : Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentProvider);

    return Scaffold(
      backgroundColor: ClayColors.background,
      appBar: AppBar(
        title: const Text('Metode Pembayaran'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Tambah metode',
            onPressed: state.isActionLoading ? null : _showAddDialog,
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(paymentProvider.notifier).reloadPaymentMethods(),
              color: ClayColors.primary,
              child: state.paymentMethods.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.credit_card_off_outlined,
                                    size: 64,
                                    color: Colors.grey.withValues(alpha: 0.4)),
                                const SizedBox(height: 12),
                                const Text('Belum ada metode pembayaran',
                                    style: TextStyle(color: ClayColors.textSecondary)),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: _showAddDialog,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Tambah Sekarang'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: ClayColors.primary,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.paymentMethods.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final method = state.paymentMethods[i];
                        final methodId = method['method_id']?.toString() ?? '';
                        final type = method['type']?.toString() ?? '';
                        final displayName = method['display_name']?.toString() ?? _methodLabel(type);
                        final isDefault = method['is_default'] as bool? ?? false;
                        final lastFour = method['last_four']?.toString();

                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(
                              color: isDefault ? ClayColors.primary : ClayColors.border,
                              width: isDefault ? 2 : 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: _methodColor(type).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(_methodIcon(type),
                                      color: _methodColor(type), size: 24),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            displayName,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600, fontSize: 14),
                                          ),
                                          if (isDefault) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: ClayColors.primary.withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: const Text(
                                                'Default',
                                                style: TextStyle(
                                                    color: ClayColors.primaryDark,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      if (lastFour != null) ...[
                                        const SizedBox(height: 2),
                                        Text('•••• $lastFour',
                                            style: const TextStyle(
                                                color: ClayColors.textSecondary, fontSize: 12)),
                                      ],
                                    ],
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert, color: ClayColors.textSecondary),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  onSelected: (val) async {
                                    if (val == 'default') {
                                      await ref
                                          .read(paymentProvider.notifier)
                                          .setDefaultPaymentMethod(methodId);
                                    } else if (val == 'delete') {
                                      await _confirmDelete(methodId, displayName);
                                    }
                                  },
                                  itemBuilder: (_) => [
                                    if (!isDefault)
                                      const PopupMenuItem(
                                        value: 'default',
                                        child: Row(children: [
                                          Icon(Icons.star_outline, size: 18),
                                          SizedBox(width: 8),
                                          Text('Set Default'),
                                        ]),
                                      ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(children: [
                                        Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Hapus', style: TextStyle(color: Colors.red)),
                                      ]),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: state.paymentMethods.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: state.isActionLoading ? null : _showAddDialog,
              backgroundColor: ClayColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Tambah', style: TextStyle(color: Colors.white)),
            )
          : null,
    );
  }
}
