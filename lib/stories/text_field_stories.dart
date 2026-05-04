import 'package:flutter/material.dart';
import 'package:storybook_flutter/storybook_flutter.dart';

import '../tokens/semantic_colors.dart';

final textFieldStories = <Story>[
  Story(
    name: 'Inputs/TextField',
    builder: (context) {
      final sem = Theme.of(context).transflo;
      return SizedBox(
        width: 280,
        child: TextField(
          enabled: context.knobs.boolean(label: 'Enabled', initial: true),
          obscureText: context.knobs.boolean(label: 'Obscure', initial: false),
          style: TextStyle(color: sem.textHeading),
          cursorColor: sem.brandPrimary,
          decoration: InputDecoration(
            labelText: context.knobs.text(label: 'Label', initial: 'Email'),
            hintText: context.knobs.text(
              label: 'Hint',
              initial: 'you@example.com',
            ),
            labelStyle: TextStyle(color: sem.textMuted),
            hintStyle: TextStyle(color: sem.textMuted),
            filled: true,
            fillColor: sem.backgroundElevated,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: sem.borderDefault),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: sem.brandPrimary, width: 2),
            ),
          ),
        ),
      );
    },
  ),
];
