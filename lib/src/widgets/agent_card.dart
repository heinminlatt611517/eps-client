import 'package:eps_client/src/features/agents/model/availabel_agent_response.dart';
import 'package:eps_client/src/utils/dimens.dart';
import 'package:eps_client/src/utils/strings.dart';
import 'package:eps_client/src/widgets/rating_view.dart';
import 'package:flutter/material.dart';

/// Reusable card widget (parent style shared across items)
class AgentCard extends StatelessWidget {
  const AgentCard({
    super.key,
    required this.agent,
    required this.onView,
    required this.onRequest,
  });

  final AgentDataVO agent;
  final VoidCallback onView;
  final VoidCallback? onRequest;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: cs.surfaceVariant.withOpacity(.45),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cs.surface,
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: Icon(Icons.person_outline, color: cs.onSurface),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      agent.name ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              /// Rating stars
              RatingView(value: double.parse(agent.rating ?? '0.0'), size: 18, showValue: true),
              const SizedBox(height: 6),

              Text(
                kLabelLocation,
                style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              Text(
                agent.location ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tt.bodySmall?.copyWith(color: cs.outline),
              ),
              const Spacer(),

              /// Buttons row
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: onView,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        kLabelView,
                        style: TextStyle(fontSize: kTextXSmall),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: onRequest,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        kLabelRequestService,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: kTextXSmall),
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
