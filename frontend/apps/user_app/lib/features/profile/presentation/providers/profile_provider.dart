import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clay_shared/clay_shared.dart';
import 'package:dio/dio.dart';

final profileProvider = StateNotifierProvider<ProfileNotifier, AsyncValue<Map<String, dynamic>>>((ref) {
  return ProfileNotifier(ClayApi.instance);
});

class ProfileNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final ClayApi _api;

  ProfileNotifier(this._api) : super(const AsyncValue.loading()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = const AsyncValue.loading();
    try {
      final response = await _api.dio.get(ApiEndpoints.getProfile);
      final data = response.data as Map<String, dynamic>;
      state = AsyncValue.data(data['data'] as Map<String, dynamic>? ?? data);
    } on DioException catch (e, st) {
      state = AsyncValue.error(e.message ?? 'Failed to load profile', st);
    }
  }

  Future<bool> updateProfile({String? fullName, String? birthDate, String? gender}) async {
    try {
      final body = <String, dynamic>{};
      if (fullName != null) body['full_name'] = fullName;
      if (birthDate != null) body['birth_date'] = birthDate;
      if (gender != null) body['gender'] = gender;

      final response = await _api.dio.put(ApiEndpoints.updateProfile, data: body);
      final data = response.data as Map<String, dynamic>;
      final profile = data['data'] as Map<String, dynamic>? ?? data;
      state = AsyncValue.data(profile);
      return true;
    } on DioException catch (_) {
      return false;
    }
  }

  Future<String?> uploadAvatar(Uint8List bytes, {String filename = 'avatar.jpg'}) async {
    try {
      final formData = FormData.fromMap({
        'avatar': MultipartFile.fromBytes(bytes, filename: filename),
      });
      final response = await _api.dio.put(ApiEndpoints.updateAvatar, data: formData);
      final data = response.data;
      String? url;
      if (data is Map<String, dynamic>) {
        final inner = data['data'];
        if (inner is Map<String, dynamic> && inner['avatar_url'] is String) {
          url = inner['avatar_url'] as String;
        } else if (data['avatar_url'] is String) {
          url = data['avatar_url'] as String;
        }
      }
      if (url != null && !url.startsWith('http')) {
        url = '${_api.dio.options.baseUrl}$url';
      }
      return url;
    } on DioException catch (_) {
      return null;
    }
  }

  Future<bool> updateAvatar(String avatarUrl) async {
    try {
      final response = await _api.dio.put(
        ApiEndpoints.updateAvatar,
        data: {'avatar_url': avatarUrl},
      );
      final data = response.data as Map<String, dynamic>;
      final profile = data['data'] as Map<String, dynamic>? ?? data;
      state = AsyncValue.data(profile);
      return true;
    } on DioException catch (_) {
      return false;
    }
  }
}
