import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../services/storage_service.dart';

class ApiClient extends GetxService {
  late final Dio _dio;
  
  static const String baseUrl = 'https://api.memolens.app/api';
  // static const String baseUrl = 'http://localhost:3000/api'; // 本地调试

  Dio get dio => _dio;

  @override
  void onInit() {
    super.onInit();
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // 添加 Token
        final token = Get.find<StorageService>().token;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (error, handler) {
        _handleError(error);
        return handler.next(error);
      },
    ));
  }

  void _handleError(DioException error) {
    String message;
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = '网络连接超时';
        break;
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) {
          message = '登录已过期，请重新登录';
          Get.find<StorageService>().clearToken();
          // Get.offAllNamed(Routes.login);
        } else if (statusCode == 403) {
          message = '没有权限';
        } else if (statusCode == 404) {
          message = '资源不存在';
        } else if (statusCode == 429) {
          message = '请求过于频繁，请稍后再试';
        } else if (statusCode != null && statusCode >= 500) {
          message = '服务器错误';
        } else {
          message = error.response?.data?['message'] ?? '请求失败';
        }
        break;
      case DioExceptionType.cancel:
        return;
      default:
        message = '网络连接失败，请检查网络';
    }
    EasyLoading.showError(message);
  }

  // GET
  Future<Response> get(String path, {Map<String, dynamic>? params}) {
    return _dio.get(path, queryParameters: params);
  }

  // POST
  Future<Response> post(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }

  // PATCH
  Future<Response> patch(String path, {dynamic data}) {
    return _dio.patch(path, data: data);
  }

  // DELETE
  Future<Response> delete(String path) {
    return _dio.delete(path);
  }

  // 上传文件
  Future<Response> upload(String path, String filePath, {
    String fieldName = 'file',
    Map<String, dynamic>? extraData,
    ProgressCallback? onSendProgress,
  }) async {
    final formData = FormData.fromMap({
      fieldName: await MultipartFile.fromFile(filePath),
      ...?extraData,
    });
    return _dio.post(path, data: formData, onSendProgress: onSendProgress);
  }
}
