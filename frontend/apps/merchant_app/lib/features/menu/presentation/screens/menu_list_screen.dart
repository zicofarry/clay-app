import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clay_ui/clay_ui.dart';
import '../../data/menu_repository.dart';
import '../providers/menu_provider.dart';
import 'add_edit_menu_item_screen.dart';

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

  void _showCategoryForm([MenuCategory? category]) {
    final nameC = TextEditingController(text: category?.name ?? '');
    final formKey = GlobalKey<FormState>();
    final isEdit = category != null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? 'Edit Kategori' : 'Tambah Kategori'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: nameC,
            decoration: const InputDecoration(labelText: 'Nama Kategori'),
            validator: (val) => val == null || val.trim().isEmpty ? 'Nama kategori tidak boleh kosong' : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                if (isEdit) {
                  ref.read(menuProvider.notifier).updateCategory(category.id, nameC.text.trim(), category.displayOrder);
                }
                Navigator.pop(ctx);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showManageCategoriesSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Consumer(
              builder: (context, ref, child) {
                final state = ref.watch(menuProvider);
                final categories = state.categories;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Kelola Kategori', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: categories.isEmpty
                          ? const Center(child: Text('Belum ada kategori'))
                          : ReorderableListView.builder(
                              scrollController: scrollController,
                              itemCount: categories.length,
                              onReorder: (oldIndex, newIndex) {
                                if (oldIndex < newIndex) {
                                  newIndex -= 1;
                                }
                                final item = categories.removeAt(oldIndex);
                                categories.insert(newIndex, item);
                                final categoryIds = categories.map((c) => c.id).toList();
                                ref.read(menuProvider.notifier).reorderCategories(categoryIds);
                              },
                              itemBuilder: (context, index) {
                                final cat = categories[index];
                                return ListTile(
                                  key: ValueKey(cat.id),
                                  title: Text(cat.name),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, size: 20),
                                        onPressed: () {
                                          _showCategoryForm(cat);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                        onPressed: () {
                                          _confirmDeleteCategory(cat);
                                        },
                                      ),
                                      const Icon(Icons.drag_handle, color: Colors.grey),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _navigateToAddEditScreen([MenuItem? item]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditMenuItemScreen(item: item),
      ),
    );
  }

  void _confirmDeleteCategory(MenuCategory category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Kategori?'),
        content: Text('Apakah Anda yakin ingin menghapus kategori "${category.name}"? Menu di dalamnya mungkin akan kehilangan kategori.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              ref.read(menuProvider.notifier).deleteCategory(category.id);
              Navigator.pop(ctx);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
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

    // Dapatkan list unik kategori dari state.categories
    final categoryNames = ['Semua', ...state.categories.map((c) => c.name)];
    // Jika ada item yang tidak punya kategori (Lainnya) dan belum ada di list, tambahkan
    if (state.items.any((i) => i.category == 'Lainnya') && !categoryNames.contains('Lainnya')) {
      categoryNames.add('Lainnya');
    }
    final categories = categoryNames;

    // Filter menu berdasarkan kategori terpilih
    final filtered = state.items.where((item) {
      return _selectedCategory == 'Semua' || item.category == _selectedCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.category),
            tooltip: 'Kelola Kategori',
            onPressed: _showManageCategoriesSheet,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _navigateToAddEditScreen(),
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
                                        _navigateToAddEditScreen(item);
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
