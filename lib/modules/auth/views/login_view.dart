import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../controllers/auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                
                // Logo
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 32,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 32),

                // 标题
                Text(
                  'login.title'.tr,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 48),

                // 手机号输入
                _buildInputField(
                  controller: controller.phoneController,
                  hint: 'login.phone'.tr,
                  keyboardType: TextInputType.phone,
                  maxLength: 11,
                ),
                const SizedBox(height: 16),

                // 验证码输入
                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        controller: controller.codeController,
                        hint: 'login.code'.tr,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Obx(() => SizedBox(
                      width: 120,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: controller.canSendCode.value
                            ? controller.sendCode
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          disabledBackgroundColor: Colors.white.withOpacity(0.1),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          controller.countdown.value > 0
                              ? '${controller.countdown.value}s'
                              : 'login.send_code'.tr,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    )),
                  ],
                ),
                const SizedBox(height: 32),

                // 登录按钮
                SizedBox(
                  width: double.infinity,
                  child: Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value ? null : controller.login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            'login.login'.tr,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  )),
                ),

                const Spacer(),

                // 协议
                Center(
                  child: Text.rich(
                    TextSpan(
                      text: 'login.agreement'.tr,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.6),
                      ),
                      children: [
                        TextSpan(
                          text: ' ${'login.terms'.tr}',
                          style: const TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()..onTap = () {},
                        ),
                        TextSpan(text: ' ${'login.and'.tr} '),
                        TextSpan(
                          text: 'login.privacy'.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()..onTap = () {},
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        counterText: '',
        filled: true,
        fillColor: Colors.white.withOpacity(0.15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
