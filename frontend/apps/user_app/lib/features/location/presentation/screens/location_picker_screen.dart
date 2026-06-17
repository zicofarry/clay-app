import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:clay_ui/clay_ui.dart';

const String _nominatimSearchUrl = 'https://nominatim.openstreetmap.org/search';
const String _nominatimReverseUrl = 'https://nominatim.openstreetmap.org/reverse';

final selectedLocationProvider = StateProvider<LatLng?>((ref) => null);
final selectedAddressProvider = StateProvider<String>((ref) => '');
final searchQueryProvider = StateProvider<String>((ref) => '');

final searchProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.length < 3) return [];

  try {
    final dio = Dio();
    final response = await dio.get(
      _nominatimSearchUrl,
      queryParameters: {
        'q': query,
        'format': 'json',
        'limit': 10,
        'countrycodes': 'id',
        'accept-language': 'id',
      },
      options: Options(
        headers: {'User-Agent': 'ClayApp/1.0'},
      ),
    );

    final data = response.data;
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
  } catch (e) {
    debugPrint('Search error: $e');
  }
  return [];
});

class LocationPickerScreen extends ConsumerStatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  ConsumerState<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends ConsumerState<LocationPickerScreen> {
  final MapController _mapController = MapController();
  LatLng _currentPosition = const LatLng(-6.9175, 107.6191);
  final List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final result = await Geolocator.requestPermission();
        if (result == LocationPermission.denied) return;
      }
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _markers.clear();
        _markers.add(
          Marker(
            point: _currentPosition,
            child: const Icon(Icons.my_location, color: Colors.blue, size: 32),
          ),
        );
      });
      _mapController.move(_currentPosition, 15);
    } catch (e) {
      debugPrint('Location error: $e');
    }
  }

  void _onMapTap(LatLng point) {
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          point: point,
          child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
        ),
      );
    });
    ref.read(selectedLocationProvider.notifier).state = point;
    ref.read(selectedAddressProvider.notifier).state = 'Loading address...';
    _getAddressFromCoordinates(point);
  }

  Future<void> _getAddressFromCoordinates(LatLng point) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        _nominatimReverseUrl,
        queryParameters: {
          'lat': point.latitude,
          'lon': point.longitude,
          'format': 'json',
          'accept-language': 'id',
        },
        options: Options(
          headers: {'User-Agent': 'ClayApp/1.0'},
        ),
      );
      final data = response.data;
      if (data is Map && data['display_name'] != null) {
        ref.read(selectedAddressProvider.notifier).state = data['display_name'];
      } else {
        ref.read(selectedAddressProvider.notifier).state = '${point.latitude}, ${point.longitude}';
      }
    } catch (e) {
      debugPrint('Reverse geocode error: $e');
      ref.read(selectedAddressProvider.notifier).state = '${point.latitude}, ${point.longitude}';
    }
  }

  Future<void> _selectPlace(Map<String, dynamic> place) async {
    final lat = double.tryParse(place['lat']?.toString() ?? '');
    final lon = double.tryParse(place['lon']?.toString() ?? '');
    final address = place['display_name'] ?? '';

    if (lat != null && lon != null) {
      final latLng = LatLng(lat, lon);
      setState(() {
        _currentPosition = latLng;
        _markers.clear();
        _markers.add(
          Marker(
            point: latLng,
            child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
          ),
        );
      });
      _mapController.move(latLng, 17);
      ref.read(selectedAddressProvider.notifier).state = address;
      ref.read(searchQueryProvider.notifier).state = '';
    }
  }

  void _confirmLocation() {
    final address = ref.read(selectedAddressProvider);
    final location = ref.read(selectedLocationProvider);

    // If no location selected via tap, use current map center
    final finalLocation = location ?? _currentPosition;
    final finalAddress = address.isNotEmpty && address != 'Loading address...'
        ? address
        : 'Selected Location';

    Navigator.pop(context, {
      'address': finalAddress,
      'lat': finalLocation.latitude,
      'lng': finalLocation.longitude,
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(searchQueryProvider);
    final searchAsync = ref.watch(searchProvider);
    final selectedAddress = ref.watch(selectedAddressProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition,
              initialZoom: 15,
              onTap: (_, point) => _onMapTap(point),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.clay.user_app',
              ),
              MarkerLayer(markers: _markers),
            ],
          ),

          // Top search bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: Colors.white,
              child: Column(
                children: [
                  Row(
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
                      const Expanded(
                        child: Text(
                          'Pick Location',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.my_location, color: ClayColors.primary),
                        onPressed: _getCurrentLocation,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: ClayColors.primary, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            onChanged: (value) => ref.read(searchQueryProvider.notifier).state = value,
                            decoration: InputDecoration(
                              hintText: 'Search location...',
                              hintStyle: TextStyle(color: ClayColors.textSecondary, fontSize: 15),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        if (searchQuery.isNotEmpty)
                          GestureDetector(
                            onTap: () => ref.read(searchQueryProvider.notifier).state = '',
                            child: const Icon(Icons.clear, size: 20),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search results
          if (searchQuery.length >= 3)
            Positioned(
              top: 130,
              left: 20,
              right: 20,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: searchAsync.when(
                    data: (places) => places.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('No results found'),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: places.length,
                            itemBuilder: (_, i) => ListTile(
                              leading: const Icon(Icons.location_on, color: ClayColors.primary),
                              title: Text(
                                places[i]['name'] ?? places[i]['display_name'] ?? 'Place',
                                style: const TextStyle(fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                places[i]['display_name'] ?? '',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () => _selectPlace(places[i]),
                            ),
                          ),
                    loading: () => const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (e, _) => Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Error: $e'),
                    ),
                  ),
                ),
              ),
            ),

          // Selected address info
          if (selectedAddress.isNotEmpty)
            Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: ClayColors.primary, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        selectedAddress,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Confirm button
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: _confirmLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: ClayColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Confirm Location',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
