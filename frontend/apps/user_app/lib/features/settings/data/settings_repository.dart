import 'package:dio/dio.dart';
import 'package:clay_shared/clay_shared.dart';

class SettingsRepository {
  final ClayApi _api;
  SettingsRepository(this._api);

  Future<Map<String, dynamic>> get() async {
    final res = await _api.dio.get(ApiEndpoints.settings);
    final body = res.data;
    if (body is Map<String, dynamic>) {
      final d = body['data'];
      if (d is Map<String, dynamic>) return d;
      return body;
    }
    return <String, dynamic>{};
  }

  Future<Map<String, dynamic>> update({bool? notifEnabled, bool? marketingEnabled, String? language}) async {
    final payload = <String, dynamic>{};
    if (notifEnabled != null) payload['notif_enabled'] = notifEnabled;
    if (marketingEnabled != null) payload['marketing_enabled'] = marketingEnabled;
    if (language != null) payload['language'] = language;

    final res = await _api.dio.put(ApiEndpoints.settings, data: payload);
    final body = res.data;
    if (body is Map<String, dynamic>) {
      final d = body['data'];
      if (d is Map<String, dynamic>) return d;
      return body;
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
