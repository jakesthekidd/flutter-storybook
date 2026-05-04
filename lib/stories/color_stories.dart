import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storybook_flutter/storybook_flutter.dart';

import '../tokens/colors.dart';

final colorStories = <Story>[
  Story(
    name: 'Tokens/Colors/All Primitives',
    builder: (context) => const _PaletteGrid(),
  ),
  Story(
    name: 'Tokens/Colors/By Family',
    builder: (context) {
      final families = TransfloColors.palette.keys.toList();
      final family = context.knobs.options(
        label: 'Family',
        initial: families.first,
        options: [for (final f in families) Option(label: f, value: f)],
      );
      return _FamilyRow(family: family);
    },
  ),
];

class _PaletteGrid extends StatelessWidget {
  const _PaletteGrid();

  @override
  Widget build(BuildContext context) {
    final families = TransfloColors.palette.keys.toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final fam in families) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(fam,
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            _FamilyRow(family: fam),
          ],
        ],
      ),
    );
  }
}

class _FamilyRow extends StatelessWidget {
  const _FamilyRow({required this.family});
  final String family;

  @override
  Widget build(BuildContext context) {
    final shades = TransfloColors.palette[family] ?? const [];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final entry in shades)
          _Swatch(
            name: '$family-${entry.key}',
            color: entry.value,
          ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.name, required this.color});
  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final hex = '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
    final luminance = color.computeLuminance();
    final fg = luminance > 0.5 ? Colors.black : Colors.white;
    return InkWell(
      onTap: () => Clipboard.setData(ClipboardData(text: hex)),
      child: Container(
        width: 120,
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
            Text(name,
                style: TextStyle(
                    color: fg, fontSize: 12, fontWeight: FontWeight.w600)),
            Text(hex, style: TextStyle(color: fg, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
