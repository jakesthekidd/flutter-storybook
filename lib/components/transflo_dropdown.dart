import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum TransfloDropdownInputState { resting, active, error, disabled }

class TransfloDropdown extends StatefulWidget {
  const TransfloDropdown({
    super.key,
    this.label,
    this.placeholder = 'Select an option',
    this.options = const [],
    this.multiSelect = false,
    this.inputState = TransfloDropdownInputState.resting,
    this.initialOpen = false,
    this.errorText,
  });

  final String? label;
  final String placeholder;
  final List<String> options;
  final bool multiSelect;
  final TransfloDropdownInputState inputState;
  final bool initialOpen;
  final String? errorText;

  @override
  State<TransfloDropdown> createState() => _TransfloDropdownState();
}

class _TransfloDropdownState extends State<TransfloDropdown> {
  bool _open = false;
  final Set<int> _selected = {};

  @override
  void initState() {
    super.initState();
    _open = widget.initialOpen;
  }

  bool get _disabled => widget.inputState == TransfloDropdownInputState.disabled;
  bool get _isError => widget.inputState == TransfloDropdownInputState.error;
  bool get _isActive =>
      _open || widget.inputState == TransfloDropdownInputState.active;

  String get _displayText {
    if (_selected.isEmpty) return '';
    if (widget.multiSelect) {
      return _selected.map((i) => widget.options[i]).join(', ');
    }
    return widget.options[_selected.first];
  }

  Color _borderColor(bool isDark) {
    if (_isError) return const Color(0xFFDE0016);
    if (_isActive) return const Color(0xFF2474BB);
    if (_disabled) {
      return isDark ? const Color(0xFF2E3441) : const Color(0xFFE2E6EB);
    }
    return isDark ? const Color(0xFF535B6D) : const Color(0xFFA9B3C2);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface0 = isDark ? const Color(0xFF0E1116) : Colors.white;
    final surfaceDisabled =
        isDark ? const Color(0xFF181C24) : const Color(0xFFF3F5F7);
    final textMain =
        isDark ? const Color(0xFFE6E8EE) : const Color(0xFF3D3D3D);
    final textMuted =
        isDark ? const Color(0xFF535B6D) : const Color(0xFFA9B3C2);
    final borderColor = _borderColor(isDark);
    final borderWidth = _isActive || _isError ? 2.0 : 1.5;
    final chevronColor = _isActive ? const Color(0xFF2474BB) : textMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 4),
            child: Text(
              widget.label!,
              style: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _isError ? const Color(0xFFDE0016) : textMain,
              ),
            ),
          ),
        GestureDetector(
          onTap: _disabled ? null : () => setState(() => _open = !_open),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: _disabled ? surfaceDisabled : surface0,
              border: Border.all(color: borderColor, width: borderWidth),
              borderRadius: _open
                  ? const BorderRadius.vertical(top: Radius.circular(4))
                  : BorderRadius.circular(4),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selected.isEmpty ? widget.placeholder : _displayText,
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: _selected.isEmpty ? textMuted : textMain,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                AnimatedRotation(
                  turns: _open ? 0.25 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(Icons.chevron_right,
                      color: chevronColor, size: 20),
                ),
              ],
            ),
          ),
        ),
        ClipRect(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _open
                ? Container(
                    decoration: BoxDecoration(
                      color: surface0,
                      border: Border(
                        left: BorderSide(color: borderColor, width: borderWidth),
                        right:
                            BorderSide(color: borderColor, width: borderWidth),
                        bottom:
                            BorderSide(color: borderColor, width: borderWidth),
                        top: const BorderSide(
                            color: Color(0xFF72CDF4), width: 2),
                      ),
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(4)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: widget.options.asMap().entries.map((entry) {
                        final i = entry.key;
                        final opt = entry.value;
                        final isSelected = _selected.contains(i);
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => setState(() {
                              if (widget.multiSelect) {
                                if (isSelected) {
                                  _selected.remove(i);
                                } else {
                                  _selected.add(i);
                                }
                              } else {
                                _selected
                                  ..clear()
                                  ..add(i);
                                _open = false;
                              }
                            }),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 14),
                              child: Row(
                                children: [
                                  _SelectionIndicator(
                                    isSelected: isSelected,
                                    multiSelect: widget.multiSelect,
                                    isDark: isDark,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      opt,
                                      style: GoogleFonts.roboto(
                                        fontSize: 16,
                                        color: isSelected
                                            ? const Color(0xFF2474BB)
                                            : textMain,
                                        fontWeight: isSelected
                                            ? FontWeight.w500
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  )
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ),
        if (_isError && widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 2, top: 4),
            child: Text(
              widget.errorText!,
              style: GoogleFonts.roboto(
                  fontSize: 12, color: const Color(0xFFDE0016)),
            ),
          ),
      ],
    );
  }
}

class _SelectionIndicator extends StatelessWidget {
  const _SelectionIndicator({
    required this.isSelected,
    required this.multiSelect,
    required this.isDark,
  });
  final bool isSelected;
  final bool multiSelect;
  final bool isDark;

  static const _blue = Color(0xFF2474BB);
  Color get _idleColor =>
      isDark ? const Color(0xFF535B6D) : const Color(0xFFA9B3C2);

  @override
  Widget build(BuildContext context) {
    if (multiSelect) {
      return Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: isSelected ? _blue : Colors.transparent,
          border: Border.all(
              color: isSelected ? _blue : _idleColor, width: 2),
          borderRadius: BorderRadius.circular(3),
        ),
        child: isSelected
            ? const Icon(Icons.check, color: Colors.white, size: 12)
            : null,
      );
    }
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
            color: isSelected ? _blue : _idleColor, width: 2),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                    color: _blue, shape: BoxShape.circle),
              ),
            )
          : null,
    );
  }
}
