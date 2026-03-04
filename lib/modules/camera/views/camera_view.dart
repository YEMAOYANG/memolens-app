import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import '../../../app/theme/app_theme.dart';
import '../controllers/camera_controller.dart';

class CameraView extends GetView<CameraPageController> {
  const CameraView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 相机预览
          Obx(() {
            if (!controller.isInitialized.value) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }
            return SizedBox.expand(
              child: CameraPreview(controller.cameraController!),
            );
          }),

          // 扫描框
          Center(
            child: Container(
              width: 300,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // 顶部栏
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                    onPressed: () => Get.back(),
                  ),
                  Obx(() => IconButton(
                    icon: Icon(
                      controller.isFlashOn.value
                          ? Icons.flash_on_rounded
                          : Icons.flash_off_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: controller.toggleFlash,
                  )),
                ],
              ),
            ),
          ),

          // 底部拍照按钮
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Obx(() => GestureDetector(
                onTap: controller.isProcessing.value ? null : controller.takePicture,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: controller.isProcessing.value
                          ? Colors.grey
                          : Colors.white,
                    ),
                  ),
                ),
              )),
            ),
          ),
        ],
      ),
    );
  }
}
