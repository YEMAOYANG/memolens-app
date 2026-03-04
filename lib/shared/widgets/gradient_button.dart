import 'package:flutter/material.dart';
import '../../app/theme.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final double height;
  final double borderRadius;
  final Widget? icon;
  const GradientButton({super.key, required this.text, this.onTap, this.height = 52, this.borderRadius = 14, this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: onTap != null ? AppGradients.primary : null,
          color: onTap == null ? AppColors.border : null,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: onTap != null ? const [BoxShadow(color: Color(0x405B5FEF), blurRadius: 16, offset: Offset(0, 6))] : null,
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (icon != null) ...[icon!, const SizedBox(width: 8)],
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}
