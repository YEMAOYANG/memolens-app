import 'package:flutter/material.dart';
import '../../../app/theme.dart';

class settingsPage extends StatelessWidget {
  const settingsPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: Center(child: Text('settings — 开发中', style: const TextStyle(color: AppColors.textSecondary))),
  );
}
