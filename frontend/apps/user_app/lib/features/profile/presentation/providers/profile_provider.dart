import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clay_shared/clay_shared.dart';

final profileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ClayApi.instance;
  final response = await api.dio.get(ApiEndpoints.getProfile);
  final data = response.data as Map<String, dynamic>;
  return data['data'] as Map<String, dynamic>;
});
