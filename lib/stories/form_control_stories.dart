import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:storybook_flutter/storybook_flutter.dart';

import '../components/star_rating.dart';
import '../tokens/semantic_colors.dart';

// Shared colors used across all form stories
const _blue = Color(0xFF2474BB);

final formControlStories = <Story>[
  // ── Drop Down ────────────────────────────────────────────────────────────────
  Story(
    name: 'Inputs/Drop Down',
    description:
        'Single-select dropdown using DropdownButtonFormField, '
        'styled with brand tokens.',
    builder: (context) {
      final sem = Theme.of(context).transflo;
      final isDark = Theme.of(context).brightness == Brightness.dark;
      const options = [
        'Save and Continue',
        'Submit for Review',
        'Mark Complete',
        'Request Approval',
      ];
      String? selected;

      return StatefulBuilder(
        builder: (context, setState) => SizedBox(
          width: 360,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              value: selected,
              decoration: InputDecoration(
                labelText: 'Select an action',
                labelStyle: GoogleFonts.roboto(
                    fontSize: 14, color: sem.textMuted),
                filled: true,
                fillColor: sem.rootSurfaceCard,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(
                      color: isDark
                          ? const Color(0xFF535B6D)
                          : const Color(0xFFA9B3C2),
                      width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide:
                      const BorderSide(color: _blue, width: 2),
                ),
              ),
              dropdownColor: sem.rootSurfaceCard,
              style: GoogleFonts.roboto(
                  fontSize: 16, color: sem.textHeading),
              icon: Icon(Icons.keyboard_arrow_down,
                  color: sem.textMuted),
              items: options
                  .map((o) => DropdownMenuItem(
                        value: o,
                        child: Text(o,
                            style: GoogleFonts.roboto(
                                fontSize: 15,
                                color: sem.textHeading)),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => selected = v),
            ),
          ),
        ),
      );
    },
  ),

  // ── Drop Down Information ─────────────────────────────────────────────────
  Story(
    name: 'Inputs/Drop Down Information',
    description:
        'Expandable info row built on ExpansionTile, styled with brand tokens.',
    builder: (context) {
      final sem = Theme.of(context).transflo;
      return SizedBox(
        width: 360,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _styledExpansionTile(
                sem: sem,
                title: 'Special Instructions',
                body:
                    'Before you leave please message the yard manager '
                    'your departure time. Add any detention times as well.',
              ),
              const SizedBox(height: 8),
              _styledExpansionTile(
                sem: sem,
                title: 'Pickup Details',
                body:
                    'Confirm pallet count and condition before signing '
                    'the bill of lading.',
              ),
            ],
          ),
        ),
      );
    },
  ),

  // ── Date & Time ───────────────────────────────────────────────────────────
  Story(
    name: 'Inputs/Date & Time',
    description:
        'Tapping the field opens the Material date picker (calendar) or '
        'the Cupertino wheel picker — toggle with the knob.',
    builder: (context) {
      final wheel =
          context.knobs.boolean(label: 'Wheel picker', initial: false);
      return SizedBox(
        width: 360,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _DateTimeField(wheelPicker: wheel),
        ),
      );
    },
  ),

  // ── Temperature ───────────────────────────────────────────────────────────
  Story(
    name: 'Inputs/Temperature',
    description:
        'Two-column CupertinoPicker drum wheel for integer and decimal '
        'temperature selection.',
    builder: (context) => const Padding(
      padding: EdgeInsets.all(24),
      child: _TemperaturePicker(),
    ),
  ),

  // ── Checks & Radio ────────────────────────────────────────────────────────
  Story(
    name: 'Inputs/Checks & Radio',
    description:
        'CheckboxListTile (multi-select) and RadioListTile (single-select), '
        'both using brand primary color.',
    builder: (context) {
      final mode = context.knobs.options(
        label: 'Mode',
        initial: _SelectMode.checkbox,
        options: const [
          Option(label: 'Checkbox', value: _SelectMode.checkbox),
          Option(label: 'Radio', value: _SelectMode.radio),
        ],
      );
      return SizedBox(
        width: 360,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _ChecksRadioList(
            mode: mode,
            options: const [
              'Save and Continue',
              'Submit for Review',
              'Mark Complete',
              'Skip for Now',
              'Request Approval',
            ],
          ),
        ),
      );
    },
  ),

  // ── Slider ───────────────────────────────────────────────────────────────
  Story(
    name: 'Inputs/Slider',
    description: 'Flutter Slider with SliderTheme applying brand tokens.',
    builder: (context) {
      final sem = Theme.of(context).transflo;
      return SizedBox(
        width: 360,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _DetentionSlider(sem: sem),
        ),
      );
    },
  ),

  // ── Toggle ───────────────────────────────────────────────────────────────
  Story(
    name: 'Inputs/Toggle',
    description: 'SwitchListTile using brand primary active color.',
    builder: (context) {
      final sem = Theme.of(context).transflo;
      return SizedBox(
        width: 360,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _ToggleList(sem: sem),
        ),
      );
    },
  ),

  // ── Star Rating ───────────────────────────────────────────────────────────
  Story(
    name: 'Inputs/Star Rating',
    description: 'Interactive 1–5 star rating. Tap a star to rate.',
    builder: (context) {
      final label = context.knobs.text(
          label: 'Prompt', initial: 'Rate your pick-up experience');
      return Padding(
        padding: const EdgeInsets.all(24),
        child: StarRating(label: label),
      );
    },
  ),
];

// ── Helpers ───────────────────────────────────────────────────────────────────

Widget _styledExpansionTile({
  required TransfloSemanticColors sem,
  required String title,
  required String body,
}) {
  return Theme(
    data: ThemeData(
      dividerColor: Colors.transparent,
      colorScheme: ColorScheme.light(
        primary: _blue,
        surface: sem.rootSurfaceCard,
      ),
    ),
    child: Container(
      decoration: BoxDecoration(
        color: sem.rootSurfaceCard,
        border: Border.all(color: sem.rootSurfaceBorder),
        borderRadius: BorderRadius.circular(6),
      ),
      child: ExpansionTile(
        tilePadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        collapsedIconColor: sem.textMuted,
        iconColor: _blue,
        title: Text(title,
            style: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: sem.textHeading)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Text(body,
                style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: sem.textMuted,
                    height: 1.5)),
          ),
        ],
      ),
    ),
  );
}

// ── Date & Time ───────────────────────────────────────────────────────────────

class _DateTimeField extends StatefulWidget {
  const _DateTimeField({this.wheelPicker = false});
  final bool wheelPicker;

  @override
  State<_DateTimeField> createState() => _DateTimeFieldState();
}

class _DateTimeFieldState extends State<_DateTimeField> {
  DateTime? _date;
  TimeOfDay? _time;

  String get _displayText {
    if (_date == null) return 'MM/DD/YYYY, 08:00 AM  –  MM/DD/YYYY';
    final m = _date!.month.toString().padLeft(2, '0');
    final d = _date!.day.toString().padLeft(2, '0');
    final t = _time?.format(context) ?? '08:00 AM';
    return '$m/${d}/${_date!.year}, $t';
  }

  Future<void> _pick() async {
    if (widget.wheelPicker) {
      // Cupertino sheet
      DateTime temp = _date ?? DateTime.now();
      await showCupertinoModalPopup<void>(
        context: context,
        builder: (ctx) {
          final sem = Theme.of(context).transflo;
          return Container(
            height: 300,
            color: sem.rootSurfaceCard,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: Text('Cancel',
                          style: GoogleFonts.roboto(color: sem.textMuted)),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                    CupertinoButton(
                      child: Text('Done',
                          style: GoogleFonts.roboto(color: _blue)),
                      onPressed: () {
                        setState(() => _date = temp);
                        Navigator.pop(ctx);
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: temp,
                    onDateTimeChanged: (d) => temp = d,
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      // Material calendar
      final sem = Theme.of(context).transflo;
      final picked = await showDatePicker(
        context: context,
        initialDate: _date ?? DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
        builder: (ctx, child) => Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: ColorScheme.light(
              primary: _blue,
              onPrimary: Colors.white,
              surface: sem.rootSurfaceCard,
              onSurface: sem.textHeading,
            ),
          ),
          child: child!,
        ),
      );
      if (picked != null) setState(() => _date = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sem = Theme.of(context).transflo;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasValue = _date != null;

    return GestureDetector(
      onTap: _pick,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date & Time',
          labelStyle:
              GoogleFonts.roboto(fontSize: 14, color: sem.textMuted),
          filled: true,
          fillColor: sem.rootSurfaceCard,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          suffixIcon: Icon(
            widget.wheelPicker
                ? Icons.expand_more
                : Icons.calendar_today_outlined,
            color: hasValue ? _blue : sem.textMuted,
            size: 20,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(
                color: hasValue
                    ? _blue
                    : (isDark
                        ? const Color(0xFF535B6D)
                        : const Color(0xFFA9B3C2)),
                width: hasValue ? 2 : 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: _blue, width: 2),
          ),
        ),
        child: Text(
          _displayText,
          style: GoogleFonts.roboto(
            fontSize: 15,
            color: hasValue ? sem.textHeading : sem.textMuted,
          ),
        ),
      ),
    );
  }
}

// ── Temperature Picker ────────────────────────────────────────────────────────

class _TemperaturePicker extends StatefulWidget {
  const _TemperaturePicker();

  @override
  State<_TemperaturePicker> createState() => _TemperaturePickerState();
}

class _TemperaturePickerState extends State<_TemperaturePicker> {
  int _whole = 28; // index into _wholes → value 8
  int _tenth = 0;

  static final List<String> _wholes =
      List.generate(61, (i) => (i - 20).toString());
  static final List<String> _tenths =
      List.generate(10, (i) => i.toString());

  int get _wholeValue => _whole - 20;

  @override
  Widget build(BuildContext context) {
    final sem = Theme.of(context).transflo;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Temperature',
            style: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: sem.textHeading)),
        const SizedBox(height: 8),
        SizedBox(
          height: 220,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Integer column
              SizedBox(
                width: 100,
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                      initialItem: _whole),
                  itemExtent: 44,
                  selectionOverlay:
                      const CupertinoPickerDefaultSelectionOverlay(
                    background: Colors.transparent,
                  ),
                  onSelectedItemChanged: (i) =>
                      setState(() => _whole = i),
                  children: _wholes
                      .map((v) => Center(
                            child: Text(v,
                                style: GoogleFonts.roboto(
                                    fontSize: 20,
                                    color: sem.textHeading)),
                          ))
                      .toList(),
                ),
              ),
              Text('.',
                  style: GoogleFonts.roboto(
                      fontSize: 28,
                      fontWeight: FontWeight.w300,
                      color: sem.textHeading)),
              // Decimal column
              SizedBox(
                width: 80,
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                      initialItem: _tenth),
                  itemExtent: 44,
                  selectionOverlay:
                      const CupertinoPickerDefaultSelectionOverlay(
                    background: Colors.transparent,
                  ),
                  onSelectedItemChanged: (i) =>
                      setState(() => _tenth = i),
                  children: _tenths
                      .map((v) => Center(
                            child: Text('$v°',
                                style: GoogleFonts.roboto(
                                    fontSize: 20,
                                    color: sem.textHeading)),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
        // Selection highlight line
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          height: 1,
          color: isDark
              ? const Color(0xFF2E3441)
              : const Color(0xFFE2E6EB),
        ),
        const SizedBox(height: 12),
        Text(
          '$_wholeValue.$_tenth°',
          style: GoogleFonts.roboto(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: _blue,
          ),
        ),
      ],
    );
  }
}

// ── Checks & Radio ────────────────────────────────────────────────────────────

enum _SelectMode { checkbox, radio }

class _ChecksRadioList extends StatefulWidget {
  const _ChecksRadioList(
      {required this.mode, required this.options});
  final _SelectMode mode;
  final List<String> options;

  @override
  State<_ChecksRadioList> createState() => _ChecksRadioListState();
}

class _ChecksRadioListState extends State<_ChecksRadioList> {
  final Set<String> _checked = {};
  String? _radio;

  @override
  Widget build(BuildContext context) {
    final sem = Theme.of(context).transflo;

    return Container(
      decoration: BoxDecoration(
        color: sem.rootSurfaceCard,
        border: Border.all(color: sem.rootSurfaceBorder),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: widget.options.map((opt) {
          if (widget.mode == _SelectMode.checkbox) {
            return CheckboxListTile(
              value: _checked.contains(opt),
              onChanged: (v) => setState(() => v == true
                  ? _checked.add(opt)
                  : _checked.remove(opt)),
              title: Text(opt,
                  style: GoogleFonts.roboto(
                      fontSize: 15, color: sem.textHeading)),
              activeColor: _blue,
              checkColor: Colors.white,
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 8),
            );
          } else {
            return RadioListTile<String>(
              value: opt,
              groupValue: _radio,
              onChanged: (v) => setState(() => _radio = v),
              title: Text(opt,
                  style: GoogleFonts.roboto(
                      fontSize: 15, color: sem.textHeading)),
              activeColor: _blue,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 8),
            );
          }
        }).toList(),
      ),
    );
  }
}

// ── Slider ────────────────────────────────────────────────────────────────────

class _DetentionSlider extends StatefulWidget {
  const _DetentionSlider({required this.sem});
  final TransfloSemanticColors sem;

  @override
  State<_DetentionSlider> createState() => _DetentionSliderState();
}

class _DetentionSliderState extends State<_DetentionSlider> {
  double _value = 0;

  @override
  Widget build(BuildContext context) {
    final sem = widget.sem;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'How many minutes did you wait for detention?',
          style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: sem.textHeading),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${_value.round()}',
              style: GoogleFonts.roboto(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: _blue),
            ),
            Text(' min',
                style: GoogleFonts.roboto(
                    fontSize: 16, color: sem.textMuted)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: _blue,
            inactiveTrackColor: sem.rootSurfaceBorder,
            thumbColor: _blue,
            overlayColor: const Color(0xFF2474BB1F),
            valueIndicatorColor: _blue,
            trackHeight: 4,
          ),
          child: Slider(
            value: _value,
            min: 0,
            max: 120,
            divisions: 120,
            label: '${_value.round()} min',
            onChanged: (v) => setState(() => _value = v),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0 min',
                style: GoogleFonts.roboto(
                    fontSize: 12, color: sem.textMuted)),
            Text('120 min',
                style: GoogleFonts.roboto(
                    fontSize: 12, color: sem.textMuted)),
          ],
        ),
      ],
    );
  }
}

// ── Toggle ────────────────────────────────────────────────────────────────────

class _ToggleList extends StatefulWidget {
  const _ToggleList({required this.sem});
  final TransfloSemanticColors sem;

  @override
  State<_ToggleList> createState() => _ToggleListState();
}

class _ToggleListState extends State<_ToggleList> {
  bool _refrigerated = false;
  bool _hazmat = false;
  bool _team = false;

  @override
  Widget build(BuildContext context) {
    final sem = widget.sem;

    Widget tile(String label, bool val, ValueChanged<bool> onChange) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: sem.rootSurfaceCard,
          border: Border.all(color: sem.rootSurfaceBorder),
          borderRadius: BorderRadius.circular(6),
        ),
        child: SwitchListTile(
          value: val,
          onChanged: onChange,
          title: Text(label,
              style: GoogleFonts.roboto(
                  fontSize: 15, color: sem.textHeading)),
          activeColor: _blue,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14),
        ),
      );
    }

    return Column(
      children: [
        tile('Refrigerated Load', _refrigerated,
            (v) => setState(() => _refrigerated = v)),
        tile('Hazardous Materials', _hazmat,
            (v) => setState(() => _hazmat = v)),
        tile('Team Driver', _team,
            (v) => setState(() => _team = v)),
      ],
    );
  }
}
