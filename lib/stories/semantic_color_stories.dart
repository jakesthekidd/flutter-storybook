import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storybook_flutter/storybook_flutter.dart';

import '../tokens/semantic_colors.dart';

final semanticColorStories = <Story>[
  Story(
    name: 'Tokens/Semantic/All',
    description: 'All semantic tokens for the active theme. Toggle the theme switcher (bottom-right) to compare light vs dark.',
    builder: (context) => const _SemanticGrid(),
  ),
  Story(
    name: 'Tokens/Semantic/By Group',
    builder: (context) {
      final groups = _grouped().keys.toList();
      final group = context.knobs.options(
        label: 'Group',
        initial: groups.first,
        options: [for (final g in groups) Option(label: g, value: g)],
      );
      return _SemanticGrid(filterGroup: group);
    },
  ),
];

Map<String, List<String>> _grouped() {
  final out = <String, List<String>>{};
  for (final n in TransfloSemanticColors.tokenNames) {
    final group = n.contains('/') ? n.split('/').first : 'misc';
    out.putIfAbsent(group, () => []).add(n);
  }
  return out;
}

class _SemanticGrid extends StatelessWidget {
  const _SemanticGrid({this.filterGroup});
  final String? filterGroup;

  @override
  Widget build(BuildContext context) {
    final sem = Theme.of(context).transflo;
    final groups = _grouped();
    final entries = filterGroup == null
        ? groups.entries.toList()
        : [MapEntry(filterGroup!, groups[filterGroup!] ?? const [])];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final entry in entries) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                entry.key,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final name in entry.value)
                  _SemanticSwatch(name: name, color: sem.byName(name)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SemanticSwatch extends StatelessWidget {
  const _SemanticSwatch({required this.name, required this.color});
  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final hex =
        '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
    final fg = color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    return InkWell(
      onTap: () => Clipboard.setData(ClipboardData(text: hex)),
      child: Container(
        width: 180,
        height: 84,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: TextStyle(
                  color: fg, fontSize: 12, fontWeight: FontWeight.w600),
            ),
            Text(hex, style: TextStyle(color: fg, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
