import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/api/api_client.dart';

class SearchPageController extends GetxController {
  final _api = Get.find<ApiClient>();
  final queryController = TextEditingController();

  final isLoading = false.obs;
  final answer = ''.obs;
  final sources = <Map<String, dynamic>>[].obs;

  Future<void> search() async {
    final query = queryController.text.trim();
    if (query.isEmpty) return;

    isLoading.value = true;
    answer.value = '';
    sources.clear();

    try {
      final response = await _api.post('/search/ask', data: {'query': query});
      final data = response.data;

      answer.value = data['answer'] ?? '';
      sources.value = List<Map<String, dynamic>>.from(data['sources'] ?? []);
    } catch (e) {
      answer.value = '抱歉，暂时无法回答这个问题';
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    queryController.dispose();
    super.onClose();
  }
}
