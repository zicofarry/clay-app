import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import '../providers/food_provider.dart';

class MenuScreen extends ConsumerStatefulWidget {
  final String merchantId;
  const MenuScreen({super.key, required this.merchantId});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  String _selectedCategory = 'Semua';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(foodStateProvider.notifier).loadMenuItems(widget.merchantId);
    });
  }

  void _showFoodDetailBottomSheet(
    BuildContext context,
    Map<String, dynamic> item,
    FoodNotifier notifier,
    int currentQty,
  ) {
    final hasImage = item['image'] != null && item['image'].toString().isNotEmpty;
    final basePrice = item['price'] as int;

    // Local states inside the bottom sheet
    int localQty = currentQty > 0 ? currentQty : 1;
    String selectedSpicy = 'Sedang';
    final selectedToppings = <String, int>{
      'Ekstra Telur': 0,
      'Ekstra Keju': 0,
    };
    final notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            int extraPrice = 0;
            if (selectedSpicy == 'Sangat Pedas') extraPrice += 2000;
            extraPrice += selectedToppings['Ekstra Telur']! * 5000;
            extraPrice += selectedToppings['Ekstra Keju']! * 4000;

            final itemTotalPrice = (basePrice + extraPrice) * localQty;

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag indicator & Close Button
                  Stack(
                    children: [
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 10),
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: ClayColors.divider,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 16,
                        top: 4,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: ClayColors.textPrimary),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),

                  // Main Scrollable Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Food Image Header
                          if (hasImage) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                item['image'],
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Name & Price
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  item['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: ClayColors.textPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Rp $basePrice',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: ClayColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Description
                          if (item['desc'] != null && item['desc'].toString().isNotEmpty) ...[
                            Text(
                              item['desc'],
                              style: const TextStyle(
                                color: ClayColors.textSecondary,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          const Divider(color: ClayColors.divider),

                          // Option 1: Level Pedas (Radio list)
                          const SizedBox(height: 12),
                          const Text(
                            'Pilihan Level Pedas',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: ClayColors.textPrimary,
                            ),
                          ),
                          const Text(
                            'Pilih salah satu',
                            style: TextStyle(color: ClayColors.textSecondary, fontSize: 11),
                          ),
                          const SizedBox(height: 8),
                          _buildRadioRow(
                            'Tidak Pedas',
                            'Gratis',
                            selectedSpicy == 'Tidak Pedas',
                            () => setModalState(() => selectedSpicy = 'Tidak Pedas'),
                          ),
                          _buildRadioRow(
                            'Sedang',
                            'Gratis',
                            selectedSpicy == 'Sedang',
                            () => setModalState(() => selectedSpicy = 'Sedang'),
                          ),
                          _buildRadioRow(
                            'Sangat Pedas',
                            '+ Rp 2.000',
                            selectedSpicy == 'Sangat Pedas',
                            () => setModalState(() => selectedSpicy = 'Sangat Pedas'),
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: ClayColors.divider),

                          // Option 2: Topping Tambahan (Checkbox list)
                          const SizedBox(height: 12),
                          const Text(
                            'Topping Tambahan',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: ClayColors.textPrimary,
                            ),
                          ),
                          const Text(
                            'Bisa pilih lebih dari satu',
                            style: TextStyle(color: ClayColors.textSecondary, fontSize: 11),
                          ),
                          const SizedBox(height: 8),
                          _buildCheckboxRow(
                            'Ekstra Telur',
                            '+ Rp 5.000',
                            selectedToppings['Ekstra Telur'] == 1,
                            (val) => setModalState(() {
                              selectedToppings['Ekstra Telur'] = val == true ? 1 : 0;
                            }),
                          ),
                          _buildCheckboxRow(
                            'Ekstra Keju',
                            '+ Rp 4.000',
                            selectedToppings['Ekstra Keju'] == 1,
                            (val) => setModalState(() {
                              selectedToppings['Ekstra Keju'] = val == true ? 1 : 0;
                            }),
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: ClayColors.divider),

                          // Option 3: Special Request Field
                          const SizedBox(height: 12),
                          const Text(
                            'Catatan Khusus',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: ClayColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: notesController,
                            style: const TextStyle(fontSize: 13, color: ClayColors.textPrimary),
                            decoration: InputDecoration(
                              hintText: 'Contoh: Pisahkan kuahnya, sambal dipisah...',
                              hintStyle: const TextStyle(color: ClayColors.textSecondary),
                              contentPadding: const EdgeInsets.all(12),
                              filled: true,
                              fillColor: ClayColors.muted,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  // Fixed Bottom Button Area
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: ClayColors.divider.withValues(alpha: 0.8))),
                    ),
                    child: SafeArea(
                      child: Row(
                        children: [
                          // Quantity Counter
                          Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: ClayColors.muted,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: ClayColors.border),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, color: ClayColors.primary, size: 18),
                                  onPressed: () {
                                    if (localQty > 1) {
                                      setModalState(() => localQty--);
                                    }
                                  },
                                ),
                                Text(
                                  '$localQty',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: ClayColors.textPrimary,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add, color: ClayColors.primary, size: 18),
                                  onPressed: () {
                                    setModalState(() => localQty++);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Add to Cart Button
                          Expanded(
                            child: ClayButton(
                              label: 'Tambah • Rp $itemTotalPrice',
                              onPressed: () {
                                notifier.updateCartQuantity(item['id'], localQty);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${item['name']} berhasil ditambahkan ke keranjang'),
                                    backgroundColor: ClayColors.primary,
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildRadioRow(String title, String subtitle, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: ClayColors.textPrimary, fontWeight: FontWeight.w500),
            ),
            Row(
              children: [
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: ClayColors.textSecondary),
                ),
                const SizedBox(width: 8),
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: isSelected ? ClayColors.primary : ClayColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxRow(String title, String subtitle, bool isChecked, ValueChanged<bool?> onChanged) {
    return InkWell(
      onTap: () => onChanged(!isChecked),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: ClayColors.textPrimary, fontWeight: FontWeight.w500),
            ),
            Row(
              children: [
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: ClayColors.textSecondary),
                ),
                const SizedBox(width: 8),
                Icon(
                  isChecked ? Icons.check_box : Icons.check_box_outline_blank,
                  color: isChecked ? ClayColors.primary : ClayColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(foodStateProvider);
    final notifier = ref.read(foodStateProvider.notifier);
    final merchantName = GoRouterState.of(context).extra as String? ?? 'Menu';

    ref.listen(foodStateProvider, (_, state) {
      if (state.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.error!),
            backgroundColor: ClayColors.error,
          ),
        );
      }
    });

    final merchant = state.merchants.firstWhere(
      (m) => m['id'] == widget.merchantId,
      orElse: () => <String, dynamic>{
        'id': widget.merchantId,
        'name': merchantName,
        'rating': 4.5,
        'distance': '1.0 km',
        'category': 'Makanan',
        'eta': '20 min',
      },
    );

    // Extract categories
    final categories = ['Semua'];
    for (final item in state.menuItems) {
      final cat = item['category']?.toString() ?? 'Makanan';
      if (!categories.contains(cat)) {
        categories.add(cat);
      }
    }

    // Filtered menu items
    final filteredItems = _selectedCategory == 'Semua'
        ? state.menuItems
        : state.menuItems.where((i) => i['category'] == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: ClayColors.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          merchant['name'],
          style: const TextStyle(
            color: ClayColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Merchant Quick Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: ClayColors.divider),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  merchant['rating'].toString(),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  merchant['distance'].toString(),
                                  style: const TextStyle(color: ClayColors.textSecondary, fontSize: 13),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              merchant['category'].toString(),
                              style: const TextStyle(color: ClayColors.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: ClayColors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Buka',
                          style: TextStyle(
                            color: ClayColors.greenDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Category Chips
                if (categories.length > 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: SizedBox(
                      height: 36,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final cat = categories[index];
                          final isSelected = cat == _selectedCategory;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(
                                cat,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : ClayColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: ClayColors.primary,
                              backgroundColor: ClayColors.muted,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedCategory = cat;
                                  });
                                }
                              },
                              showCheckmark: false,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSelected ? ClayColors.primary : ClayColors.border,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                const Divider(color: ClayColors.divider, height: 1),

                // Menu Items List
                Expanded(
                  child: filteredItems.isEmpty
                      ? const Center(
                          child: Text(
                            'Tidak ada menu tersedia',
                            style: TextStyle(color: ClayColors.textSecondary),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                          itemCount: filteredItems.length,
                          itemBuilder: (_, i) {
                            final item = filteredItems[i];
                            final qty = state.cart[item['id']] ?? 0;
                            final hasImage = item['image'] != null && item['image'].toString().isNotEmpty;

                            return InkWell(
                              onTap: () => _showFoodDetailBottomSheet(context, item, notifier, qty),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                  border: Border.all(color: ClayColors.divider.withOpacity(0.8)),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Item Text Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['name'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: ClayColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Rp ${item['price']}',
                                            style: const TextStyle(
                                              color: ClayColors.textPrimary,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                            ),
                                          ),
                                          if (item['desc'] != null && item['desc'].toString().isNotEmpty) ...[
                                            const SizedBox(height: 6),
                                            Text(
                                              item['desc'],
                                              style: const TextStyle(
                                                color: ClayColors.textSecondary,
                                                fontSize: 12,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),

                                    // Item Image & Overlapping Add Button Stack
                                    Stack(
                                      clipBehavior: Clip.none,
                                      alignment: Alignment.bottomCenter,
                                      children: [
                                        Container(
                                          width: 88,
                                          height: 88,
                                          decoration: BoxDecoration(
                                            color: ClayColors.muted,
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(16),
                                            child: hasImage
                                                ? Image.network(
                                                    item['image'],
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error, stackTrace) => const Icon(
                                                      Icons.restaurant,
                                                      color: ClayColors.textSecondary,
                                                    ),
                                                  )
                                                : const Icon(
                                                    Icons.restaurant,
                                                    color: ClayColors.textSecondary,
                                                  ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: -12,
                                          child: Container(
                                            height: 30,
                                            width: 80,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.1),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: qty > 0
                                                ? Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(16),
                                                      border: Border.all(color: ClayColors.primary, width: 1.5),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () => notifier.addToCart(item['id'], -1),
                                                          child: const Padding(
                                                            padding: EdgeInsets.symmetric(horizontal: 6),
                                                            child: Icon(Icons.remove, size: 14, color: ClayColors.primary),
                                                          ),
                                                        ),
                                                        Text(
                                                          '$qty',
                                                          style: const TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            color: ClayColors.primary,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () => notifier.addToCart(item['id'], 1),
                                                          child: const Padding(
                                                            padding: EdgeInsets.symmetric(horizontal: 6),
                                                            child: Icon(Icons.add, size: 14, color: ClayColors.primary),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.white,
                                                      foregroundColor: ClayColors.primary,
                                                      surfaceTintColor: Colors.white,
                                                      elevation: 0,
                                                      padding: EdgeInsets.zero,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(16),
                                                        side: const BorderSide(color: ClayColors.primary, width: 1.5),
                                                      ),
                                                    ),
                                                    onPressed: () => notifier.addToCart(item['id'], 1),
                                                    child: const Text(
                                                      '+ TAMBAH',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ),
                                          ),
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
              ],
            ),
      bottomNavigationBar: notifier.totalItems > 0
          ? SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: ClayButton(
                  label: 'Lihat Keranjang (${notifier.totalItems} Item • Rp ${notifier.totalPrice})',
                  onPressed: () => context.push('/food/cart'),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildErrorWidget(BuildContext context, WidgetRef ref, String error, String merchantId) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ClayColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 64,
                color: ClayColors.error,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Gagal Memuat Menu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ClayColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pastikan server backend Anda sudah berjalan atau periksa koneksi internet Anda.\n\nDetail: $error',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: ClayColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 180,
              child: ClayButton(
                label: 'Coba Lagi',
                onPressed: () => ref.read(foodStateProvider.notifier).loadMenuItems(merchantId),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
