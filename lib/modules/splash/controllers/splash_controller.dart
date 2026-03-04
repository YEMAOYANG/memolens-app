import 'package:get/get.dart';
import '../../../shared/services/storage_service.dart';
import '../../../shared/services/auth_service.dart';
import '../../../app/routes/app_routes.dart';

class SplashController extends GetxController {
  final _storage = Get.find<StorageService>();
  final _auth = Get.find<AuthService>();

  @override
  void onReady() {
    super.onReady();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 1500));

    if (_storage.isFirstLaunch) {
      Get.offAllNamed(Routes.onboarding);
    } else if (_auth.isLoggedIn) {
      await _auth.fetchUser();
      Get.offAllNamed(Routes.home);
    } else {
      Get.offAllNamed(Routes.login);
    }
  }
}
