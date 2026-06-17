import 'package:dio/dio.dart';
import 'package:clay_shared/clay_shared.dart';

class AddressRepository {
  final ClayApi _api;
  AddressRepository(this._api);

  Future<List<Map<String, dynamic>>> list() async {
    final res = await _api.dio.get(ApiEndpoints.addresses);
    final body = res.data;
    if (body is Map<String, dynamic>) {
      final inner = body['data'];
      if (inner is Map<String, dynamic> && inner['data'] is List) {
        return List<Map<String, dynamic>>.from(inner['data']);
      }
      if (inner is List) {
        return List<Map<String, dynamic>>.from(inner);
      }
    }
    return <Map<String, dynamic>>[];
  }

  Future<Map<String, dynamic>> create({
    required String label,
    required String address,
    required double lat,
    required double lng,
    String notes = '',
    bool isDefault = false,
  }) async {
    final res = await _api.dio.post(ApiEndpoints.addresses, data: {
      'label': label,
      'address': address,
      'lat': lat,
      'lng': lng,
      'notes': notes,
      'is_default': isDefault,
    });
    return _extractData(res.data);
  }

  Future<Map<String, dynamic>> update({
    required String id,
    required String label,
    required String address,
    required double lat,
    required double lng,
    String notes = '',
    bool isDefault = false,
  }) async {
    final res = await _api.dio.put('${ApiEndpoints.addresses}/$id', data: {
      'label': label,
      'address': address,
      'lat': lat,
      'lng': lng,
      'notes': notes,
      'is_default': isDefault,
    });
    return _extractData(res.data);
  }

  Future<void> remove(String id) async {
    await _api.dio.delete('${ApiEndpoints.addresses}/$id');
  }

  Future<void> setDefault(String id) async {
    await _api.dio.put('${ApiEndpoints.addresses}/$id/default');
  }

  Map<String, dynamic> _extractData(dynamic body) {
    if (body is Map<String, dynamic>) {
      final d = body['data'];
      if (d is Map<String, dynamic>) return d;
    }
    return <String, dynamic>{};
  }

  String describe(DioException e) {
    final msg = e.response?.data;
    if (msg is Map<String, dynamic> && msg['message'] is String) {
      return msg['message'] as String;
    }
    return e.message ?? 'Terjadi kesalahan';
  }
}
