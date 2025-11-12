import 'package:eps_client/src/common_widgets/custom_app_bar_view.dart';
import 'package:eps_client/src/features/profile/data/profile_repository.dart';
import 'package:eps_client/src/features/profile/presentation/edit_profile_page.dart';
import 'package:eps_client/src/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../../../widgets/error_tetry_view.dart';

class CustomerProfilePage extends ConsumerWidget {
  const CustomerProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    List<Widget> section(String title, List<Widget> children) {
      final visible = children
          .where((w) => w.key != const ValueKey('__hidden'))
          .toList();
      if (visible.isEmpty) return const [];
      return [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(
            title,
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        ...visible,
      ];
    }

    Widget kv(String label, String? value, {IconData? icon}) {
      final v = (value ?? '').trim();
      if (v.isEmpty) return const SizedBox.shrink(key: ValueKey('__hidden'));
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: cs.primary),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: tt.labelLarge?.copyWith(
                      color: cs.outline,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    v,
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    ///state
    final profileDataState = ref.watch(fetchProfileDataProvider);

    return Scaffold(
      appBar: CustomAppBarView(title: 'Profile',
      trailing: TextButton(
        onPressed: profileDataState.maybeWhen(
          data: (profileData) => () async {
            final profile = profileData.data;
            final changed = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => EditCustomerProfilePage(profile: profile),
              ),
            );

            if (changed == true && context.mounted) {
              ref.invalidate(fetchProfileDataProvider);
            }
          },
          orElse: () => null,
        ),
        child: const Text('Edit'),
      ),),
      backgroundColor: cs.surface,
      body: profileDataState.when(
        data: (profileData) {
          final profile = profileData.data;
          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              /// Header card
              Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: cs.surfaceVariant.withOpacity(.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.person, size: 40),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: DefaultTextStyle(
                        style: tt.bodyMedium!,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile?.name ?? '—',
                              style: tt.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 10,
                              runSpacing: -6,
                              children: [
                                if ((profile?.customerId ?? '').isNotEmpty)
                                  _chip(
                                    'Customer ID: ${profile?.customerId}',
                                    cs,
                                  ),
                                if ((profile?.cusId ?? '').isNotEmpty)
                                  _chip('CUS ID: ${profile?.cusId}', cs),
                                if ((profile?.sex ?? '').isNotEmpty)
                                  _chip('Gender: ${profile?.sex}', cs),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// Identity
              ...section('Identity', [
                kv('Name (EN)', profile?.name, icon: Icons.badge_outlined),
                kv('Name (MM)', profile?.nameMm, icon: Icons.translate),
                kv('Gender', profile?.sex, icon: Icons.wc),
                kv(
                  'Date of Birth',
                  profile?.dob?.formattedFullDate,
                  icon: Icons.cake_outlined,
                ),
                kv(
                  'NRC No.',
                  profile?.nrcNo,
                  icon: Icons.contact_page_outlined,
                ),
              ]),

              /// Passport
              ...section('Passport', [
                kv(
                  'Passport No.',
                  profile?.passportNo,
                  icon: Icons.airplane_ticket_outlined,
                ),
                kv(
                  'Expiry',
                  profile?.passportExpiry,
                  icon: Icons.schedule_outlined,
                ),
                kv(
                  'Previous Passport',
                  profile?.prevPassportNo,
                  icon: Icons.history_outlined,
                ),
              ]),

              /// Visa
              ...section('Visa', [
                kv(
                  'Type',
                  profile?.visaType,
                  icon: Icons.assignment_turned_in_outlined,
                ),
                kv(
                  'Number',
                  profile?.visaNumber,
                  icon: Icons.confirmation_number_outlined,
                ),
                kv(
                  'Expiry',
                  profile?.visaExpiry,
                  icon: Icons.event_busy_outlined,
                ),
              ]),

              /// CI
              ...section('CI', [
                kv('CI No.', profile?.ciNo, icon: Icons.credit_card_outlined),
                kv(
                  'CI Expiry',
                  profile?.ciExpiry,
                  icon: Icons.event_busy_outlined,
                ),
              ]),

              /// Pink Card
              ...section('Pink Card', [
                kv(
                  'Pink Card No.',
                  profile?.pinkCardNo,
                  icon: Icons.credit_score_outlined,
                ),
                kv(
                  'Pink Card Expiry',
                  profile?.pinkCardExpiry,
                  icon: Icons.event_busy_outlined,
                ),
              ]),

              /// Contact
              ...section('Contact', [
                kv('Email', profile?.email, icon: Icons.email_outlined),
                kv('Phone', profile?.phone, icon: Icons.phone_android),
                kv(
                  'Secondary Phone',
                  profile?.phoneSecondary,
                  icon: Icons.phone_iphone,
                ),
                kv('Address', profile?.address, icon: Icons.place_outlined),
              ]),
            ],
          );
        },

        /// ---------- ERROR (centered) ----------
        error: (error, stack) => Center(
          child: ErrorRetryView(
            title: 'Error loading profileData',
            message: error.toString(),
            onRetry: () => ref.refresh(fetchProfileDataProvider),
          ),
        ),

        /// ---------- LOADING (centered) ----------
        loading: () => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
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
  }

  Widget _chip(String text, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceVariant.withOpacity(.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text),
    );
  }
}
