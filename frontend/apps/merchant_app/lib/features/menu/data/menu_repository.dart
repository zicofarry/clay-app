import 'package:clay_shared/clay_shared.dart';
import 'package:dio/dio.dart';

class VariantOption {
  final String id;
  final String name;
  final int extraPrice;

  VariantOption({
    required this.id,
    required this.name,
    this.extraPrice = 0,
  });

  factory VariantOption.fromJson(Map<String, dynamic> json) {
    return VariantOption(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      extraPrice: (json['extra_price_cents'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'extra_price_cents': extraPrice,
    };
  }
}

class MenuVariant {
  final String id;
  final String name;
  final List<VariantOption> options;
  final bool isRequired;

  MenuVariant({
    required this.id,
    required this.name,
    this.options = const [],
    this.isRequired = false,
  });

  factory MenuVariant.fromJson(Map<String, dynamic> json) {
    var ops = <VariantOption>[];
    if (json['options'] != null) {
      ops = (json['options'] as List).map((o) => VariantOption.fromJson(o as Map<String, dynamic>)).toList();
    }
    return MenuVariant(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      options: ops,
      isRequired: json['required'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'options': options.map((o) => o.toJson()).toList(),
      'required': isRequired,
    };
  }
}

class MenuAddOn {
  final String id;
  final String name;
  final int price;
  final int maxQty;

  MenuAddOn({
    required this.id,
    required this.name,
    this.price = 0,
    this.maxQty = 1,
  });

  factory MenuAddOn.fromJson(Map<String, dynamic> json) {
    return MenuAddOn(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: (json['price_cents'] as num?)?.toInt() ?? 0,
      maxQty: (json['max_qty'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price_cents': price,
      'max_qty': maxQty,
    };
  }
}

class MenuItem {
  final String id;
  final String merchantId;
  final String categoryId;
  final String name;
  final String category; // Category name (mapped from ID for UI compatibility)
  final int price;       // Price in standard Rupiah (matches price_cents directly)
  final bool available;
  final String? description;
  final String? imageUrl;
  final List<MenuVariant> variants;
  final List<MenuAddOn> addOns;
  final List<String> tags;

  MenuItem({
    required this.id,
    this.merchantId = '',
    this.categoryId = '',
    required this.name,
    required this.category,
    required this.price,
    this.available = true,
    this.description,
    this.imageUrl,
    this.variants = const [],
    this.addOns = const [],
    this.tags = const [],
  });

  MenuItem copyWith({
    String? id,
    String? merchantId,
    String? categoryId,
    String? name,
    String? category,
    int? price,
    bool? available,
    String? description,
    String? imageUrl,
    List<MenuVariant>? variants,
    List<MenuAddOn>? addOns,
    List<String>? tags,
  }) {
    return MenuItem(
      id: id ?? this.id,
      merchantId: merchantId ?? this.merchantId,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      available: available ?? this.available,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      variants: variants ?? this.variants,
      addOns: addOns ?? this.addOns,
      tags: tags ?? this.tags,
    );
  }
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

  Future<MenuCategory> updateCategory(String merchantId, String categoryId, String name, int displayOrder) async {
    try {
      final response = await _api.dio.put(
        '${ApiEndpoints.merchants}/$merchantId/menu/categories/$categoryId',
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
      throw AppException(errorMsg ?? 'Gagal memperbarui kategori menu: ${e.message}');
    }
  }

  Future<void> deleteCategory(String merchantId, String categoryId) async {
    try {
      await _api.dio.delete('${ApiEndpoints.merchants}/$merchantId/menu/categories/$categoryId');
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message']?.toString();
      throw AppException(errorMsg ?? 'Gagal menghapus kategori menu: ${e.message}');
    }
  }

  Future<List<MenuCategory>> reorderCategories(String merchantId, List<String> categoryIds) async {
    try {
      final response = await _api.dio.patch(
        '${ApiEndpoints.merchants}/$merchantId/menu/categories/reorder',
        data: {
          'category_ids': categoryIds,
        },
      );
      final body = response.data as Map<String, dynamic>;
      final rawList = body['data'] as List?;
      if (rawList == null) return [];
      return rawList.map((item) => MenuCategory.fromJson(item as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message']?.toString();
      throw AppException(errorMsg ?? 'Gagal mengubah urutan kategori menu: ${e.message}');
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
          description: item['description']?.toString(),
          imageUrl: item['image_url']?.toString(),
          variants: (item['variants'] as List?)?.map((v) => MenuVariant.fromJson(v as Map<String, dynamic>)).toList() ?? [],
          addOns: (item['add_ons'] as List?)?.map((a) => MenuAddOn.fromJson(a as Map<String, dynamic>)).toList() ?? [],
          tags: (item['tags'] as List?)?.map((t) => t.toString()).toList() ?? [],
        );
      }).toList();
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message']?.toString();
      throw AppException(errorMsg ?? 'Gagal mengambil item menu: ${e.message}');
    }
  }

  Future<MenuItem> createMenuItem(MenuItem item) async {
    try {
      final response = await _api.dio.post(
        '${ApiEndpoints.merchants}/${item.merchantId}/menu/items',
        data: {
          'category_id': item.categoryId,
          'name': item.name,
          'description': item.description,
          'price_cents': item.price,
          'image_url': item.imageUrl,
          'variants': item.variants.map((v) => v.toJson()).toList(),
          'add_ons': item.addOns.map((a) => a.toJson()).toList(),
          'tags': item.tags,
        },
      );
      final body = response.data as Map<String, dynamic>;
      final createdItem = body['data'] as Map<String, dynamic>;
      return MenuItem(
        id: createdItem['id']?.toString() ?? '',
        merchantId: createdItem['merchant_id']?.toString() ?? item.merchantId,
        categoryId: createdItem['category_id']?.toString() ?? item.categoryId,
        name: createdItem['name']?.toString() ?? '',
        category: item.category, // Preserve mapped category
        price: (createdItem['price_cents'] as num?)?.toInt() ?? 0,
        available: createdItem['is_available'] as bool? ?? true,
        description: createdItem['description']?.toString(),
        imageUrl: createdItem['image_url']?.toString(),
        variants: (createdItem['variants'] as List?)?.map((v) => MenuVariant.fromJson(v as Map<String, dynamic>)).toList() ?? [],
        addOns: (createdItem['add_ons'] as List?)?.map((a) => MenuAddOn.fromJson(a as Map<String, dynamic>)).toList() ?? [],
        tags: (createdItem['tags'] as List?)?.map((t) => t.toString()).toList() ?? [],
      );
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message']?.toString();
      throw AppException(errorMsg ?? 'Gagal membuat item menu: ${e.message}');
    }
  }

  Future<MenuItem> updateMenuItem(MenuItem item) async {
    if (item.id.isEmpty) {
      throw AppException('Gagal memperbarui: ID item kosong');
    }
    try {
      final response = await _api.dio.put(
        '${ApiEndpoints.merchants}/${item.merchantId}/menu/items/${item.id}',
        data: {
          'category_id': item.categoryId,
          'name': item.name,
          'description': item.description,
          'price_cents': item.price,
          'image_url': item.imageUrl,
          'variants': item.variants.map((v) => v.toJson()).toList(),
          'add_ons': item.addOns.map((a) => a.toJson()).toList(),
          'tags': item.tags,
        },
      );
      final body = response.data as Map<String, dynamic>;
      final updatedItem = body['data'] as Map<String, dynamic>;
      return MenuItem(
        id: updatedItem['id']?.toString() ?? '',
        merchantId: updatedItem['merchant_id']?.toString() ?? item.merchantId,
        categoryId: updatedItem['category_id']?.toString() ?? item.categoryId,
        name: updatedItem['name']?.toString() ?? '',
        category: item.category, // Preserve mapped category
        price: (updatedItem['price_cents'] as num?)?.toInt() ?? 0,
        available: updatedItem['is_available'] as bool? ?? true,
        description: updatedItem['description']?.toString(),
        imageUrl: updatedItem['image_url']?.toString(),
        variants: (updatedItem['variants'] as List?)?.map((v) => MenuVariant.fromJson(v as Map<String, dynamic>)).toList() ?? [],
        addOns: (updatedItem['add_ons'] as List?)?.map((a) => MenuAddOn.fromJson(a as Map<String, dynamic>)).toList() ?? [],
        tags: (updatedItem['tags'] as List?)?.map((t) => t.toString()).toList() ?? [],
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
      final updatedItem = body['data'] as Map<String, dynamic>;
      return MenuItem(
        id: updatedItem['id']?.toString() ?? '',
        merchantId: updatedItem['merchant_id']?.toString() ?? merchantId,
        categoryId: updatedItem['category_id']?.toString() ?? '',
        name: updatedItem['name']?.toString() ?? '',
        category: '',
        price: (updatedItem['price_cents'] as num?)?.toInt() ?? 0,
        available: updatedItem['is_available'] as bool? ?? true,
        description: updatedItem['description']?.toString(),
        imageUrl: updatedItem['image_url']?.toString(),
        variants: (updatedItem['variants'] as List?)?.map((v) => MenuVariant.fromJson(v as Map<String, dynamic>)).toList() ?? [],
        addOns: (updatedItem['add_ons'] as List?)?.map((a) => MenuAddOn.fromJson(a as Map<String, dynamic>)).toList() ?? [],
        tags: (updatedItem['tags'] as List?)?.map((t) => t.toString()).toList() ?? [],
      );
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message']?.toString();
      throw AppException(errorMsg ?? 'Gagal mengubah status ketersediaan item menu: ${e.message}');
    }
  }
}
