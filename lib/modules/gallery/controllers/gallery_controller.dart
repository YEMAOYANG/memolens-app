import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../../shared/api/api_client.dart';
import '../../../shared/models/record.dart';

enum GalleryViewMode { grid, list, timeline }

class GalleryController extends GetxController {
  final _api = Get.find<ApiClient>();

  final records = <Record>[].obs;
  final isLoading = false.obs;
  final viewMode = GalleryViewMode.grid.obs;
  final isSelectMode = false.obs;
  final selectedIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRecords();
  }

  Future<void> fetchRecords() async {
    isLoading.value = true;
    try {
      final response = await _api.get('/records', params: {'limit': 100});
      final List data = response.data['data'] ?? [];
      records.value = data.map((e) => Record.fromJson(e)).toList();
    } catch (e) {
      // 错误已处理
    } finally {
      isLoading.value = false;
    }
  }

  void toggleViewMode(GalleryViewMode mode) {
    viewMode.value = mode;
  }

  void toggleSelectMode() {
    isSelectMode.value = !isSelectMode.value;
    if (!isSelectMode.value) selectedIds.clear();
  }

  void toggleSelect(String id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }
  }

  void selectAll() {
    if (selectedIds.length == records.length) {
      selectedIds.clear();
    } else {
      selectedIds.addAll(records.map((r) => r.id));
    }
  }

  Future<void> deleteSelected() async {
    if (selectedIds.isEmpty) return;

    EasyLoading.show(status: '删除中...');
    try {
      for (final id in selectedIds) {
        await _api.delete('/records/$id');
      }
      records.removeWhere((r) => selectedIds.contains(r.id));
      selectedIds.clear();
      isSelectMode.value = false;
      EasyLoading.showSuccess('已删除');
    } catch (e) {
      EasyLoading.showError('删除失败');
    }
  }
}
