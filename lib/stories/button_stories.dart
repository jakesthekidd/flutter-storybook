import 'package:flutter/material.dart';
import 'package:storybook_flutter/storybook_flutter.dart';

final buttonStories = <Story>[
  Story(
    name: 'Buttons/Elevated',
    builder: (context) => ElevatedButton(
      onPressed: context.knobs.boolean(label: 'Enabled', initial: true)
          ? () {}
          : null,
      child: Text(context.knobs.text(label: 'Label', initial: 'Press me')),
    ),
  ),
  Story(
    name: 'Buttons/Filled',
    builder: (context) => FilledButton(
      onPressed: () {},
      child: Text(context.knobs.text(label: 'Label', initial: 'Submit')),
    ),
  ),
  Story(
    name: 'Buttons/Outlined',
    builder: (context) => OutlinedButton(
      onPressed: () {},
      child: Text(context.knobs.text(label: 'Label', initial: 'Cancel')),
    ),
  ),
  Story(
    name: 'Buttons/Icon',
    builder: (context) => IconButton(
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
    ),
  ),
];
