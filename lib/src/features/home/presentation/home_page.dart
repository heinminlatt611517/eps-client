import 'package:eps_client/src/features/job_opportunities/presentation/job_opportunities_page.dart';
import 'package:eps_client/src/features/upload_documents/presentation/upload_documents_page.dart';
import 'package:eps_client/src/utils/images.dart';
import 'package:eps_client/src/utils/strings.dart';
import 'package:flutter/material.dart';

import '../../../widgets/app_card_view.dart';
import '../../../widgets/home_service_card_view.dart';
import '../../notifications/presentation/notification_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: cs.secondaryContainer,
                    child: Icon(Icons.person_outline, color: cs.onSecondaryContainer),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Hello | Login',
                        style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                  _IconBadge(
                    icon: Icons.notifications_none_rounded,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NotificationsPage()),
                      );

                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              ///search view
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    Icon(Icons.search, color: cs.outline),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: kLabelSearchServices,
                          border: InputBorder.none,
                          hintStyle: text.bodyMedium?.copyWith(color: cs.outline),
                          isCollapsed: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const SectionTitle(kLabelOurMostUsefulServices),
              const SizedBox(height: 12),

              /// Services grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.6,
                children:  [
                  ServiceCard(
                    imageName: kVisaPassportImage,
                    title: kLabelVisaPassportServices,
                    enabled: true,
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const UploadDocumentsPage()),
                      );
                    },
                  ),
                  ServiceCard(
                    imageName: kJobImage,
                    title: kLabelJobOpportunities,
                    enabled: true,
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const JobOpportunitiesPage()),
                      );
                    },
                  ),
                  ServiceCard(
                    imageName: kLicensesImage,
                    title: kLabelDrivingLicenseServices,
                    enabled: true,
                  ),
                  ServiceCard(
                    imageName: kCarWorkshopImage,
                    title: kLabelCarAndWorkshops,
                    enabled: false, // greyed like mock
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const SectionTitle(kLabelWhatIsNew),
              const SizedBox(height: 12),

              /// Promo banner
              PromoBanner(
                leadingIcon: Icons.campaign_outlined,
                title: kLabelFreeCarWorkShop,
                trailing: Image.asset(kFreeCardWorkshopImage,height: 50,width: 60,fit: BoxFit.contain,),
                onTap: () {},
              ),
              const SizedBox(height: 20),

              const SectionTitle(kLabelFindNearByServicePoints),
              const SizedBox(height: 12),

              /// Two small maps/cards
              Row(
                children: [
                  Expanded(
                    child: AppCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            Icon(Icons.place_outlined, color: cs.primary,size: 40,),
                            const SizedBox(width: 10),
                            Text(
                              kLabelHelpYouFindRTA,
                              style: text.bodySmall?.copyWith(color: cs.outline),
                            ),
                          ],),
                          Image.asset(kMapImage,height: 100,width: 110,fit: BoxFit.contain,),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------- Section title ----------
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}

/// ---------- Promo banner (uses AppCard) ----------
class PromoBanner extends StatelessWidget {
  const PromoBanner({
    super.key,
    required this.leadingIcon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  final IconData leadingIcon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(leadingIcon, color: cs.onSurface),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: t.bodyMedium),
          ),
          if (trailing != null) const SizedBox(width: 12),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// ---------- Notification icon with small badge ----------
class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: onTap,
          icon: Icon(icon, color: cs.onSurface),
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: cs.error,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}
