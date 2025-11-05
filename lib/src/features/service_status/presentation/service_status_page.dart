import 'package:eps_client/src/features/service_status/data/service_status_repository.dart';
import 'package:eps_client/src/features/service_status/presentation/service_status_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../../../widgets/error_tetry_view.dart';

class ServiceStatusPage extends ConsumerWidget {
  const ServiceStatusPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    ///provider states
    final customerServiceStatusState = ref.watch(
      fetchAllCustomerServiceStatusProvider,
    );

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ---- Header OUTSIDE the LayoutBuilder ----
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Text(
                'Service Status',
                style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(height: 10),

            /// Fill remaining height
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return customerServiceStatusState.when(
                    // ---------- DATA ----------
                    data: (customerServices) => SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: customerServices.data?.length ?? 0,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final item = customerServices.data![i];
                          return _CustomerServiceTile(
                            serviceName: item.serviceName ?? '-',
                            agentName: item.agentName ?? '-',
                            cost: item.serviceCost ?? '0',
                            status: item.status ?? 0,
                            updatedAt: item.updatedAt,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ServiceStatusDetailsPage(id: item.id),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),

                    /// ---------- ERROR (centered) ----------
                    error: (error, stack) => SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Center(
                          child: ErrorRetryView(
                            title: 'Error loading customer service status',
                            message: error.toString(),
                            onRetry: () => ref.refresh(fetchAllCustomerServiceStatusProvider),
                          ),
                        ),
                      ),
                    ),

                    /// ---------- LOADING (centered) ----------
                    loading: () => SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _CustomerServiceTile({
  required String serviceName,
  required String agentName,
  required String cost,
  required int status,
  dynamic updatedAt,
  VoidCallback? onTap,
}) {
  return Builder(
    builder: (context) {
      final cs = Theme.of(context).colorScheme;
      final tt = Theme.of(context).textTheme;

      String _fmtDate(dynamic v) {
        DateTime? d;
        if (v is DateTime) d = v;
        if (v is String) {
          d = DateTime.tryParse(v);
        }
        if (d == null) return '-';
        const m = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        return '${d.day.toString().padLeft(2, '0')} ${m[d.month - 1]} ${d.year}';
      }

      String _statusLabel(int s) => s == 1 ? 'Active' : 'Inactive';
      Color _statusColor(int s) =>
          s == 1 ? const Color(0xFF50B463) : cs.outline;

      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Row(
              children: [
                /// Left: icon box
                Container(
                  width: 54,
                  height: 48,
                  decoration: BoxDecoration(
                    color: cs.surfaceVariant.withOpacity(.35),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.assignment_turned_in_outlined),
                ),
                const SizedBox(width: 12),

                /// Middle: info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Service name
                      Text(
                        serviceName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),

                      /// Agent + cost
                      Row(
                        children: [
                          const Icon(Icons.person_outline, size: 16),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              agentName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: tt.bodyMedium,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '\u0E3F $cost',
                            style: tt.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      /// Date + status chip
                      Row(
                        children: [
                          Text(
                            'Updated ${_fmtDate(updatedAt)}',
                            style: tt.bodySmall?.copyWith(color: cs.outline),
                          ),
                          const Spacer(),
                          // Container(
                          //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          //   decoration: BoxDecoration(
                          //     color: _statusColor(status).withOpacity(.12),
                          //     borderRadius: BorderRadius.circular(999),
                          //     border: Border.all(color: _statusColor(status)),
                          //   ),
                          //   child: Text(
                          //     _statusLabel(status),
                          //     style: tt.labelSmall?.copyWith(
                          //       color: _statusColor(status),
                          //       fontWeight: FontWeight.w700,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ),
      );
    },
  );
}
