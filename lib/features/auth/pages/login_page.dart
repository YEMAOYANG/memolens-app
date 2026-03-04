import 'package:flutter/material.dart';
import '../../../app/theme.dart';

class loginPage extends StatelessWidget {
  const loginPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: Center(child: Text('login — 开发中', style: const TextStyle(color: AppColors.textSecondary))),
  );
}
