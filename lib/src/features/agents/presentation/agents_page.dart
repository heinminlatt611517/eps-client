import 'package:eps_client/src/features/agents/data/agent_repository.dart';
import 'package:eps_client/src/features/agents/model/availabel_agent_response.dart';
import 'package:eps_client/src/features/service_request/presentation/service_request_page.dart';
import 'package:eps_client/src/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../../../widgets/agent_card.dart';
import '../../../widgets/error_tetry_view.dart';
import '../../agent_details/presentation/agent_details_page.dart';

class AgentsPage extends ConsumerWidget {
  const AgentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    ///provider states
    final availableAgentsState = ref.watch(fetchAvailableAgentsProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                kLabelAvailableAgents,
                style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                kLabelSelectAndAgentToBegin,
                style: tt.bodyMedium?.copyWith(color: cs.outline),
              ),
              const SizedBox(height: 16),

              /// Grid of agent cards
              availableAgentsState.when(
                data: (agents) {
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: agents.data?.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 2 / 2.1,
                        ),
                    itemBuilder: (context, i) => AgentCard(
                      agent: agents.data?[i] ?? AgentDataVO(),
                      onView: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AgentDetailsPage(
                              id: agents.data?[i].id.toString() ?? '',
                              onServiceTap: (s) =>
                                  debugPrint('Tap service: $s'),
                              onViewCertification: () =>
                                  debugPrint('View certification'),
                            ),
                          ),
                        );
                      },
                      onRequest: agents.data?[i].canRequest ?? true
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ServiceRequestPage(),
                                ),
                              );
                            }
                          : null, // disabled state
                    ),
                  );
                },
                error: (error, stackTrace) => ErrorRetryView(
                  title: 'Error loading agents',
                  message: error.toString(),
                  onRetry: () => ref.invalidate(fetchAvailableAgentsProvider),
                ),
                loading: () => Center(
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: LoadingIndicator(
                      indicatorType: Indicator.ballBeat,
                      strokeWidth: 2,
                      backgroundColor: Colors.transparent,
                      pathBackgroundColor: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
