import 'package:eps_client/src/common_widgets/custom_app_bar_view.dart';
import 'package:eps_client/src/features/job_opportunities/data/job_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../../../widgets/error_tetry_view.dart';

class JobDetailPage extends ConsumerWidget {
  const JobDetailPage({
    super.key,
    required this.id
  });

  final String id;

  @override
  Widget build(BuildContext context,WidgetRef ref) {

    ///job details data provider
    final agentDetailsDataProvider = ref.watch(
      fetchJobDetailByIdProvider(id: id ?? ''),
    );


    return Scaffold(
      appBar: CustomAppBarView(title: 'Job Detail'),
      body:
          agentDetailsDataProvider.when(data: (jobDetailResponse){
           return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// title
                  Text(
                    jobDetailResponse.data?.title ?? '',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  /// location + type
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoChip(
                        icon: Icons.place_outlined,
                        label: jobDetailResponse.data?.location ?? '',
                      ),
                      _InfoChip(
                        icon: Icons.work_outline,
                        label: jobDetailResponse.data?.type ?? '',
                      ),
                      _InfoChip(
                        icon: Icons.payments_outlined,
                        label: "${jobDetailResponse.data?.salary ?? ''} Ks",
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  /// updated date
                  Text(
                    "Updated: ${jobDetailResponse.data?.updatedAt ?? ''}",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Divider(),
                  const SizedBox(height: 16),

                  Text(
                    "Job Description",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                      jobDetailResponse.data?.description ?? '',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          },/// ---------- ERROR (centered) ----------
            error: (error, stack) => SingleChildScrollView(
              child: Center(
                child: ErrorRetryView(
                  title: 'Error loading job detail',
                  message: error.toString(),
                  onRetry: () => ref.invalidate(fetchJobDetailByIdProvider),
                ),
              ),
            ),

            /// ---------- LOADING (centered) ----------
            loading: () => SingleChildScrollView(
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
            ),)
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: Colors.grey[100],
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
    );
  }
}

