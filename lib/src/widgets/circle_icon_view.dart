import 'package:flutter/material.dart';

/// ---------- Small circular icon ----------
class CircleIcon extends StatelessWidget {
  const CircleIcon({super.key, required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: cs.surfaceVariant.withOpacity(.3),
      ),
      child: Icon(icon, color: color),
    );
  }
}
