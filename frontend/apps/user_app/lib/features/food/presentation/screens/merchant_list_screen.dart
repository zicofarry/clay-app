import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import '../providers/food_provider.dart';
import 'package:user_app/features/location/presentation/providers/address_provider.dart';

class MerchantListScreen extends ConsumerStatefulWidget {
  const MerchantListScreen({super.key});

  @override
  ConsumerState<MerchantListScreen> createState() => _MerchantListScreenState();
}

class _MerchantListScreenState extends ConsumerState<MerchantListScreen> {
  String _selectedCategory = 'Semua';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(foodStateProvider.notifier).loadMerchants());
  }

  void _showAddressPickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final addressState = ref.watch(addressProvider);
            final foodState = ref.watch(foodStateProvider);
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pilih Alamat Pengiriman',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ClayColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (addressState.addresses.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'Belum ada alamat tersimpan di profil Anda.',
                            style: TextStyle(color: ClayColors.textSecondary),
                          ),
                        ),
                      )
                    else
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: addressState.addresses.length,
                          itemBuilder: (context, index) {
                            final addr = addressState.addresses[index];
                            final isSelected = foodState.selectedAddress == addr.address;
                            return ListTile(
                              leading: Icon(
                                addr.isDefault ? Icons.home : Icons.location_on,
                                color: isSelected ? ClayColors.primary : ClayColors.textSecondary,
                              ),
                              title: Text(
                                addr.label,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : Alignment.centerLeft == null ? FontWeight.normal : FontWeight.normal,
                                  color: ClayColors.textPrimary,
                                ),
                              ),
                              subtitle: Text(
                                addr.address,
                                style: const TextStyle(fontSize: 12, color: ClayColors.textSecondary),
                              ),
                              trailing: isSelected
                                  ? const Icon(Icons.check_circle, color: ClayColors.primary)
                                  : null,
                              onTap: () {
                                ref.read(foodStateProvider.notifier).setSelectedAddress(
                                  addr.address,
                                  addr.label,
                                );
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final addressState = ref.watch(addressProvider);
    final state = ref.watch(foodStateProvider);
    final notifier = ref.read(foodStateProvider.notifier);

    // Auto-initialize selectedAddress from profile if empty
    if (state.selectedAddress == null && addressState.addresses.isNotEmpty) {
      final defaultAddr = addressState.addresses.firstWhere(
        (a) => a.isDefault,
        orElse: () => addressState.addresses.first,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifier.setSelectedAddress(
          defaultAddr.address,
          defaultAddr.label,
        );
      });
    }

    // Apply filters
    final filteredMerchants = state.merchants.where((m) {
      if (_searchQuery.isNotEmpty) {
        final name = m['name']?.toString().toLowerCase() ?? '';
        final cat = m['category']?.toString().toLowerCase() ?? '';
        final q = _searchQuery.toLowerCase();
        if (!name.contains(q) && !cat.contains(q)) {
          return false;
        }
      }

      if (_selectedCategory == 'Semua') return true;
      if (_selectedCategory == 'Promo') {
        return m['promo'] != null && m['promo'].toString().isNotEmpty;
      }
      if (_selectedCategory == 'Terdekat') {
        final distStr = m['distance']?.toString() ?? '';
        final val = double.tryParse(distStr.split(' ')[0]) ?? 999.0;
        return val <= 1.5;
      }
      if (_selectedCategory == 'Terlaris') {
        final rating = double.tryParse(m['rating']?.toString() ?? '') ?? 0.0;
        return rating >= 4.7;
      }

      final category = m['category']?.toString().toLowerCase() ?? '';
      return category == _selectedCategory.toLowerCase();
    }).toList();

    return Scaffold(
      backgroundColor: ClayColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 72,
        title: InkWell(
          onTap: _showAddressPickerSheet,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ClayColors.accent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.location_on, color: ClayColors.accent, size: 20),
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
                              state.selectedAddressLabel ?? 'Kantor Clay',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: ClayColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.keyboard_arrow_down, color: ClayColors.primary, size: 16),
                        ],
                      ),
                      Text(
                        state.selectedAddress ?? 'Jl. Sudirman No. 1, Jakarta',
                        style: const TextStyle(
                          fontSize: 12,
                          color: ClayColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(foodStateProvider.notifier).loadMerchants(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Modern Search Box
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val;
                            });
                          },
                          style: const TextStyle(fontSize: 14, color: ClayColors.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Mau makan apa hari ini?',
                            hintStyle: const TextStyle(color: ClayColors.textSecondary, fontSize: 14),
                            prefixIcon: const Icon(Icons.search, color: ClayColors.textSecondary),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      setState(() {
                                        _searchQuery = '';
                                      });
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ),

                    // Quick Categories (Modern GoFood Grid / Capsules)
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 95,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          _buildCategoryItem(Icons.restaurant_menu, 'Semua', ClayColors.primary),
                          _buildCategoryItem(Icons.star, 'Terlaris', Colors.amber),
                          _buildCategoryItem(Icons.percent, 'Promo', ClayColors.accent),
                          _buildCategoryItem(Icons.restaurant, 'Terdekat', Colors.orange),
                          _buildCategoryItem(Icons.coffee, 'Minuman', Colors.brown),
                          _buildCategoryItem(Icons.fastfood, 'Makanan', Colors.teal),
                        ],
                      ),
                    ),

                    // Beautiful Banner Promo with rounded gradient and 3D feel
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Container(
                        height: 140,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE94E1B), Color(0xFFF17B21)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE94E1B).withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              right: -10,
                              bottom: -20,
                              child: Opacity(
                                opacity: 0.12,
                                child: Icon(Icons.fastfood_outlined, size: 160, color: Colors.white),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'DISKON GILA-GILAAN',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Pesan Gofood Hemat s.d. 50%',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Khusus pembayaran menggunakan ClayPay Wallet',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Restaurant list title
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedCategory == 'Semua' ? 'Rekomendasi Restoran' : 'Kategori: $_selectedCategory',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: ClayColors.textPrimary,
                            ),
                          ),
                          if (_selectedCategory != 'Semua' || _searchQuery.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCategory = 'Semua';
                                  _searchQuery = '';
                                });
                              },
                              child: const Text(
                                'Reset Filter',
                                style: TextStyle(
                                  color: ClayColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Modern floating Cards List
                    filteredMerchants.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(40),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.search_off, size: 60, color: ClayColors.textSecondary.withOpacity(0.4)),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Tidak menemukan merchant yang cocok',
                                    style: TextStyle(color: ClayColors.textSecondary, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filteredMerchants.length,
                            itemBuilder: (context, index) {
                              final m = filteredMerchants[index];
                              final hasImage = m['image'] != null && m['image'].toString().isNotEmpty;

                              return GestureDetector(
                                onTap: () {
                                  notifier.selectMerchant(m['id'], m['name']);
                                  context.push('/food/menu/${m['id']}', extra: m['name']);
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Image with top rounded corners
                                      Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(24),
                                              topRight: Radius.circular(24),
                                            ),
                                            child: Container(
                                              height: 150,
                                              width: double.infinity,
                                              color: ClayColors.muted,
                                              child: hasImage
                                                  ? Image.network(
                                                      m['image'],
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) => const Center(
                                                        child: Icon(Icons.restaurant, size: 40, color: ClayColors.textSecondary),
                                                      ),
                                                    )
                                                  : const Center(
                                                      child: Icon(Icons.restaurant, size: 40, color: ClayColors.textSecondary),
                                                    ),
                                            ),
                                          ),
                                          // Discount / Promo Badge
                                          if (m['promo'] != null && m['promo'].toString().isNotEmpty)
                                            Positioned(
                                              left: 12,
                                              top: 12,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: ClayColors.accent,
                                                  borderRadius: BorderRadius.circular(12),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: ClayColors.accent.withOpacity(0.3),
                                                      blurRadius: 8,
                                                      offset: const Offset(0, 4),
                                                    ),
                                                  ],
                                                ),
                                                child: Text(
                                                  m['promo'].toString(),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),

                                      // Details block
                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    m['name'],
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                      color: ClayColors.textPrimary,
                                                    ),
                                                  ),
                                                ),
                                                // Verified Partner Badge
                                                const Icon(Icons.verified, color: Colors.blue, size: 18),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              m['category'] ?? 'Makanan',
                                              style: const TextStyle(
                                                color: ClayColors.textSecondary,
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                const Icon(Icons.star, color: Colors.amber, size: 16),
                                                const SizedBox(width: 4),
                                                Text(
                                                  m['rating'].toString(),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                const Icon(Icons.schedule, color: ClayColors.textSecondary, size: 16),
                                                const SizedBox(width: 4),
                                                Text(
                                                  m['eta'] ?? '20 min',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: ClayColors.textSecondary,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                const Icon(Icons.location_on_outlined, color: ClayColors.textSecondary, size: 16),
                                                const SizedBox(width: 4),
                                                Text(
                                                  m['distance'],
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: ClayColors.textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCategoryItem(IconData icon, String title, Color color) {
    final isSelected = _selectedCategory == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedCategory = 'Semua';
          } else {
            _selectedCategory = title;
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: isSelected ? color : color.withOpacity(0.08),
                shape: BoxShape.circle,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? ClayColors.primary : ClayColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
