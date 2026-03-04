import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/routes/app_routes.dart';
import '../controllers/gallery_controller.dart';

class GalleryView extends GetView<GalleryController> {
  const GalleryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('gallery.title'.tr),
        actions: [
          // 视图切换
          Obx(() => PopupMenuButton<GalleryViewMode>(
            icon: Icon(_getViewIcon(controller.viewMode.value)),
            onSelected: controller.toggleViewMode,
            itemBuilder: (_) => [
              PopupMenuItem(
                value: GalleryViewMode.grid,
                child: Row(
                  children: [Icon(Icons.grid_view_rounded), SizedBox(width: 8), Text('gallery.grid'.tr)],
                ),
              ),
              PopupMenuItem(
                value: GalleryViewMode.list,
                child: Row(
                  children: [Icon(Icons.view_list_rounded), SizedBox(width: 8), Text('gallery.list'.tr)],
                ),
              ),
              PopupMenuItem(
                value: GalleryViewMode.timeline,
                child: Row(
                  children: [Icon(Icons.timeline_rounded), SizedBox(width: 8), Text('gallery.timeline'.tr)],
                ),
              ),
            ],
          )),
          // 选择模式
          Obx(() => IconButton(
            icon: Icon(controller.isSelectMode.value ? Icons.close : Icons.checklist_rounded),
            onPressed: controller.toggleSelectMode,
          )),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.records.isEmpty) {
          return const Center(child: Text('暂无记录'));
        }

        switch (controller.viewMode.value) {
          case GalleryViewMode.grid:
            return _buildGridView();
          case GalleryViewMode.list:
            return _buildListView();
          case GalleryViewMode.timeline:
            return _buildTimelineView();
        }
      }),
      bottomNavigationBar: Obx(() {
        if (!controller.isSelectMode.value) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: controller.selectAll,
                icon: const Icon(Icons.select_all_rounded),
                label: Text('gallery.select_all'.tr),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: controller.selectedIds.isEmpty ? null : controller.deleteSelected,
                icon: const Icon(Icons.delete_outline_rounded),
                label: Text('gallery.delete_selected'.tr),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              ),
            ],
          ),
        );
      }),
    );
  }

  IconData _getViewIcon(GalleryViewMode mode) {
    switch (mode) {
      case GalleryViewMode.grid: return Icons.grid_view_rounded;
      case GalleryViewMode.list: return Icons.view_list_rounded;
      case GalleryViewMode.timeline: return Icons.timeline_rounded;
    }
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: controller.records.length,
      itemBuilder: (_, i) => _buildGridItem(controller.records[i]),
    );
  }

  Widget _buildGridItem(record) {
    return Obx(() => GestureDetector(
      onTap: () {
        if (controller.isSelectMode.value) {
          controller.toggleSelect(record.id);
        } else {
          Get.toNamed('${Routes.detail}/${record.id}');
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: record.thumbnailUrl ?? record.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          if (controller.isSelectMode.value)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: controller.selectedIds.contains(record.id)
                      ? AppColors.primary
                      : Colors.white.withOpacity(0.8),
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: controller.selectedIds.contains(record.id)
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ),
        ],
      ),
    ));
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.records.length,
      itemBuilder: (_, i) {
        final record = controller.records[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: CachedNetworkImage(
                imageUrl: record.thumbnailUrl ?? record.imageUrl,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(record.summary ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(record.contentTypeName),
            onTap: () => Get.toNamed('${Routes.detail}/${record.id}'),
          ),
        );
      },
    );
  }

  Widget _buildTimelineView() {
    // 简化版时间线
    return _buildListView();
  }
}
