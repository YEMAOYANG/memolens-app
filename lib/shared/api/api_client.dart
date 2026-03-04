import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/hive_boxes.dart';
import 'models/record.dart';

const _base = String.fromEnvironment('API_BASE_URL', defaultValue: 'https://api.memolens.app');

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(baseUrl: _base, connectTimeout: const Duration(seconds: 10), receiveTimeout: const Duration(seconds: 30)));
  dio.interceptors.add(InterceptorsWrapper(onRequest: (opts, handler) {
    final token = HiveBoxes.jwtToken;
    if (token != null) opts.headers['Authorization'] = 'Bearer $token';
    handler.next(opts);
  }));
  return dio;
});

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient(ref.read(dioProvider)));

class ApiClient {
  final Dio _dio;
  ApiClient(this._dio);

  Future<void> sendCode(String phone) async =>
    _dio.post('/auth/send-code', data: {'phone': phone});

  Future<String> verify(String phone, String code) async {
    final r = await _dio.post('/auth/verify', data: {'phone': phone, 'code': code});
    return r.data['token'] as String;
  }

  Future<Record> uploadRecord(String imagePath, String ocrText, List<String> tags) async {
    final form = FormData.fromMap({
      'image': await MultipartFile.fromFile(imagePath, filename: 'capture.jpg'),
      'ocr_text': ocrText,
      'user_tags': tags.join(','),
    });
    final r = await _dio.post('/records/upload', data: form);
    return Record.fromJson(r.data as Map<String, dynamic>);
  }

  Future<List<Record>> getRecords({int page = 1, String? type}) async {
    final r = await _dio.get('/records', queryParameters: {'page': page, if (type != null) 'type': type});
    return (r.data['data'] as List).map((e) => Record.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Record> getRecord(String id) async {
    final r = await _dio.get('/records/$id');
    return Record.fromJson(r.data as Map<String, dynamic>);
  }

  Future<void> deleteRecord(String id) => _dio.delete('/records/$id');

  Future<Map<String, dynamic>> ask(String question) async {
    final r = await _dio.post('/search/ask', data: {'question': question});
    return r.data as Map<String, dynamic>;
  }

  Future<AppUser> getMe() async {
    final r = await _dio.get('/users/me');
    return AppUser.fromJson(r.data as Map<String, dynamic>);
  }
}
