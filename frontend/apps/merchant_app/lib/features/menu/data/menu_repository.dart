import 'package:clay_shared/clay_shared.dart';
import 'package:dio/dio.dart';

class MenuItem {
  final String id;
  final String merchantId;
  final String categoryId;
  final String name;
  final String category; // Category name (mapped from ID for UI compatibility)
  final int price;       // Price in standard Rupiah (matches price_cents directly)
  final bool available;

  MenuItem({
    required this.id,
    this.merchantId = '',
    this.categoryId = '',
    required this.name,
    required this.category,
    required this.price,
    this.available = true,
  });
}

class MenuCategory {
  final String id;
  final String merchantId;
  final String name;
  final int displayOrder;

  MenuCategory({
    required this.id,
    required this.merchantId,
    required this.name,
    required this.displayOrder,
  });

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    return MenuCategory(
      id: json['id']?.toString() ?? '',
      merchantId: json['merchant_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      displayOrder: json['display_order'] as int? ?? 0,
    );
  }
}

class MenuRepository {
  final ClayApi _api;

  MenuRepository(this._api);

  Future<List<MenuCategory>> fetchCategories(String merchantId) async {
    try {
      final response = await _api.dio.get('${ApiEndpoints.merchants}/$merchantId/menu/categories');
      final body = response.data as Map<String, dynamic>;
      final rawList = body['data'] as List?;
      if (rawList == null) return [];
      return rawList.map((item) => MenuCategory.fromJson(item as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message']?.toString();
      throw AppException(errorMsg ?? 'Gagal mengambil kategori menu: ${e.message}');
    }
  }

  Future<MenuCategory> createCategory(String merchantId, String name, int displayOrder) async {
    try {
      final response = await _api.dio.post(
        '${ApiEndpoints.merchants}/$merchantId/menu/categories',
        data: {
          'name': name,
          'display_order': displayOrder,
        },
      );
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      return MenuCategory.fromJson(data);
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message']?.toString();
      throw AppException(errorMsg ?? 'Gagal membuat kategori menu: ${e.message}');
    }
  }

  Future<List<MenuItem>> fetchMenuItems(String merchantId, List<MenuCategory> categories) async {
    try {
      final response = await _api.dio.get('${ApiEndpoints.merchants}/$merchantId/menu/items');
      final body = response.data as Map<String, dynamic>;
      final rawList = body['data'] as List?;
      if (rawList == null) return [];

      // Create a category map for quick ID to name lookup
      final catMap = {for (var cat in categories) cat.id: cat.name};

      return rawList.map((item) {
        final catId = item['category_id']?.toString() ?? '';
        final catName = catMap[catId] ?? 'Lainnya';
        return MenuItem(
          id: item['id']?.toString() ?? '',
          merchantId: item['merchant_id']?.toString() ?? merchantId,
          categoryId: catId,
          name: item['name']?.toString() ?? '',
          category: catName,
          price: (item['price_cents'] as num?)?.toInt() ?? 0,
          available: item['is_available'] as bool? ?? true,
        );
      }).toList();
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message']?.toString();
      throw AppException(errorMsg ?? 'Gagal mengambil item menu: ${e.message}');
    }
  }

  Future<MenuItem> createMenuItem(String merchantId, String categoryId, String name, int price) async {
    try {
      final response = await _api.dio.post(
        '${ApiEndpoints.merchants}/$merchantId/menu/items',
        data: {
          'category_id': categoryId,
          'name': name,
          'price_cents': price,
        },
      );
      final body = response.data as Map<String, dynamic>;
      final item = body['data'] as Map<String, dynamic>;
      return MenuItem(
        id: item['id']?.toString() ?? '',
        merchantId: item['merchant_id']?.toString() ?? merchantId,
        categoryId: item['category_id']?.toString() ?? '',
        name: item['name']?.toString() ?? '',
        category: '', // Mapped by caller
        price: (item['price_cents'] as num?)?.toInt() ?? 0,
        available: item['is_available'] as bool? ?? true,
      );
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message']?.toString();
      throw AppException(errorMsg ?? 'Gagal membuat item menu: ${e.message}');
    }
  }

  Future<MenuItem> updateMenuItem(String merchantId, String itemId, String categoryId, String name, int price) async {
    try {
      final response = await _api.dio.put(
        '${ApiEndpoints.merchants}/$merchantId/menu/items/$itemId',
        data: {
          'category_id': categoryId,
          'name': name,
          'price_cents': price,
        },
      );
      final body = response.data as Map<String, dynamic>;
      final item = body['data'] as Map<String, dynamic>;
      return MenuItem(
        id: item['id']?.toString() ?? '',
        merchantId: item['merchant_id']?.toString() ?? merchantId,
        categoryId: item['category_id']?.toString() ?? '',
        name: item['name']?.toString() ?? '',
        category: '',
        price: (item['price_cents'] as num?)?.toInt() ?? 0,
        available: item['is_available'] as bool? ?? true,
      );
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message']?.toString();
      throw AppException(errorMsg ?? 'Gagal memperbarui item menu: ${e.message}');
    }
  }

  Future<void> deleteMenuItem(String merchantId, String itemId) async {
    try {
      await _api.dio.delete('${ApiEndpoints.merchants}/$merchantId/menu/items/$itemId');
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message']?.toString();
      throw AppException(errorMsg ?? 'Gagal menghapus item menu: ${e.message}');
    }
  }

  Future<MenuItem> toggleAvailability(String merchantId, String itemId, bool isAvailable) async {
    try {
      final response = await _api.dio.patch(
        '${ApiEndpoints.merchants}/$merchantId/menu/items/$itemId/availability',
        data: {
          'is_available': isAvailable,
        },
      );
      final body = response.data as Map<String, dynamic>;
      final item = body['data'] as Map<String, dynamic>;
      return MenuItem(
        id: item['id']?.toString() ?? '',
        merchantId: item['merchant_id']?.toString() ?? merchantId,
        categoryId: item['category_id']?.toString() ?? '',
        name: item['name']?.toString() ?? '',
        category: '',
        price: (item['price_cents'] as num?)?.toInt() ?? 0,
        available: item['is_available'] as bool? ?? true,
      );
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message']?.toString();
      throw AppException(errorMsg ?? 'Gagal mengubah status ketersediaan item menu: ${e.message}');
    }
  }
}
