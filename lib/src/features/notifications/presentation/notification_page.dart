import 'package:eps_client/src/common_widgets/custom_app_bar_view.dart';
import 'package:eps_client/src/features/notifications/data/notification_repository.dart';
import 'package:eps_client/src/utils/gap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../../../widgets/error_tetry_view.dart';
import '../model/notification_response.dart';

/// Page name per image instruction: **NotificationsPage**
class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    /// provider state
    final notificationState = ref.watch(fetchAllNotificationsProvider);

    return Scaffold(
      appBar: CustomAppBarView(title: 'Notifications'),
      body: SafeArea(
        child: notificationState.when(
          data: (notificationResponse) {
            final list = notificationResponse.data ?? <NotificationVO>[];

            if (list.isEmpty) {
              return Center(
                child: Text('No notifications yet', style: tt.bodyMedium),
              );
            }

            /// ---- Group into Today / This Week ----
            final now = DateTime.now();
            final today = <_UiNotification>[];
            final thisWeek = <_UiNotification>[];

            for (final n in list) {
              final created = n.createdAt;
              if (created == null) continue;

              final isSameDay =
                  created.year == now.year &&
                  created.month == now.month &&
                  created.day == now.day;

              final diff = now.difference(created).inDays;

              final ui = _UiNotification(
                vo: n,
                timeAgo: _formatTimeAgo(now, created),
              );

              if (isSameDay) {
                today.add(ui);
              } else if (diff >= 1 && diff < 7) {
                thisWeek.add(ui);
              }
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                14.vGap,

                /// Today
                if (today.isNotEmpty) ...[
                  Text(
                    'Today',
                    style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  for (final n in today) ...[
                    NotificationTile(n: n),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 16),
                ],

                /// This Week
                if (thisWeek.isNotEmpty) ...[
                  Text(
                    'This Week',
                    style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  for (final n in thisWeek) ...[
                    NotificationTile(n: n),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 24),
                ],

                if (today.isEmpty && thisWeek.isEmpty)
                  Center(
                    child: Text(
                      'No recent notifications',
                      style: tt.bodyMedium,
                    ),
                  ),

                /// (Optional) Coming Soon block – can keep or remove
                // if (today.isNotEmpty || thisWeek.isNotEmpty) ...[
                //   Center(
                //     child: Column(
                //       children: [
                //         Icon(
                //           Icons.lock_outline,
                //           size: 64,
                //           color: cs.outline.withOpacity(.9),
                //         ),
                //         const SizedBox(height: 12),
                //         Text(
                //           'Coming Soon !',
                //           style: tt.titleMedium?.copyWith(
                //             fontWeight: FontWeight.w900,
                //           ),
                //         ),
                //         const SizedBox(height: 8),
                //         SizedBox(
                //           width: 320,
                //           child: Text(
                //             'This feature will be available in a future update. Stay tuned !',
                //             textAlign: TextAlign.center,
                //             style: tt.bodyMedium?.copyWith(color: cs.outline),
                //           ),
                //         ),
                //         const SizedBox(height: 16),
                //         SizedBox(
                //           width: 220,
                //           child: FilledButton(
                //             onPressed: () {
                //               ScaffoldMessenger.of(context).showSnackBar(
                //                 const SnackBar(content: Text('Got it')),
                //               );
                //             },
                //             child: const Text('Got it'),
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ],
              ],
            );
          },
          error: (error, stackTrace) => ErrorRetryView(
            title: 'Error loading notifications',
            message: error.toString(),
            onRetry: () => ref.invalidate(fetchAllNotificationsProvider),
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

/// Simple UI wrapper: NotificationVO + timeAgo string
class _UiNotification {
  final NotificationVO vo;
  final String timeAgo;

  _UiNotification({required this.vo, required this.timeAgo});
}

/// Reusable list tile for a notifications
class NotificationTile extends StatelessWidget {
  const NotificationTile({super.key, required this.n});

  final _UiNotification n;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final vo = n.vo;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Leading icon box
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: cs.surfaceVariant.withOpacity(.35),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.notifications_none_rounded, color: cs.outline),
        ),
        const SizedBox(width: 12),

        /// Title + message
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                vo.title ?? '—',
                style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                vo.body ?? '',
                style: tt.bodyMedium?.copyWith(color: cs.outline),
              ),
            ],
          ),
        ),

        /// Time ago
        const SizedBox(width: 8),
        Text(n.timeAgo, style: tt.bodySmall?.copyWith(color: cs.outline)),
      ],
    );
  }
}

/// Helper to format "time ago"
String _formatTimeAgo(DateTime now, DateTime date) {
  final diff = now.difference(date);

  if (diff.inSeconds < 60) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}
