import 'package:flutter/material.dart';
import '../../../app/theme.dart';

class galleryPage extends StatelessWidget {
  const galleryPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: Center(child: Text('gallery — 开发中', style: const TextStyle(color: AppColors.textSecondary))),
  );
}
