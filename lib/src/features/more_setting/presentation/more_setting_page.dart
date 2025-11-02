import 'package:eps_client/src/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';

import '../../../utils/secure_storage.dart';
import '../../../widgets/circle_icon_view.dart';
import '../../../widgets/setting_tile_view.dart';
import '../../dashboard/controller/dashboard_controller.dart';

class MoreSettingsPage extends ConsumerWidget {
  const MoreSettingsPage({super.key});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('More'),
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          SettingsTile(
            leading: CircleIcon(icon: Icons.language, color: cs.primary),
            title: kLabelChangeLanguage,
            onTap: () {
            },
          ),
          const SizedBox(height: 8),

          SettingsTile(
            leading: CircleIcon(icon: Icons.share_outlined, color: cs.primary),
            title: kLabelShareApp,
            subtitle: kLabelInviteFriendToTry,
            onTap: () async {
              debugPrint('Share app tapped');
            },
          ),
          const SizedBox(height: 8),

          SettingsTile(
            leading: CircleIcon(icon: Icons.chat_bubble_outline, color: cs.primary),
            title: kLabelChatWithUs,
            trailing: _OnlineChip(),
            onTap: () {
            },
          ),
          const SizedBox(height: 8),

          SettingsTile(
            leading: CircleIcon(icon: Icons.help_outline, color: cs.primary),
            title: kLabelFaqs,
            onTap: () {

            },
          ),
          const SizedBox(height: 12),

          SettingsTile(
            leading: CircleIcon(icon: Icons.description_outlined, color: cs.primary),
            title: kLabelTermAndCondition,
            bordered: true,
            onTap: () {

            },
          ),
          const SizedBox(height: 16),

          SettingsTile(
            leading: CircleIcon(icon: Icons.logout, color: cs.error),
            title: kLabelLogout,
            showChevron: false,
            onTap: () async {
              final ok = await _confirmLogout(context);
              if (ok == true) {
                await GetStorage()
                    .remove(SecureDataList.isAlreadyLogin.name);
                ref
                    .read(secureStorageProvider)
                    .saveAuthStatus(kAuthNotLoggedIn);
                ref.invalidate(secureStorageProvider);
                ref.invalidate(dashboardControllerProvider);
              }
            },
          ),
        ],
      ),
    );
  }
}

/// ---------- “Online” chip ----------
class _OnlineChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Online',
        style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// ---------- Logout confirm ----------
Future<bool?> _confirmLogout(BuildContext context) {
  final cs = Theme.of(context).colorScheme;
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Log out?'),
      content: const Text('You will need to sign in again to use the app.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: FilledButton.styleFrom(backgroundColor: cs.error, foregroundColor: cs.onError),
          child: const Text('Log out'),
        ),
      ],
    ),
  );
}
