import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/quota_bar.dart';
import '../providers/records_provider.dart';
import '../widgets/memo_card.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String? _selectedType;
  final _types = [null, 'whiteboard', 'business_card', 'document', 'receipt', 'menu'];
  final _typeLabels = ['全部', '白板', '名片', '文档', '票据', '菜单'];

  @override
  Widget build(BuildContext context) {
    final recordsAsync = ref.watch(recordsProvider(_selectedType));
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(slivers: [
        // 顶部
        SliverAppBar(
          expandedHeight: 120,
          floating: true,
          snap: true,
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            title: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
              const Text('MemoLens', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              // 配额栏
              const QuotaBar(used: 42, total: 200),
            ]),
          ),
          actions: [
            IconButton(onPressed: () => context.go('/search'), icon: const Icon(Icons.search_rounded, color: AppColors.textPrimary)),
          ],
        ),
        // 类型筛选
        SliverToBoxAdapter(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(children: List.generate(_types.length, (i) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _selectedType = _types[i]),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: _selectedType == _types[i] ? AppGradients.primary : null,
                    color: _selectedType == _types[i] ? null : AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _selectedType == _types[i] ? Colors.transparent : AppColors.border),
                  ),
                  child: Text(_typeLabels[i], style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600,
                    color: _selectedType == _types[i] ? Colors.white : AppColors.textSecondary,
                  )),
                ),
              ),
            ))),
          ),
        ),
        // 记录列表
        recordsAsync.when(
          loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
          error: (e, _) => SliverFillRemaining(child: Center(child: Text('加载失败：$e'))),
          data: (records) => records.isEmpty
            ? const SliverFillRemaining(child: Center(child: Text('暂无记录，拍张照片开始吧 📷', style: TextStyle(color: AppColors.textSecondary))))
            : SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(delegate: SliverChildBuilderDelegate(
                  (ctx, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: MemoCard(record: records[i], onTap: () => context.go('/detail/${records[i].id}')),
                  ),
                  childCount: records.length,
                )),
              ),
        ),
      ]),
    );
  }
}
