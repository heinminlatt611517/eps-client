import 'package:eps_client/src/common_widgets/custom_app_bar_view.dart';
import 'package:eps_client/src/features/service_status/data/service_status_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../../../widgets/error_tetry_view.dart';

class ServiceStatusDetailsPage extends ConsumerWidget {
  const ServiceStatusDetailsPage({super.key, required this.id});
  final int? id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final detailsState =
    ref.watch(fetchServiceStatusDetailsByIdProvider(id: id.toString()));

    return Scaffold(
      appBar: const CustomAppBarView(title: 'Service Status Detail'),
      body: SafeArea(
        child: detailsState.when(
          data: (resp) {
            final d = resp.data;

            /// Top card info
            final serviceName = d?.serviceName ?? 'Service Name';
            final agentName = d?.agentName ?? 'Agent Name';
            final costLabel =
            d?.serviceCost == null ? '\$ —' : '\$ ${d!.serviceCost}';

            /// Stage from status (1..4)
            final stage = _stageFromStatus(d?.status);

            /// Map histories -> UI updates (newest first)
            final List<_UpdateVM> updates = (d?.histories ?? const [])
                .map<_UpdateVM>((h) => _UpdateVM(
              title: (h.note ?? '').trim().isEmpty
                  ? 'Updated'
                  : (h.note ?? ''),
              time: _tryParseDate(h.createdAt),
            ))
                .toList()
              ..sort((a, b) => (b.time ?? DateTime(0))
                  .compareTo(a.time ?? DateTime(0))); // newest first

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Service Status',
                      style:
                      tt.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 10),

                  _ServiceCard(
                    title: serviceName,
                    subtitle: agentName,
                    priceLabel: costLabel,
                  ),
                  const SizedBox(height: 16),

                  _StageProgress(current: stage),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      stage.label,
                      style:
                      tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(color: cs.outlineVariant),

                  const SizedBox(height: 16),
                  Text('Updates',
                      style: tt.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),

                  if (updates.isEmpty)
                    Text('No updates yet',
                        style: tt.bodyMedium?.copyWith(color: cs.outline))
                  else
                    ...updates.expand((u) => [
                      _UpdateTile(title: u.title, time: u.time),
                      const SizedBox(height: 16),
                      Divider(color: cs.outlineVariant),
                      const SizedBox(height: 4),
                    ]),
                ],
              ),
            );
          },
          error: (e, __) => ErrorRetryView(
            title: 'Error loading customer service details',
            message: e.toString(),
            onRetry: () =>
                ref.invalidate(fetchServiceStatusDetailsByIdProvider),
          ),
          loading: () => SizedBox(
            height: 200,
            child: Center(
              child: SizedBox(
                width: 36,
                height: 36,
                child: LoadingIndicator(
                  indicatorType: Indicator.ballBeat,
                  colors: [Theme.of(context).colorScheme.primary],
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ─────────── Stage mapping & label ───────────
enum StatusStage { received, processing, readyForPickup, completed }

extension on StatusStage {
  String get label => switch (this) {
    StatusStage.received => 'Received',
    StatusStage.processing => 'In Progress',
    StatusStage.readyForPickup => 'Ready for Pickup',
    StatusStage.completed => 'Completed',
  };
}

StatusStage _stageFromStatus(int? status) {
  switch (status) {
    case 1:
      return StatusStage.received;
    case 2:
      return StatusStage.processing;
    case 3:
      return StatusStage.readyForPickup;
    case 4:
      return StatusStage.completed;
    default:
      return StatusStage.processing; // sensible fallback
  }
}

/// ─────────── Small VMs / helpers ───────────
class _UpdateVM {
  final String title;
  final DateTime? time;
  _UpdateVM({required this.title, this.time});
}

DateTime? _tryParseDate(Object? v) {
  if (v is DateTime) return v;
  if (v is String && v.isNotEmpty) {
    try {
      return DateTime.parse(v);
    } catch (_) {}
  }
  return null;
}

String _timeAgo(DateTime? t) {
  if (t == null) return '';
  final now = DateTime.now();
  final diff = now.difference(t);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
  if (diff.inHours < 24) return '${diff.inHours} hours ago';
  final isYesterday = DateTime(t.year, t.month, t.day) ==
      DateTime(now.year, now.month, now.day - 1);
  if (isYesterday) return 'Yesterday';
  return DateFormat.MMMMd().format(t); // e.g., Apr 3
}

/// ─────────── UI pieces ───────────
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

class _StageProgress extends StatelessWidget {
  const _StageProgress({required this.current});
  final StatusStage current;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final labels = const [
      'Received',
      'Processing',
      'Ready for pickup',
      'Completed',
    ];
    final idx = StatusStage.values.indexOf(current);

    Widget dot(bool active) => Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: active ? cs.primary : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: active ? cs.primary : cs.outlineVariant,
          width: active ? 0 : 2,
        ),
      ),
    );

    Widget bar(bool active) => Expanded(
      child: Container(
        height: 2,
        color: active ? cs.primary : cs.outlineVariant,
      ),
    );

    return Column(
      children: [
        Row(
          children: [
            dot(0 <= idx),
            bar(1 <= idx),
            dot(1 <= idx),
            bar(2 <= idx),
            dot(2 <= idx),
            bar(3 <= idx),
            dot(3 <= idx),
          ],
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

class _UpdateTile extends StatelessWidget {
  const _UpdateTile({required this.title, this.time});
  final String title;
  final DateTime? time;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(_timeAgo(time), style: tt.bodySmall?.copyWith(color: cs.outline)),
      ],
    );
  }
}
