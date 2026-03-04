import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../shared/api/api_client.dart';
import '../../../shared/api/models/record.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});
  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _ctrl = TextEditingController();
  final _focusNode = FocusNode();
  bool _isLoading = false;
  String? _answer;
  List<Record> _sources = [];
  String _displayedAnswer = '';
  final List<String> _history = ['上周那张白板写了什么？', '那个客户叫什么名字？', '餐厅菜单有什么推荐？'];

  Future<void> _ask(String q) async {
    if (q.trim().isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() { _isLoading = true; _answer = null; _displayedAnswer = ''; _sources = []; });
    try {
      final api = ref.read(apiClientProvider);
      final result = await api.ask(q.trim());
      final answer = result['answer'] as String? ?? '';
      final sources = (result['sources'] as List? ?? []).map((e) => Record.fromJson(e as Map<String, dynamic>)).toList();
      setState(() { _isLoading = false; _answer = answer; _sources = sources; });
      _typeWriter(answer);
    } catch (e) {
      setState(() { _isLoading = false; _answer = '查询失败：$e'; });
    }
  }

  void _typeWriter(String text) async {
    for (int i = 0; i <= text.length; i++) {
      await Future.delayed(const Duration(milliseconds: 20));
      if (!mounted) return;
      setState(() => _displayedAnswer = text.substring(0, i));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('AI 问答'), backgroundColor: AppColors.background),
      body: Column(children: [
        // 搜索框
        Padding(padding: const EdgeInsets.fromLTRB(16, 4, 16, 16), child: Container(
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border), boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 8)]),
          child: Row(children: [
            const SizedBox(width: 14),
            const Icon(Icons.search_rounded, color: AppColors.textTertiary),
            const SizedBox(width: 8),
            Expanded(child: TextField(
              controller: _ctrl,
              focusNode: _focusNode,
              decoration: const InputDecoration(hintText: '问你的记忆…', border: InputBorder.none, hintStyle: TextStyle(color: AppColors.textTertiary)),
              onSubmitted: _ask,
            )),
            if (_ctrl.text.isNotEmpty)
              IconButton(onPressed: () { _ctrl.clear(); setState(() {}); }, icon: const Icon(Icons.close_rounded, color: AppColors.textTertiary, size: 18)),
            Container(margin: const EdgeInsets.all(6), decoration: const BoxDecoration(gradient: AppGradients.primary, borderRadius: BorderRadius.all(Radius.circular(10))),
              child: IconButton(
                onPressed: () => _ask(_ctrl.text),
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                padding: EdgeInsets.zero,
              )),
          ]),
        )),

        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _isLoading
            ? Padding(padding: const EdgeInsets.only(top: 60), child: Column(children: [
                Container(width: 64, height: 64, decoration: const BoxDecoration(gradient: AppGradients.primary, shape: BoxShape.circle), child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 28)),
                const SizedBox(height: 16),
                const Text('正在检索你的记忆…', style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
              ]))
            : _answer != null
              ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // AI 回答
                  Container(padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF0C0C18), Color(0xFF1A0F2E)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(16)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Container(width: 28, height: 28, decoration: const BoxDecoration(gradient: AppGradients.primary, shape: BoxShape.circle), child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 14)),
                        const SizedBox(width: 8),
                        const Text('AI 回答', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                      ]),
                      const SizedBox(height: 12),
                      Text(_displayedAnswer, style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.7)),
                    ])),
                  // 来源
                  if (_sources.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text('来源记录', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                    const SizedBox(height: 10),
                    SizedBox(height: 120, child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _sources.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (_, i) {
                        final r = _sources[i];
                        return GestureDetector(
                          onTap: () => context.go('/detail/${r.id}'),
                          child: Container(width: 200, padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(r.contentType ?? '其他', style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(r.aiSummary ?? r.ocrText ?? '', style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4), maxLines: 3, overflow: TextOverflow.ellipsis),
                            ]),
                          ),
                        );
                      },
                    )),
                  ],
                ])
              : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('历史问题', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                  const SizedBox(height: 10),
                  ..._history.map((q) => GestureDetector(
                    onTap: () { _ctrl.text = q; _ask(q); },
                    child: Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                      child: Row(children: [
                        const Icon(Icons.history_rounded, color: AppColors.textTertiary, size: 18),
                        const SizedBox(width: 10),
                        Text(q, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                      ]),
                    ),
                  )),
                ]),
        )),
      ]),
    );
  }
}
