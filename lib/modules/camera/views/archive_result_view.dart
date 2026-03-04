import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/routes/app_routes.dart';
import '../../../shared/api/api_client.dart';

class ArchiveResultView extends StatefulWidget {
  const ArchiveResultView({super.key});

  @override
  State<ArchiveResultView> createState() => _ArchiveResultViewState();
}

class _ArchiveResultViewState extends State<ArchiveResultView> {
  final _api = Get.find<ApiClient>();

  late String imagePath;
  late String ocrText;

  bool isAnalyzing = true;
  String? contentType;
  String? summary;
  List<String> tags = [];
  final tagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    imagePath = args['imagePath'];
    ocrText = args['ocrText'] ?? '';
    _analyze();
  }

  Future<void> _analyze() async {
    try {
      // 上传图片 + 调用 AI 分析
      final response = await _api.upload('/records', imagePath, extraData: {
        'ocr_text': ocrText,
      });

      final data = response.data;
      setState(() {
        contentType = data['content_type'];
        summary = data['summary'];
        tags = List<String>.from(data['tags'] ?? []);
        isAnalyzing = false;
      });
    } catch (e) {
      setState(() => isAnalyzing = false);
      EasyLoading.showError('分析失败');
    }
  }

  void _addTag() {
    final tag = tagController.text.trim();
    if (tag.isNotEmpty && !tags.contains(tag)) {
      setState(() => tags.add(tag));
      tagController.clear();
    }
  }

  void _removeTag(String tag) {
    setState(() => tags.remove(tag));
  }

  Future<void> _save() async {
    EasyLoading.showSuccess('archive.success'.tr);
    Get.offAllNamed(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('archive.title'.tr),
        actions: [
          TextButton(
            onPressed: isAnalyzing ? null : _save,
            child: Text(
              'save'.tr,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图片预览
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(imagePath),
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),

            // AI 分析状态
            if (isAnalyzing)
              Center(
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    Text('archive.analyzing'.tr),
                  ],
                ),
              )
            else ...[
              // 摘要
              Text(
                'archive.summary'.tr,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.lightBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  summary ?? '暂无摘要',
                  style: const TextStyle(fontSize: 14, height: 1.6),
                ),
              ),
              const SizedBox(height: 24),

              // 标签
              Text(
                'archive.tags'.tr,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...tags.map((tag) => Chip(
                    label: Text(tag),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => _removeTag(tag),
                  )),
                  // 添加标签按钮
                  ActionChip(
                    avatar: const Icon(Icons.add, size: 18),
                    label: Text('archive.add_tag'.tr),
                    onPressed: () {
                      Get.dialog(AlertDialog(
                        title: Text('archive.add_tag'.tr),
                        content: TextField(
                          controller: tagController,
                          autofocus: true,
                          decoration: const InputDecoration(hintText: '输入标签'),
                          onSubmitted: (_) {
                            _addTag();
                            Get.back();
                          },
                        ),
                        actions: [
                          TextButton(onPressed: Get.back, child: Text('cancel'.tr)),
                          TextButton(
                            onPressed: () {
                              _addTag();
                              Get.back();
                            },
                            child: Text('confirm'.tr),
                          ),
                        ],
                      ));
                    },
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
