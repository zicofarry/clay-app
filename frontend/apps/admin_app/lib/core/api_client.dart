import 'package:dio/dio.dart';

class AdminApiClient {
  static AdminApiClient? _instance;
  late final Dio dio;
  String? _token;

  AdminApiClient._() {
    dio = Dio(BaseOptions(
      baseUrl: 'http://10.0.2.2:8080',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        handler.next(error);
      },
    ));
  }

  static AdminApiClient get instance {
    _instance ??= AdminApiClient._();
    return _instance!;
  }

  void setToken(String token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  String? get token => _token;
}
