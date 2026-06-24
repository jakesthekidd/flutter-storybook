import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:storybook_flutter/storybook_flutter.dart';

import '../components/status_icon.dart';

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
];

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
