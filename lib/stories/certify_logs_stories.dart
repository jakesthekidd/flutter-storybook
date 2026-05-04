import 'package:flutter/material.dart';
import 'package:storybook_flutter/storybook_flutter.dart';

import '../components/certify_logs_banner.dart';

final certifyLogsStories = <Story>[
  Story(
    name: 'Banners/Certify Logs/Static',
    description: 'Pick any state via knobs. Tap the chevron to expand/collapse.',
    builder: (context) {
      final state = context.knobs.options(
        label: 'State',
        initial: CertifyLogsState.uncertified,
        options: const [
          Option(label: 'Loading', value: CertifyLogsState.loading),
          Option(label: 'Uncertified', value: CertifyLogsState.uncertified),
          Option(label: 'Unverifiable', value: CertifyLogsState.unverifiable),
          Option(label: 'Certified', value: CertifyLogsState.certified),
        ],
      );
      final required = context.knobs.boolean(label: 'Required', initial: true);
      final expanded = context.knobs.boolean(label: 'Expanded', initial: true);
      return SizedBox(
        width: 366,
        child: CertifyLogsBanner(
          state: state,
          expanded: expanded,
          required: required,
          verifiedAt: state == CertifyLogsState.certified
              ? DateTime.now().subtract(const Duration(minutes: 2))
              : null,
        ),
      );
    },
  ),
  Story(
    name: 'Banners/Certify Logs/Interactive Flow',
    description:
        'Live demo: tap "Certify" to simulate the Geotab round-trip. The banner flows through loading → certified. Use the toolbar to inject the unverifiable error.',
    builder: (context) => const _InteractiveFlow(),
  ),
];

class _InteractiveFlow extends StatefulWidget {
  const _InteractiveFlow();

  @override
  State<_InteractiveFlow> createState() => _InteractiveFlowState();
}

class _InteractiveFlowState extends State<_InteractiveFlow> {
  CertifyLogsState _state = CertifyLogsState.uncertified;
  bool _expanded = true;
  bool _required = true;
  bool _failNext = false;
  DateTime? _verifiedAt;

  Future<void> _certify() async {
    setState(() {
      _state = CertifyLogsState.loading;
      _expanded = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() {
      if (_failNext) {
        _state = CertifyLogsState.unverifiable;
        _failNext = false;
      } else {
        _state = CertifyLogsState.certified;
        _verifiedAt = DateTime.now();
      }
    });
  }

  void _selfAttest() {
    setState(() {
      _state = CertifyLogsState.certified;
      _verifiedAt = DateTime.now();
    });
  }

  void _reset() {
    setState(() {
      _state = CertifyLogsState.uncertified;
      _verifiedAt = null;
      _expanded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 366,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CertifyLogsBanner(
            state: _state,
            expanded: _expanded,
            required: _required,
            verifiedAt: _verifiedAt,
            onExpandToggle: () => setState(() => _expanded = !_expanded),
            onCertifyTap: _certify,
            onSkipTap: () => setState(() => _expanded = false),
            onTryAgainTap: _certify,
            onSelfAttestTap: _selfAttest,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              FilterChip(
                label: const Text('Required'),
                selected: _required,
                onSelected: (v) => setState(() => _required = v),
              ),
              FilterChip(
                label: const Text('Fail next call'),
                selected: _failNext,
                onSelected: (v) => setState(() => _failNext = v),
              ),
              ActionChip(
                label: const Text('Reset'),
                onPressed: _reset,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
