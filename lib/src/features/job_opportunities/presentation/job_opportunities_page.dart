import 'package:eps_client/src/features/job_opportunities/data/job_repository.dart';
import 'package:eps_client/src/features/job_opportunities/model/jobs_response.dart'; // ← use JobsResponse/JobVO here
import 'package:eps_client/src/features/submit_cv_page/presentation/submit_cv_page.dart';
import 'package:eps_client/src/widgets/job_card_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../../../common_widgets/custom_app_bar_view.dart';
import '../../../widgets/error_tetry_view.dart';

class JobOpportunitiesPage extends ConsumerStatefulWidget {
  const JobOpportunitiesPage({super.key});

  @override
  ConsumerState<JobOpportunitiesPage> createState() => _JobOpportunitiesPageState();
}

class _JobOpportunitiesPageState extends ConsumerState<JobOpportunitiesPage> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    /// provider state
    final jobState = ref.watch(fetchAllJobsProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: const CustomAppBarView(title: 'Job Opportunities'),
      body: SafeArea(
        child: jobState.when(
          data: (networkData) {
            final all = (networkData.data ?? <JobVO>[]);
            final q = _query.trim().toLowerCase();
            final results = q.isEmpty
                ? all
                : all.where((j) {
              final title = (j.title ?? '').toLowerCase();
              final loc = (j.location ?? '').toLowerCase();
              return title.contains(q) || loc.contains(q);
            }).toList();

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                const SizedBox(height: 12),

                /// Search + Filter
                _SearchBar(
                  controller: _search,
                  onChanged: (v) => setState(() => _query = v),
                  onFilterTap: () {
                    // TODO: open filter sheet
                  },
                ),
                const SizedBox(height: 12),

                /// Job list
                ...results.map((job) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: JobCardView(
                    job: job,
                    onView: () {
                    },
                  ),
                )),

                const SizedBox(height: 8),

                _CvCallout(
                  onSubmit: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SubmitCvPage()),
                    );
                  },
                ),
              ],
            );
          },
          error: (error, stackTrace) => ErrorRetryView(
            title: 'Error loading jobs',
            message: error.toString(),
            onRetry: () => ref.invalidate(fetchAllJobsProvider),
          ),
          loading: () => SizedBox(
            height: 200,
            child: Center(
              child: SizedBox(
                width: 36,
                height: 36,
                child: LoadingIndicator(
                  indicatorType: Indicator.ballBeat,
                  colors: [Theme.of(context).colorScheme.primary], // color fix
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

/// SEARCH BAR
class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onChanged,
    this.onFilterTap,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onFilterTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 46,
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: 'Search by job title or keyword',
                border: InputBorder.none,
              ),
            ),
          ),
          InkWell(
            onTap: onFilterTap,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Icon(Icons.filter_list_rounded, color: cs.primary),
            ),
          ),
        ],
      ),
    );
  }
}

/// BOTTOM CALLOUT
class _CvCallout extends StatelessWidget {
  const _CvCallout({this.onSubmit});

  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        children: [
          Text(
            "Didn't find a suitable job ?",
            style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onSubmit,
            child: const Text('Submit your CV'),
          ),
        ],
      ),
    );
  }
}
