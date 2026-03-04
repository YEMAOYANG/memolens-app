import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/api/api_client.dart';
import '../../../shared/api/models/record.dart';

final recordsProvider = FutureProvider.family<List<Record>, String?>((ref, type) async {
  final api = ref.read(apiClientProvider);
  return api.getRecords(type: type);
});
