import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:storybook_flutter/storybook_flutter.dart';

import '../components/status_icon.dart';
import '../components/workflow_panels.dart';

final userWorkflowStories = <Story>[
  Story(
    name: 'User Workflow/Status Icons',
    description:
        'Circular step-status indicator used on workflow screens. '
        'Six states: Not Done, Active, Done, Skipped, Locked, Warning. '
        'Auto-adapts to light and dark themes.',
    builder: (context) {
      final state = context.knobs.options(
        label: 'State',
        initial: StatusIconState.notDone,
        options: const [
          Option(label: 'Not Done', value: StatusIconState.notDone),
          Option(label: 'Active', value: StatusIconState.active),
          Option(label: 'Done', value: StatusIconState.done),
          Option(label: 'Skipped', value: StatusIconState.skipped),
          Option(label: 'Locked', value: StatusIconState.locked),
          Option(label: 'Warning', value: StatusIconState.warning),
        ],
      );
      return StatusIcon(state: state);
    },
  ),
  Story(
    name: 'User Workflow/Status Icons/All States',
    description: 'All six states at the canonical 21 px size.',
    builder: (context) => const _AllStatesGrid(),
  ),
  Story(
    name: 'User Workflow/Panels/Segment Panel',
    description:
        'Full-width segment panel containing step panels. Locked status disables all children.',
    builder: (context) {
      final status = context.knobs.options(
        label: 'Status',
        initial: StatusIconState.notDone,
        options: const [
          Option(label: 'Not Done', value: StatusIconState.notDone),
          Option(label: 'Active', value: StatusIconState.active),
          Option(label: 'Done', value: StatusIconState.done),
          Option(label: 'Skipped', value: StatusIconState.skipped),
          Option(label: 'Locked', value: StatusIconState.locked),
          Option(label: 'Warning', value: StatusIconState.warning),
        ],
      );
      final expanded = context.knobs.boolean(label: 'Expanded', initial: true);

      return SingleChildScrollView(
        child: WorkflowSegmentPanel(
          title: 'Load Documents',
          status: status,
          initialExpanded: expanded,
          children: [
            WorkflowStepPanel(
              title: 'Bill of Lading',
              status: StatusIconState.active,
              initialExpanded: true,
              children: const [
                _DemoTextField(label: 'Reference Number'),
                _DemoTextField(label: 'Shipper Name'),
              ],
            ),
            WorkflowStepPanel(
              title: 'Proof of Delivery',
              status: StatusIconState.notDone,
              optional: true,
              children: const [
                _DemoTextField(label: 'Delivery Date'),
              ],
            ),
            WorkflowStepPanel(
              title: 'Rate Confirmation',
              status: StatusIconState.done,
              children: const [
                _DemoTextField(label: 'Carrier Name'),
              ],
            ),
          ],
        ),
      );
    },
  ),
  Story(
    name: 'User Workflow/Panels/Step Panel',
    description: 'Individual step card with optional tag and form content slot.',
    builder: (context) {
      final status = context.knobs.options(
        label: 'Status',
        initial: StatusIconState.notDone,
        options: const [
          Option(label: 'Not Done', value: StatusIconState.notDone),
          Option(label: 'Active', value: StatusIconState.active),
          Option(label: 'Done', value: StatusIconState.done),
          Option(label: 'Skipped', value: StatusIconState.skipped),
          Option(label: 'Locked', value: StatusIconState.locked),
          Option(label: 'Warning', value: StatusIconState.warning),
        ],
      );
      final optional = context.knobs.boolean(label: 'Optional', initial: false);
      final expanded = context.knobs.boolean(label: 'Expanded', initial: true);

      return SizedBox(
        width: 366,
        child: WorkflowStepPanel(
          title: 'Bill of Lading',
          status: status,
          optional: optional,
          initialExpanded: expanded,
          children: const [
            _DemoTextField(label: 'Reference Number'),
            _DemoTextField(label: 'Shipper Name'),
          ],
        ),
      );
    },
  ),
];

// ── Demo helpers ──────────────────────────────────────────────────────────────

class _DemoTextField extends StatelessWidget {
  const _DemoTextField({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface0 = isDark ? Colors.black : Colors.white;
    final surface600 = isDark ? const Color(0xFF535B6D) : const Color(0xFFA9B3C2);
    final textMain = isDark ? const Color(0xFFE6E8EE) : const Color(0xFF3D3D3D);
    const blue = Color(0xFF2474BB);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 4),
          child: Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textMain,
            ),
          ),
        ),
        TextField(
          style: GoogleFonts.roboto(fontSize: 16, color: textMain),
          decoration: InputDecoration(
            hintText: label,
            hintStyle: GoogleFonts.roboto(fontSize: 16, color: surface600),
            filled: true,
            fillColor: surface0,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: surface600, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: blue, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

// ── All-states overview ────────────────────────────────────────────────────

class _AllStatesGrid extends StatelessWidget {
  const _AllStatesGrid();

  static const _states = [
    (StatusIconState.notDone, 'Not Done'),
    (StatusIconState.active, 'Active'),
    (StatusIconState.done, 'Done'),
    (StatusIconState.skipped, 'Skipped'),
    (StatusIconState.locked, 'Locked'),
    (StatusIconState.warning, 'Warning'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark ? Colors.white70 : const Color(0xFF8D9AAE);

    return Wrap(
      spacing: 32,
      runSpacing: 28,
      alignment: WrapAlignment.center,
      children: _states.map((entry) {
        final (state, label) = entry;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StatusIcon(state: state),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: 11,
                color: labelColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
