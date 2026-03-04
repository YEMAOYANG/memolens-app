import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../../app/routes/app_routes.dart';

class CameraPageController extends GetxController {
  CameraController? cameraController;
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.chinese);

  final isInitialized = false.obs;
  final isFlashOn = false.obs;
  final isProcessing = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      EasyLoading.showError('没有可用的摄像头');
      return;
    }

    cameraController = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await cameraController!.initialize();
    isInitialized.value = true;
  }

  Future<void> toggleFlash() async {
    if (cameraController == null) return;
    isFlashOn.value = !isFlashOn.value;
    await cameraController!.setFlashMode(
      isFlashOn.value ? FlashMode.torch : FlashMode.off,
    );
  }

  Future<void> takePicture() async {
    if (cameraController == null || isProcessing.value) return;

    isProcessing.value = true;
    EasyLoading.show(status: 'camera.scanning'.tr);

    try {
      final file = await cameraController!.takePicture();
      
      // 本地 OCR
      final inputImage = InputImage.fromFilePath(file.path);
      final result = await textRecognizer.processImage(inputImage);
      final ocrText = result.text;

      EasyLoading.dismiss();

      // 跳转到归档结果页
      Get.toNamed(Routes.archiveResult, arguments: {
        'imagePath': file.path,
        'ocrText': ocrText,
      });
    } catch (e) {
      EasyLoading.showError('拍照失败');
    } finally {
      isProcessing.value = false;
    }
  }

  @override
  void onClose() {
    cameraController?.dispose();
    textRecognizer.close();
    super.onClose();
  }
}
