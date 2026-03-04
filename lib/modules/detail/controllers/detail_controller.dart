import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../../shared/api/api_client.dart';
import '../../../shared/models/record.dart';

class DetailController extends GetxController {
  final _api = Get.find<ApiClient>();

  final record = Rxn<Record>();
  final isLoading = true.obs;

  String get recordId => Get.parameters['id'] ?? '';

  @override
  void onInit() {
    super.onInit();
    fetchRecord();
  }

  Future<void> fetchRecord() async {
    isLoading.value = true;
    try {
      final response = await _api.get('/records/$recordId');
      record.value = Record.fromJson(response.data);
    } catch (e) {
      EasyLoading.showError('加载失败');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> copyOcrText() async {
    if (record.value?.ocrText == null) return;
    await Clipboard.setData(ClipboardData(text: record.value!.ocrText!));
    EasyLoading.showSuccess('detail.copied'.tr);
  }

  Future<void> deleteRecord() async {
    EasyLoading.show(status: '删除中...');
    try {
      await _api.delete('/records/$recordId');
      EasyLoading.showSuccess('已删除');
      Get.back();
    } catch (e) {
      // 错误已处理
    }
  }
}
