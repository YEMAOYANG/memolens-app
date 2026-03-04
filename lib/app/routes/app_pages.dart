import 'package:get/get.dart';

import '../../modules/splash/bindings/splash_binding.dart';
import '../../modules/splash/views/splash_view.dart';
import '../../modules/onboarding/bindings/onboarding_binding.dart';
import '../../modules/onboarding/views/onboarding_view.dart';
import '../../modules/auth/bindings/auth_binding.dart';
import '../../modules/auth/views/login_view.dart';
import '../../modules/home/bindings/home_binding.dart';
import '../../modules/home/views/home_view.dart';
import '../../modules/camera/bindings/camera_binding.dart';
import '../../modules/camera/views/camera_view.dart';
import '../../modules/camera/views/archive_result_view.dart';
import '../../modules/search/bindings/search_binding.dart';
import '../../modules/search/views/search_view.dart';
import '../../modules/gallery/bindings/gallery_binding.dart';
import '../../modules/gallery/views/gallery_view.dart';
import '../../modules/detail/bindings/detail_binding.dart';
import '../../modules/detail/views/detail_view.dart';
import '../../modules/settings/bindings/settings_binding.dart';
import '../../modules/settings/views/settings_view.dart';

import 'app_routes.dart';

class AppPages {
  static const initial = Routes.splash;

  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.camera,
      page: () => const CameraView(),
      binding: CameraBinding(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: Routes.archiveResult,
      page: () => const ArchiveResultView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.search,
      page: () => const SearchView(),
      binding: SearchBinding(),
    ),
    GetPage(
      name: Routes.gallery,
      page: () => const GalleryView(),
      binding: GalleryBinding(),
    ),
    GetPage(
      name: '${Routes.detail}/:id',
      page: () => const DetailView(),
      binding: DetailBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
  ];
}
