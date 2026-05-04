import 'package:flutter/material.dart';
import 'package:storybook_flutter/storybook_flutter.dart';

final cardStories = <Story>[
  Story(
    name: 'Cards/Basic',
    builder: (context) => SizedBox(
      width: 320,
      child: Card(
        elevation: context.knobs.sliderInt(
          label: 'Elevation',
          initial: 2,
          min: 0,
          max: 12,
        ).toDouble(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.knobs.text(label: 'Title', initial: 'Card title'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                context.knobs.text(
                  label: 'Body',
                  initial: 'Supporting text for the card content.',
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
  Story(
    name: 'Cards/With Actions',
    builder: (context) => SizedBox(
      width: 320,
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              leading: Icon(Icons.album),
              title: Text('Now playing'),
              subtitle: Text('Artist · Album'),
            ),
            OverflowBar(
              alignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () {}, child: const Text('Share')),
                TextButton(onPressed: () {}, child: const Text('Listen')),
              ],
            ),
          ],
        ),
      ),
    ),
  ),
];
