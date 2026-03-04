import 'package:get/get.dart';

import '../../shared/services/auth_service.dart';
import '../../shared/services/storage_service.dart';
import '../../shared/api/api_client.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // 全局单例服务
    Get.put(StorageService(), permanent: true);
    Get.put(ApiClient(), permanent: true);
    Get.put(AuthService(), permanent: true);
  }
}
