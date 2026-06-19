import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clay_ui/clay_ui.dart';
import '../../data/menu_repository.dart';
import '../providers/menu_provider.dart';

class AddEditMenuItemScreen extends ConsumerStatefulWidget {
  final MenuItem? item;
  const AddEditMenuItemScreen({super.key, this.item});

  @override
  ConsumerState<AddEditMenuItemScreen> createState() => _AddEditMenuItemScreenState();
}

class _AddEditMenuItemScreenState extends ConsumerState<AddEditMenuItemScreen> {
  late TextEditingController _nameC;
  late TextEditingController _categoryC;
  late TextEditingController _priceC;
  late TextEditingController _descC;
  late TextEditingController _imageC;
  late TextEditingController _tagsC;

  final _formKey = GlobalKey<FormState>();

  List<MenuVariant> _variants = [];
  List<MenuAddOn> _addOns = [];

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nameC = TextEditingController(text: item?.name ?? '');
    _categoryC = TextEditingController(text: item?.category ?? '');
    _priceC = TextEditingController(text: item?.price.toString() ?? '');
    _descC = TextEditingController(text: item?.description ?? '');
    _imageC = TextEditingController(text: item?.imageUrl ?? '');
    _tagsC = TextEditingController(text: item?.tags.join(', ') ?? '');

    if (item != null) {
      _variants = List.from(item.variants);
      _addOns = List.from(item.addOns);
    }
  }

  @override
  void dispose() {
    _nameC.dispose();
    _categoryC.dispose();
    _priceC.dispose();
    _descC.dispose();
    _imageC.dispose();
    _tagsC.dispose();
    super.dispose();
  }

  void _saveItem() {
    if (_formKey.currentState?.validate() ?? false) {
      final tags = _tagsC.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      final newItem = MenuItem(
        id: widget.item?.id ?? '', // Handled by repository if new
        name: _nameC.text.trim(),
        category: _categoryC.text.trim(),
        price: int.tryParse(_priceC.text) ?? 0,
        available: widget.item?.available ?? true,
        description: _descC.text.trim().isEmpty ? null : _descC.text.trim(),
        imageUrl: _imageC.text.trim().isEmpty ? null : _imageC.text.trim(),
        variants: _variants,
        addOns: _addOns,
        tags: tags,
      );

      if (widget.item != null) {
        ref.read(menuProvider.notifier).updateItem(newItem);
      } else {
        ref.read(menuProvider.notifier).addItem(newItem);
      }
      Navigator.pop(context);
    }
  }

  void _showAddVariantDialog() {
    final nameC = TextEditingController();
    bool isRequired = false;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Tambah Varian'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameC,
                decoration: const InputDecoration(labelText: 'Nama Varian (contoh: Ukuran)'),
              ),
              CheckboxListTile(
                title: const Text('Wajib dipilih'),
                value: isRequired,
                onChanged: (v) => setState(() => isRequired = v ?? false),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                if (nameC.text.trim().isNotEmpty) {
                  this.setState(() {
                    _variants.add(MenuVariant(
                      id: 'var-${DateTime.now().millisecondsSinceEpoch}',
                      name: nameC.text.trim(),
                      isRequired: isRequired,
                      options: [],
                    ));
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Tambah'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddOptionDialog(int variantIndex) {
    final nameC = TextEditingController();
    final priceC = TextEditingController(text: '0');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Opsi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameC,
              decoration: const InputDecoration(labelText: 'Nama Opsi (contoh: Besar)'),
            ),
            TextField(
              controller: priceC,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Harga Tambahan (Rp)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              if (nameC.text.trim().isNotEmpty) {
                setState(() {
                  _variants[variantIndex].options.add(VariantOption(
                    id: 'opt-${DateTime.now().millisecondsSinceEpoch}',
                    name: nameC.text.trim(),
                    extraPrice: int.tryParse(priceC.text) ?? 0,
                  ));
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  void _showAddAddOnDialog() {
    final nameC = TextEditingController();
    final priceC = TextEditingController(text: '0');
    final maxC = TextEditingController(text: '1');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Add-On'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameC,
              decoration: const InputDecoration(labelText: 'Nama Add-On (contoh: Ekstra Keju)'),
            ),
            TextField(
              controller: priceC,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Harga (Rp)'),
            ),
            TextField(
              controller: maxC,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Maksimal Qty'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              if (nameC.text.trim().isNotEmpty) {
                setState(() {
                  _addOns.add(MenuAddOn(
                    id: 'ao-${DateTime.now().millisecondsSinceEpoch}',
                    name: nameC.text.trim(),
                    price: int.tryParse(priceC.text) ?? 0,
                    maxQty: int.tryParse(maxC.text) ?? 1,
                  ));
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.item != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Menu' : 'Tambah Menu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveItem,
            tooltip: 'Simpan',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Informasi Dasar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ClayTextField(
              label: 'Nama Menu',
              controller: _nameC,
              validator: (val) => val == null || val.trim().isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            ClayTextField(
              label: 'Kategori',
              controller: _categoryC,
              validator: (val) => val == null || val.trim().isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            ClayTextField(
              label: 'Harga Dasar (Rp)',
              controller: _priceC,
              keyboardType: TextInputType.number,
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Wajib diisi';
                if ((int.tryParse(val) ?? -1) < 0) return 'Tidak valid';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descC,
              decoration: const InputDecoration(labelText: 'Deskripsi'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ClayTextField(
              label: 'URL Gambar',
              controller: _imageC,
            ),
            const SizedBox(height: 16),
            ClayTextField(
              label: 'Tags (pisahkan dengan koma)',
              controller: _tagsC,
            ),

            const Divider(height: 40),
            
            // Variants Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Varian', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(onPressed: _showAddVariantDialog, child: const Text('Tambah')),
              ],
            ),
            if (_variants.isEmpty) const Text('Tidak ada varian', style: TextStyle(color: Colors.grey)),
            ..._variants.asMap().entries.map((entry) {
              final idx = entry.key;
              final variant = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${variant.name} ${variant.isRequired ? "(Wajib)" : "(Opsional)"}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                            onPressed: () {
                              setState(() => _variants.removeAt(idx));
                            },
                          )
                        ],
                      ),
                      ...variant.options.asMap().entries.map((optEntry) {
                        final optIdx = optEntry.key;
                        final opt = optEntry.value;
                        return ListTile(
                          dense: true,
                          title: Text(opt.name),
                          subtitle: Text('+ Rp ${opt.extraPrice}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.close, size: 16),
                            onPressed: () {
                              setState(() => _variants[idx].options.removeAt(optIdx));
                            },
                          ),
                        );
                      }),
                      TextButton(
                        onPressed: () => _showAddOptionDialog(idx),
                        child: const Text('+ Tambah Opsi'),
                      )
                    ],
                  ),
                ),
              );
            }),

            const Divider(height: 40),

            // Add-ons Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Add-Ons', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(onPressed: _showAddAddOnDialog, child: const Text('Tambah')),
              ],
            ),
            if (_addOns.isEmpty) const Text('Tidak ada add-on', style: TextStyle(color: Colors.grey)),
            ..._addOns.asMap().entries.map((entry) {
              final idx = entry.key;
              final addOn = entry.value;
              return ListTile(
                title: Text(addOn.name),
                subtitle: Text('+ Rp ${addOn.price} (Maks: ${addOn.maxQty})'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() => _addOns.removeAt(idx));
                  },
                ),
              );
            }),

            const SizedBox(height: 40),
            ClayButton(
              label: isEdit ? 'Simpan Perubahan' : 'Tambah Menu',
              onPressed: _saveItem,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
