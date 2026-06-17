import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_ServiceItem> _filterServices(String query) {
    if (query.isEmpty) return [];
    final q = query.toLowerCase();
    return _allServices.where((s) {
      return s.name.toLowerCase().contains(q) ||
          s.description.toLowerCase().contains(q) ||
          s.keywords.any((k) => k.contains(q));
    }).toList();
  }

  void _onSearchChanged(String value) {
    setState(() => _query = value);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  void _tapPopularSearch(String value) {
    _searchController.text = value;
    setState(() => _query = value);
  }

  @override
  Widget build(BuildContext context) {
    final results = _filterServices(_query);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, size: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Search',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: ClayColors.textPrimary),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: ClayColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: ClayColors.primary, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'Find a service',
                          hintStyle: TextStyle(color: ClayColors.textSecondary, fontSize: 15),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    if (_query.isNotEmpty)
                      GestureDetector(
                        onTap: _clearSearch,
                        child: Icon(Icons.clear, color: ClayColors.textSecondary, size: 20),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_query.isNotEmpty)
                      _buildSearchResults(results)
                    else ...[
                      _buildPromoSection(),
                      const SizedBox(height: 28),
                      _buildPopularSearches(),
                      const SizedBox(height: 28),
                      _buildRecentPlaces(),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(List<_ServiceItem> results) {
    if (results.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Results',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ClayColors.textPrimary),
          ),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                Icon(Icons.search_off, size: 48, color: ClayColors.textSecondary),
                const SizedBox(height: 12),
                Text(
                  'No service found',
                  style: TextStyle(fontSize: 15, color: ClayColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${results.length} service${results.length > 1 ? 's' : ''} found',
          style: TextStyle(fontSize: 14, color: ClayColors.textSecondary),
        ),
        const SizedBox(height: 16),
        ...results.map((s) => _ServiceResultCard(item: s)),
      ],
    );
  }

  Widget _buildPromoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Promo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ClayColors.textPrimary),
            ),
            GestureDetector(
              onTap: () {},
              child: const Text(
                'See all',
                style: TextStyle(fontSize: 14, color: ClayColors.primary, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _promos.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _PromoCard(promo: _promos[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildPopularSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Popular Searches',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ClayColors.textPrimary),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _popularSearches.map((s) => _SearchChip(
            label: s,
            onTap: () => _tapPopularSearch(s),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildRecentPlaces() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Want To Visit This Place Again?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ClayColors.textPrimary),
        ),
        const SizedBox(height: 14),
        ..._recentPlaces.map((p) => _RecentPlaceItem(place: p)),
      ],
    );
  }
}

class _ServiceResultCard extends StatelessWidget {
  final _ServiceItem item;
  const _ServiceResultCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(item.route),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ClayColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: item.bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: item.imageAsset.isEmpty
                  ? const Icon(Icons.grid_view, color: Colors.grey, size: 22)
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(item.imageAsset, fit: BoxFit.contain),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ClayColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.description,
                    style: TextStyle(fontSize: 13, color: ClayColors.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: ClayColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _SearchChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const _SearchChip({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 14, color: ClayColors.textPrimary),
        ),
      ),
    );
  }
}

class _RecentPlaceItem extends StatelessWidget {
  final _PlaceItem place;
  const _RecentPlaceItem({required this.place});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.history, color: ClayColors.textSecondary, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: ClayColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  place.address,
                  style: TextStyle(fontSize: 13, color: ClayColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  final _PromoItem promo;
  const _PromoCard({required this.promo});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: promo.bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  promo.discountText,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  promo.subText,
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    promo.codeText,
                    style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: -5,
            bottom: -5,
            child: Image.asset(
              promo.imageAsset,
              width: 70,
              height: 70,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceItem {
  final String name, route, imageAsset, description;
  final Color bgColor;
  final List<String> keywords;

  const _ServiceItem({
    required this.name,
    required this.route,
    required this.imageAsset,
    required this.description,
    required this.bgColor,
    required this.keywords,
  });
}

class _PromoItem {
  final String discountText, subText, codeText, imageAsset;
  final Color bgColor;
  const _PromoItem({
    required this.discountText,
    required this.subText,
    required this.codeText,
    required this.bgColor,
    required this.imageAsset,
  });
}

class _PlaceItem {
  final String name, address;
  const _PlaceItem({required this.name, required this.address});
}

const _lightBlue = Color(0xFFB3D4F0);

final _allServices = [
  _ServiceItem(
    name: 'ClayRide',
    route: '/ride',
    imageAsset: 'assets/logo/logo_clayride.png',
    description: 'Ojek online untuk perjalanan harianmu',
    bgColor: _lightBlue,
    keywords: ['ride', 'ojek', 'motor', 'motorcycle', 'travel', 'perjalanan'],
  ),
  _ServiceItem(
    name: 'ClayCar',
    route: '/car',
    imageAsset: 'assets/logo/logo_claycar.png',
    description: 'Sewa mobil untuk perjalanan nyaman',
    bgColor: _lightBlue,
    keywords: ['car', 'mobil', 'sewa', 'rental', 'kendaraan'],
  ),
  _ServiceItem(
    name: 'ClaySend',
    route: '/send',
    imageAsset: 'assets/logo/logo_claysend.png',
    description: 'Kirim paket cepat dan aman',
    bgColor: _lightBlue,
    keywords: ['send', 'kirim', 'paket', 'package', 'delivery', 'pengiriman'],
  ),
  _ServiceItem(
    name: 'ClayFood',
    route: '/food',
    imageAsset: 'assets/logo/logo_clayfood.png',
    description: 'Pesan makanan favoritmu',
    bgColor: const Color(0xFFF08080),
    keywords: ['food', 'makanan', 'pesan', 'order', 'restoran', 'restaurant', 'kuliner'],
  ),
  _ServiceItem(
    name: 'ClayPet',
    route: '/pet',
    imageAsset: 'assets/logo/logo_claypet.png',
    description: 'Layanan perawatan hewan peliharaan',
    bgColor: _lightBlue,
    keywords: ['pet', 'hewan', 'kucing', 'anjing', 'grooming', 'veterinary'],
  ),
  _ServiceItem(
    name: 'ClayWaste',
    route: '/waste',
    imageAsset: 'assets/logo/logo_claywaste.png',
    description: 'Pengelolaan sampah dan daur ulang',
    bgColor: _lightBlue,
    keywords: ['waste', 'sampah', 'daur ulang', 'recycle', 'environment', 'lingkungan'],
  ),
  _ServiceItem(
    name: 'ClayCare',
    route: '/care',
    imageAsset: 'assets/logo/logo_claycare.png',
    description: 'Layanan kesehatan dan perawatan',
    bgColor: _lightBlue,
    keywords: ['care', 'sehat', 'kesehatan', 'health', 'perawatan', 'medical'],
  ),
  _ServiceItem(
    name: 'Other',
    route: '/other',
    imageAsset: '',
    description: 'Layanan lainnya',
    bgColor: Colors.grey.shade300,
    keywords: ['lainnya', 'other', 'more'],
  ),
];

final _promos = [
  _PromoItem(
    discountText: 'DISCOUNT\n50%',
    subText: 'First Ride',
    codeText: 'Use Code : NEW10',
    bgColor: const Color(0xFF7EB8E0),
    imageAsset: 'assets/logo/logo_clayride.png',
  ),
  _PromoItem(
    discountText: 'DISCOUNT\n25%',
    subText: 'First Order',
    codeText: 'Use Code : NEW10',
    bgColor: const Color(0xFFE87070),
    imageAsset: 'assets/logo/logo_clayfood.png',
  ),
  _PromoItem(
    discountText: 'DISCOUNT\n15%',
    subText: 'First Order',
    codeText: 'Use Code : NEW10',
    bgColor: const Color(0xFFC0392B),
    imageAsset: 'assets/logo/logo_clayfood.png',
  ),
];

final _popularSearches = [
  'ClayRide', 'ClayFood', 'ClaySend', 'ClayCar',
  'ClayPet', 'ClayWaste', 'ClayCare',
];

final _recentPlaces = [
  _PlaceItem(
    name: 'Sky Emperor',
    address: 'Jl. Buah Batu No.263, Turangga, Kec. Lengkong, Kota Bandung, Jawa Barat 40264',
  ),
  _PlaceItem(
    name: 'Sky Emperor',
    address: 'Jl. Buah Batu No.263, Turangga, Kec. Lengkong, Kota Bandung, Jawa Barat 40264',
  ),
  _PlaceItem(
    name: 'Sky Emperor',
    address: 'Jl. Buah Batu No.263, Turangga, Kec. Lengkong, Kota Bandung, Jawa Barat 40264',
  ),
  _PlaceItem(
    name: 'Sky Emperor',
    address: 'Jl. Buah Batu No.263, Turangga, Kec. Lengkong, Kota Bandung, Jawa Barat 40264',
  ),
];
