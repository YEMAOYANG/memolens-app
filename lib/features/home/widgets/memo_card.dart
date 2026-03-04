import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../app/theme.dart';
import '../../../shared/api/models/record.dart';

class MemoCard extends StatelessWidget {
  final Record record;
  final VoidCallback? onTap;
  const MemoCard({super.key, required this.record, this.onTap});

  Color _typeColor(String? type) => switch (type) {
    'whiteboard'   => AppColors.whiteboard,
    'business_card'=> AppColors.card,
    'document'     => AppColors.success,
    'receipt'      => AppColors.accent,
    'menu'         => AppColors.error,
    _ => AppColors.textSecondary,
  };

  String _typeLabel(String? type) => switch (type) {
    'whiteboard'   => '白板',
    'business_card'=> '名片',
    'document'     => '文档',
    'receipt'      => '票据',
    'menu'         => '菜单',
    _ => '其他',
  };

  @override
  Widget build(BuildContext context) {
    final typeColor = _typeColor(record.contentType);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Row(children: [
          // 图片缩略图
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
            child: CachedNetworkImage(
              imageUrl: record.imageUrl,
              width: 80, height: 80,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(width: 80, height: 80, color: AppColors.border),
              errorWidget: (_, __, ___) => Container(
                width: 80, height: 80, color: AppColors.background,
                child: const Icon(Icons.image_not_supported_rounded, color: AppColors.textTertiary),
              ),
            ),
          ),
          // 内容
          Expanded(child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(_typeLabel(record.contentType), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: typeColor)),
                ),
                const Spacer(),
                Text(
                  _formatDate(record.createdAt),
                  style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                ),
              ]),
              const SizedBox(height: 8),
              Text(
                record.aiSummary ?? record.ocrText ?? '无内容摘要',
                style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.4),
                maxLines: 2, overflow: TextOverflow.ellipsis,
              ),
              if (record.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(spacing: 6, children: record.tags.take(3).map((t) => Text(
                  '#$t', style: const TextStyle(fontSize: 12, color: AppColors.primary),
                )).toList()),
              ],
            ]),
          )),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
          const SizedBox(width: 8),
        ]),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return '今天 ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
    if (diff.inDays == 1) return '昨天';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    return '${dt.month}月${dt.day}日';
  }
}
