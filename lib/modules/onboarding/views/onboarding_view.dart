import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradient),
        child: SafeArea(
          child: Column(
            children: [
              // Skip 按钮
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: controller.skip,
                  child: Text(
                    'onboarding.skip'.tr,
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                ),
              ),

              // PageView
              Expanded(
                child: PageView.builder(
                  controller: controller.pageController,
                  onPageChanged: controller.onPageChanged,
                  itemCount: controller.pages.length,
                  itemBuilder: (context, index) {
                    final page = controller.pages[index];
                    return _buildPage(
                      icon: page['icon'] as IconData,
                      title: (page['title'] as String).tr,
                      desc: (page['desc'] as String).tr,
                    );
                  },
                ),
              ),

              // 指示器 + 按钮
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    // 点指示器
                    Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        controller.pages.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: controller.currentPage.value == i ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: controller.currentPage.value == i
                                ? Colors.white
                                : Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    )),
                    const SizedBox(height: 32),

                    // 按钮
                    SizedBox(
                      width: double.infinity,
                      child: Obx(() => ElevatedButton(
                        onPressed: controller.next,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          controller.currentPage.value == controller.pages.length - 1
                              ? 'onboarding.start'.tr
                              : 'onboarding.next'.tr,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Icon(icon, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 48),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
