import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clay_ui/clay_ui.dart';
import '../providers/address_provider.dart';
import 'address_form_sheet.dart';

class AddressListScreen extends ConsumerWidget {
  const AddressListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alamat Tersimpan'),
        actions: [
          if (state.addresses.isNotEmpty)
            IconButton(
              tooltip: 'Refresh',
              icon: const Icon(Icons.refresh_outlined),
              onPressed: state.isLoading ? null : () => ref.read(addressProvider.notifier).load(),
            ),
        ],
      ),
      body: _buildBody(context, ref, state),
      floatingActionButton: state.error != null
          ? null
          : FloatingActionButton.extended(
              backgroundColor: ClayColors.primary,
              foregroundColor: Colors.white,
              onPressed: () => _openForm(context),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Alamat'),
            ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, AddressState state) {
    if (state.isLoading && state.addresses.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null && state.addresses.isEmpty) {
      return _ErrorRetry(message: state.error!, onRetry: () => ref.read(addressProvider.notifier).load());
    }
    if (state.addresses.isEmpty) {
      return const _EmptyState();
    }
    return RefreshIndicator(
      onRefresh: () => ref.read(addressProvider.notifier).load(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        itemCount: state.addresses.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (ctx, i) => _AddressCard(
          address: state.addresses[i],
          onEdit: () => _openForm(context, existing: state.addresses[i]),
          onDelete: () => _confirmDelete(context, ref, state.addresses[i]),
          onSetDefault: () => _setDefault(context, ref, state.addresses[i]),
        ),
      ),
    );
  }

  Future<void> _openForm(BuildContext context, {Address? existing}) async {
    final ok = await AddressFormSheet.show(context, existing: existing);
    if (!context.mounted) return;
    if (ok == true) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(existing == null ? 'Alamat berhasil ditambahkan' : 'Alamat berhasil diperbarui'),
          backgroundColor: Colors.green,
        ));
    } else if (ok == false) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('Gagal menyimpan alamat'),
          backgroundColor: Colors.red,
        ));
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Address addr) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus alamat?'),
        content: Text('"${addr.label}" akan dihapus dari daftar.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: ClayColors.error, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;
    final ok = await ref.read(addressProvider.notifier).remove(addr.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(ok ? 'Alamat dihapus' : 'Gagal menghapus alamat'),
        backgroundColor: ok ? Colors.green : ClayColors.error,
      ));
  }

  Future<void> _setDefault(BuildContext context, WidgetRef ref, Address addr) async {
    final ok = await ref.read(addressProvider.notifier).setDefault(addr.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(ok ? '"${addr.label}" jadi alamat utama' : 'Gagal mengubah alamat utama'),
        backgroundColor: ok ? Colors.green : ClayColors.error,
      ));
  }
}

class _AddressCard extends StatelessWidget {
  final Address address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  const _AddressCard({
    required this.address,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });

  IconData get _icon {
    switch (address.label.toLowerCase()) {
      case 'rumah':
      case 'home':
        return Icons.home_outlined;
      case 'kantor':
      case 'office':
      case 'work':
        return Icons.business_outlined;
      default:
        return Icons.place_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(address.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: ClayColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: address.isDefault ? ClayColors.primary : ClayColors.divider),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (address.isDefault ? ClayColors.primary : Colors.grey).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_icon, color: address.isDefault ? ClayColors.primary : Colors.grey.shade700),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          address.label,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (address.isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: ClayColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'Utama',
                            style: TextStyle(fontSize: 10, color: ClayColors.primary, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(address.address, style: const TextStyle(fontSize: 13, color: ClayColors.textSecondary)),
                  if (address.notes.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(address.notes, style: const TextStyle(fontSize: 11, color: ClayColors.textSecondary)),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _TextButton(icon: Icons.edit_outlined, label: 'Edit', onTap: onEdit),
                      const SizedBox(width: 4),
                      if (!address.isDefault)
                        _TextButton(icon: Icons.star_outline, label: 'Jadikan utama', onTap: onSetDefault),
                      const Spacer(),
                      _TextButton(icon: Icons.delete_outline, label: 'Hapus', onTap: onDelete, danger: true),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;
  const _TextButton({required this.icon, required this.label, required this.onTap, this.danger = false});

  @override
  Widget build(BuildContext context) {
    final color = danger ? ClayColors.error : ClayColors.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ClayColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.location_on_outlined, size: 56, color: ClayColors.primary),
            ),
            const SizedBox(height: 16),
            const Text('Belum ada alamat tersimpan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            const Text(
              'Tambahkan alamat agar checkout lebih cepat',
              textAlign: TextAlign.center,
              style: TextStyle(color: ClayColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorRetry({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: ClayColors.error),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Coba Lagi')),
          ],
        ),
      ),
    );
  }
}
