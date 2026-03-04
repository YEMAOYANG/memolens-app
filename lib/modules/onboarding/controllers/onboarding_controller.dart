import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/services/storage_service.dart';
import '../../../app/routes/app_routes.dart';

class OnboardingController extends GetxController {
  final _storage = Get.find<StorageService>();
  final pageController = PageController();
  final currentPage = 0.obs;

  final pages = [
    {
      'icon': Icons.camera_alt_rounded,
      'title': 'onboarding.title1',
      'desc': 'onboarding.desc1',
    },
    {
      'icon': Icons.search_rounded,
      'title': 'onboarding.title2',
      'desc': 'onboarding.desc2',
    },
    {
      'icon': Icons.lock_rounded,
      'title': 'onboarding.title3',
      'desc': 'onboarding.desc3',
    },
  ];

  void onPageChanged(int page) {
    currentPage.value = page;
  }

  void next() {
    if (currentPage.value < pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      finish();
    }
  }

  void skip() => finish();

  void finish() {
    _storage.isFirstLaunch = false;
    Get.offAllNamed(Routes.login);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
