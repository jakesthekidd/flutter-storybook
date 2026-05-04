import 'package:flutter/material.dart';
import 'package:storybook_flutter/storybook_flutter.dart';

import 'stories/button_stories.dart';
import 'stories/card_stories.dart';
import 'stories/certify_logs_stories.dart';
import 'stories/color_stories.dart';
import 'stories/semantic_color_stories.dart';
import 'stories/text_field_stories.dart';
import 'tokens/semantic_colors.dart';

void main() => runApp(const StorybookApp());

class StorybookApp extends StatefulWidget {
  const StorybookApp({super.key});

  @override
  State<StorybookApp> createState() => _StorybookAppState();
}

class _StorybookAppState extends State<StorybookApp> {
  ThemeMode _mode = ThemeMode.light;

  void _toggle() => setState(() {
        _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
      });

  @override
  Widget build(BuildContext context) {
    final lightTheme = ThemeData(
      colorSchemeSeed: Colors.indigo,
      useMaterial3: true,
      brightness: Brightness.light,
      extensions: const [TransfloSemanticColors.light],
    );
    final darkTheme = ThemeData(
      colorSchemeSeed: Colors.indigo,
      useMaterial3: true,
      brightness: Brightness.dark,
      extensions: const [TransfloSemanticColors.dark],
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: _mode,
      theme: lightTheme,
      darkTheme: darkTheme,
      home: Stack(
        children: [
          Positioned.fill(
            child: Storybook(
              wrapperBuilder: (context, child) => Builder(
                builder: (context) {
                  final sem = Theme.of(context).transflo;
                  return Material(
                    color: sem.backgroundBase,
                    child: Center(child: child),
                  );
                },
              ),
              stories: [
                ...colorStories,
                ...semanticColorStories,
                ...certifyLogsStories,
                ...buttonStories,
                ...cardStories,
                ...textFieldStories,
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: Builder(
              builder: (context) => FloatingActionButton.small(
                tooltip: _mode == ThemeMode.light
                    ? 'Switch to dark'
                    : 'Switch to light',
                onPressed: _toggle,
                child: Icon(
                  _mode == ThemeMode.light
                      ? Icons.dark_mode
                      : Icons.light_mode,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
