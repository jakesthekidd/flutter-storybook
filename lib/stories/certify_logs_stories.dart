import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storybook_flutter/storybook_flutter.dart';

import '../components/certify_logs_banner.dart';
import '../components/certify_logs_controller.dart';

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
        'Live demo using CertifyLogsController. Tap "Certify" to simulate the Geotab round-trip; toggle the chip to make the next call fail.',
    builder: (context) => const _InteractiveFlow(),
  ),
  Story(
    name: 'Banners/Certify Logs/Implementation Guide',
    description: 'Drop-in usage, controller API, and event-tracking notes.',
    builder: (context) => const _ImplementationGuide(),
  ),
];

class _InteractiveFlow extends StatefulWidget {
  const _InteractiveFlow();

  @override
  State<_InteractiveFlow> createState() => _InteractiveFlowState();
}

class _InteractiveFlowState extends State<_InteractiveFlow> {
  final _controller = CertifyLogsController();
  bool _required = true;
  bool _failNext = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Stand-in for `geotab.isCertified()` — resolves after a short delay
  /// and either succeeds or fails based on the toggle.
  Future<bool> _fakeGeotabCheck() async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (_failNext) {
      _failNext = false;
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 480,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListenableBuilder(
            listenable: _controller,
            builder: (context, _) => CertifyLogsBanner.controlled(
              _controller,
              required: _required,
              onCertifyTap: () => _controller.runGeotabCheck(_fakeGeotabCheck),
              onTryAgainTap: () => _controller.runGeotabCheck(_fakeGeotabCheck),
              onSelfAttestTap: () => _controller.markCertified(attested: true),
            ),
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
                onPressed: () {
                  _controller.setUncertified();
                  _controller.expand();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImplementationGuide extends StatelessWidget {
  const _ImplementationGuide();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: const _ImplementationNotes(showHeader: true),
        ),
      ),
    );
  }
}

class _ImplementationNotes extends StatelessWidget {
  const _ImplementationNotes({this.showHeader = false});

  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showHeader) ...[
          Text('Certify Logs Banner — Implementation Guide',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
        ],
        const _Section(
          title: '1. Drop-in usage (controller pattern)',
          body:
              'One CertifyLogsController owns the state. Wrap the banner in '
              'ListenableBuilder so it rebuilds when the controller notifies. '
              'The controller is a ChangeNotifier — you can also pass it '
              'through Provider, Riverpod, GetIt, or whatever your app uses.',
          code: '''final certifyLogs = CertifyLogsController();

// Inside the workflow's Steps screen, pinned at the top:
ListenableBuilder(
  listenable: certifyLogs,
  builder: (_, __) => CertifyLogsBanner.controlled(
    certifyLogs,
    required: workflow.requiresCertification,
    onCertifyTap: () => certifyLogs.runGeotabCheck(geotab.isCertified),
    onTryAgainTap: () => certifyLogs.runGeotabCheck(geotab.isCertified),
    onSelfAttestTap: () => certifyLogs.markCertified(attested: true),
  ),
);''',
        ),
        const _Section(
          title: '2. Wire the Geotab callback',
          body:
              'runGeotabCheck takes a Future<bool> Function() — your real '
              'API call. It handles loading state, success → certified, '
              'false-or-throw → unverifiable, and re-expands the banner '
              'so the result is visible. No manual setState orchestration.',
          code: '''Future<bool> isCertified() async {
  final res = await geotabClient.checkHosCertification(
    driverId: driver.id,
    days: 14,
  );
  return res.allDaysCertified;
}

// Anywhere the user triggers certification:
await certifyLogs.runGeotabCheck(isCertified);''',
        ),
        const _Section(
          title: '3. Block workflow progression',
          body:
              'isBlockingProgress is true while the banner is in any state '
              'other than certified. Use it to gate the Submit button on '
              'the Steps screen.',
          code: '''ElevatedButton(
  onPressed: certifyLogs.isBlockingProgress ? null : workflow.submit,
  child: const Text('Submit'),
);''',
        ),
        const _Section(
          title: '4. Event tracking (compliance)',
          body:
              'attested is true when the user reached certified via '
              '"I Have Certified My Logs" instead of a successful Geotab '
              'API call. Log the two paths separately.',
          code: '''certifyLogs.addListener(() {
  if (certifyLogs.state != CertifyLogsState.certified) return;
  analytics.track(certifyLogs.attested
    ? 'hos_logs_self_attested'
    : 'hos_logs_geotab_verified');
});''',
        ),
        const _Section(
          title: '5. Required vs Optional',
          body:
              'Pass required: false for inline workflow placement where the '
              'banner is a reminder. Adds a "Skip For Now" tile that calls '
              'controller.collapse() by default — override onSkipTap to do '
              'more (dismiss for the session, log "reminder skipped", etc.).',
          code: '''CertifyLogsBanner.controlled(
  certifyLogs,
  required: false,
  onSkipTap: () {
    certifyLogs.collapse();
    analytics.track('hos_reminder_skipped');
  },
  // ...
);''',
        ),
        const _Section(
          title: '6. Theme tokens',
          body:
              'The banner reads Theme.of(context).brightness and pulls hex '
              'pairs from the Figma variables export. It auto-swaps in '
              'light/dark with the rest of the app. No additional theming '
              'required.',
          code: null,
        ),
        const _Section(
          title: '7. Accessibility',
          body:
              'Respects MediaQuery.disableAnimations (iOS Reduce Motion / '
              'Android Remove animations). When on, the spring/scale/'
              'translate transforms are bypassed and the ambient breathing '
              'loop is suppressed; state changes still happen via fast '
              'color/opacity crossfades.',
          code: null,
        ),
        const _Section(
          title: '8. Controller API summary',
          body: '',
          code: '''class CertifyLogsController extends ChangeNotifier {
  CertifyLogsState get state;
  bool get expanded;
  DateTime? get verifiedAt;
  bool get attested;
  bool get isBlockingProgress;

  // Direct transitions
  void setLoading();
  void setUncertified();
  void setUnverifiable();
  void markCertified({DateTime? at, bool attested = false});

  // Expansion
  void expand();
  void collapse();
  void toggleExpanded();

  // Orchestration
  Future<void> runGeotabCheck(Future<bool> Function() check);
}''',
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body, this.code});
  final String title;
  final String body;
  final String? code;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          if (body.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(body, style: theme.textTheme.bodyMedium),
          ],
          if (code != null) ...[
            const SizedBox(height: 10),
            _CodeBlock(code: code!),
          ],
        ],
      ),
    );
  }
}

class _CodeBlock extends StatelessWidget {
  const _CodeBlock({required this.code});
  final String code;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2128) : const Color(0xFFF4F5F7),
        border: Border.all(
          color: isDark ? const Color(0xFF2D3038) : const Color(0xFFE0E2E8),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 48, 12),
            child: SelectableText(
              code,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12.5,
                height: 1.55,
                color: isDark ? const Color(0xFFE6E8EE) : const Color(0xFF1F2128),
              ),
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: _CopyButton(text: code),
          ),
        ],
      ),
    );
  }
}

class _CopyButton extends StatefulWidget {
  const _CopyButton({required this.text});
  final String text;

  @override
  State<_CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<_CopyButton> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: _copied ? 'Copied' : 'Copy',
      iconSize: 16,
      icon: Icon(_copied ? Icons.check : Icons.copy_outlined),
      onPressed: () async {
        await Clipboard.setData(ClipboardData(text: widget.text));
        if (!mounted) return;
        setState(() => _copied = true);
        Future<void>.delayed(const Duration(seconds: 1), () {
          if (mounted) setState(() => _copied = false);
        });
      },
    );
  }
}
