import 'package:flutter/material.dart';
import '../../../app/theme.dart';

class detailPage extends StatelessWidget {
  const detailPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: Center(child: Text('detail — 开发中', style: const TextStyle(color: AppColors.textSecondary))),
  );
}
