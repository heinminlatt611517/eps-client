import 'package:eps_client/src/features/agents/data/agent_repository.dart';
import 'package:eps_client/src/features/agents/model/availabel_agent_response.dart';
import 'package:eps_client/src/features/service_request/presentation/service_request_page.dart';
import 'package:eps_client/src/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../../../utils/secure_storage.dart';
import '../../../widgets/agent_card.dart';
import '../../../widgets/error_tetry_view.dart';
import '../../agent_details/presentation/agent_details_page.dart';
import '../../home/model/category_response.dart';

class AgentsPage extends ConsumerStatefulWidget {
  const AgentsPage({super.key});

  @override
  ConsumerState<AgentsPage> createState() => _AgentsPageState();
}

class _AgentsPageState extends ConsumerState<AgentsPage> {
  String categoryId = "";

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    /// categories from local cache
    final categoriesState = ref.watch(categoriesLocalProvider);

    /// agents by selected category
    final availableAgentsState =
    ref.watch(fetchAvailableAgentsProvider(categoryId: categoryId));

    String categoryLabel(CategoryVO c) {
      return nameValues.reverse[c.name] ?? '-';
    }

    Widget chip({
      required String label,
      required bool selected,
      required VoidCallback onTap,
      Color? color,
    }) {
      final base = color ?? cs.primary;
      return ChoiceChip(
        label: Text(
          label,
          overflow: TextOverflow.ellipsis,
        ),
        selected: selected,
        onSelected: (_) => onTap(),
        labelStyle: TextStyle(
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? cs.onPrimary : cs.onSurface,
        ),
        selectedColor: base,
        backgroundColor: cs.surfaceVariant.withOpacity(.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: const VisualDensity(vertical: -2, horizontal: -2),
      );
    }

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            /// Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kLabelAvailableAgents,
                      style: tt.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      kLabelSelectAndAgentToBegin,
                      style: tt.bodyMedium?.copyWith(color: cs.outline),
                    ),
                    const SizedBox(height: 12),

                    /// --- Category Filter Bar ---
                    categoriesState.when(
                      loading: () => const SizedBox(height: 42),
                      error: (e, _) => const SizedBox.shrink(),
                      data: (cats) {
                        final items = cats;
                        if (items.isEmpty) return const SizedBox.shrink();
                        return SizedBox(
                          height: 42,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.only(bottom: 4),
                            itemBuilder: (context, i) {
                              if (i == 0) {
                                // "All" chip (empty category)
                                return chip(
                                  label: 'All',
                                  selected: categoryId.isEmpty,
                                  onTap: () {
                                    setState(() => categoryId = "");
                                  },
                                );
                              }
                              final c = items[i - 1];
                              final idStr = (c.id ?? '').toString();
                              return chip(
                                label: categoryLabel(c),
                                selected: categoryId == idStr,
                                onTap: () {
                                  setState(() => categoryId = idStr);
                                },
                              );
                            },
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemCount: items.length + 1,
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),

            /// Content (agents)
            ...availableAgentsState.when(
              data: (agents) => [
                if ((agents.data?.isEmpty ?? true))
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        categoryId.isEmpty
                            ? 'Select a category to view agents'
                            : 'No agents found in this category',
                        style: tt.bodyMedium?.copyWith(color: cs.outline),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    sliver: SliverGrid(
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 2 / 2.1,
                      ),
                      delegate: SliverChildBuilderDelegate(
                            (context, i) => AgentCard(
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
                          onRequest: (agents.data?[i].canRequest ?? true)
                              ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ServiceRequestPage(
                                  agentID: agents.data?[i].id,
                                ),
                              ),
                            );
                          }
                              : null,
                        ),
                        childCount: (agents.data?.length ?? 0),
                      ),
                    ),
                  ),
              ],
              error: (error, stackTrace) => [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: ErrorRetryView(
                      title: 'Error loading agents',
                      message: error.toString(),
                      onRetry: () => ref.invalidate(
                        fetchAvailableAgentsProvider(categoryId: categoryId),
                      ),
                    ),
                  ),
                ),
              ],
              loading: () => [
                SliverFillRemaining(
                  hasScrollBody: false,
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
