import 'dart:io';

import 'package:eps_client/src/features/service_request/controller/service_request_controller.dart';
import 'package:eps_client/src/utils/async_value_ui.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:eps_client/src/common_widgets/custom_app_bar_view.dart';
import 'package:eps_client/src/features/agents/model/availabel_agent_response.dart';
import 'package:eps_client/src/utils/dimens.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:path/path.dart' as p;
import '../../../common_widgets/personal_detail_input_field.dart';
import '../../../widgets/loading_view.dart';
import '../../upload_documents/model/passport_mrz_vo.dart';
import '../../upload_documents/presentation/camera_id_ocr_page.dart';
import '../../upload_documents/presentation/mrz_live_sacnner_page.dart';
import '../../upload_documents/presentation/upload_documents_page.dart';
import '../form/service_request_form_notifier.dart';

class ServiceRequestPage extends ConsumerStatefulWidget {
  const ServiceRequestPage({super.key});

  @override
  ConsumerState<ServiceRequestPage> createState() => _ServiceRequestPageState();
}

enum StepStage { choose, uploadDocs, uploadSupporting, review }

class _ServiceRequestPageState extends ConsumerState<ServiceRequestPage> {
  StepStage _step = StepStage.choose;

  AgentDataVO? _agent;
  Service? _service;
  bool _manualEntry = false;
  bool _isSuccessService = false;

  final notes = TextEditingController();
  bool _agree = false;

  /// sample data
  final agents = [
    AgentDataVO(name: 'John Doe', rating: '4.6'),
    AgentDataVO(name: 'Jane Smith', rating: '4.8'),
    AgentDataVO(name: 'Alex Lee', rating: '4.5'),
  ];
  final services = const [
    Service(
      name: 'Visa Extension',
      detail: 'Statesvice',
      duration: '3-5 working days',
      costUsd: 150,
    ),
    Service(
      name: 'Passport Renewal',
      detail: 'Processing',
      duration: '5-7 working days',
      costUsd: 120,
    ),
    Service(
      name: 'Work Permit',
      detail: 'Permit filing & issue',
      duration: '7-10 working days',
      costUsd: 180,
    ),
  ];
  final docs = <DocItem>[
    DocItem(title: 'TM 7 Form'),
    DocItem(title: 'TM 30 Receipt'),
    DocItem(title: 'Passport Main Page'),
    DocItem(title: 'Passport Last Page'),
    DocItem(title: 'Photo'),
    DocItem(title: 'Other Supporting Documents'),
  ];

  /// Personal details controllers (manual entry)
  late final TextEditingController _passportCtrl;
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _dobCtrl;
  late final TextEditingController _nationalityCtrl;
  late final TextEditingController _genderCtrl;
  late final TextEditingController _expiryCtrl;
  String? _seedKey;

  @override
  void initState() {
    _passportCtrl = TextEditingController();
    _firstNameCtrl = TextEditingController();
    _lastNameCtrl = TextEditingController();
    _dobCtrl = TextEditingController();
    _nationalityCtrl = TextEditingController();
    _genderCtrl = TextEditingController();
    _expiryCtrl = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    notes.dispose();
    _passportCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _dobCtrl.dispose();
    _nationalityCtrl.dispose();
    _genderCtrl.dispose();
    _expiryCtrl.dispose();
    super.dispose();
  }

  /// ---------------- helpers ----------------
  bool get _isFirst => _step == StepStage.choose;

  bool get _canNext {
    final form = ref.watch(serviceRequestFormNotifierProvider);

    switch (_step) {
      case StepStage.choose:            return form.canProceedFromChoose;
      case StepStage.uploadDocs:        return form.canProceedFromUploadDocs;
      case StepStage.uploadSupporting:  return form.canProceedFromUploadSupporting;
      case StepStage.review:            return form.canSubmit;
    }
  }

  void _next() {
    if (_step == StepStage.review) {
      _submit();
      return;
    }
    setState(() {
      _step = StepStage.values[_step.index + 1];
    });

    if (_manualEntry) {
      ref.read(serviceRequestFormNotifierProvider.notifier).setPersonal(
        number:     _passportCtrl.text.trim(),
        firstName:  _firstNameCtrl.text.trim(),
        lastName:   _lastNameCtrl.text.trim(),
        dob:        _parseDmy(_dobCtrl.text),
        nationality:_nationalityCtrl.text.trim(),
        gender:     _genderCtrl.text.trim(),
        expiryDate: _parseDmy(_expiryCtrl.text),
      );
    }
  }

  void _back() {
    if (_isFirst) return;
    setState(() {
      if (_step == StepStage.uploadDocs && _manualEntry) {
        _manualEntry = false;
      } else {
        _step = StepStage.values[_step.index - 1];
      }
    });
  }

  Future<void> _pickDate(TextEditingController c, {DateTime? initial}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) c.text = _fmtDate(picked);
  }

  void _seedFromMrz(PassportMrz? mrz) {
    final key = mrz?.documentNumber ?? 'none';
    if (_seedKey == key) return;
    _seedKey = key;

    final firstName = _firstGivenName(mrz?.secondaryIdentifier ?? '');
    final lastName = mrz?.primaryIdentifier ?? '';
    final nationality = _iso3ToName(mrz?.nationality ?? '');
    final gender = _prettySex(mrz?.sex ?? '');

    _passportCtrl.text = mrz?.documentNumber ?? '';
    _firstNameCtrl.text = firstName;
    _lastNameCtrl.text = lastName;
    _dobCtrl.text = _fmtDate(mrz?.birthDate);
    _nationalityCtrl.text = nationality;
    _genderCtrl.text = gender;
    _expiryCtrl.text = _fmtDate(mrz?.expiryDate);
  }

  DateTime _parseDmy(String s) {
    final p = s.trim().split(RegExp(r'\s+'));
    if (p.length != 3) return DateTime.now();
    const months = {
      'Jan':1,'Feb':2,'Mar':3,'Apr':4,'May':5,'Jun':6,
      'Jul':7,'Aug':8,'Sep':9,'Oct':10,'Nov':11,'Dec':12
    };
    final d = int.tryParse(p[0]) ?? 1;
    final m = months[p[1]] ?? 1;
    final y = int.tryParse(p[2]) ?? DateTime.now().year;
    return DateTime(y, m, d);
  }

  /// ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final state = ref.watch(serviceRequestControllerProvider);

    ///show error dialog when network response error
    ref.listen<AsyncValue>(
      serviceRequestControllerProvider,
          (_, state) => state.showAlertDialogOnError(context),
    );

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: const CustomAppBarView(title: 'Service Request'),
      body: Stack(
        children: [
          Column(
            children: [
              _header(),
              Container(
                margin: const EdgeInsets.all(kMarginMedium2),
                height: 0.5,
                color: Colors.grey[300],
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: switch (_step) {
                    StepStage.choose => _pageChoose(),
                    StepStage.uploadDocs =>
                      _manualEntry ? _confirmDocumentsPage() : _uploadDocsIntro(),
                    StepStage.uploadSupporting => _isSuccessService ? buildServiceRequestSuccess(serviceName: 'Test',agentName: 'Test',costUsd: 100,onTrackPressed: (){}) : _uploadSupportingDocuments(),
                    StepStage.review => _pageReview(),
                  },
                ),
              ),
              _isSuccessService ? SizedBox.shrink() : _bottomBar(),
            ],
          ),
          ///loading view
          if (state.isLoading)
            Container(
              color: Colors.black12,
              child: const Center(
                child: LoadingView(
                  indicatorColor: Colors.white,
                  indicator: Indicator.ballRotate,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// ---------- header ----------
  Widget _header() {
    Color on(int i) =>
        i <= _step.index ? Theme.of(context).colorScheme.primary : Colors.grey;
    final tt = Theme.of(context).textTheme;

    Widget stepLabel(String title, String sub) => Column(
      children: [
        Text(title, style: tt.bodySmall),
        Text(
          sub,
          style: const TextStyle(fontSize: 10),
          textAlign: TextAlign.center,
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
      child: Column(
        children: [
          Row(
            children: [
              _dot(on(0)),
              _line(),
              _dot(on(1)),
              _line(),
              _dot(on(2)),
              _line(),
              _dot(on(3)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              // keep concise
              _StepLabel('Step 1', 'Choose Service'),
              _StepLabel('Step 2', 'Upload documents'),
              _StepLabel('Step 3', 'Upload Supporting\ndocuments'),
              _StepLabel('Step 4', 'Reviews & Submit'),
            ],
          ),
        ],
      ),
    );
  }

  /// ---------- pages ----------
  Widget _pageChoose() {
    final tt = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: [
        Text(
          'Agent & Dropdown',
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
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
                  Expanded(
                    child: Text(
                      a.name ?? '',
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Icon(Icons.star, size: 18, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(a.rating ?? ''),
                ],
              ),
            );

            ///set agent name to provider
            if (v != null) setState(() => _agent = v);
            ref.read(serviceRequestFormNotifierProvider.notifier).setAgent(v?.name ?? '');
          },
          child: Row(
            children: [
              const CircleAvatar(radius: 18, child: Icon(Icons.person)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _agent?.name ?? 'Agent Name',
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text((_agent?.rating ?? '')),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.keyboard_arrow_down_rounded),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Select Service',
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
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
                  Expanded(
                    child: Text(
                      s.name,
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text('\$ ${s.costUsd} USD'),
                ],
              ),
            );

            ///set service id to provider
            if (v != null) setState(() => _service = v);
            ref.read(serviceRequestFormNotifierProvider.notifier)
                .setService(id: 1);
          },
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _service?.name ?? 'Visa Extension',
                  style: tt.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
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

  /// Upload docs – intro (when NOT in manual entry mode)
  Widget _uploadDocsIntro() {
    final tt = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Text(
          ' Upload Passport/ Visa/ CI/ Pink Card',
          style: tt.bodyMedium?.copyWith(
            fontSize: kTextRegular18,
          ),
        ),
        const SizedBox(height: 16),

        /// Scan flow (kept as-is)
        UploadActionTile(
          icon: Icons.document_scanner_outlined,
          label: 'Scan Passport',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LiveMrzScannerPage(
                  onFound: (mrz) {
                    _seedFromMrz(mrz);
                    setState(() => _manualEntry = true);
                  },
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 14),

        /// Scan flow (kept as-is)
        UploadActionTile(
          icon: Icons.document_scanner_outlined,
          label: 'Scan Document',
          onTap: () {
            Navigator.push(
              context,
                MaterialPageRoute(
                  builder: (_) => CameraIdOcrPage(
                    onParsed: (fields) {
                      PassportMrz mrz = PassportMrz(documentNumber: fields.idNumber,primaryIdentifier: fields.name,
                          secondaryIdentifier: fields.name,expiryDate: DateTime.parse(fields.dateOfExpiry ?? ''),
                          nationality: fields.nationality,sex: fields.gender,birthDate: DateTime.parse(fields.dateOfBirth ?? ''));
                      _seedFromMrz(mrz);
                      setState(() => _manualEntry = true);
                    },
                  ),
                )
            );
          },
        ),
        const SizedBox(height: 14),

        UploadActionTile(
          icon: Icons.upload_file_outlined,
          label: 'Manual Entry',
          onTap: () {
            setState(() => _manualEntry = true);
          },
        ),
      ],
    );
  }

  /// Upload supporting docs (step 3)
  Widget _uploadSupportingDocuments() {
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
            final pickedFile = await _pickAnyFile();
            if (pickedFile == null) return;

            ref.read(serviceRequestFormNotifierProvider.notifier)
                .upsertDocument(type: d.title, file: pickedFile);

            setState(() {
              d.fileName = p.basename(pickedFile.path);
              d.isUploaded = true;
            });
          },
        )),

        const SizedBox(height: 8),
        Text('$uploaded/${docs.length} uploaded',
            style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  /// Review (step 4)
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _agent?.name ?? '-',
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Row(
                    children: List.generate(5, (i) {
                      final on =
                          i < (double.parse(_agent?.rating ?? '4').round());
                      return Icon(
                        on ? Icons.star : Icons.star_border,
                        size: 18,
                        color: Colors.amber,
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Selected service',
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(_service?.name ?? '-', style: tt.bodyLarge),
        const SizedBox(height: 6),
        Text('Duration: ${_service?.duration ?? '-'}'),
        const SizedBox(height: 4),
        Text('Cost: \$ ${_service?.costUsd ?? '-'} USD'),
        const Divider(height: 24),
        Text(
          'Uploaded Documents',
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        ...docs.map(
          (d) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(
                  d.isUploaded ? Icons.check_circle : Icons.cancel,
                  color: d.isUploaded ? Colors.green : Colors.red,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(d.title)),
                Text(
                  d.isUploaded ? 'Uploaded' : 'Not uploaded',
                  style: tt.bodyMedium?.copyWith(
                    color: d.isUploaded ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Notes',
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: notes,
          maxLines: 4,
          onChanged: (v) => ref.read(serviceRequestFormNotifierProvider.notifier).setNote(v),
          decoration: InputDecoration(
            hintText: 'Enter any special instructions here',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Checkbox(
              value: _agree,
              onChanged: (v) => setState(() {
                ref.read(serviceRequestFormNotifierProvider.notifier).setAgree(v ?? false);
                _agree = v ?? false;}),
            ),
            const SizedBox(width: 6),
            const Expanded(
              child: Text('I confirm that all information is accurate'),
            ),
          ],
        ),
      ],
    );
  }

  /// Manual entry (Confirm Documents UI)
  Widget _confirmDocumentsPage() {
    final theme = Theme.of(context);

    void _sync() => _updateFormFromControllers();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Please review and confirm details',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          Text(
            'Personal Details',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),


          PersonalDetailInputField(
            label: 'Passport Number',
            controller: _passportCtrl,
            keyboardType: TextInputType.text,
            onChanged: (_) => _sync(),
          ),
          const SizedBox(height: 10),


          PersonalDetailInputField(
            label: 'First Name',
            controller: _firstNameCtrl,
            onChanged: (_) => _sync(),
          ),
          const SizedBox(height: 10),


          PersonalDetailInputField(
            label: 'Last Name',
            controller: _lastNameCtrl,
            onChanged: (_) => _sync(),
          ),
          const SizedBox(height: 10),


          PersonalDetailInputField(
            label: 'Date of Birth',
            controller: _dobCtrl,
            hint: 'dd MMM yyyy',
            readOnly: true,
            suffix: const Icon(Icons.calendar_month_rounded, size: 18),
            onTap: () async {
              await _pickDate(_dobCtrl);
              _sync();
            },
          ),
          const SizedBox(height: 10),


          PersonalDetailInputField(
            label: 'Nationality',
            controller: _nationalityCtrl,
            onChanged: (_) => _sync(),
          ),
          const SizedBox(height: 10),


          PersonalDetailInputField(
            label: 'Gender',
            controller: _genderCtrl,
            onChanged: (_) => _sync(),
          ),
          const SizedBox(height: 10),


          PersonalDetailInputField(
            label: 'Expiry date',
            controller: _expiryCtrl,
            hint: 'dd MMM yyyy',
            readOnly: true,
            suffix: const Icon(Icons.calendar_month_rounded, size: 18),
            onTap: () async {
              await _pickDate(_expiryCtrl);
              _sync();
            },
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }


  void _updateFormFromControllers() {
    ref.read(serviceRequestFormNotifierProvider.notifier).setPersonal(
      number     : _passportCtrl.text.nullIfEmpty,
      firstName  : _firstNameCtrl.text.nullIfEmpty,
      lastName   : _lastNameCtrl.text.nullIfEmpty,
      dob        : _parseDmyNullable(_dobCtrl.text),
      nationality: _nationalityCtrl.text.nullIfEmpty,
      gender     : _genderCtrl.text.nullIfEmpty,
      expiryDate : _parseDmyNullable(_expiryCtrl.text),
    );
  }

  /// ---------- bottom bar (UPDATED) ----------
  Widget _bottomBar() {
    final cs = Theme.of(context).colorScheme;

    /// Default bar for other stages (and for manual entry view)
    final primaryText = switch (_step) {
      StepStage.choose => 'Continue',
      StepStage.uploadDocs => 'Save & Continue',
      StepStage.uploadSupporting => 'Continue to Review & Submit',
      StepStage.review => 'Submit Request',
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: Row(
        children: [
          if (!_isFirst)
            TextButton(onPressed: _back, child: const Text('Back')),
          if (!_isFirst) const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: _canNext ? _next : null,
              style: FilledButton.styleFrom(
                backgroundColor: _canNext ? cs.primary : cs.surfaceVariant,
                foregroundColor: _canNext ? cs.onPrimary : cs.onSurfaceVariant,
              ),
              child: Text(primaryText),
            ),
          ),
        ],
      ),
    );
  }


  ///success service request widget
  Widget buildServiceRequestSuccess({
    required String serviceName,
    required String agentName,
    required num costUsd,
    required VoidCallback onTrackPressed,
  }) {
    return Builder(
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        final tt = Theme.of(context).textTheme;

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Your service request has been successfully submitted. '
                          'You can track the status of your request.',
                      textAlign: TextAlign.center,
                      style: tt.bodyMedium?.copyWith(color: Colors.grey[700]),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: const Color(0xFF50B463),
                    child: const Icon(Icons.check, color: Colors.white, size: 38),
                  ),
                  const SizedBox(height: 24),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Selected Service',
                      style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _serviceTile(context, title: serviceName),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: kv(
                          context,
                          k: 'Agent',
                          v: agentName,
                          alignEnd: false,
                        ),
                      ),
                      Expanded(
                        child: kv(
                          context,
                          k: 'Cost',
                          v: '\$ ${costUsd.toStringAsFixed(0)}',
                          alignEnd: true,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: onTrackPressed,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: cs.primaryContainer,
                        foregroundColor: cs.onPrimaryContainer,
                      ),
                      child: const Text(
                        'Track Service Status',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// helpers (functions, not widgets classes)
  Widget _serviceTile(BuildContext context, {required String title}) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: cs.outline.withOpacity(.4)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 84,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget kv(BuildContext context,
      {required String k, required String v, bool alignEnd = false}) {
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment:
      alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          k,
          style: tt.labelLarge?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(v, style: tt.bodyLarge),
      ],
    );
  }

  /// ---------- utilities ----------
  Widget _kv(String k, String? v) {
    final tt = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            k,
            style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        Expanded(child: Text(v ?? '-', textAlign: TextAlign.right)),
      ],
    );
  }

 ///pick file
  Future<File?> _pickAnyFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result == null || result.files.single.path == null) return null;
    return File(result.files.single.path!);
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
              Text(
                title,
                style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              ...items.map(
                (e) => ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  title: itemBuilder(e),
                  onTap: () => Navigator.of(ctx).pop<T>(e),
                ),
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() async{
   final state = ref.watch(serviceRequestControllerProvider);
    if (!state.isLoading) {
      final isSuccess = await ref.read(serviceRequestControllerProvider.notifier).submit();

      ///is success login
      if (isSuccess) {
        setState(() {
          _isSuccessService = true;
        });
      }
    }
  }

  /// simple text helpers
  static String _firstGivenName(String names) {
    final parts = names.trim().split(RegExp(r'\s+'));
    return parts.isNotEmpty ? parts.first : '';
  }

  static String _fmtDate(DateTime? d) {
    if (d == null) return '';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
  }

  static String _prettySex(String s) {
    switch (s.toUpperCase()) {
      case 'M':
        return 'Male';
      case 'F':
        return 'Female';
      default:
        return '';
    }
  }

  static String _iso3ToName(String iso3) {
    const map = {
      'MMR': 'Myanmar',
      'THA': 'Thailand',
      'USA': 'United States',
      'GBR': 'United Kingdom',
      'FRA': 'France',
      'DEU': 'Germany',
      'CHN': 'China',
      'JPN': 'Japan',
      'KOR': 'South Korea',
      'IND': 'India',
    };
    return map[iso3.toUpperCase()] ?? iso3;
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
                Text(
                  item.title,
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
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

  const Service({
    required this.name,
    required this.detail,
    required this.duration,
    required this.costUsd,
  });
}

class DocItem {
  final String title;
  bool isUploaded;
  String? fileName;

  DocItem({required this.title, this.isUploaded = false, this.fileName});
}

class _StepLabel extends StatelessWidget {
  const _StepLabel(this.t, this.s, {super.key});

  final String t, s;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(t, style: Theme.of(context).textTheme.bodySmall),
      Text(
        s,
        style: const TextStyle(fontSize: 10),
        textAlign: TextAlign.center,
      ),
    ],
  );
}

/// header dots & line
Widget _dot(Color c) => Container(
  margin: const EdgeInsets.symmetric(horizontal: 20),
  width: 10,
  height: 10,
  decoration: BoxDecoration(color: c, shape: BoxShape.circle),
);

Widget _line() =>
    Expanded(child: Container(height: 2, color: Colors.grey[300]));

/// --- helpers ---
extension _NullIfEmpty on String {
  String? get nullIfEmpty {
    final t = trim();
    return t.isEmpty ? null : t;
  }
}

/// Parses `dd MMM yyyy` or full month (e.g. `25 December 2025`).
/// Returns null when empty/invalid.
DateTime? _parseDmyNullable(String s) {
  final t = s.trim();
  if (t.isEmpty) return null;

  final m = RegExp(r'^(\d{1,2})\s+([A-Za-z]+)\s+(\d{4})$').firstMatch(t);
  if (m == null) return null;

  final day = int.tryParse(m.group(1)!);
  final mon = m.group(2)!;
  final year = int.tryParse(m.group(3)!);

  if (day == null || year == null) return null;

  const monthMap = {
    'JAN': 1, 'JANUARY': 1,
    'FEB': 2, 'FEBRUARY': 2,
    'MAR': 3, 'MARCH': 3,
    'APR': 4, 'APRIL': 4,
    'MAY': 5,
    'JUN': 6, 'JUNE': 6,
    'JUL': 7, 'JULY': 7,
    'AUG': 8, 'AUGUST': 8,
    'SEP': 9, 'SEPT': 9, 'SEPTEMBER': 9,
    'OCT': 10, 'OCTOBER': 10,
    'NOV': 11, 'NOVEMBER': 11,
    'DEC': 12, 'DECEMBER': 12,
  };

  final month = monthMap[mon.toUpperCase()];
  if (month == null) return null;

  try {
    return DateTime(year, month, day);
  } catch (_) {
    return null;
  }
}

