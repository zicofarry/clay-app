import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clay_ui/clay_ui.dart';
import '../providers/address_provider.dart';

class AddressFormSheet extends ConsumerStatefulWidget {
  final Address? existing;
  const AddressFormSheet({super.key, this.existing});

  static Future<bool?> show(BuildContext context, {Address? existing}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddressFormSheet(existing: existing),
    );
  }

  @override
  ConsumerState<AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends ConsumerState<AddressFormSheet> {
  late final TextEditingController _labelCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _notesCtrl;
  late bool _isDefault;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _labelCtrl = TextEditingController(text: e?.label ?? '');
    _addressCtrl = TextEditingController(text: e?.address ?? '');
    _notesCtrl = TextEditingController(text: e?.notes ?? '');
    _isDefault = e?.isDefault ?? false;
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  bool get _isValid => _labelCtrl.text.trim().isNotEmpty && _addressCtrl.text.trim().isNotEmpty;

  Future<void> _save() async {
    if (!_isValid || _saving) return;
    setState(() => _saving = true);
    final notifier = ref.read(addressProvider.notifier);
    final lat = widget.existing?.lat ?? -6.2088;
    final lng = widget.existing?.lng ?? 106.8456;

    final bool ok;
    if (widget.existing == null) {
      ok = await notifier.create(
        label: _labelCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        lat: lat,
        lng: lng,
        notes: _notesCtrl.text.trim(),
        isDefault: _isDefault,
      );
    } else {
      ok = await notifier.update(
        id: widget.existing!.id,
        label: _labelCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        lat: lat,
        lng: lng,
        notes: _notesCtrl.text.trim(),
        isDefault: _isDefault,
      );
    }
    if (!mounted) return;
    Navigator.of(context).pop(ok);
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.existing != null;
    final mq = MediaQuery.of(context);

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: 16 + mq.viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: ClayColors.divider, borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 16),
            Text(
              editing ? 'Edit Alamat' : 'Tambah Alamat Baru',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _labelCtrl,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Nama Alamat',
                hintText: 'Contoh: Rumah, Kantor',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _addressCtrl,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Alamat Lengkap',
                hintText: 'Jalan, nomor, RT/RW, kelurahan',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on_outlined),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesCtrl,
              minLines: 1,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Catatan (opsional)',
                hintText: 'Patokan, kode pos, instruksi kurir',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes_outlined),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _isDefault,
              onChanged: (v) => setState(() => _isDefault = v),
              title: const Text('Jadikan alamat utama'),
              subtitle: const Text('Dipakai otomatis saat checkout', style: TextStyle(fontSize: 12)),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ClayColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isValid && !_saving ? _save : null,
                child: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(editing ? 'Simpan Perubahan' : 'Tambah Alamat'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
