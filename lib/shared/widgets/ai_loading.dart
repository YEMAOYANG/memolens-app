import 'package:flutter/material.dart';
import '../../app/theme.dart';

class AiLoadingWidget extends StatefulWidget {
  final String? message;
  const AiLoadingWidget({super.key, this.message});
  @override
  State<AiLoadingWidget> createState() => _AiLoadingWidgetState();
}
class _AiLoadingWidgetState extends State<AiLoadingWidget> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _anim = Tween(begin: 0.3, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      AnimatedBuilder(animation: _anim, builder: (_, __) => Opacity(
        opacity: _anim.value,
        child: Container(
          width: 28, height: 28,
          decoration: const BoxDecoration(gradient: AppGradients.primary, shape: BoxShape.circle),
          child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 14),
        ),
      )),
      if (widget.message != null) ...[
        const SizedBox(width: 10),
        Text(widget.message!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
      ],
    ]);
  }
}
