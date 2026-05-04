import 'package:flutter/material.dart';
import 'package:storybook_flutter/storybook_flutter.dart';

import 'stories/button_stories.dart';
import 'stories/card_stories.dart';
import 'stories/text_field_stories.dart';

void main() => runApp(const StorybookApp());

class StorybookApp extends StatelessWidget {
  const StorybookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Storybook(
      wrapperBuilder: (context, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.indigo,
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorSchemeSeed: Colors.indigo,
          brightness: Brightness.dark,
          useMaterial3: true,
        ),
        home: Scaffold(body: Center(child: child)),
      ),
      stories: [
        ...buttonStories,
        ...cardStories,
        ...textFieldStories,
      ],
    );
  }
}
