import 'package:eps_client/src/features/service_request/presentation/service_request_page.dart';
import 'package:eps_client/src/utils/strings.dart';
import 'package:flutter/material.dart';

import '../../../widgets/agent_card.dart';
import '../../agent_details/model/agent_profile.dart';
import '../../agent_details/presentation/agent_details_page.dart';
import '../model/agent.dart';

class AgentsPage extends StatelessWidget {
  const AgentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final agents = <Agent>[
      Agent(
        name: 'Agent 1',
        rating: 4.0,
        location: 'Location',
        canRequest: true,
      ),
      Agent(
        name: 'Agent 1',
        rating: 4.5,
        location: 'Location',
        canRequest: true,
      ),
      Agent(
        name: 'Agent 1',
        rating: 1.0,
        location: 'Location',
        canRequest: false,
      ),
      Agent(
        name: 'Agent 1',
        rating: 4.5,
        location: 'Location',
        canRequest: true,
      ),
      Agent(
        name: 'Agent 1',
        rating: 1.0,
        location: 'Location',
        canRequest: true,
      ),
      Agent(
        name: 'Agent 1',
        rating: 5.0,
        location: 'Location',
        canRequest: false,
      ),
      Agent(
        name: 'Agent 1',
        rating: 3.0,
        location: 'Location',
        canRequest: true,
      ),
      Agent(
        name: 'Agent 1',
        rating: 2.5,
        location: 'Location',
        canRequest: false,
      ),
      Agent(
        name: 'Agent 1',
        rating: 0.0,
        location: 'Location',
        canRequest: true,
      ),
      Agent(
        name: 'Agent 1',
        rating: 2.5,
        location: 'Location',
        canRequest: true,
      ),
    ];

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          child: Column(
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
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: agents.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2 / 2.1,
                ),
                itemBuilder: (context, i) => AgentCard(
                  agent: agents[i],
                  onView: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AgentDetailsPage(
                          agent: const AgentProfile(
                            name: 'John Doe',
                            rating: 4.6,
                            location: 'Bangkok, Thailand',
                            languages: ['English', 'Thai'],
                            experienceYears: 5,
                            services: ['Passport Renewal', 'Visa Extension'],
                          ),
                          onServiceTap: (s) => debugPrint('Tap service: $s'),
                          onViewCertification: () =>
                              debugPrint('View certification'),
                        ),
                      ),
                    );
                  },
                  onRequest: agents[i].canRequest
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
