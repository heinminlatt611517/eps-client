import 'package:eps_client/src/common_widgets/custom_app_bar_view.dart';
import 'package:eps_client/src/features/agents/model/availabel_agent_response.dart';
import 'package:eps_client/src/utils/dimens.dart';
import 'package:flutter/material.dart';

class ServiceRequestPage extends StatefulWidget {
  const ServiceRequestPage({super.key});

  @override
  State<ServiceRequestPage> createState() => _ServiceRequestPageState();
}

class _ServiceRequestPageState extends State<ServiceRequestPage> {
  int _step = 0;

  AgentDataVO? _agent;
  Service? _service;

  final notes = TextEditingController();
  bool _agree = false;

  final agents =  [
    AgentDataVO(name: 'John Doe', rating: '4.6'),
    AgentDataVO(name: 'Jane Smith', rating: '4.8'),
    AgentDataVO(name: 'Alex Lee', rating: '4.5'),
  ];
  final services = const [
    Service(name: 'Visa Extension', detail: 'Statesvice', duration: '3-5 working days', costUsd: 150),
    Service(name: 'Passport Renewal', detail: 'Processing', duration: '5-7 working days', costUsd: 120),
    Service(name: 'Work Permit', detail: 'Permit filing & issue', duration: '7-10 working days', costUsd: 180),
  ];
  final docs = <DocItem>[
    DocItem(title: 'TM 7 Form'),
    DocItem(title: 'TM 30 Receipt'),
    DocItem(title: 'Passport Main Page'),
    DocItem(title: 'Passport Last Page'),
    DocItem(title: 'Photo'),
    DocItem(title: 'Other Supporting Documents'),
  ];

  @override
  void dispose() {
    notes.dispose();
    super.dispose();
  }

  ///step header
  Widget _header() {
    Color on(int i) => i <= _step ? Theme.of(context).colorScheme.primary : Colors.grey;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
      child: Column(
        children: [
          Row(children: [_dot(on(0)), _line(), _dot(on(1)), _line(), _dot(on(2))]),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text('Step 1', style: tt.bodySmall),
                  Text('Choose Service', style: TextStyle(fontSize: 10)),
                ],
              ),
              Column(
                children: [
                  Text('Step 2', style: tt.bodySmall),
                  Text('Upload documents', style: TextStyle(fontSize: 10)),
                ],
              ),
              Column(
                children: [
                  Text('Step 3', style: tt.bodySmall),
                  Text('Reviews & Submit', style: TextStyle(fontSize: 10)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  ///service request step
  Widget _pageChoose() {
    final tt = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: [
        Text('Agent & Dropdoom', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        _SelectBox(
          onTap: () async {
            final v = await _pickOne<AgentDataVO>(
              title: 'Select Agent',
              items: agents,
              itemBuilder: (a) => Row(
                children: [
                  const CircleAvatar(radius: 18, child: Icon(Icons.person)),
                  const SizedBox(width: 12),
                  Expanded(child: Text(a.name ?? '', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
                  const Icon(Icons.star, size: 18, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(a.rating ?? ''),
                ],
              ),
            );
            if (v != null) setState(() => _agent = v);
          },
          child: Row(
            children: [
              const CircleAvatar(radius: 18, child: Icon(Icons.person)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_agent?.name ?? 'Agent Name', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Row(children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text((_agent?.rating ?? '')),
                    ]),
                  ],
                ),
              ),
              const Icon(Icons.keyboard_arrow_down_rounded),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text('Select Service', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        _SelectBox(
          onTap: () async {
            final v = await _pickOne<Service>(
              title: 'Select Service',
              items: services,
              itemBuilder: (s) => Row(
                children: [
                  const Icon(Icons.assignment_turned_in_outlined),
                  const SizedBox(width: 12),
                  Expanded(child: Text(s.name, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600))),
                  Text('\$ ${s.costUsd} USD'),
                ],
              ),
            );
            if (v != null) setState(() => _service = v);
          },
          child: Row(
            children: [
              Expanded(child: Text(_service?.name ?? 'Visa Extension', style: tt.titleMedium, overflow: TextOverflow.ellipsis)),
              const Icon(Icons.keyboard_arrow_down_rounded),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _kv('Service Detail', _service?.detail),
        const SizedBox(height: 12),
        _kv('Service Duration', _service?.duration),
        const SizedBox(height: 12),
        _kv('Cost', _service == null ? null : '\$ ${_service!.costUsd} USD'),
      ],
    );
  }

  ///upload documents step
  Widget _pageUpload() {
    final tt = Theme.of(context).textTheme;
    final uploaded = docs.where((d) => d.isUploaded).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: [
        Text('Required Documents', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        ...docs.map((d) => _DocRow(
          item: d,
          onUpload: () async {
            // TODO: replace with your file picker / camera
            setState(() {
              d.fileName = 'Uploaded.pdf';
              d.isUploaded = true;
            });
          },
        )),
        const SizedBox(height: 8),
        Text('$uploaded/${docs.length} uploaded', style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  ///review step
  Widget _pageReview() {
    final tt = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: [
        Row(
          children: [
            const CircleAvatar(radius: 22, child: Icon(Icons.person)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_agent?.name ?? '-', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                Row(
                  children: List.generate(5, (i) {
                    final on = i < (double.parse(_agent?.rating ?? '4').round());
                    return Icon(on ? Icons.star : Icons.star_border, size: 18, color: Colors.amber);
                  }),
                ),
              ]),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text('Selected service', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text(_service?.name ?? '-', style: tt.bodyLarge),
        const SizedBox(height: 6),
        Text('Duration: ${_service?.duration ?? '-'}'),
        const SizedBox(height: 4),
        Text('Cost:\$ ${_service?.costUsd ?? '-'} USD'),
        const Divider(height: 24),
        Text('Uploaded Documents', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        ...docs.map((d) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(d.isUploaded ? Icons.check_circle : Icons.cancel,
                  color: d.isUploaded ? Colors.green : Colors.red, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(d.title)),
              Text(d.isUploaded ? 'Uploaded' : 'Not uploaded',
                  style: tt.bodyMedium?.copyWith(
                    color: d.isUploaded ? Colors.green : Colors.red,
                  )),
            ],
          ),
        )),
        const SizedBox(height: 12),
        Text('Notes', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        TextField(
          controller: notes,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Enter any special instructions here',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Checkbox(value: _agree, onChanged: (v) => setState(() => _agree = v ?? false)),
            const SizedBox(width: 6),
            const Expanded(child: Text('I confirm that all information is accurate')),
          ],
        ),
      ],
    );
  }

  /// ---------- bottom bar ----------
  Widget _bottomBar() {
    final isFirst = _step == 0;
    final isLast = _step == 2;

    final canNext = switch (_step) {
      0 => _agent != null && _service != null,
      1 => docs.any((d) => d.isUploaded),
      2 => _agree,
      _ => true,
    };

    final primaryText = switch (_step) {
      0 => 'Continue',
      1 => 'Continue to Review& Submit',
      _ => 'Submit Request',
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: FilledButton(
              onPressed: canNext
                  ? () {
                if (isLast) {
                  _submit();
                } else {
                  setState(() => _step += 1);
                }
              }
                  : null,
              child: Text(primaryText),
            ),
          ),
          const SizedBox(width: 12),
          if (!isFirst)
            TextButton(
              onPressed: () => setState(() => _step -= 1),
              child: const Text('Back'),
            ),
        ],
      ),
    );
  }

  /// ---------- scaffold ----------
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: CustomAppBarView(title: 'Service Request'),
      body: Column(
        children: [
          _header(),

          Container(
            margin: EdgeInsets.all(kMarginMedium2),
            height: 0.5,color: Colors.grey[300],width: double.infinity,),

          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: switch (_step) {
                0 => _pageChoose(),
                1 => _pageUpload(),
                2 => _pageReview(),
                _ => const SizedBox(),
              },
            ),
          ),
          _bottomBar(),
        ],
      ),
    );
  }

  /// ---------- helpers ----------
  Widget _kv(String k, String? v) {
    final tt = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(child: Text(k, style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w800))),
        Expanded(child: Text(v ?? '-', textAlign: TextAlign.right)),
      ],
    );
  }

  Future<T?> _pickOne<T>({
    required String title,
    required List<T> items,
    required Widget Function(T) itemBuilder,
  }) {
    final tt = Theme.of(context).textTheme;
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              ...items.map((e) => ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                title: itemBuilder(e),
                onTap: () => Navigator.of(ctx).pop<T>(e),
              )),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Request submitted')),
    );
  }
}

/// ───────── small widgets / models ─────────
class _SelectBox extends StatelessWidget {
  const _SelectBox({required this.child, this.onTap});
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: cs.surfaceVariant.withOpacity(.5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _DocRow extends StatelessWidget {
  const _DocRow({required this.item, this.onUpload});
  final DocItem item;
  final VoidCallback? onUpload;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 66,
            height: 54,
            decoration: BoxDecoration(
              color: cs.surfaceVariant.withOpacity(.5),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  item.fileName ?? 'Not uploaded',
                  style: tt.bodyMedium?.copyWith(
                    color: item.isUploaded ? Colors.green : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 110),
            child: OutlinedButton(
              onPressed: onUpload,
              child: Text(item.isUploaded ? 'Replace' : 'Upload'),
            ),
          ),
        ],
      ),
    );
  }
}

class Service {
  final String name;
  final String detail;
  final String duration;
  final int costUsd;
  const Service({required this.name, required this.detail, required this.duration, required this.costUsd});
}

class DocItem {
  final String title;
  bool isUploaded;
  String? fileName;
  DocItem({required this.title, this.isUploaded = false, this.fileName});
}

/// header pieces
Widget _dot(Color c) => Container(
    margin: EdgeInsets.only(right: 25,left: 25),
    width: 10, height: 10, decoration: BoxDecoration(color: c, shape: BoxShape.circle));
Widget _line() => Expanded(child: Container(height: 2, color: Colors.grey[300]));
