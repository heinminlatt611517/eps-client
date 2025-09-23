import 'package:eps_client/src/features/job_opportunities/model/job_item_vo.dart';
import 'package:eps_client/src/features/submit_cv_page/submit_cv_page.dart';
import 'package:eps_client/src/widgets/job_card_view.dart';
import 'package:flutter/material.dart';

import '../../../common_widgets/custom_app_bar_view.dart';

class JobOpportunitiesPage extends StatefulWidget {
  const JobOpportunitiesPage({super.key});

  @override
  State<JobOpportunitiesPage> createState() => _JobOpportunitiesPageState();
}

class _JobOpportunitiesPageState extends State<JobOpportunitiesPage> {
  final TextEditingController _search = TextEditingController();
  final List<JobItemVO> _all = const [
    JobItemVO(
      title: 'Admin Assistant',
      city: 'Bangkok',
      type: 'Full-time',
      postedDaysAgo: 2,
    ),
    JobItemVO(
      title: 'Interpreter',
      city: 'Tokyo',
      type: 'Part-time',
      postedDaysAgo: 3,
    ),
    JobItemVO(
      title: 'IT Support Specialist',
      city: 'Dubai',
      type: 'Full-time',
      postedDaysAgo: 5,
    ),
  ];

  String _query = '';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final results = _all
        .where((j) =>
    j.title.toLowerCase().contains(_query.toLowerCase()) ||
        j.city.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: CustomAppBarView(title: 'Job Opportunities'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [

            const SizedBox(height: 12),

            /// Search + Filter
            _SearchBar(
              controller: _search,
              onChanged: (v) => setState(() => _query = v),
              onFilterTap: () {
                // TODO: open filters
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
