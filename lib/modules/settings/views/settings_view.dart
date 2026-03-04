import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('settings.title'.tr)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 用户卡片
          _buildUserCard(),
          const SizedBox(height: 24),

          // 配额
          _buildQuotaCard(),
          const SizedBox(height: 24),

          // 设置项
          _buildSection([
            _buildSwitchTile(
              icon: Icons.dark_mode_rounded,
              title: 'settings.theme'.tr,
              value: controller.isDarkMode,
              onChanged: controller.toggleDarkMode,
            ),
            _buildSwitchTile(
              icon: Icons.notifications_rounded,
              title: 'settings.notification'.tr,
              value: controller.isNotificationOn,
              onChanged: controller.toggleNotification,
            ),
          ]),
          const SizedBox(height: 16),

          _buildSection([
            _buildNavTile(
              icon: Icons.privacy_tip_rounded,
              title: 'settings.privacy'.tr,
              onTap: () {},
            ),
            _buildNavTile(
              icon: Icons.description_rounded,
              title: 'settings.terms'.tr,
              onTap: () {},
            ),
            _buildNavTile(
              icon: Icons.info_rounded,
              title: 'settings.about'.tr,
              subtitle: 'v1.0.0',
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 24),

          // 退出
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: controller.logout,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text('settings.logout'.tr),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard() {
    final user = controller.user;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.gradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Text(
              user?['nickname']?.substring(0, 1) ?? 'U',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?['nickname'] ?? '用户',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user?['phone'] ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          if (user?['is_pro'] == true)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'PRO',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuotaCard() {
    final user = controller.user;
    final quota = user?['quota'] ?? 200;
    final used = user?['monthly_used'] ?? 0;
    final remaining = quota - used;
    final percent = used / quota;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'settings.quota'.tr,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                Text(
                  '$remaining / $quota',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percent,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(
                  percent > 0.8 ? AppColors.warning : AppColors.primary,
                ),
                minHeight: 8,
              ),
            ),
            if (user?['is_pro'] != true) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text('settings.upgrade'.tr),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection(List<Widget> children) {
    return Card(
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required RxBool value,
    required Function(bool) onChanged,
  }) {
    return Obx(() => SwitchListTile(
      secondary: Icon(icon),
      title: Text(title),
      value: value.value,
      onChanged: onChanged,
    ));
  }

  Widget _buildNavTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
