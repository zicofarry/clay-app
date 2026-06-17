import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'api_interceptor.dart';

class ClayApi {
  static ClayApi? _instance;
  late final Dio dio;

  ClayApi._() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );
    dio.interceptors.add(ApiInterceptor());
  }

  static ClayApi get instance {
    _instance ??= ClayApi._();
    return _instance!;
  }

  void setToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearToken() {
    dio.options.headers.remove('Authorization');
  }

  bool hasToken() {
    return dio.options.headers['Authorization'] != null;
  }

  String? getToken() {
    final auth = dio.options.headers['Authorization']?.toString();
    if (auth == null) return null;
    return auth.replaceFirst('Bearer ', '');
  }
}
