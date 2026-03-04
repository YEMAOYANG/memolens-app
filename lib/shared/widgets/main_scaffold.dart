import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';

class MainScaffold extends StatelessWidget {
  final StatefulNavigationShell shell;
  const MainScaffold({super.key, required this.shell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: _BottomNav(
        currentIndex: shell.currentIndex,
        onTap: (index) => shell.goBranch(
          index,
          initialLocation: index == shell.currentIndex,
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: const Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.home_rounded,      label: '首页',   index: 0, current: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.search_rounded,    label: '问答',   index: 2, current: currentIndex, onTap: onTap),
              // 中间相机大按钮
              GestureDetector(
                onTap: () => onTap(1),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    gradient: AppGradients.primary,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Color(0x405B5FEF), blurRadius: 16, offset: Offset(0, 6))],
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 26),
                ),
              ),
              _NavItem(icon: Icons.photo_library_rounded, label: '相册', index: 3, current: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.person_rounded,    label: '我的',   index: 4, current: currentIndex, onTap: onTap),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int current;
  final ValueChanged<int> onTap;
  const _NavItem({required this.icon, required this.label, required this.index, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isActive = current == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: isActive ? AppColors.primary : AppColors.textTertiary, size: 24),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: isActive ? AppColors.primary : AppColors.textTertiary, fontWeight: isActive ? FontWeight.w600 : FontWeight.w400)),
        ]),
      ),
    );
  }
}
