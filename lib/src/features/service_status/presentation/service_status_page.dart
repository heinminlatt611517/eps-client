import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ServiceStatusPage extends StatelessWidget {
  const ServiceStatusPage({
    super.key,
    this.serviceName,
    this.agentName,
    this.priceLabel,
    this.currentStage,
    this.updates = const [],
  });

  final String? serviceName;
  final String? agentName;
  final String? priceLabel;
  final StatusStage? currentStage;
  final List<StatusUpdate> updates;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final stage = currentStage ?? StatusStage.processing;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Service Status',
                  style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),

              // Details card
              _ServiceCard(
                title: serviceName ?? 'Service Name',
                subtitle: agentName ?? 'Agent Name',
                priceLabel: priceLabel ?? '\$ 200',
              ),
              const SizedBox(height: 16),

              // Step progress
              _StageProgress(current: stage),
              const SizedBox(height: 8),

              Center(
                child: Text(
                  stage.label,
                  style:
                  tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 24),

              Text('Updates',
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),

              if (updates.isEmpty) ...[
                Text('No updates yet',
                    style: tt.bodyMedium?.copyWith(color: cs.outline)),
              ] else ...[
                for (final u in updates) ...[
                  _UpdateTile(update: u),
                  const SizedBox(height: 16),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// ───────────────────── Models & helpers ─────────────────────

enum StatusStage { received, processing, readyForPickup, completed }

extension on StatusStage {
  String get label => switch (this) {
    StatusStage.received => 'Received',
    StatusStage.processing => 'In Progress',
    StatusStage.readyForPickup => 'Ready for Pickup',
    StatusStage.completed => 'Completed',
  };
}

/// Update item
class StatusUpdate {
  final String? title;
  final DateTime? time;
  const StatusUpdate({this.title, this.time});

  String timeAgo() {
    final t = time ?? DateTime.now();
    final now = DateTime.now();
    final diff = now.difference(t);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';

    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dayOnly = DateTime(t.year, t.month, t.day);
    if (dayOnly == yesterday) return 'Yesterday';
    return DateFormat.MMMMd().format(t);
  }
}

/// ───────────────────── UI pieces ─────────────────────

///service card view
class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.title,
    required this.subtitle,
    required this.priceLabel,
  });

  final String title;
  final String subtitle;
  final String priceLabel;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: cs.surfaceVariant.withOpacity(.5),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DefaultTextStyle(
              style: tt.bodyMedium!,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style:
                      tt.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: tt.bodyMedium?.copyWith(color: cs.outline)),
                ],
              ),
            ),
          ),
          Text(priceLabel, style: tt.titleMedium),
        ],
      ),
    );
  }
}

///state progress view
class _StageProgress extends StatelessWidget {
  const _StageProgress({required this.current});
  final StatusStage current;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final labels = const [
      'Received',
      'Processing',
      'Ready for Pickup',
      'Completed',
    ];

    int idx = StatusStage.values.indexOf(current);

    Widget dot(bool active) => Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: active ? cs.onPrimary : cs.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: active ? cs.primary : cs.outlineVariant,
          width: 6,
        ),
      ),
    );

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(4, (i) => dot(i <= idx)),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            4,
                (i) => SizedBox(
              width: MediaQuery.of(context).size.width / 5.6,
              child: Text(
                labels[i],
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: cs.outline),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

///update tile view
class _UpdateTile extends StatelessWidget {
  const _UpdateTile({required this.update});
  final StatusUpdate update;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          update.title ?? '—',
          style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(update.timeAgo(), style: tt.bodySmall?.copyWith(color: cs.outline)),
      ],
    );
  }
}
