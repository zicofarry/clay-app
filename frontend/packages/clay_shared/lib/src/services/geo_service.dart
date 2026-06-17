import 'package:dio/dio.dart';
import '../api/clay_api.dart';
import '../api/api_endpoints.dart';

class GeoService {
  final Dio _dio = ClayApi.instance.dio;

  Future<Response> autocomplete({required String query}) async {
    return _dio.get(
      ApiEndpoints.mapsAutocomplete,
      queryParameters: {'input': query},
    );
  }

  Future<Response> getPlaceDetails({required String placeId}) async {
    return _dio.get(
      ApiEndpoints.mapsPlaceDetails,
      queryParameters: {'place_id': placeId},
    );
  }

  Future<Response> geocode({required String address}) async {
    return _dio.post(
      ApiEndpoints.mapsGeocode,
      data: {'address': address},
    );
  }

  Future<Response> reverseGeocode({required double lat, required double lng}) async {
    return _dio.post(
      ApiEndpoints.mapsReverseGeocode,
      data: {'lat': lat, 'lng': lng},
    );
  }

  Future<Response> getEstimate({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    return _dio.post(
      ApiEndpoints.mapsEstimate,
      data: {
        'origin': {'lat': originLat, 'lng': originLng},
        'destination': {'lat': destLat, 'lng': destLng},
      },
    );
  }

  Future<Response> getPolyline({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    return _dio.get(
      ApiEndpoints.mapsPolyline,
      queryParameters: {
        'origin_lat': originLat,
        'origin_lng': originLng,
        'dest_lat': destLat,
        'dest_lng': destLng,
      },
    );
  }

  Future<Response> getRouting({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    return _dio.get(
      ApiEndpoints.mapsRouting,
      queryParameters: {
        'origin_lat': originLat,
        'origin_lng': originLng,
        'dest_lat': destLat,
        'dest_lng': destLng,
      },
    );
  }

  Future<Response> getDistance({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    return _dio.get(
      ApiEndpoints.distance,
      queryParameters: {
        'origin_lat': originLat,
        'origin_lng': originLng,
        'dest_lat': destLat,
        'dest_lng': destLng,
      },
    );
  }

  Future<Response> getNearbyDrivers({required double lat, required double lng}) async {
    return _dio.get(
      ApiEndpoints.driversNearby,
      queryParameters: {'lat': lat, 'lng': lng},
    );
  }
}
