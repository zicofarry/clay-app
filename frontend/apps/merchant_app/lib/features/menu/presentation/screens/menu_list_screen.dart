import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clay_ui/clay_ui.dart';
import '../../data/mock_menu_repository.dart';
import '../providers/menu_provider.dart';

class MenuListScreen extends ConsumerStatefulWidget {
  const MenuListScreen({super.key});

  @override
  ConsumerState<MenuListScreen> createState() => _MenuListScreenState();
}

class _MenuListScreenState extends ConsumerState<MenuListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(menuProvider.notifier).loadMenu());
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
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isEdit ? 'Edit Menu' : 'Tambah Menu', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ClayTextField(label: 'Nama Menu', controller: nameC),
              const SizedBox(height: 16),
              ClayTextField(label: 'Kategori', controller: categoryC),
              const SizedBox(height: 16),
              ClayTextField(label: 'Harga', controller: priceC, keyboardType: TextInputType.number),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(menuProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Menu')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.items.isEmpty
              ? const Center(child: Text('Belum ada menu'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.items.length,
                  itemBuilder: (_, i) {
                    final item = state.items[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: item.available ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                          child: Icon(item.available ? Icons.restaurant : Icons.restaurant, color: item.available ? Colors.green : Colors.grey),
                        ),
                        title: Text(item.name, style: item.available ? null : const TextStyle(color: Colors.grey)),
                        subtitle: Text('${item.category} • Rp ${item.price}'),
                        trailing: PopupMenuButton(
                          itemBuilder: (_) => [
                            PopupMenuItem(value: 'edit', child: const Text('Edit')),
                            PopupMenuItem(value: 'toggle', child: Text(item.available ? 'Nonaktifkan' : 'Aktifkan')),
                            PopupMenuItem(value: 'delete', child: const Text('Hapus', style: TextStyle(color: Colors.red))),
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
    );
  }
}
