import 'package:flutter/material.dart';

import '../features/job_opportunities/model/job_item_vo.dart';

/// JOB CARD
class JobCardView extends StatelessWidget {
  const JobCardView({required this.job, this.onView});

  final JobItemVO job;
  final VoidCallback? onView;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Left: job info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(job.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.place_outlined, size: 18),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        job.city,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tt.bodyMedium,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text('• ${job.type}',
                        style: tt.bodyMedium?.copyWith(color: Colors.grey[600])),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Posted ${job.postedDaysAgo} day${job.postedDaysAgo == 1 ? '' : 's'} ago',
                  style: tt.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          /// Right: button
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 108),
            child: FilledButton(
              onPressed: onView,
              style: FilledButton.styleFrom(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('View Now'),
            ),
          ),
        ],
      ),
    );
  }
}