import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clay_shared/clay_shared.dart';
import 'package:dio/dio.dart';
import '../../data/address_repository.dart';

final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  return AddressRepository(ClayApi.instance);
});

class Address {
  final String id;
  final String label;
  final String address;
  final double lat;
  final double lng;
  final String notes;
  final bool isDefault;

  const Address({
    required this.id,
    required this.label,
    required this.address,
    required this.lat,
    required this.lng,
    required this.notes,
    required this.isDefault,
  });

  factory Address.fromJson(Map<String, dynamic> j) => Address(
        id: j['id']?.toString() ?? '',
        label: j['label']?.toString() ?? '',
        address: j['address']?.toString() ?? '',
        lat: (j['lat'] as num?)?.toDouble() ?? 0,
        lng: (j['lng'] as num?)?.toDouble() ?? 0,
        notes: j['notes']?.toString() ?? '',
        isDefault: j['is_default'] == true,
      );
}

class AddressState {
  final bool isLoading;
  final String? error;
  final List<Address> addresses;
  AddressState({required this.isLoading, this.error, required this.addresses});

  AddressState copyWith({bool? isLoading, String? error, bool clearError = false, List<Address>? addresses}) {
    return AddressState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      addresses: addresses ?? this.addresses,
    );
  }
}

class AddressNotifier extends StateNotifier<AddressState> {
  final AddressRepository _repo;
  AddressNotifier(this._repo) : super(AddressState(isLoading: false, addresses: [])) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final rows = await _repo.list();
      state = state.copyWith(
        isLoading: false,
        addresses: rows.map(Address.fromJson).toList(),
      );
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, error: _repo.describe(e));
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> create({
    required String label,
    required String address,
    required double lat,
    required double lng,
    String notes = '',
    bool isDefault = false,
  }) async {
    try {
      await _repo.create(
        label: label, address: address, lat: lat, lng: lng, notes: notes, isDefault: isDefault,
      );
      await load();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> update({
    required String id,
    required String label,
    required String address,
    required double lat,
    required double lng,
    String notes = '',
    bool isDefault = false,
  }) async {
    try {
      await _repo.update(
        id: id, label: label, address: address, lat: lat, lng: lng, notes: notes, isDefault: isDefault,
      );
      await load();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> remove(String id) async {
    try {
      await _repo.remove(id);
      await load();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> setDefault(String id) async {
    try {
      await _repo.setDefault(id);
      await load();
      return true;
    } catch (_) {
      return false;
    }
  }
}

final addressProvider = StateNotifierProvider<AddressNotifier, AddressState>((ref) {
  return AddressNotifier(ref.watch(addressRepositoryProvider));
});
