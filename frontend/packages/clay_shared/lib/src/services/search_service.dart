import 'package:dio/dio.dart';
import '../api/clay_api.dart';
import '../api/api_endpoints.dart';

class SearchService {
  final Dio _dio = ClayApi.instance.dio;

  Future<Response> searchMerchants({String? query}) async {
    return _dio.get(
      ApiEndpoints.searchMerchants,
      queryParameters: query != null ? {'q': query} : null,
    );
  }

  Future<Response> searchMenuItems({String? query}) async {
    return _dio.get(
      ApiEndpoints.searchMenuItems,
      queryParameters: query != null ? {'q': query} : null,
    );
  }

  Future<Response> getSuggestions({String? query}) async {
    return _dio.get(
      ApiEndpoints.searchSuggest,
      queryParameters: query != null ? {'q': query} : null,
    );
  }

  Future<Response> getTrending() async {
    return _dio.get(ApiEndpoints.searchTrending);
  }

  Future<Response> getPopular() async {
    return _dio.get(ApiEndpoints.searchPopular);
  }
}
