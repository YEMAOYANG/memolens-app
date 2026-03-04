import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../../shared/api/api_client.dart';
import '../../../shared/models/record.dart';

class HomeController extends GetxController {
  final _api = Get.find<ApiClient>();

  final records = <Record>[].obs;
  final isLoading = false.obs;
  final isRefreshing = false.obs;

  int _page = 1;
  bool _hasMore = true;

  @override
  void onInit() {
    super.onInit();
    fetchRecords();
  }

  Future<void> fetchRecords({bool refresh = false}) async {
    if (refresh) {
      _page = 1;
      _hasMore = true;
      isRefreshing.value = true;
    } else {
      if (!_hasMore || isLoading.value) return;
      isLoading.value = true;
    }

    try {
      final response = await _api.get('/records', params: {
        'page': _page,
        'limit': 20,
      });

      final List data = response.data['data'] ?? [];
      final list = data.map((e) => Record.fromJson(e)).toList();

      if (refresh) {
        records.value = list;
      } else {
        records.addAll(list);
      }

      _hasMore = list.length >= 20;
      _page++;
    } catch (e) {
      // 错误已在 ApiClient 处理
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  Future<void> onRefresh() => fetchRecords(refresh: true);

  Future<void> deleteRecord(String id) async {
    try {
      EasyLoading.show(status: '删除中...');
      await _api.delete('/records/$id');
      records.removeWhere((r) => r.id == id);
      EasyLoading.showSuccess('已删除');
    } catch (e) {
      // 错误已处理
    }
  }
}
