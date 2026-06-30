import 'package:flutter/material.dart';
import 'package:storybook_flutter/storybook_flutter.dart';

import '../components/scan_field.dart';

Widget _frame(Widget child) => SizedBox(
      width: 380,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );

const _splitFields = <ScanSubField>[
  ScanSubField(label: 'Account #', value: '004821', locked: true),
  ScanSubField(label: 'Store Number', value: '0093', locked: true),
  ScanSubField(label: 'Quantity', value: '0150', editable: true),
];

const _splitFieldsError = <ScanSubField>[
  ScanSubField(label: 'Account #', value: '004821', locked: true),
  ScanSubField(label: 'Store Number', value: '0093', locked: true),
  ScanSubField(
    label: 'Quantity',
    value: '0150',
    editable: true,
    error: 'Expected 4 digits',
  ),
];

/// Interactive demo: tapping Scan/Rescan/Confirm transitions state.
class _ScanFieldDemo extends StatefulWidget {
  const _ScanFieldDemo({
    required this.initialState,
    this.captureValue,
    this.rawScan,
    this.subfields = const [],
    this.errorText,
    this.withConfirm = false,
    this.required = false,
  });

  final ScanFieldState initialState;
  final String? captureValue;
  final String? rawScan;
  final List<ScanSubField> subfields;
  final String? errorText;
  final bool withConfirm;
  final bool required;

  @override
  State<_ScanFieldDemo> createState() => _ScanFieldDemoState();
}

class _ScanFieldDemoState extends State<_ScanFieldDemo> {
  late ScanFieldState _state = widget.initialState;
  bool _confirmed = false;

  void _onScan() => setState(() {
        _state = widget.subfields.isNotEmpty
            ? ScanFieldState.capturedSplit
            : ScanFieldState.capturedSingle;
        _confirmed = false;
      });

  void _onRescan() => setState(() {
        _state = ScanFieldState.empty;
        _confirmed = false;
      });

  void _onConfirm() => setState(() => _confirmed = true);

  @override
  Widget build(BuildContext context) {
    if (_confirmed) {
      return TransfloScanField(
        label: 'Order barcode',
        required: widget.required,
        state: _state,
        value: widget.captureValue,
        rawScan: widget.rawScan,
        subfields: widget.subfields,
        errorText: widget.errorText,
        onRescan: _onRescan,
      );
    }

    return TransfloScanField(
      label: 'Order barcode',
      required: widget.required,
      state: _state,
      value: widget.captureValue,
      rawScan: widget.rawScan,
      subfields: widget.subfields,
      errorText: widget.errorText,
      withConfirm: widget.withConfirm,
      onScan: _onScan,
      onRescan: _onRescan,
      onConfirm: _onConfirm,
    );
  }
}

final scanFieldStories = <Story>[
  Story(
    name: 'User Workflow/Scan Field/Empty',
    description: 'Tap Scan Barcode to simulate a capture.',
    builder: (_) => _frame(const _ScanFieldDemo(
      initialState: ScanFieldState.empty,
      captureValue: '00540991009020817685',
    )),
  ),
  Story(
    name: 'User Workflow/Scan Field/Empty · Required',
    description: 'Required scan field — label carries required marker.',
    builder: (_) => _frame(const _ScanFieldDemo(
      initialState: ScanFieldState.empty,
      captureValue: '00540991009020817685',
      required: true,
    )),
  ),
  Story(
    name: 'User Workflow/Scan Field/Captured · Single value',
    description:
        'Captured single value — no Confirm (form step; surrounding form Submit commits). Tap Rescan to clear.',
    builder: (_) => _frame(const _ScanFieldDemo(
      initialState: ScanFieldState.capturedSingle,
      captureValue: '00540991009020817685',
    )),
  ),
  Story(
    name: 'User Workflow/Scan Field/Captured · Single + Confirm',
    description:
        'Non-form step — Confirm commits the value (button disappears on tap).',
    builder: (_) => _frame(const _ScanFieldDemo(
      initialState: ScanFieldState.capturedSingle,
      captureValue: '00540991009020817685',
      withConfirm: true,
    )),
  ),
  Story(
    name: 'User Workflow/Scan Field/Captured · Split',
    description:
        'Captured multi-value (split enabled) — locked Account # / Store Number; Quantity is a real editable input.',
    builder: (_) => _frame(const _ScanFieldDemo(
      initialState: ScanFieldState.capturedSplit,
      rawScan: '004821-0093-0150',
      subfields: _splitFields,
    )),
  ),
  Story(
    name: 'User Workflow/Scan Field/Captured · Split + Confirm',
    description:
        'Non-form step — Confirm commits and hides the button. Rescan returns to empty.',
    builder: (_) => _frame(const _ScanFieldDemo(
      initialState: ScanFieldState.capturedSplit,
      rawScan: '004821-0093-0150',
      subfields: _splitFields,
      withConfirm: true,
    )),
  ),
  Story(
    name: 'User Workflow/Scan Field/Error · Captured (rejected)',
    description:
        'Transient rejection row — wrong symbology was read. Refresh to rescan.',
    builder: (_) => _frame(const _ScanFieldDemo(
      initialState: ScanFieldState.errorCapturedSingle,
      errorText: 'Wrong barcode type',
    )),
  ),
  Story(
    name: 'User Workflow/Scan Field/Error · Wrong barcode type',
    description:
        'After dismissal — returned to scannable with inline message.',
    builder: (_) => _frame(const _ScanFieldDemo(
      initialState: ScanFieldState.errorWrongType,
      errorText: 'Wrong barcode type — try again',
    )),
  ),
  Story(
    name: 'User Workflow/Scan Field/Error · Parse mismatch (split)',
    description:
        'Captured but invalid against split rules. Failing sub-field flagged; Confirm auto-disabled.',
    builder: (_) => _frame(const _ScanFieldDemo(
      initialState: ScanFieldState.errorParseMismatch,
      rawScan: '004821-0093-0150',
      subfields: _splitFieldsError,
      withConfirm: true,
    )),
  ),
];
