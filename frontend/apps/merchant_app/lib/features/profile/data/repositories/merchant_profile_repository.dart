import 'package:clay_shared/clay_shared.dart';
import 'package:dio/dio.dart';

class MerchantProfileRepository {
  final ClayApi _api;

  MerchantProfileRepository(this._api);

  // Map backend profile response to the UI-compatible format
  Map<String, dynamic> _mapProfile(Map<String, dynamic> backend) {
    return {
      'id': backend['id'],
      'user_id': backend['user_id'],
      'name': backend['name'],
      'owner': 'Pemilik Toko', // Fallback placeholder
      'phone': backend['phone_number'] ?? '',
      'category': backend['category'] ?? '',
      'address': backend['address'] ?? '',
      'rating': (backend['rating'] as num?)?.toDouble() ?? 4.5,
      'total_orders': backend['total_reviews'] ?? 0,
      'status': backend['status'],
      ...backend,
    };
  }

  Future<Map<String, dynamic>> fetchProfile() async {
    try {
      final response = await _api.dio.get('${ApiEndpoints.merchants}/me');
      final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      return _mapProfile(data);
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message']?.toString();
      throw AppException(errorMsg ?? 'Gagal mengambil profil: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _api.dio.put(
        '${ApiEndpoints.merchants}/me',
        data: {
          'name': data['name'],
          'phone_number': data['phone'],
          'address': data['address'],
          'category': data['category'],
        },
      );
      final responseData = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      return _mapProfile(responseData);
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message']?.toString();
      throw AppException(errorMsg ?? 'Gagal memperbarui profil: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> updateMerchantStatus(String merchantId, String status) async {
    try {
      final response = await _api.dio.patch(
        '${ApiEndpoints.merchants}/$merchantId/status',
        data: {
          'status': status,
        },
      );
      final responseData = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      return _mapProfile(responseData);
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message']?.toString();
      throw AppException(errorMsg ?? 'Gagal memperbarui status: ${e.message}');
    }
  }

  // Operating Hours
  static const List<String> _dayNames = [
    'Minggu', // 0
    'Senin',  // 1
    'Selasa', // 2
    'Rabu',   // 3
    'Kamis',  // 4
    'Jumat',  // 5
    'Sabtu',  // 6
  ];

  Future<List<Map<String, dynamic>>> fetchOperatingHours(String merchantId) async {
    try {
      final response = await _api.dio.get('${ApiEndpoints.merchants}/$merchantId/operating-hours');
      final rawList = (response.data as Map<String, dynamic>)['data'] as List?;
      if (rawList == null) return [];

      final List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(
        rawList.map((item) {
          final dayOfWeek = item['day_of_week'] as int? ?? 0;
          return {
            'day': _dayNames[dayOfWeek],
            'open': item['open_time'] ?? '09:00',
            'close': item['close_time'] ?? '21:00',
            'closed': item['is_closed'] ?? false,
            'day_of_week': dayOfWeek,
          };
        }),
      );

      // Sort based on: Senin (1) -> Sabtu (6) -> Minggu (0)
      list.sort((a, b) {
        int dayA = a['day_of_week'] == 0 ? 7 : a['day_of_week'];
        int dayB = b['day_of_week'] == 0 ? 7 : b['day_of_week'];
        return dayA.compareTo(dayB);
      });

      return list;
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message']?.toString();
      throw AppException(errorMsg ?? 'Gagal mengambil jam operasional: ${e.message}');
    }
  }

  Future<List<Map<String, dynamic>>> upsertOperatingHours(String merchantId, List<Map<String, dynamic>> uiHours) async {
    try {
      final List<Map<String, dynamic>> requestList = uiHours.map((h) {
        final dayName = h['day'] as String;
        final dayOfWeek = _dayNames.indexOf(dayName);
        return {
          'day_of_week': dayOfWeek != -1 ? dayOfWeek : 1,
          'open_time': h['open'] ?? '09:00',
          'close_time': h['close'] ?? '21:00',
          'is_closed': h['closed'] ?? false,
        };
      }).toList();

      final response = await _api.dio.put(
        '${ApiEndpoints.merchants}/$merchantId/operating-hours',
        data: {
          'hours': requestList,
        },
      );
      final rawList = (response.data as Map<String, dynamic>)['data'] as List?;
      if (rawList == null) return [];

      final List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(
        rawList.map((item) {
          final dayOfWeek = item['day_of_week'] as int? ?? 0;
          return {
            'day': _dayNames[dayOfWeek],
            'open': item['open_time'] ?? '09:00',
            'close': item['close_time'] ?? '21:00',
            'closed': item['is_closed'] ?? false,
            'day_of_week': dayOfWeek,
          };
        }),
      );

      list.sort((a, b) {
        int dayA = a['day_of_week'] == 0 ? 7 : a['day_of_week'];
        int dayB = b['day_of_week'] == 0 ? 7 : b['day_of_week'];
        return dayA.compareTo(dayB);
      });

      return list;
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message']?.toString();
      throw AppException(errorMsg ?? 'Gagal menyimpan jam operasional: ${e.message}');
    }
  }

  // Bank Accounts
  Future<List<Map<String, dynamic>>> fetchBankAccounts(String merchantId) async {
    try {
      final response = await _api.dio.get('${ApiEndpoints.merchants}/$merchantId/bank-accounts');
      final rawList = (response.data as Map<String, dynamic>)['data'] as List?;
      if (rawList == null) return [];

      return List<Map<String, dynamic>>.from(
        rawList.map((item) {
          return {
            'id': item['id'],
            'bank': item['bank_code'] ?? '',
            'number': item['account_number'] ?? '',
            'name': item['account_name'] ?? '',
            'primary': item['is_primary'] ?? false,
          };
        }),
      );
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message']?.toString();
      throw AppException(errorMsg ?? 'Gagal mengambil rekening bank: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> addBankAccount(String merchantId, Map<String, dynamic> bank) async {
    try {
      final response = await _api.dio.post(
        '${ApiEndpoints.merchants}/$merchantId/bank-accounts',
        data: {
          'bank_code': bank['bank'],
          'account_number': bank['number'],
          'account_name': bank['name'],
          'set_primary': bank['primary'] ?? false,
        },
      );
      final item = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      return {
        'id': item['id'],
        'bank': item['bank_code'] ?? '',
        'number': item['account_number'] ?? '',
        'name': item['account_name'] ?? '',
        'primary': item['is_primary'] ?? false,
      };
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message']?.toString();
      throw AppException(errorMsg ?? 'Gagal menambah rekening bank: ${e.message}');
    }
  }

  Future<void> deleteBankAccount(String merchantId, String accountId) async {
    try {
      await _api.dio.delete('${ApiEndpoints.merchants}/$merchantId/bank-accounts/$accountId');
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message']?.toString();
      throw AppException(errorMsg ?? 'Gagal menghapus rekening bank: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> setPrimaryBankAccount(String merchantId, String accountId) async {
    try {
      final response = await _api.dio.patch('${ApiEndpoints.merchants}/$merchantId/bank-accounts/$accountId/set-primary');
      final item = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      return {
        'id': item['id'],
        'bank': item['bank_code'] ?? '',
        'number': item['account_number'] ?? '',
        'name': item['account_name'] ?? '',
        'primary': item['is_primary'] ?? false,
      };
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message']?.toString();
      throw AppException(errorMsg ?? 'Gagal menandai rekening utama: ${e.message}');
    }
  }
}
