import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../tokens/semantic_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Shared field wrapper: label + helper/error + child
// ─────────────────────────────────────────────────────────────────────────────
class TransfloFieldShell extends StatelessWidget {
  const TransfloFieldShell({
    super.key,
    this.label,
    this.helper,
    this.error,
    required this.child,
  });

  final String? label;
  final String? helper;
  final String? error;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final sem = Theme.of(context).transflo;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: GoogleFonts.roboto(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: sem.textMuted,
            ),
          ),
          const SizedBox(height: 6),
        ],
        child,
        if (error != null || helper != null) ...[
          const SizedBox(height: 6),
          Text(
            error ?? helper!,
            style: GoogleFonts.roboto(
              fontSize: 12,
              color: error != null ? sem.statusError : sem.textMuted,
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. Search Field
// ─────────────────────────────────────────────────────────────────────────────
class TransfloSearchField extends StatefulWidget {
  const TransfloSearchField({
    super.key,
    this.hint = 'Search',
    this.onChanged,
    this.onSubmitted,
  });

  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<TransfloSearchField> createState() => _TransfloSearchFieldState();
}

class _TransfloSearchFieldState extends State<TransfloSearchField> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sem = Theme.of(context).transflo;
    return TextField(
      controller: _ctrl,
      onChanged: (v) {
        setState(() {});
        widget.onChanged?.call(v);
      },
      onSubmitted: widget.onSubmitted,
      style: GoogleFonts.roboto(fontSize: 16, color: sem.textHeading),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: GoogleFonts.roboto(fontSize: 16, color: sem.textMuted),
        prefixIcon: Icon(Icons.search, color: sem.textMuted),
        suffixIcon: _ctrl.text.isEmpty
            ? null
            : IconButton(
                icon: Icon(Icons.close, color: sem.textMuted, size: 20),
                onPressed: () {
                  _ctrl.clear();
                  setState(() {});
                  widget.onChanged?.call('');
                },
              ),
        filled: true,
        fillColor: sem.rootSurfaceCard,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: sem.rootSurfaceBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: sem.brandPrimary, width: 2),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. Numeric Stepper (+/-)
// ─────────────────────────────────────────────────────────────────────────────
class TransfloNumericStepper extends StatefulWidget {
  const TransfloNumericStepper({
    super.key,
    this.value = 0,
    this.min = 0,
    this.max = 99,
    this.step = 1,
    this.label,
    this.onChanged,
  });

  final int value;
  final int min;
  final int max;
  final int step;
  final String? label;
  final ValueChanged<int>? onChanged;

  @override
  State<TransfloNumericStepper> createState() => _TransfloNumericStepperState();
}

class _TransfloNumericStepperState extends State<TransfloNumericStepper> {
  late int _value = widget.value;

  void _update(int next) {
    final clamped = next.clamp(widget.min, widget.max);
    if (clamped == _value) return;
    setState(() => _value = clamped);
    widget.onChanged?.call(clamped);
  }

  @override
  Widget build(BuildContext context) {
    final sem = Theme.of(context).transflo;
    final canDec = _value > widget.min;
    final canInc = _value < widget.max;

    Widget btn(IconData icon, bool enabled, VoidCallback onTap) => Material(
          color: enabled ? sem.rootSurfaceCard : sem.rootSurfaceGround,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: sem.rootSurfaceBorder, width: 1.5),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: enabled ? onTap : null,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Icon(
                icon,
                color: enabled ? sem.brandPrimary : sem.statusDisabled,
              ),
            ),
          ),
        );

    return TransfloFieldShell(
      label: widget.label,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          btn(Icons.remove, canDec, () => _update(_value - widget.step)),
          Container(
            width: 64,
            height: 44,
            alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: sem.rootSurfaceCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: sem.rootSurfaceBorder, width: 1.5),
            ),
            child: Text(
              '$_value',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: sem.textHeading,
              ),
            ),
          ),
          btn(Icons.add, canInc, () => _update(_value + widget.step)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. Currency Field
// ─────────────────────────────────────────────────────────────────────────────
class _CurrencyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(text: '');
    }
    final cents = int.parse(digits);
    final dollars = cents ~/ 100;
    final remainder = cents % 100;
    final dollarsStr = dollars
        .toString()
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    final formatted = '$dollarsStr.${remainder.toString().padLeft(2, '0')}';
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class TransfloCurrencyField extends StatelessWidget {
  const TransfloCurrencyField({
    super.key,
    this.label,
    this.hint = '0.00',
    this.symbol = '\$',
    this.onChanged,
  });

  final String? label;
  final String hint;
  final String symbol;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final sem = Theme.of(context).transflo;
    return TransfloFieldShell(
      label: label,
      child: TextField(
        keyboardType: TextInputType.number,
        inputFormatters: [_CurrencyFormatter()],
        onChanged: onChanged,
        style: GoogleFonts.roboto(fontSize: 18, color: sem.textHeading),
        decoration: InputDecoration(
          prefixText: '$symbol ',
          prefixStyle: GoogleFonts.roboto(
              fontSize: 18,
              color: sem.textMuted,
              fontWeight: FontWeight.w500),
          hintText: hint,
          hintStyle: GoogleFonts.roboto(fontSize: 18, color: sem.textMuted),
          filled: true,
          fillColor: sem.rootSurfaceCard,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: sem.rootSurfaceBorder, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: sem.brandPrimary, width: 2),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. Phone Field
// ─────────────────────────────────────────────────────────────────────────────
class _PhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 10) digits = digits.substring(0, 10);
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 0) buf.write('(');
      if (i == 3) buf.write(') ');
      if (i == 6) buf.write('-');
      buf.write(digits[i]);
    }
    final out = buf.toString();
    return TextEditingValue(
      text: out,
      selection: TextSelection.collapsed(offset: out.length),
    );
  }
}

class TransfloPhoneField extends StatelessWidget {
  const TransfloPhoneField({super.key, this.label, this.onChanged});

  final String? label;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final sem = Theme.of(context).transflo;
    return TransfloFieldShell(
      label: label,
      child: TextField(
        keyboardType: TextInputType.phone,
        inputFormatters: [_PhoneFormatter()],
        onChanged: onChanged,
        style: GoogleFonts.roboto(fontSize: 16, color: sem.textHeading),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.phone_outlined, color: sem.textMuted),
          hintText: '(555) 123-4567',
          hintStyle: GoogleFonts.roboto(fontSize: 16, color: sem.textMuted),
          filled: true,
          fillColor: sem.rootSurfaceCard,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: sem.rootSurfaceBorder, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: sem.brandPrimary, width: 2),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. Multi-Select Chips
// ─────────────────────────────────────────────────────────────────────────────
class TransfloChipMultiSelect extends StatefulWidget {
  const TransfloChipMultiSelect({
    super.key,
    required this.options,
    this.initial = const [],
    this.label,
    this.onChanged,
  });

  final List<String> options;
  final List<String> initial;
  final String? label;
  final ValueChanged<List<String>>? onChanged;

  @override
  State<TransfloChipMultiSelect> createState() =>
      _TransfloChipMultiSelectState();
}

class _TransfloChipMultiSelectState extends State<TransfloChipMultiSelect> {
  late final Set<String> _selected = {...widget.initial};

  @override
  Widget build(BuildContext context) {
    final sem = Theme.of(context).transflo;
    return TransfloFieldShell(
      label: widget.label,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: widget.options.map((opt) {
          final on = _selected.contains(opt);
          return Material(
            color: on ? sem.brandPrimaryLight : sem.rootSurfaceCard,
            shape: StadiumBorder(
              side: BorderSide(
                color: on ? sem.brandPrimary : sem.rootSurfaceBorder,
                width: 1.5,
              ),
            ),
            child: InkWell(
              customBorder: const StadiumBorder(),
              onTap: () {
                setState(() {
                  if (on) {
                    _selected.remove(opt);
                  } else {
                    _selected.add(opt);
                  }
                });
                widget.onChanged?.call(_selected.toList());
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (on) ...[
                      Icon(Icons.check, size: 16, color: sem.brandPrimary),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      opt,
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        fontWeight:
                            on ? FontWeight.w600 : FontWeight.w500,
                        color: on ? sem.brandPrimary : sem.textBody,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 6. Segmented Control
// ─────────────────────────────────────────────────────────────────────────────
class TransfloSegmented extends StatefulWidget {
  const TransfloSegmented({
    super.key,
    required this.options,
    this.initialIndex = 0,
    this.label,
    this.onChanged,
  });

  final List<String> options;
  final int initialIndex;
  final String? label;
  final ValueChanged<int>? onChanged;

  @override
  State<TransfloSegmented> createState() => _TransfloSegmentedState();
}

class _TransfloSegmentedState extends State<TransfloSegmented> {
  late int _index = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    final sem = Theme.of(context).transflo;
    return TransfloFieldShell(
      label: widget.label,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: sem.rootSurfaceGround,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: sem.rootSurfaceBorder),
        ),
        child: Row(
          children: List.generate(widget.options.length, (i) {
            final on = i == _index;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _index = i);
                  widget.onChanged?.call(i);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: on ? sem.rootSurfaceCard : Colors.transparent,
                    borderRadius: BorderRadius.circular(7),
                    boxShadow: on
                        ? [
                            BoxShadow(
                              color: sem.overlayMain.withValues(alpha: 0.08),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    widget.options[i],
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: on ? FontWeight.w600 : FontWeight.w500,
                      color: on ? sem.brandPrimary : sem.textMuted,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 7. Photo Upload Grid
// ─────────────────────────────────────────────────────────────────────────────
class TransfloPhotoUpload extends StatefulWidget {
  const TransfloPhotoUpload({
    super.key,
    this.label,
    this.maxPhotos = 6,
  });

  final String? label;
  final int maxPhotos;

  @override
  State<TransfloPhotoUpload> createState() => _TransfloPhotoUploadState();
}

class _TransfloPhotoUploadState extends State<TransfloPhotoUpload> {
  final List<Color> _photos = [];

  void _addPhoto() {
    if (_photos.length >= widget.maxPhotos) return;
    final palette = [
      const Color(0xFF93C5FD),
      const Color(0xFFFCA5A5),
      const Color(0xFF86EFAC),
      const Color(0xFFFCD34D),
      const Color(0xFFC4B5FD),
      const Color(0xFF67E8F9),
    ];
    setState(() => _photos.add(palette[_photos.length % palette.length]));
  }

  @override
  Widget build(BuildContext context) {
    final sem = Theme.of(context).transflo;
    return TransfloFieldShell(
      label: widget.label,
      helper: '${_photos.length}/${widget.maxPhotos} attached',
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          ..._photos.asMap().entries.map((e) => Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: e.value,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: sem.rootSurfaceBorder),
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.image,
                        color: sem.textWhite.withValues(alpha: 0.8), size: 28),
                  ),
                  Positioned(
                    top: -6,
                    right: -6,
                    child: Material(
                      color: sem.statusError,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () =>
                            setState(() => _photos.removeAt(e.key)),
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: Icon(Icons.close,
                              size: 14, color: sem.statusErrorOn),
                        ),
                      ),
                    ),
                  ),
                ],
              )),
          if (_photos.length < widget.maxPhotos)
            Material(
              color: sem.brandPrimaryLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: sem.brandPrimary,
                  width: 1.5,
                  style: BorderStyle.solid,
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: _addPhoto,
                child: SizedBox(
                  width: 76,
                  height: 76,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_outlined,
                          color: sem.brandPrimary, size: 24),
                      const SizedBox(height: 4),
                      Text('Add',
                          style: GoogleFonts.roboto(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: sem.brandPrimary)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 8. Signature Pad
// ─────────────────────────────────────────────────────────────────────────────
class TransfloSignaturePad extends StatefulWidget {
  const TransfloSignaturePad({
    super.key,
    this.label,
    this.height = 180,
  });

  final String? label;
  final double height;

  @override
  State<TransfloSignaturePad> createState() => _TransfloSignaturePadState();
}

class _TransfloSignaturePadState extends State<TransfloSignaturePad> {
  final List<List<Offset>> _strokes = [];

  @override
  Widget build(BuildContext context) {
    final sem = Theme.of(context).transflo;
    final empty = _strokes.isEmpty;
    return TransfloFieldShell(
      label: widget.label,
      helper: empty ? 'Sign above' : null,
      child: Stack(
        children: [
          Container(
            height: widget.height,
            decoration: BoxDecoration(
              color: sem.rootSurfaceCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: sem.rootSurfaceBorder, width: 1.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: GestureDetector(
                onPanStart: (d) =>
                    setState(() => _strokes.add([d.localPosition])),
                onPanUpdate: (d) {
                  if (_strokes.isEmpty) return;
                  setState(() => _strokes.last.add(d.localPosition));
                },
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _SignaturePainter(_strokes, sem.textHeading),
                  child: empty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.draw_outlined,
                                  color: sem.textMuted, size: 28),
                              const SizedBox(height: 6),
                              Text('Sign here',
                                  style: GoogleFonts.roboto(
                                      fontSize: 13,
                                      color: sem.textMuted)),
                            ],
                          ),
                        )
                      : const SizedBox.expand(),
                ),
              ),
            ),
          ),
          if (!empty)
            Positioned(
              top: 8,
              right: 8,
              child: Material(
                color: sem.rootSurfaceCard,
                shape: StadiumBorder(
                  side: BorderSide(color: sem.rootSurfaceBorder),
                ),
                child: InkWell(
                  customBorder: const StadiumBorder(),
                  onTap: () => setState(() => _strokes.clear()),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh, size: 16, color: sem.textBody),
                        const SizedBox(width: 4),
                        Text('Clear',
                            style: GoogleFonts.roboto(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: sem.textBody)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  _SignaturePainter(this.strokes, this.color);
  final List<List<Offset>> strokes;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final s in strokes) {
      for (var i = 0; i < s.length - 1; i++) {
        canvas.drawLine(s[i], s[i + 1], paint);
      }
      if (s.length == 1) {
        canvas.drawCircle(s.first, 1.25, paint..style = PaintingStyle.fill);
        paint.style = PaintingStyle.stroke;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter old) =>
      old.strokes != strokes || old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// 9. OTP Input
// ─────────────────────────────────────────────────────────────────────────────
class TransfloOtpInput extends StatefulWidget {
  const TransfloOtpInput({
    super.key,
    this.length = 6,
    this.label,
    this.onCompleted,
  });

  final int length;
  final String? label;
  final ValueChanged<String>? onCompleted;

  @override
  State<TransfloOtpInput> createState() => _TransfloOtpInputState();
}

class _TransfloOtpInputState extends State<TransfloOtpInput> {
  late final List<TextEditingController> _ctrls =
      List.generate(widget.length, (_) => TextEditingController());
  late final List<FocusNode> _nodes =
      List.generate(widget.length, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _handle(int i, String v) {
    if (v.length > 1) {
      // paste
      final chars = v.replaceAll(RegExp(r'[^0-9]'), '').split('');
      for (var k = 0; k < widget.length; k++) {
        _ctrls[k].text = k < chars.length ? chars[k] : '';
      }
      FocusScope.of(context).requestFocus(
          _nodes[math.min(chars.length, widget.length - 1)]);
    } else if (v.isNotEmpty && i < widget.length - 1) {
      _nodes[i + 1].requestFocus();
    } else if (v.isEmpty && i > 0) {
      _nodes[i - 1].requestFocus();
    }
    setState(() {});
    final all = _ctrls.map((c) => c.text).join();
    if (all.length == widget.length) widget.onCompleted?.call(all);
  }

  @override
  Widget build(BuildContext context) {
    final sem = Theme.of(context).transflo;
    return TransfloFieldShell(
      label: widget.label,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(widget.length, (i) {
          final filled = _ctrls[i].text.isNotEmpty;
          final focused = _nodes[i].hasFocus;
          return SizedBox(
            width: 44,
            height: 52,
            child: TextField(
              controller: _ctrls[i],
              focusNode: _nodes[i],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              style: GoogleFonts.roboto(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: sem.textHeading,
              ),
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor:
                    filled ? sem.brandPrimaryLight : sem.rootSurfaceCard,
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                      color: filled
                          ? sem.brandPrimary
                          : sem.rootSurfaceBorder,
                      width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      BorderSide(color: sem.brandPrimary, width: 2),
                ),
              ),
              onChanged: (v) => _handle(i, v),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              key: ValueKey('otp-$i-${focused ? 1 : 0}'),
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 10. Address Autocomplete
// ─────────────────────────────────────────────────────────────────────────────
class TransfloAddressField extends StatefulWidget {
  const TransfloAddressField({
    super.key,
    this.label,
    this.suggestions = const [
      '123 Main St, Tampa, FL 33602',
      '456 Bay Shore Blvd, Tampa, FL 33606',
      '789 Westshore Blvd, Tampa, FL 33607',
      '1010 Channelside Dr, Tampa, FL 33602',
      '2200 N Dale Mabry Hwy, Tampa, FL 33607',
    ],
    this.onSelected,
  });

  final String? label;
  final List<String> suggestions;
  final ValueChanged<String>? onSelected;

  @override
  State<TransfloAddressField> createState() => _TransfloAddressFieldState();
}

class _TransfloAddressFieldState extends State<TransfloAddressField> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _open = _focus.hasFocus));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  List<String> get _filtered {
    final q = _ctrl.text.trim().toLowerCase();
    if (q.isEmpty) return widget.suggestions;
    return widget.suggestions
        .where((s) => s.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final sem = Theme.of(context).transflo;
    return TransfloFieldShell(
      label: widget.label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _ctrl,
            focusNode: _focus,
            onChanged: (_) => setState(() {}),
            style: GoogleFonts.roboto(fontSize: 16, color: sem.textHeading),
            decoration: InputDecoration(
              hintText: 'Start typing an address',
              hintStyle:
                  GoogleFonts.roboto(fontSize: 16, color: sem.textMuted),
              prefixIcon: Icon(Icons.location_on_outlined,
                  color: sem.brandPrimary),
              filled: true,
              fillColor: sem.rootSurfaceCard,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    BorderSide(color: sem.rootSurfaceBorder, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: sem.brandPrimary, width: 2),
              ),
            ),
          ),
          if (_open && _filtered.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: sem.rootSurfaceOverlay,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: sem.rootSurfaceBorder),
                boxShadow: [
                  BoxShadow(
                    color: sem.overlayMain.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: _filtered.take(5).map((s) {
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        _ctrl.text = s;
                        _focus.unfocus();
                        widget.onSelected?.call(s);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        child: Row(
                          children: [
                            Icon(Icons.location_on,
                                size: 18, color: sem.textMuted),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                s,
                                style: GoogleFonts.roboto(
                                    fontSize: 14, color: sem.textBody),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 11. Range Slider
// ─────────────────────────────────────────────────────────────────────────────
class TransfloRangeSlider extends StatefulWidget {
  const TransfloRangeSlider({
    super.key,
    this.label,
    this.min = 0,
    this.max = 100,
    this.initial = const RangeValues(20, 80),
    this.unit = '',
    this.onChanged,
  });

  final String? label;
  final double min;
  final double max;
  final RangeValues initial;
  final String unit;
  final ValueChanged<RangeValues>? onChanged;

  @override
  State<TransfloRangeSlider> createState() => _TransfloRangeSliderState();
}

class _TransfloRangeSliderState extends State<TransfloRangeSlider> {
  late RangeValues _v = widget.initial;

  @override
  Widget build(BuildContext context) {
    final sem = Theme.of(context).transflo;
    String fmt(double n) =>
        '${n.round()}${widget.unit.isEmpty ? '' : widget.unit}';
    return TransfloFieldShell(
      label: widget.label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(fmt(_v.start),
                  style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: sem.brandPrimary)),
              Text(fmt(_v.end),
                  style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: sem.brandPrimary)),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: sem.brandPrimary,
              inactiveTrackColor: sem.rootSurfaceBorder,
              thumbColor: sem.brandPrimary,
              overlayColor: sem.brandPrimary.withValues(alpha: 0.15),
              valueIndicatorColor: sem.brandPrimary,
              trackHeight: 4,
            ),
            child: RangeSlider(
              min: widget.min,
              max: widget.max,
              values: _v,
              labels: RangeLabels(fmt(_v.start), fmt(_v.end)),
              onChanged: (n) {
                setState(() => _v = n);
                widget.onChanged?.call(n);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 12. Notes Field with character counter
// ─────────────────────────────────────────────────────────────────────────────
class TransfloNotesField extends StatefulWidget {
  const TransfloNotesField({
    super.key,
    this.label,
    this.hint = 'Add notes…',
    this.maxLength = 240,
    this.minLines = 4,
    this.onChanged,
  });

  final String? label;
  final String hint;
  final int maxLength;
  final int minLines;
  final ValueChanged<String>? onChanged;

  @override
  State<TransfloNotesField> createState() => _TransfloNotesFieldState();
}

class _TransfloNotesFieldState extends State<TransfloNotesField> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sem = Theme.of(context).transflo;
    final remaining = widget.maxLength - _ctrl.text.length;
    final low = remaining <= 20;
    return TransfloFieldShell(
      label: widget.label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextField(
            controller: _ctrl,
            minLines: widget.minLines,
            maxLines: widget.minLines + 4,
            maxLength: widget.maxLength,
            buildCounter: (_,
                    {required currentLength,
                    required isFocused,
                    maxLength}) =>
                null,
            onChanged: (v) {
              setState(() {});
              widget.onChanged?.call(v);
            },
            style: GoogleFonts.roboto(fontSize: 15, color: sem.textHeading),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle:
                  GoogleFonts.roboto(fontSize: 15, color: sem.textMuted),
              filled: true,
              fillColor: sem.rootSurfaceCard,
              contentPadding: const EdgeInsets.all(12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    BorderSide(color: sem.rootSurfaceBorder, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: sem.brandPrimary, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$remaining left',
            style: GoogleFonts.roboto(
              fontSize: 12,
              color: low ? sem.statusWarningDark : sem.textMuted,
              fontWeight: low ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
