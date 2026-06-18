import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clay_ui/clay_ui.dart';
import '../../data/menu_repository.dart';
import '../providers/menu_provider.dart';

class MenuListScreen extends ConsumerStatefulWidget {
  const MenuListScreen({super.key});

  @override
  ConsumerState<MenuListScreen> createState() => _MenuListScreenState();
}

class _MenuListScreenState extends ConsumerState<MenuListScreen> {
  String _selectedCategory = 'Semua';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(menuProvider.notifier).loadMenu());
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showForm([MenuItem? item]) {
    final nameC = TextEditingController(text: item?.name ?? '');
    final priceC = TextEditingController(text: item?.price.toString() ?? '');
    final categoryC = TextEditingController(text: item?.category ?? '');
    final formKey = GlobalKey<FormState>();
    final isEdit = item != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(sheetCtx).viewInsets.bottom + 16),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isEdit ? 'Edit Menu' : 'Tambah Menu', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  ClayTextField(
                    label: 'Nama Menu',
                    controller: nameC,
                    validator: (val) => val == null || val.trim().isEmpty ? 'Nama menu tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 16),
                  ClayTextField(
                    label: 'Kategori',
                    controller: categoryC,
                    validator: (val) => val == null || val.trim().isEmpty ? 'Kategori tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 16),
                  ClayTextField(
                    label: 'Harga',
                    controller: priceC,
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Harga tidak boleh kosong';
                      }
                      final price = int.tryParse(val.trim());
                      if (price == null || price <= 0) {
                        return 'Harga harus berupa angka positif';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ClayButton(label: isEdit ? 'Simpan' : 'Tambah', onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      final newItem = MenuItem(
                        id: item?.id ?? 'M-${DateTime.now().millisecondsSinceEpoch}',
                        name: nameC.text.trim(),
                        category: categoryC.text.trim(),
                        price: int.tryParse(priceC.text) ?? 0,
                        available: item?.available ?? true,
                      );
                      if (isEdit) {
                        ref.read(menuProvider.notifier).updateItem(newItem);
                      } else {
                        ref.read(menuProvider.notifier).addItem(newItem);
                      }
                      Navigator.pop(context);
                    }
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<MenuState>(
      menuProvider,
      (previous, next) {
        if (next.error != null && next.error != previous?.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.error!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );

    final state = ref.watch(menuProvider);

    // Dapatkan list unik kategori
    final categories = ['Semua', ...state.items.map((i) => i.category).toSet()];

    // Filter menu berdasarkan kategori terpilih
    final filtered = state.items.where((item) {
      return _selectedCategory == 'Semua' || item.category == _selectedCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Menu')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(),
      ),
      body: SafeArea(
        child: Column(
          children: [

            if (state.items.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedCategory = cat);
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                      ? Center(
                          child: Text(
                            state.items.isEmpty
                                ? 'Belum ada menu'
                                : 'Menu tidak ditemukan',
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) {
                            final item = filtered[i];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: item.available
                                      ? Colors.green.withValues(alpha: 0.1)
                                      : Colors.grey.withValues(alpha: 0.1),
                                  child: Icon(
                                    item.available ? Icons.restaurant : Icons.restaurant,
                                    color: item.available ? Colors.green : Colors.grey,
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.name,
                                        style: item.available
                                            ? null
                                            : const TextStyle(
                                                color: Colors.grey,
                                                decoration: TextDecoration.lineThrough,
                                              ),
                                      ),
                                    ),
                                    if (!item.available)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'HABIS',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                subtitle: Text('${item.category} • Rp ${item.price}'),
                                trailing: PopupMenuButton(
                                  itemBuilder: (_) => [
                                    PopupMenuItem(value: 'edit', child: const Text('Edit')),
                                    PopupMenuItem(
                                      value: 'toggle',
                                      child: Text(item.available ? 'Tandai Stok Habis' : 'Tandai Stok Tersedia'),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                  onSelected: (v) {
                                    switch (v) {
                                      case 'edit':
                                        _showForm(item);
                                      case 'toggle':
                                        ref.read(menuProvider.notifier).toggleAvailability(item.id);
                                      case 'delete':
                                        ref.read(menuProvider.notifier).deleteItem(item.id);
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
