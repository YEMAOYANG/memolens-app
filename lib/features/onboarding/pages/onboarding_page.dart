import 'package:flutter/material.dart';
import '../../../app/theme.dart';

class onuboardingPage extends StatelessWidget {
  const onuboardingPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: Center(child: Text('onboarding — 开发中', style: const TextStyle(color: AppColors.textSecondary))),
  );
}
