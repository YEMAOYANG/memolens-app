import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/gradient_button.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _ctrl = PageController();
  int _page = 0;

  static const _slides = [
    _Slide(
      emoji: '📷',
      title: '拍一下，存入脑',
      desc: '用摄像头扫描名片、白板、文件、菜单…\nAI 自动识别内容类型并归档，3 秒完成。',
      bgColor: Color(0xFF0C0C18),
      accentColor: Color(0xFF5B5FEF),
    ),
    _Slide(
      emoji: '✨',
      title: 'AI 智能归档',
      desc: '自动提取关键信息、生成摘要、打上标签。\n名片联系人、票据金额，一键结构化。',
      bgColor: Color(0xFF0F0A1E),
      accentColor: Color(0xFF8B5CF6),
    ),
    _Slide(
      emoji: '🔍',
      title: '随时找回',
      desc: '用自然语言提问「上周那张白板写了什么」\nAI 秒级回答，附带原图来源，永不遗忘。',
      bgColor: Color(0xFF0A1218),
      accentColor: Color(0xFF10B981),
    ),
  ];

  void _next() {
    if (_page < _slides.length - 1) {
      _ctrl.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _slides[_page].bgColor,
      body: Stack(children: [
        // 页面内容
        PageView.builder(
          controller: _ctrl,
          onPageChanged: (i) => setState(() => _page = i),
          itemCount: _slides.length,
          itemBuilder: (_, i) => _SlidePage(slide: _slides[i]),
        ),

        // 底部控制
        Positioned(
          left: 0, right: 0, bottom: 0,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                // 指示点
                Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(
                  _slides.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: i == _page ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: i == _page ? _slides[_page].accentColor : Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                )),
                const SizedBox(height: 28),
                // 按钮
                GradientButton(
                  text: _page == _slides.length - 1 ? '开始使用 →' : '下一步',
                  onTap: _next,
                ),
                const SizedBox(height: 12),
                if (_page < _slides.length - 1)
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('跳过', style: TextStyle(color: Colors.white38, fontSize: 14)),
                  ),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

class _Slide {
  final String emoji;
  final String title;
  final String desc;
  final Color bgColor;
  final Color accentColor;
  const _Slide({required this.emoji, required this.title, required this.desc, required this.bgColor, required this.accentColor});
}

class _SlidePage extends StatelessWidget {
  final _Slide slide;
  const _SlidePage({super.key, required this.slide});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      color: slide.bgColor,
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 160),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        // 大 Emoji + 光晕
        Container(
          width: 160, height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [slide.accentColor.withOpacity(0.2), Colors.transparent]),
          ),
          child: Center(child: Text(slide.emoji, style: const TextStyle(fontSize: 80))),
        ),
        const SizedBox(height: 40),
        Text(slide.title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2, letterSpacing: -0.5)),
        const SizedBox(height: 16),
        Text(slide.desc,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Colors.white54, height: 1.7)),
      ]),
    );
  }
}
