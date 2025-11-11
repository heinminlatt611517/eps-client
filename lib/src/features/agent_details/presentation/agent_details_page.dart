import 'package:eps_client/src/features/agent_details/data/agent_details_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../../../common_widgets/custom_app_bar_view.dart';
import '../../../widgets/error_tetry_view.dart';
class AgentDetailsPage extends ConsumerWidget {
  const AgentDetailsPage({
    super.key,
    this.id,
    this.onServiceTap,
    this.onViewCertification,
  });

  final String? id;
  final void Function(String service)? onServiceTap;
  final VoidCallback? onViewCertification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    ///agent details data provider
    final agentDetailsDataProvider = ref.watch(
      fetchAgentDetailsByIdProvider(id: id ?? ''),
    );

    return Scaffold(
      appBar: CustomAppBarView(title: 'Agent'),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return agentDetailsDataProvider.when(
              // ---------- DATA ----------
              data: (agent) {
                final cs = Theme.of(context).colorScheme;
                final tt = Theme.of(context).textTheme;

                final name = agent.data?.name ?? 'Agent';
                final rating = double.tryParse('${agent.data?.rating ?? 0}') ?? 0;
                final location = agent.data?.location ?? 'Location';
                final experienceYears = 1;
                final services = (agent.data?.services ?? [])
                    .map((e) => e.title ?? '')
                    .where((s) => s.isNotEmpty)
                    .toList();

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// header
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 112,
                              height: 112,
                              decoration: BoxDecoration(
                                color: cs.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: cs.outlineVariant, width: 3),
                              ),
                              child: const Icon(Icons.person, size: 64),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              name,
                              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            _RatingRow(rating: rating),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      /// info
                      _InfoRow(icon: Icons.place_outlined, text: location),
                      // const SizedBox(height: 8),
                      // _InfoRow(
                      //   icon: Icons.badge_outlined,
                      //   text: '$experienceYears years experience',
                      // ),
                      const SizedBox(height: 12),

                      /// services buttons
                      if (services.isNotEmpty)
                        Wrap(
                          spacing: 12,
                          runSpacing: 10,
                          children: services.map((s) {
                            return FilledButton(
                              onPressed: () => onServiceTap?.call(s),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: Text(s),
                            );
                          }).toList(),
                        ),

                      const SizedBox(height: 12),
                      const _SectionDivider(),

                      if ((agent.data?.reviews?.isNotEmpty ?? false))
                        Text('Reviews', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: agent.data?.reviews?.length ?? 0,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) =>
                            _SkeletonCard(height: 100, comment: agent.data?.reviews?[i].comment ?? ''),
                      ),
                    ],
                  ),
                );
              },

              /// ---------- ERROR (centered) ----------
              error: (error, stack) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: ErrorRetryView(
                      title: 'Error loading agent detail',
                      message: error.toString(),
                      onRetry: () => ref.invalidate(fetchAgentDetailsByIdProvider),
                    ),
                  ),
                ),
              ),

              /// ---------- LOADING (centered) ----------
              loading: () => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child:  Center(
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
            );
          },
        ),
      ),
    );
  }
}

/// ======= pieces =======

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, this.text});

  final IconData icon;
  final String? text;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: cs.onSurface),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text?.isNotEmpty == true ? text! : '—',
            style: tt.bodyLarge,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

///rating row view
class _RatingRow extends StatelessWidget {
  const _RatingRow({this.rating});

  final double? rating;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final r = (rating ?? 0).clamp(0, 5);

    int full = r.floor();
    num frac = r - full;
    bool half = frac >= .25 && frac < .75;
    if (frac >= .75) {
      full += 1;
      half = false;
    }
    final empty = 5 - full - (half ? 1 : 0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < full; i++)
          Icon(Icons.star, size: 18, color: cs.primary),
        if (half) Icon(Icons.star_half, size: 18, color: cs.primary),
        for (int i = 0; i < empty; i++)
          Icon(Icons.star_border, size: 18, color: cs.primary),
        const SizedBox(width: 6),
        Text(r.toStringAsFixed(1)),
      ],
    );
  }
}

///divider view
class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        height: 6,
        decoration: BoxDecoration(
          color: cs.surfaceVariant.withOpacity(.6),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

///card view
class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.height,required this.comment});
  final String comment;
  final double height;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: cs.surfaceVariant.withOpacity(.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(comment),
      ),
    );
  }
}
