import 'package:flutter/material.dart';
import 'package:storybook_flutter/storybook_flutter.dart';

final textFieldStories = <Story>[
  Story(
    name: 'Inputs/TextField',
    builder: (context) => SizedBox(
      width: 280,
      child: TextField(
        enabled: context.knobs.boolean(label: 'Enabled', initial: true),
        obscureText: context.knobs.boolean(label: 'Obscure', initial: false),
        decoration: InputDecoration(
          labelText: context.knobs.text(label: 'Label', initial: 'Email'),
          hintText: context.knobs.text(
            label: 'Hint',
            initial: 'you@example.com',
          ),
          border: const OutlineInputBorder(),
        ),
      ),
    ),
  ),
];
