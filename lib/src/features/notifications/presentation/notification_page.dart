import 'package:eps_client/src/common_widgets/custom_app_bar_view.dart';
import 'package:eps_client/src/utils/gap.dart';
import 'package:flutter/material.dart';

/// Page name per image instruction: **NotificationsPage**
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({
    super.key,
    this.today = const [],
    this.thisWeek = const [],
    this.onGotIt,
  });

  /// Provide lists or use the demo defaults below
  final List<AppNotification> today;
  final List<AppNotification> thisWeek;
  final VoidCallback? onGotIt;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final _today = today.isNotEmpty
        ? today
        : const [
            AppNotification(
              title: 'Visa Renewal Request Approved',
              message: 'Your request has been accepted',
              timeAgo: '2h ago',
              icon: Icons.description_outlined,
            ),
            AppNotification(
              title: 'Passport Expired',
              message: 'Your passport has expired',
              timeAgo: '2h ago',
              icon: Icons.public_outlined,
            ),
            AppNotification(
              title: 'Visa Renewal Service Completed',
              message: 'Your visa has been renewed',
              timeAgo: '2h ago',
              icon: Icons.description_outlined,
            ),
          ];

    final _week = thisWeek.isNotEmpty
        ? thisWeek
        : const [
            AppNotification(
              title: 'Document Uploaded',
              message: 'Your file was uploaded successfully',
              timeAgo: '2h ago',
              icon: Icons.description_outlined,
            ),
            AppNotification(
              title: 'Document Uploaded',
              message: 'Your file was uploaded successfully',
              timeAgo: '2h ago',
              icon: Icons.description_outlined,
            ),
          ];

    return Scaffold(
      ///app bar
      appBar: CustomAppBarView(title: 'Notifications'),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            14.vGap,
            /// Today
            Text(
              'Today',
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            for (final n in _today) ...[
              NotificationTile(n: n),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 8),

            /// This Week
            Text(
              'This Week',
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            for (final n in _week) ...[
              NotificationTile(n: n),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 24),

            /// Coming Soon block
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 64,
                    color: cs.outline.withOpacity(.9),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Coming Soon !',
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 320,
                    child: Text(
                      'This feature will be available in a future update. Stay tuned !',
                      textAlign: TextAlign.center,
                      style: tt.bodyMedium?.copyWith(color: cs.outline),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 220,
                    child: FilledButton(
                      onPressed:
                          onGotIt ??
                          () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Got it')),
                          ),
                      child: const Text('Got it'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Notification model
class AppNotification {
  final String? title;
  final String? message;
  final String? timeAgo;
  final IconData icon;

  const AppNotification({
    this.title,
    this.message,
    this.timeAgo,
    this.icon = Icons.notifications_none_rounded,
  });
}

/// Reusable list tile for a notifications
class NotificationTile extends StatelessWidget {
  const NotificationTile({super.key, required this.n});

  final AppNotification n;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

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
          child: Icon(n.icon, color: cs.outline),
        ),
        const SizedBox(width: 12),

        /// Title + message
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                n.title ?? '—',
                style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                n.message ?? '',
                style: tt.bodyMedium?.copyWith(color: cs.outline),
              ),
            ],
          ),
        ),

        /// Time ago
        const SizedBox(width: 8),
        Text(n.timeAgo ?? '', style: tt.bodySmall?.copyWith(color: cs.outline)),
      ],
    );
  }
}
