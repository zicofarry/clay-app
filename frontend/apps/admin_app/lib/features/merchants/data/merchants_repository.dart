import '../../../core/api_client.dart';
import '../../../core/api_endpoints.dart';

class Merchant {
  final String id;
  final String name;
  final String owner;
  final String category;
  final double rating;
  final String status;
  final String? phone;

  Merchant({
    required this.id,
    required this.name,
    required this.owner,
    required this.category,
    required this.rating,
    required this.status,
    this.phone,
  });

  factory Merchant.fromJson(Map<String, dynamic> json) {
    return Merchant(
      id: json['merchant_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] ?? json['merchant_name'] ?? '',
      owner: json['owner_name'] ?? json['owner'] ?? '',
      category: json['category'] ?? json['cuisine'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      status: json['status'] ?? 'active',
      phone: json['phone_number'] ?? json['phone'],
    );
  }
}

class MerchantsRepository {
  final AdminApiClient _client = AdminApiClient.instance;

  Future<List<Merchant>> getMerchants() async {
    final response = await _client.dio.get(ApiEndpoint.merchants);
    final data = response.data;
    final List<dynamic> items = data['data'] is List ? data['data'] : [];
    return items.map((e) => Merchant.fromJson(e as Map<String, dynamic>)).toList();
  }
}
