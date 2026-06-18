import '../../../core/api_client.dart';
import '../../../core/api_endpoints.dart';

class Driver {
  final String id;
  final String name;
  final String phone;
  final String vehicle;
  final String plate;
  final String status;
  final double rating;

  Driver({
    required this.id,
    required this.name,
    required this.phone,
    required this.vehicle,
    required this.plate,
    required this.status,
    required this.rating,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['user_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['full_name'] ?? json['name'] ?? '',
      phone: json['phone_number'] ?? json['phone'] ?? '',
      vehicle: json['vehicle_brand'] != null
          ? '${json['vehicle_brand']} ${json['vehicle_model'] ?? ''}'
          : json['vehicle'] ?? '',
      plate: json['vehicle_plate'] ?? json['plate'] ?? '',
      status: json['status'] ?? json['is_online'] == true ? 'online' : 'offline',
      rating: (json['rating'] ?? 0).toDouble(),
    );
  }
}

class DriversRepository {
  final AdminApiClient _client = AdminApiClient.instance;

  Future<List<Driver>> getDrivers() async {
    final response = await _client.dio.get('/drivers');
    final data = response.data;
    final List<dynamic> items = data['data'] is List ? data['data'] : [];
    return items.map((e) => Driver.fromJson(e as Map<String, dynamic>)).toList();
  }
}
