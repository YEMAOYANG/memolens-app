import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../shared/api/api_client.dart';
import '../../../shared/api/models/record.dart';
import '../../../shared/db/hive_boxes.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/quota_bar.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('我的'), backgroundColor: AppColors.background),
      body: ListView(padding: const EdgeInsets.symmetric(horizontal: 16), children: [
        // 头像 + 用户信息
        const SizedBox(height: 8),
        _UserCard(),
        const SizedBox(height: 16),

        // Pro 升级横幅
        _ProBanner(),
        const SizedBox(height: 24),

        // 功能设置
        _SectionTitle('功能设置'),
        _ToggleItem(icon: Icons.smartphone_rounded, iconColor: AppColors.primary, title: '本地 OCR', subtitle: '在设备本地识别文字，更快更安全', value: true),
        _ToggleItem(icon: Icons.translate_rounded, iconColor: AppColors.accent, title: '自动翻译', subtitle: '识别外语内容时自动翻译为中文', value: false),
        _ToggleItem(icon: Icons.notifications_rounded, iconColor: AppColors.warning, title: '配额提醒', subtitle: '用量达到 80% 时提醒', value: true),
        const SizedBox(height: 24),

        // 数据管理
        _SectionTitle('数据管理'),
        _NavItem(icon: Icons.cloud_upload_rounded, iconColor: AppColors.info, title: '导出全部数据', subtitle: '导出为 JSON 格式'),
        _NavItem(icon: Icons.delete_sweep_rounded, iconColor: AppColors.error, title: '清空回收站', subtitle: '永久删除已删除的记录'),
        const SizedBox(height: 24),

        // 关于
        _SectionTitle('关于'),
        _NavItem(icon: Icons.star_rounded, iconColor: AppColors.warning, title: '给我们评分', subtitle: 'App Store / Google Play'),
        _NavItem(icon: Icons.share_rounded, iconColor: AppColors.primary, title: '分享给朋友'),
        _NavItem(icon: Icons.privacy_tip_rounded, iconColor: AppColors.textSecondary, title: '隐私政策'),
        _NavItem(icon: Icons.description_rounded, iconColor: AppColors.textSecondary, title: '使用条款'),
        _NavItem(icon: Icons.info_outline_rounded, iconColor: AppColors.textSecondary, title: '版本', subtitle: 'v1.0.0'),
        const SizedBox(height: 24),

        // 退出登录
        OutlinedButton(
          onPressed: () async {
            await HiveBoxes.clearToken();
            if (context.mounted) context.go('/login');
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text('退出登录', style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
        ),
        const SizedBox(height: 40),
      ]),
    );
  }
}

class _UserCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
    child: Row(children: [
      Container(
        width: 56, height: 56,
        decoration: const BoxDecoration(gradient: AppGradients.primary, shape: BoxShape.circle),
        child: const Center(child: Text('M', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800))),
      ),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('MemoLens 用户', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 2),
        const Text('Free 版本', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        const QuotaBar(used: 42, total: 200),
      ])),
    ]),
  );
}

class _ProBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFF0C0C18), Color(0xFF1A0F2E)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(16),
    ),
    padding: const EdgeInsets.all(20),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(gradient: AppGradients.primary, borderRadius: BorderRadius.circular(8)),
          child: const Text('Pro', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800))),
        const SizedBox(height: 8),
        const Text('解锁无限归档', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 4),
        const Text('无限额度 · 高级 AI · 知识图谱', style: TextStyle(fontSize: 13, color: Colors.white54)),
        const SizedBox(height: 14),
        SizedBox(
          height: 40,
          child: GradientButton(text: '首月 ¥9.9 升级 Pro →', onTap: () {}, borderRadius: 10, height: 40),
        ),
      ])),
    ]),
  );
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10, left: 4),
    child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.5)),
  );
}

class _ToggleItem extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final bool value;
  const _ToggleItem({required this.icon, required this.iconColor, required this.title, this.subtitle, required this.value});
  @override
  State<_ToggleItem> createState() => _ToggleItemState();
}
class _ToggleItemState extends State<_ToggleItem> {
  late bool _val;
  @override void initState() { super.initState(); _val = widget.value; }
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      leading: Container(width: 36, height: 36, decoration: BoxDecoration(color: widget.iconColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)), child: Icon(widget.icon, color: widget.iconColor, size: 18)),
      title: Text(widget.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      subtitle: widget.subtitle != null ? Text(widget.subtitle!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)) : null,
      trailing: CupertinoSwitch(value: _val, onChanged: (v) => setState(() => _val = v), activeColor: AppColors.primary),
    ),
  );
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  const _NavItem({required this.icon, required this.iconColor, required this.title, this.subtitle});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      leading: Container(width: 36, height: 36, decoration: BoxDecoration(color: iconColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: iconColor, size: 18)),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)) : null,
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
      onTap: () {},
    ),
  );
}
