import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../../shared/services/auth_service.dart';
import '../../../app/routes/app_routes.dart';

class AuthController extends GetxController {
  final _authService = Get.find<AuthService>();

  final phoneController = TextEditingController();
  final codeController = TextEditingController();

  final countdown = 0.obs;
  final canSendCode = true.obs;
  final isLoading = false.obs;

  Timer? _timer;

  bool get isPhoneValid => phoneController.text.length == 11;
  bool get isCodeValid => codeController.text.length >= 4;

  Future<void> sendCode() async {
    if (!isPhoneValid) {
      EasyLoading.showError('请输入正确的手机号');
      return;
    }

    final success = await _authService.sendCode(phoneController.text);
    if (success) {
      _startCountdown();
    }
  }

  void _startCountdown() {
    countdown.value = 60;
    canSendCode.value = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      countdown.value--;
      if (countdown.value <= 0) {
        timer.cancel();
        canSendCode.value = true;
      }
    });
  }

  Future<void> login() async {
    if (!isPhoneValid || !isCodeValid) {
      EasyLoading.showError('请填写完整信息');
      return;
    }

    isLoading.value = true;
    final success = await _authService.login(
      phoneController.text,
      codeController.text,
    );
    isLoading.value = false;

    if (success) {
      Get.offAllNamed(Routes.home);
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    phoneController.dispose();
    codeController.dispose();
    super.onClose();
  }
}
