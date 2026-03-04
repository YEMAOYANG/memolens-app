import 'package:hive_flutter/hive_flutter.dart';
class HiveBoxes {
  static late Box<dynamic> settings;
  static late Box<dynamic> uploadQueue;
  static Future<void> init() async {
    settings     = await Hive.openBox('settings');
    uploadQueue  = await Hive.openBox('upload_queue');
  }
  static String? get jwtToken => settings.get('jwt_token') as String?;
  static Future<void> saveToken(String token) => settings.put('jwt_token', token);
  static Future<void> clearToken() => settings.delete('jwt_token');
}
