import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class StorageService extends GetxService {
  late Box _settingsBox;
  late Box _cacheBox;

  @override
  void onInit() {
    super.onInit();
    _settingsBox = Hive.box('settings');
    _cacheBox = Hive.box('cache');
  }

  // Token
  String? get token => _settingsBox.get('token');
  set token(String? value) => _settingsBox.put('token', value);
  void clearToken() => _settingsBox.delete('token');

  // 是否首次启动（显示 onboarding）
  bool get isFirstLaunch => _settingsBox.get('isFirstLaunch', defaultValue: true);
  set isFirstLaunch(bool value) => _settingsBox.put('isFirstLaunch', value);

  // 深色模式
  bool get isDarkMode => _settingsBox.get('isDarkMode', defaultValue: false);
  set isDarkMode(bool value) => _settingsBox.put('isDarkMode', value);

  // 语言
  String get locale => _settingsBox.get('locale', defaultValue: 'zh_CN');
  set locale(String value) => _settingsBox.put('locale', value);

  // 用户信息缓存
  Map<String, dynamic>? get userInfo {
    final data = _cacheBox.get('userInfo');
    return data != null ? Map<String, dynamic>.from(data) : null;
  }
  set userInfo(Map<String, dynamic>? value) => _cacheBox.put('userInfo', value);

  // 清除所有数据
  Future<void> clearAll() async {
    await _settingsBox.clear();
    await _cacheBox.clear();
  }
}
