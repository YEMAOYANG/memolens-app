import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/services/auth_service.dart';
import '../../../shared/services/storage_service.dart';

class SettingsController extends GetxController {
  final _auth = Get.find<AuthService>();
  final _storage = Get.find<StorageService>();

  final isDarkMode = false.obs;
  final isNotificationOn = true.obs;

  Map<String, dynamic>? get user => _auth.currentUser.value;

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = _storage.isDarkMode;
  }

  void toggleDarkMode(bool value) {
    isDarkMode.value = value;
    _storage.isDarkMode = value;
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  void toggleNotification(bool value) {
    isNotificationOn.value = value;
  }

  void logout() {
    Get.dialog(AlertDialog(
      title: Text('settings.logout'.tr),
      content: const Text('确定要退出登录吗？'),
      actions: [
        TextButton(onPressed: Get.back, child: Text('cancel'.tr)),
        TextButton(
          onPressed: () {
            Get.back();
            _auth.logout();
          },
          child: Text('confirm'.tr),
        ),
      ],
    ));
  }
}
