import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../api/api_client.dart';
import 'storage_service.dart';
import '../../app/routes/app_routes.dart';

class AuthService extends GetxService {
  final _api = Get.find<ApiClient>();
  final _storage = Get.find<StorageService>();

  // 用户状态
  final Rx<Map<String, dynamic>?> currentUser = Rx(null);
  bool get isLoggedIn => _storage.token != null;

  @override
  void onInit() {
    super.onInit();
    // 从缓存恢复用户信息
    currentUser.value = _storage.userInfo;
  }

  // 发送验证码
  Future<bool> sendCode(String phone) async {
    try {
      EasyLoading.show(status: '发送中...');
      await _api.post('/auth/send-code', data: {'phone': phone});
      EasyLoading.showSuccess('验证码已发送');
      return true;
    } catch (e) {
      return false;
    }
  }

  // 验证码登录
  Future<bool> login(String phone, String code) async {
    try {
      EasyLoading.show(status: '登录中...');
      final response = await _api.post('/auth/verify', data: {
        'phone': phone,
        'code': code,
      });
      
      final data = response.data;
      _storage.token = data['token'];
      currentUser.value = data['user'];
      _storage.userInfo = data['user'];
      
      EasyLoading.showSuccess('登录成功');
      return true;
    } catch (e) {
      return false;
    }
  }

  // 获取当前用户信息
  Future<void> fetchUser() async {
    if (!isLoggedIn) return;
    try {
      final response = await _api.get('/users/me');
      currentUser.value = response.data;
      _storage.userInfo = response.data;
    } catch (e) {
      // 静默失败
    }
  }

  // 退出登录
  Future<void> logout() async {
    _storage.clearToken();
    _storage.userInfo = null;
    currentUser.value = null;
    Get.offAllNamed(Routes.login);
  }
}
