import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../shared/api/api_client.dart';
import '../../../shared/api/models/record.dart';

enum _ViewMode { grid, list, timeline }

final _galleryProvider = FutureProvider<List<Record>>((ref) async {
  return ref.read(apiClientProvider).getRecords();
});

class GalleryPage extends ConsumerStatefulWidget {
  const GalleryPage({super.key});
  @override
  ConsumerState<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends ConsumerState<GalleryPage> {
  _ViewMode _view = _ViewMode.grid;
  bool _multiSelect = false;
  final Set<String> _selected = {};
  String? _filterType;

  static const _types = [null, 'whiteboard', 'business_card', 'document', 'receipt', 'menu'];
  static const _typeLabels = ['全部', '白板', '名片', '文档', '票据', '菜单'];

  Color _typeColor(String? type) => switch (type) {
    'whiteboard'    => AppColors.whiteboard,
    'business_card' => AppColors.card,
    'document'      => AppColors.success,
    'receipt'       => AppColors.accent,
    'menu'          => AppColors.error,
    _ => AppColors.textSecondary,
  };

  String _shortLabel(String? type) => switch (type) {
    'whiteboard'    => '白板',
    'business_card' => '名片',
    'document'      => '文档',
    'receipt'       => '票据',
    'menu'          => '菜单',
    _ => '其他',
  };

  void _toggleSelect(String id) {
    setState(() => _selected.contains(id) ? _selected.remove(id) : _selected.add(id));
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_galleryProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('相册'),
        actions: [
          // 视图切换
          if (!_multiSelect) ...[
            IconButton(icon: Icon(_view == _ViewMode.grid ? Icons.view_list_rounded : _view == _ViewMode.list ? Icons.view_timeline_rounded : Icons.grid_view_rounded), onPressed: () => setState(() => _view = _ViewMode.values[(_view.index + 1) % 3])),
            TextButton(onPressed: () => setState(() { _multiSelect = true; }), child: const Text('选择', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600))),
          ] else ...[
            TextButton(onPressed: () => setState(() { _multiSelect = false; _selected.clear(); }), child: const Text('完成', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600))),
          ],
        ],
      ),
      body: Column(children: [
        // 类型筛选
        SizedBox(height: 44, child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _types.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final isSelected = _filterType == _types[i];
            return GestureDetector(
              onTap: () => setState(() => _filterType = _types[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppGradients.primary : null,
                  color: isSelected ? null : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? Colors.transparent : AppColors.border),
                ),
                alignment: Alignment.center,
                child: Text(_typeLabels[i], style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.textSecondary)),
              ),
            );
          },
        )),
        const SizedBox(height: 12),

        // 内容区
        Expanded(child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('加载失败：$e')),
          data: (all) {
            final records = _filterType == null ? all : all.where((r) => r.contentType == _filterType).toList();
            if (records.isEmpty) return const Center(child: Text('暂无记录', style: TextStyle(color: AppColors.textSecondary)));
            return switch (_view) {
              _ViewMode.grid     => _GridView(records: records, selected: _selected, multiSelect: _multiSelect, onTap: _onTap, typeColor: _typeColor, shortLabel: _shortLabel),
              _ViewMode.list     => _ListView(records: records, selected: _selected, multiSelect: _multiSelect, onTap: _onTap, shortLabel: _shortLabel, typeColor: _typeColor),
              _ViewMode.timeline => _TimelineView(records: records, onTap: _onTap),
            };
          },
        )),
      ]),

      // 多选底部操作栏
      bottomNavigationBar: _multiSelect && _selected.isNotEmpty
        ? SafeArea(child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: BoxDecoration(color: AppColors.surface, border: const Border(top: BorderSide(color: AppColors.border))),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _ActionBtn(Icons.share_rounded, '分享', AppColors.primary, () {}),
              _ActionBtn(Icons.label_outline_rounded, '标签', AppColors.accent, () {}),
              _ActionBtn(Icons.delete_outline_rounded, '删除', AppColors.error, () {}),
            ]),
          ))
        : null,
    );
  }

  void _onTap(String id) {
    if (_multiSelect) { _toggleSelect(id); } else { context.go('/detail/$id'); }
  }
}

// 网格视图
class _GridView extends StatelessWidget {
  final List<Record> records;
  final Set<String> selected;
  final bool multiSelect;
  final void Function(String) onTap;
  final Color Function(String?) typeColor;
  final String Function(String?) shortLabel;
  const _GridView({required this.records, required this.selected, required this.multiSelect, required this.onTap, required this.typeColor, required this.shortLabel});

  @override
  Widget build(BuildContext context) => GridView.builder(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 4, mainAxisSpacing: 4),
    itemCount: records.length,
    itemBuilder: (_, i) {
      final r = records[i];
      final isSelected = selected.contains(r.id);
      return GestureDetector(
        onTap: () => onTap(r.id),
        onLongPress: () {},
        child: Stack(fit: StackFit.expand, children: [
          ClipRRect(borderRadius: BorderRadius.circular(8), child: CachedNetworkImage(imageUrl: r.imageUrl, fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: AppColors.border),
            errorWidget: (_, __, ___) => Container(color: AppColors.background, child: const Icon(Icons.image_not_supported_rounded, color: AppColors.textTertiary)),
          )),
          // 类型标签
          Positioned(top: 6, left: 6, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: typeColor(r.contentType), borderRadius: BorderRadius.circular(6)),
            child: Text(shortLabel(r.contentType), style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
          )),
          // 选中覆盖
          if (multiSelect) Positioned.fill(child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withOpacity(0.4) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent, width: 2),
            ),
            child: isSelected ? const Center(child: Icon(Icons.check_circle_rounded, color: Colors.white, size: 24)) : null,
          )),
        ]),
      );
    },
  );
}

// 列表视图
class _ListView extends StatelessWidget {
  final List<Record> records;
  final Set<String> selected;
  final bool multiSelect;
  final void Function(String) onTap;
  final String Function(String?) shortLabel;
  final Color Function(String?) typeColor;
  const _ListView({required this.records, required this.selected, required this.multiSelect, required this.onTap, required this.shortLabel, required this.typeColor});

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    itemCount: records.length,
    separatorBuilder: (_, __) => const SizedBox(height: 8),
    itemBuilder: (_, i) {
      final r = records[i];
      final isSelected = selected.contains(r.id);
      final color = typeColor(r.contentType);
      return GestureDetector(
        onTap: () => onTap(r.id),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.08) : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
          ),
          child: Row(children: [
            ClipRRect(borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
              child: CachedNetworkImage(imageUrl: r.imageUrl, width: 72, height: 72, fit: BoxFit.cover,
                placeholder: (_, __) => Container(width: 72, height: 72, color: AppColors.border),
                errorWidget: (_, __, ___) => Container(width: 72, height: 72, color: AppColors.background, child: const Icon(Icons.image_not_supported_rounded, color: AppColors.textTertiary)),
              )),
            Expanded(child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                    child: Text(shortLabel(r.contentType), style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w700))),
                  const Spacer(),
                  Text('${r.createdAt.month}/${r.createdAt.day}', style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                ]),
                const SizedBox(height: 6),
                Text(r.aiSummary ?? r.ocrText ?? '', style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                if (r.tags.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(r.tags.take(3).map((t) => '#$t').join(' '), style: const TextStyle(fontSize: 11, color: AppColors.primary), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ]),
            )),
            if (multiSelect) Padding(padding: const EdgeInsets.only(right: 12), child: Icon(isSelected ? Icons.check_circle_rounded : Icons.circle_outlined, color: isSelected ? AppColors.primary : AppColors.border)),
          ]),
        ),
      );
    },
  );
}

// 时间线视图
class _TimelineView extends StatelessWidget {
  final List<Record> records;
  final void Function(String) onTap;
  const _TimelineView({required this.records, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // 按日期分组
    final Map<String, List<Record>> grouped = {};
    for (final r in records) {
      final key = '${r.createdAt.year}年${r.createdAt.month}月${r.createdAt.day}日';
      grouped.putIfAbsent(key, () => []).add(r);
    }
    final dates = grouped.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: dates.length,
      itemBuilder: (_, i) {
        final date = dates[i];
        final dayRecords = grouped[date]!;
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsets.only(bottom: 8, top: 4), child: Text(date, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary))),
          SizedBox(
            height: 130,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: dayRecords.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, j) {
                final r = dayRecords[j];
                return GestureDetector(
                  onTap: () => onTap(r.id),
                  child: ClipRRect(borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(imageUrl: r.imageUrl, width: 120, height: 120, fit: BoxFit.cover,
                      placeholder: (_, __) => Container(width: 120, height: 120, color: AppColors.border),
                      errorWidget: (_, __, ___) => Container(width: 120, height: 120, color: AppColors.background, child: const Icon(Icons.image_not_supported_rounded)),
                    )),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ]);
      },
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn(this.icon, this.label, this.color, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: color, size: 24),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
    ]),
  );
}
