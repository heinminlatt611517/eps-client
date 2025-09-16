import 'package:flutter/material.dart';

import 'app_card_view.dart';

/// ---------- Service card (uses AppCard) ----------
class ServiceCard extends StatelessWidget {
  const ServiceCard({
    super.key,
    required this.icon,
    required this.title,
    this.enabled = true,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    final base = cs.surfaceVariant.withOpacity(.25);
    final bg = enabled ? base : base.withOpacity(.2);
    final fg = enabled ? cs.onSurface : cs.outline;

    return AppCard(
      onTap: enabled ? onTap : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: cs.onSurface),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: DefaultTextStyle(
              style: t.bodyMedium!.copyWith(color: fg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Text('Explore',
                      style: t.labelLarge?.copyWith(
                        color: Colors.teal,
                        fontWeight: FontWeight.w700,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}