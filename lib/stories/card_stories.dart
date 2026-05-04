import 'package:flutter/material.dart';
import 'package:storybook_flutter/storybook_flutter.dart';

import '../tokens/semantic_colors.dart';

final cardStories = <Story>[
  Story(
    name: 'Cards/Basic',
    builder: (context) {
      final sem = Theme.of(context).transflo;
      return SizedBox(
        width: 320,
        child: Card(
          color: sem.backgroundElevated,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: sem.borderDefault),
          ),
          elevation: context.knobs
              .sliderInt(label: 'Elevation', initial: 0, min: 0, max: 12)
              .toDouble(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.knobs.text(label: 'Title', initial: 'Card title'),
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: sem.textHeading),
                ),
                const SizedBox(height: 8),
                Text(
                  context.knobs.text(
                    label: 'Body',
                    initial: 'Supporting text for the card content.',
                  ),
                  style: TextStyle(color: sem.textBody),
                ),
              ],
            ),
          ),
        ),
      );
    },
  ),
  Story(
    name: 'Cards/With Actions',
    builder: (context) {
      final sem = Theme.of(context).transflo;
      return SizedBox(
        width: 320,
        child: Card(
          color: sem.backgroundElevated,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: sem.borderDefault),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.album, color: sem.brandIcon),
                title: Text('Now playing',
                    style: TextStyle(color: sem.textHeading)),
                subtitle: Text('Artist · Album',
                    style: TextStyle(color: sem.textMuted)),
              ),
              OverflowBar(
                alignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: sem.brandPrimary),
                    onPressed: () {},
                    child: const Text('Share'),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: sem.brandPrimary),
                    onPressed: () {},
                    child: const Text('Listen'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  ),
  Story(
    name: 'Cards/Status',
    builder: (context) {
      final sem = Theme.of(context).transflo;
      final variant = context.knobs.options(
        label: 'Variant',
        initial: 'success',
        options: const [
          Option(label: 'Success', value: 'success'),
          Option(label: 'Warning', value: 'warning'),
          Option(label: 'Error', value: 'error'),
          Option(label: 'Info', value: 'info'),
        ],
      );
      final (bg, fg, icon) = switch (variant) {
        'warning' => (sem.statusWarningLight, sem.statusWarningDark, Icons.warning_amber),
        'error' => (sem.statusErrorLight, sem.statusErrorDark, Icons.error_outline),
        'info' => (sem.statusInfoLight, sem.statusInfoDark, Icons.info_outline),
        _ => (sem.statusSuccessLight, sem.statusSuccessDark, Icons.check_circle_outline),
      };
      return SizedBox(
        width: 320,
        child: Card(
          color: bg,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: fg),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.knobs.text(
                      label: 'Message',
                      initial: 'Something happened. Here\'s what to know.',
                    ),
                    style: TextStyle(color: fg, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  ),
];
