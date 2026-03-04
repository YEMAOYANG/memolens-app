import 'package:flutter/material.dart';
import '../../app/theme.dart';

class QuotaBar extends StatelessWidget {
  final int used;
  final int total;
  const QuotaBar({super.key, required this.used, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = (used / total).clamp(0.0, 1.0);
    final isLow = pct >= 0.8;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('本月已用 $used / $total 张', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        if (isLow) const Text('即将用完', style: TextStyle(fontSize: 12, color: AppColors.warning, fontWeight: FontWeight.w600)),
      ]),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: pct,
          minHeight: 4,
          backgroundColor: AppColors.border,
          valueColor: AlwaysStoppedAnimation(isLow ? AppColors.warning : AppColors.primary),
        ),
      ),
    ]);
  }
}
