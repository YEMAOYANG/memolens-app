import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/routes/app_routes.dart';
import '../../../shared/models/record.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('home.title'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => Get.toNamed(Routes.search),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Get.toNamed(Routes.settings),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.records.isEmpty && !controller.isLoading.value) {
          return _buildEmpty();
        }
        return RefreshIndicator(
          onRefresh: controller.onRefresh,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.records.length + 1,
            itemBuilder: (context, index) {
              if (index == controller.records.length) {
                return _buildLoadMore();
              }
              return _buildRecordCard(controller.records[index]);
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(Routes.camera),
        icon: const Icon(Icons.camera_alt_rounded),
        label: const Text('扫描'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) Get.toNamed(Routes.gallery);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: '首页'),
          BottomNavigationBarItem(icon: Icon(Icons.photo_library_rounded), label: '相册'),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_rounded, size: 80, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text(
            'home.empty'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMore() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget _buildRecordCard(Record record) {
    return GestureDetector(
      onTap: () => Get.toNamed('${Routes.detail}/${record.id}'),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 缩略图
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: record.thumbnailUrl ?? record.imageUrl,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    width: 72,
                    height: 72,
                    color: Colors.grey.shade200,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // 内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 类型标签
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getTypeColor(record.contentType).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        record.contentTypeName,
                        style: TextStyle(
                          fontSize: 11,
                          color: _getTypeColor(record.contentType),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // 摘要
                    Text(
                      record.summary ?? record.ocrText ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                    const SizedBox(height: 4),

                    // 时间
                    Text(
                      _formatDate(record.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),

              // 更多按钮
              IconButton(
                icon: const Icon(Icons.more_vert_rounded, size: 20),
                onPressed: () => _showActions(record),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'whiteboard': return AppColors.typeWhiteboard;
      case 'business_card': return AppColors.typeCard;
      case 'document': return AppColors.typeDocument;
      case 'receipt': return AppColors.typeReceipt;
      case 'menu': return AppColors.typeMenu;
      default: return AppColors.primary;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes} 分钟前';
    if (diff.inDays < 1) return '${diff.inHours} 小时前';
    if (diff.inDays < 7) return '${diff.inDays} 天前';
    return '${date.month}/${date.day}';
  }

  void _showActions(Record record) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
              title: const Text('删除', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Get.back();
                controller.deleteRecord(record.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
