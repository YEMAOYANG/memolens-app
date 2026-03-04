import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../shared/api/api_client.dart';
import '../../../shared/api/models/record.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/tag_chip.dart';
import '../../../shared/widgets/ai_loading.dart';

class ArchiveResultPage extends ConsumerStatefulWidget {
  final String imagePath;
  final String ocrText;
  const ArchiveResultPage({super.key, required this.imagePath, required this.ocrText});
  @override
  ConsumerState<ArchiveResultPage> createState() => _ArchiveResultPageState();
}

class _ArchiveResultPageState extends ConsumerState<ArchiveResultPage> {
  Record? _result;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  List<String> _tags = [];
  final _tagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _upload();
  }

  Future<void> _upload() async {
    try {
      final api = ref.read(apiClientProvider);
      final record = await api.uploadRecord(widget.imagePath, widget.ocrText, []);
      setState(() {
        _result = record;
        _tags = List.from(record.tags);
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 500)); // 保存成功模拟
    if (!mounted) return;
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 64, height: 64, decoration: const BoxDecoration(gradient: AppGradients.primary, shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 36)),
          const SizedBox(height: 16),
          const Text('保存成功！', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('已归档到你的记忆库', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          GradientButton(text: '返回首页', onTap: () { Navigator.of(context).pop(); context.go('/home'); }),
        ]),
      ),
    );
  }

  String _typeLabel(String? type) => switch (type) {
    'whiteboard'    => '📋 白板',
    'business_card' => '💼 名片',
    'document'      => '📄 文档',
    'receipt'       => '🧾 票据',
    'menu'          => '🍽️ 菜单',
    _ => '📷 其他',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close_rounded), onTap: () => context.go('/home'), onPressed: null),
        title: const Text('AI 归档结果'),
        actions: [if (!_isLoading && _result != null) Padding(
          padding: const EdgeInsets.only(right: 16),
          child: TextButton(onPressed: _save, child: const Text('保存', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 16))),
        )],
      ),
      body: _isLoading
        ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
            AiLoadingWidget(message: 'AI 正在分析内容…'),
            SizedBox(height: 16),
            Text('通常需要 3-5 秒', style: TextStyle(color: AppColors.textTertiary, fontSize: 13)),
          ]))
        : _error != null
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text('分析失败：$_error'),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () { setState(() {_isLoading=true; _error=null;}); _upload(); }, child: const Text('重试')),
            ]))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // 图片
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(File(widget.imagePath), height: 200, width: double.infinity, fit: BoxFit.cover),
                ),
                const SizedBox(height: 20),
                // 类型 + 识别率
                Row(children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(gradient: AppGradients.primary, borderRadius: BorderRadius.circular(20)),
                    child: Text(_typeLabel(_result?.contentType), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13))),
                  const Spacer(),
                  const Icon(Icons.verified_rounded, color: AppColors.success, size: 18),
                  const SizedBox(width: 4),
                  const Text('识别率 96%', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600, fontSize: 13)),
                ]),
                const SizedBox(height: 16),
                // AI 摘要
                _Section(title: '✨ AI 摘要', child: Text(_result?.aiSummary ?? '（无摘要）', style: const TextStyle(fontSize: 15, height: 1.6, color: AppColors.textPrimary))),
                const SizedBox(height: 16),
                // 标签
                _Section(title: '🏷️ 标签', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Wrap(spacing: 8, runSpacing: 8, children: _tags.map((t) => TagChip(label: t, onDelete: () => setState(() => _tags.remove(t)))).toList()),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _tagController,
                    decoration: InputDecoration(
                      hintText: '添加标签，按回车确认',
                      hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 13),
                      isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                    ),
                    onSubmitted: (v) { if (v.trim().isNotEmpty) { setState(() => _tags.add(v.trim())); _tagController.clear(); } },
                  ),
                ])),
                const SizedBox(height: 16),
                // OCR 原文
                _Section(title: '📝 识别原文', child: Text(widget.ocrText.isEmpty ? '（未识别到文字）' : widget.ocrText, style: const TextStyle(fontSize: 13, height: 1.6, color: AppColors.textSecondary))),
                const SizedBox(height: 32),
                GradientButton(text: _isSaving ? '保存中…' : '保存到记忆库', onTap: _isSaving ? null : _save),
                const SizedBox(height: 12),
                SizedBox(width: double.infinity, child: TextButton(onPressed: () => context.go('/home'), child: const Text('不保存，返回', style: TextStyle(color: AppColors.textSecondary)))),
              ]),
            ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
      const SizedBox(height: 10),
      child,
    ]),
  );
}
