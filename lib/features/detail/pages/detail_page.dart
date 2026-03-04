import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../shared/api/api_client.dart';
import '../../../shared/api/models/record.dart';
import '../../../shared/widgets/tag_chip.dart';

final recordDetailProvider = FutureProvider.family<Record, String>((ref, id) async {
  return ref.read(apiClientProvider).getRecord(id);
});

class DetailPage extends ConsumerWidget {
  final String recordId;
  const DetailPage({super.key, required this.recordId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(recordDetailProvider(recordId));
    return Scaffold(
      backgroundColor: AppColors.background,
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Scaffold(appBar: AppBar(), body: Center(child: Text('加载失败：$e'))),
        data: (record) => _DetailBody(record: record),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  final Record record;
  const _DetailBody({required this.record});

  Color _typeColor(String? type) => switch (type) {
    'whiteboard'    => AppColors.whiteboard,
    'business_card' => AppColors.card,
    'document'      => AppColors.success,
    'receipt'       => AppColors.accent,
    'menu'          => AppColors.error,
    _ => AppColors.textSecondary,
  };

  String _typeLabel(String? type) => switch (type) {
    'whiteboard'    => '📋 白板',
    'business_card' => '💼 名片',
    'document'      => '📄 文档',
    'receipt'       => '🧾 票据',
    'menu'          => '🍽️ 菜单',
    _ => '📷 其他',
  };

  String _formatDate(DateTime dt) =>
    '${dt.year}年${dt.month}月${dt.day}日 ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';

  @override
  Widget build(BuildContext context) {
    final typeColor = _typeColor(record.contentType);
    return CustomScrollView(slivers: [
      // Hero 图片头
      SliverAppBar(
        expandedHeight: 280,
        pinned: true,
        backgroundColor: Colors.black,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(margin: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18)),
        ),
        actions: [
          GestureDetector(
            onTap: () {},
            child: Container(margin: const EdgeInsets.all(8), width: 38, height: 38, decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: const Icon(Icons.share_rounded, color: Colors.white, size: 18)),
          ),
        ],
        flexibleSpace: FlexibleSpaceBar(
          background: CachedNetworkImage(imageUrl: record.imageUrl, fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: Colors.black12),
            errorWidget: (_, __, ___) => Container(color: AppColors.background, child: const Icon(Icons.image_not_supported_rounded, size: 48, color: AppColors.textTertiary)),
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.all(20),
        sliver: SliverList(delegate: SliverChildListDelegate([
          // 类型 + 时间
          Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: typeColor.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
              child: Text(_typeLabel(record.contentType), style: TextStyle(color: typeColor, fontWeight: FontWeight.w700, fontSize: 13))),
            const Spacer(),
            Text(_formatDate(record.createdAt), style: const TextStyle(color: AppColors.textTertiary, fontSize: 13)),
          ]),
          const SizedBox(height: 16),

          // AI 摘要
          _InfoCard(title: '✨ AI 摘要', child: Text(record.aiSummary ?? '（无摘要）', style: const TextStyle(fontSize: 15, height: 1.7))),
          const SizedBox(height: 12),

          // 标签
          if (record.tags.isNotEmpty) ...[
            _InfoCard(title: '🏷️ 标签', child: Wrap(spacing: 8, runSpacing: 8, children: record.tags.map((t) => TagChip(label: t)).toList())),
            const SizedBox(height: 12),
          ],

          // 名片 metadata
          if (record.contentType == 'business_card' && record.metadata != null) ...[
            _InfoCard(title: '💼 名片信息', child: Column(children: [
              if (record.metadata!['name'] != null) _MetaRow(Icons.person_rounded, '姓名', record.metadata!['name'].toString()),
              if (record.metadata!['title'] != null) _MetaRow(Icons.work_rounded, '职位', record.metadata!['title'].toString()),
              if (record.metadata!['company'] != null) _MetaRow(Icons.business_rounded, '公司', record.metadata!['company'].toString()),
              if (record.metadata!['phone'] != null) _MetaRow(Icons.phone_rounded, '电话', record.metadata!['phone'].toString()),
              if (record.metadata!['email'] != null) _MetaRow(Icons.email_rounded, '邮箱', record.metadata!['email'].toString()),
            ])),
            const SizedBox(height: 12),
          ],

          // 票据 metadata
          if (record.contentType == 'receipt' && record.metadata != null) ...[
            _InfoCard(title: '🧾 票据信息', child: Column(children: [
              if (record.metadata!['total'] != null) _MetaRow(Icons.payments_rounded, '金额', '¥${record.metadata!['total']}'),
              if (record.metadata!['merchant'] != null) _MetaRow(Icons.store_rounded, '商户', record.metadata!['merchant'].toString()),
              if (record.metadata!['date'] != null) _MetaRow(Icons.calendar_today_rounded, '日期', record.metadata!['date'].toString()),
            ])),
            const SizedBox(height: 12),
          ],

          // OCR 原文
          _InfoCard(
            title: '📝 识别原文',
            action: TextButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: record.ocrText ?? ''));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已复制'), behavior: SnackBarBehavior.floating));
              },
              icon: const Icon(Icons.copy_rounded, size: 14),
              label: const Text('复制'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary, padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            ),
            child: Text(record.ocrText?.isEmpty ?? true ? '（未识别到文字）' : record.ocrText!, style: const TextStyle(fontSize: 13, height: 1.7, color: AppColors.textSecondary)),
          ),
          const SizedBox(height: 24),

          // 删除
          OutlinedButton.icon(
            onPressed: () => showDialog(context: context, builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('确认删除'),
              content: const Text('删除后无法恢复，确定吗？'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
                TextButton(onPressed: () { Navigator.pop(context); context.pop(); }, child: const Text('删除', style: TextStyle(color: AppColors.error))),
              ],
            )),
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            label: const Text('删除记录'),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), minimumSize: const Size(double.infinity, 48)),
          ),
          const SizedBox(height: 40),
        ])),
      ),
    ]);
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? action;
  const _InfoCard({required this.title, required this.child, this.action});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity, padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
        if (action != null) ...[const Spacer(), action!],
      ]),
      const SizedBox(height: 10), child,
    ]),
  );
}

class _MetaRow extends StatelessWidget {
  final IconData icon; final String label; final String value;
  const _MetaRow(this.icon, this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      Icon(icon, size: 15, color: AppColors.primary), const SizedBox(width: 8),
      Text('$label：', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
    ]),
  );
}
