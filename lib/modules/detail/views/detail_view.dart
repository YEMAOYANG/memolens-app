import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import '../../../app/theme/app_theme.dart';
import '../controllers/detail_controller.dart';

class DetailView extends GetView<DetailController> {
  const DetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('详情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () {
              Get.dialog(AlertDialog(
                title: const Text('确认删除'),
                content: const Text('删除后无法恢复'),
                actions: [
                  TextButton(onPressed: Get.back, child: Text('cancel'.tr)),
                  TextButton(
                    onPressed: () {
                      Get.back();
                      controller.deleteRecord();
                    },
                    child: Text('delete'.tr, style: TextStyle(color: AppColors.error)),
                  ),
                ],
              ));
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final record = controller.record.value;
        if (record == null) {
          return const Center(child: Text('记录不存在'));
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 图片（可缩放）
              GestureDetector(
                onTap: () => Get.to(() => _FullScreenImage(url: record.imageUrl)),
                child: Hero(
                  tag: 'image_${record.id}',
                  child: CachedNetworkImage(
                    imageUrl: record.imageUrl,
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 类型 + 时间
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            record.contentTypeName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${record.createdAt.month}/${record.createdAt.day} ${record.createdAt.hour}:${record.createdAt.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(fontSize: 13, color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 摘要
                    if (record.summary != null) ...[
                      const Text(
                        'AI 摘要',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
                          record.summary!,
                          style: const TextStyle(fontSize: 14, height: 1.6),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // 标签
                    if (record.tags.isNotEmpty) ...[
                      const Text(
                        '标签',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: record.tags.map((tag) => Chip(label: Text(tag))).toList(),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // OCR 文字
                    if (record.ocrText != null && record.ocrText!.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('detail.ocr_text'.tr, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          TextButton.icon(
                            onPressed: controller.copyOcrText,
                            icon: const Icon(Icons.copy_rounded, size: 16),
                            label: Text('detail.copy'.tr),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.lightBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SelectableText(
                          record.ocrText!,
                          style: const TextStyle(fontSize: 13, height: 1.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _FullScreenImage extends StatelessWidget {
  final String url;
  const _FullScreenImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PhotoView(
        imageProvider: CachedNetworkImageProvider(url),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 3,
      ),
    );
  }
}
