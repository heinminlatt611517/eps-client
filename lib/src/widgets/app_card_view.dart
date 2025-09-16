import 'package:flutter/material.dart';

/// ---------- Parent reusable card ----------
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(14),
  });

  final Widget? child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surface,
      elevation: 0,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            color: cs.surfaceVariant.withOpacity(.25),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}