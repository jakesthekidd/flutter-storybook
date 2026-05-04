import 'package:flutter/material.dart';
import 'package:storybook_flutter/storybook_flutter.dart';

import '../tokens/semantic_colors.dart';

final buttonStories = <Story>[
  Story(
    name: 'Buttons/Elevated',
    builder: (context) {
      final sem = Theme.of(context).transflo;
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: sem.backgroundElevated,
          foregroundColor: sem.textHeading,
        ),
        onPressed:
            context.knobs.boolean(label: 'Enabled', initial: true) ? () {} : null,
        child: Text(context.knobs.text(label: 'Label', initial: 'Press me')),
      );
    },
  ),
  Story(
    name: 'Buttons/Filled',
    builder: (context) {
      final sem = Theme.of(context).transflo;
      return FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: sem.brandPrimary,
          foregroundColor: sem.brandPrimaryOn,
        ),
        onPressed: () {},
        child: Text(context.knobs.text(label: 'Label', initial: 'Submit')),
      );
    },
  ),
  Story(
    name: 'Buttons/Outlined',
    builder: (context) {
      final sem = Theme.of(context).transflo;
      return OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: sem.brandPrimary,
          side: BorderSide(color: sem.borderDefault),
        ),
        onPressed: () {},
        child: Text(context.knobs.text(label: 'Label', initial: 'Cancel')),
      );
    },
  ),
  Story(
    name: 'Buttons/Destructive',
    builder: (context) {
      final sem = Theme.of(context).transflo;
      return FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: sem.statusError,
          foregroundColor: sem.statusErrorOn,
        ),
        onPressed: () {},
        child: Text(context.knobs.text(label: 'Label', initial: 'Delete')),
      );
    },
  ),
  Story(
    name: 'Buttons/Icon',
    builder: (context) {
      final sem = Theme.of(context).transflo;
      return IconButton(
        color: sem.brandIcon,
        onPressed: () {},
        icon: Icon(
          context.knobs.options(
            label: 'Icon',
            initial: Icons.favorite,
            options: const [
              Option(label: 'Favorite', value: Icons.favorite),
              Option(label: 'Star', value: Icons.star),
              Option(label: 'Bookmark', value: Icons.bookmark),
            ],
          ),
        ),
      );
    },
  ),
];
