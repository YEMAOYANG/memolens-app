import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../../app/theme.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/api/api_client.dart';
import '../../../shared/db/hive_boxes.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _phoneCtrl = TextEditingController();
  final _codeCtrl  = TextEditingController();
  bool _codeSent   = false;
  bool _loading    = false;
  int  _countdown  = 0;
  Timer? _timer;

  @override
  void dispose() { _phoneCtrl.dispose(); _codeCtrl.dispose(); _timer?.cancel(); super.dispose(); }

  Future<void> _sendCode() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.length != 11) {
      _showSnack('请输入正确的手机号');
      return;
    }
    setState(() => _loading = true);
    try {
      final api = ref.read(apiClientProvider);
      await api.sendCode(phone);
      setState(() { _codeSent = true; _countdown = 60; });
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (_countdown <= 1) { t.cancel(); setState(() => _countdown = 0); }
        else setState(() => _countdown--);
      });
    } catch (e) {
      _showSnack('发送失败：$e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _verify() async {
    final phone = _phoneCtrl.text.trim();
    final code  = _codeCtrl.text.trim();
    if (code.length != 6) { _showSnack('请输入6位验证码'); return; }
    setState(() => _loading = true);
    try {
      final api = ref.read(apiClientProvider);
      final token = await api.verify(phone, code);
      await HiveBoxes.saveToken(token);
      if (mounted) context.go('/home');
    } catch (e) {
      _showSnack('验证失败：验证码错误或已过期');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showSnack(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 60),
          // Logo
          ShaderMask(
            shaderCallback: (r) => AppGradients.primary.createShader(r),
            child: const Text('MemoLens', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white)),
          ),
          const SizedBox(height: 8),
          const Text('登录 / 注册', style: TextStyle(fontSize: 16, color: Colors.white54)),
          const SizedBox(height: 48),

          // 手机号
          _Label('手机号'),
          const SizedBox(height: 8),
          _Input(
            controller: _phoneCtrl,
            hint: '请输入手机号',
            keyboardType: TextInputType.phone,
            maxLength: 11,
            enabled: !_codeSent,
            prefix: const Padding(padding: EdgeInsets.only(right: 8), child: Text('+86', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600))),
          ),
          const SizedBox(height: 20),

          // 验证码
          if (_codeSent) ...[
            _Label('验证码'),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _Input(controller: _codeCtrl, hint: '6位验证码', keyboardType: TextInputType.number, maxLength: 6)),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _countdown > 0 ? null : _sendCode,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: _countdown > 0 ? Colors.white12 : AppColors.primary.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _countdown > 0 ? '${_countdown}s' : '重新发送',
                    style: TextStyle(color: _countdown > 0 ? Colors.white38 : AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 32),
            GradientButton(text: _loading ? '验证中…' : '登录 / 注册', onTap: _loading ? null : _verify),
          ] else ...[
            const SizedBox(height: 32),
            GradientButton(text: _loading ? '发送中…' : '获取验证码', onTap: _loading ? null : _sendCode),
          ],

          const Spacer(),
          Center(child: Text('登录即同意 隐私政策 与 使用条款', style: const TextStyle(fontSize: 12, color: Colors.white24))),
          const SizedBox(height: 24),
        ]),
      )),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white54));
}

class _Input extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final int? maxLength;
  final bool enabled;
  final Widget? prefix;
  const _Input({required this.controller, required this.hint, this.keyboardType, this.maxLength, this.enabled = true, this.prefix});

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: keyboardType,
    maxLength: maxLength,
    enabled: enabled,
    inputFormatters: [if (keyboardType == TextInputType.phone || keyboardType == TextInputType.number) FilteringTextInputFormatter.digitsOnly],
    style: const TextStyle(color: Colors.white, fontSize: 16),
    decoration: InputDecoration(
      counterText: '',
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white24),
      prefixIcon: prefix != null ? Padding(padding: const EdgeInsets.only(left: 16, right: 0), child: prefix) : null,
      prefixIconConstraints: const BoxConstraints(),
      contentPadding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      filled: true,
      fillColor: Colors.white.withOpacity(0.06),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.08))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.08))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
      disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.04))),
    ),
  );
}
