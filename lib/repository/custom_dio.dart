import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CustomDio {
  final _dio = Dio();

  Dio get dio => _dio;

  CustomDio() {
    _dio.options.baseUrl = dotenv.get('BASE_URL');
    _dio.options.headers['X-Parse-Application-Id'] =
        dotenv.get('APPLICATION_ID');
    _dio.options.headers['X-Parse-REST-API-Key'] = dotenv.get('REST_API_KEY');
    _dio.options.headers['Content-Type'] = 'application/json';
  }
}
