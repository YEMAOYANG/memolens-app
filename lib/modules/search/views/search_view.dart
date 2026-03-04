import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/routes/app_routes.dart';
import '../controllers/search_controller.dart';

class SearchView extends GetView<SearchPageController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('search.title'.tr)),
      body: Column(
        children: [
          // 搜索框
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: controller.queryController,
              decoration: InputDecoration(
                hintText: 'search.hint'.tr,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send_rounded),
                  onPressed: controller.search,
                ),
              ),
              onSubmitted: (_) => controller.search(),
            ),
          ),

          // 结果区
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.answer.value.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'search.examples'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                        height: 1.8,
                      ),
                    ),
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // AI 回答
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: AppColors.gradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        controller.answer.value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          height: 1.7,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 来源
                    if (controller.sources.isNotEmpty) ...[
                      const Text(
                        '来源',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...controller.sources.map((s) => _buildSourceCard(s)),
                    ],
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceCard(Map<String, dynamic> source) {
    return GestureDetector(
      onTap: () => Get.toNamed('${Routes.detail}/${source['id']}'),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: source['thumbnail_url'] ?? source['image_url'] ?? '',
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  source['summary'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
