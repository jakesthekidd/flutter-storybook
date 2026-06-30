import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../tokens/semantic_colors.dart';

enum ScanFieldState {
  empty,
  capturedSingle,
  capturedSplit,
  errorCapturedSingle,
  errorWrongType,
  errorParseMismatch,
}

class ScanSubField {
  const ScanSubField({
    required this.label,
    required this.value,
    this.locked = true,
    this.editable = false,
    this.error,
  });

  final String label;
  final String value;
  final bool locked;
  final bool editable;
  final String? error;
}

class TransfloScanField extends StatelessWidget {
  const TransfloScanField({
    super.key,
    this.label = 'Label Text',
    this.required = false,
    this.state = ScanFieldState.empty,
    this.value,
    this.rawScan,
    this.subfields = const [],
    this.errorText,
    this.withConfirm = false,
    this.confirmEnabled = true,
    this.onScan,
    this.onRescan,
    this.onConfirm,
    this.onSubfieldChanged,
  });

  final String label;
  final bool required;
  final ScanFieldState state;
  final String? value;
  final String? rawScan;
  final List<ScanSubField> subfields;
  final String? errorText;
  final bool withConfirm;
  final bool confirmEnabled;
  final VoidCallback? onScan;
  final VoidCallback? onRescan;
  final VoidCallback? onConfirm;
  final void Function(int index, String value)? onSubfieldChanged;

  bool get _isError =>
      state == ScanFieldState.errorWrongType ||
      state == ScanFieldState.errorParseMismatch ||
      state == ScanFieldState.errorCapturedSingle;

  @override
  Widget build(BuildContext context) {
    final sem = Theme.of(context).transflo;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LabelText(label: label, required: required),
        const SizedBox(height: 8),
        _body(context, sem),
        if (state == ScanFieldState.errorWrongType && errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: GoogleFonts.roboto(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: sem.statusErrorDark,
            ),
          ),
        ],
        if (withConfirm && _showSeparateConfirm) ...[
          const SizedBox(height: 8),
          _ConfirmButton(
            enabled: confirmEnabled && !_isError,
            onTap: onConfirm,
          ),
        ],
      ],
    );
  }

  bool get _showSeparateConfirm {
    // Split states host Confirm inside the card; row states render it below.
    return state == ScanFieldState.capturedSingle ||
        state == ScanFieldState.errorCapturedSingle ||
        state == ScanFieldState.errorWrongType;
  }

  Widget _body(BuildContext context, TransfloSemanticColors sem) {
    switch (state) {
      case ScanFieldState.empty:
      case ScanFieldState.errorWrongType:
        return _ScanTrigger(onTap: onScan);
      case ScanFieldState.capturedSingle:
        return _CapturedSingleRow(value: value ?? '', onRescan: onRescan);
      case ScanFieldState.errorCapturedSingle:
        return _CapturedErrorRow(
          message: errorText ?? '{error message}',
          onRescan: onRescan,
        );
      case ScanFieldState.capturedSplit:
      case ScanFieldState.errorParseMismatch:
        return _SplitCard(
          rawScan: rawScan ?? '',
          subfields: subfields,
          isError: state == ScanFieldState.errorParseMismatch,
          withConfirm: withConfirm,
          confirmEnabled: confirmEnabled,
          onRescan: onRescan,
          onConfirm: onConfirm,
          onSubfieldChanged: onSubfieldChanged,
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Subcomponents
// ─────────────────────────────────────────────────────────────────────────────

class _LabelText extends StatelessWidget {
  const _LabelText({required this.label, required this.required});
  final String label;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final sem = Theme.of(context).transflo;
    return RichText(
      text: TextSpan(
        text: label,
        style: GoogleFonts.roboto(
          fontSize: 14,
          color: sem.textHeading,
        ),
        children: required
            ? [
                TextSpan(
                  text: ' *',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: sem.statusError,
                  ),
                ),
              ]
            : null,
      ),
    );
  }
}

class _ScanTrigger extends StatelessWidget {
  const _ScanTrigger({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final sem = Theme.of(context).transflo;
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: sem.brandSecondaryLight,
          foregroundColor: sem.brandPrimaryDark,
          disabledBackgroundColor: sem.rootSurfaceGround,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: BorderSide(color: sem.brandSecondaryHighlight, width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.barcode,
              size: 14,
              color: sem.brandPrimaryDark,
            ),
            const SizedBox(width: 8),
            Text(
              'Scan Barcode',
              style: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: sem.brandPrimaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CapturedSingleRow extends StatelessWidget {
  const _CapturedSingleRow({required this.value, this.onRescan});
  final String value;
  final VoidCallback? onRescan;

  @override
  Widget build(BuildContext context) {
    final sem = Theme.of(context).transflo;
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: sem.rootSurfaceCard,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: sem.rootSurfaceBorder, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: sem.statusSuccess),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: sem.textMain,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _RefreshIconButton(onTap: onRescan),
        ],
      ),
    );
  }
}

class _CapturedErrorRow extends StatelessWidget {
  const _CapturedErrorRow({required this.message, this.onRescan});
  final String message;
  final VoidCallback? onRescan;

  @override
  Widget build(BuildContext context) {
    final sem = Theme.of(context).transflo;
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: sem.rootSurfaceCard,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: sem.statusError, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.error, size: 16, color: sem.statusError),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: sem.textMain,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _RefreshIconButton(onTap: onRescan),
        ],
      ),
    );
  }
}

class _RefreshIconButton extends StatelessWidget {
  const _RefreshIconButton({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final sem = Theme.of(context).transflo;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(Icons.refresh, size: 18, color: sem.textMuted),
        ),
      ),
    );
  }
}

class _SplitCard extends StatelessWidget {
  const _SplitCard({
    required this.rawScan,
    required this.subfields,
    required this.isError,
    required this.withConfirm,
    required this.confirmEnabled,
    this.onRescan,
    this.onConfirm,
    this.onSubfieldChanged,
  });

  final String rawScan;
  final List<ScanSubField> subfields;
  final bool isError;
  final bool withConfirm;
  final bool confirmEnabled;
  final VoidCallback? onRescan;
  final VoidCallback? onConfirm;
  final void Function(int index, String value)? onSubfieldChanged;

  @override
  Widget build(BuildContext context) {
    final sem = Theme.of(context).transflo;
    final accent = isError ? sem.statusError : sem.brandPrimaryHighlight;
    final outerBorder = isError ? sem.statusError : sem.brandPrimary;
    final headerBg = isError ? sem.statusErrorLight : sem.rootSurfaceGround;
    final headerText = isError ? sem.textHeading : sem.textMain;
    final softDivider = sem.rootSurfaceBorder;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: sem.rootSurfaceCard,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: outerBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                Container(width: 4, color: accent),
                Expanded(
                  child: Container(
                    color: headerBg,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'From Scan:',
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: headerText,
                          ),
                        ),
                        Text(
                          rawScan,
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: headerText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _RescanButton(onTap: onRescan),
                const SizedBox(height: 12),
                Divider(height: 1, thickness: 0.5, color: softDivider),
                for (var i = 0; i < subfields.length; i++) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: subfields[i].editable
                        ? _EditableSubField(
                            field: subfields[i],
                            onChanged: onSubfieldChanged == null
                                ? null
                                : (v) => onSubfieldChanged!(i, v),
                          )
                        : _LockedSubField(field: subfields[i]),
                  ),
                  if (i < subfields.length - 1)
                    Divider(height: 1, thickness: 0.5, color: softDivider),
                ],
                if (withConfirm) ...[
                  const SizedBox(height: 4),
                  Divider(height: 1, thickness: 0.5, color: softDivider),
                  const SizedBox(height: 12),
                  _ConfirmButton(
                    enabled: confirmEnabled && !isError,
                    onTap: onConfirm,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RescanButton extends StatelessWidget {
  const _RescanButton({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final sem = Theme.of(context).transflo;
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: sem.textMain,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        minimumSize: const Size(double.infinity, 36),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(FontAwesomeIcons.barcode, size: 14, color: sem.textMain),
          const SizedBox(width: 10),
          Text(
            'Rescan',
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: sem.textMain,
            ),
          ),
        ],
      ),
    );
  }
}

class _LockedSubField extends StatelessWidget {
  const _LockedSubField({required this.field});
  final ScanSubField field;

  @override
  Widget build(BuildContext context) {
    final sem = Theme.of(context).transflo;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                field.label,
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: sem.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                field.value,
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: sem.textMain,
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.lock_outline, size: 14, color: sem.textMuted),
      ],
    );
  }
}

class _EditableSubField extends StatefulWidget {
  const _EditableSubField({required this.field, this.onChanged});
  final ScanSubField field;
  final ValueChanged<String>? onChanged;

  @override
  State<_EditableSubField> createState() => _EditableSubFieldState();
}

class _EditableSubFieldState extends State<_EditableSubField> {
  late final TextEditingController _ctrl =
      TextEditingController(text: widget.field.value);
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sem = Theme.of(context).transflo;
    final hasError = widget.field.error != null;
    final focused = _focus.hasFocus;

    final Color borderColor;
    if (hasError) {
      borderColor = sem.statusErrorDark;
    } else if (focused) {
      borderColor = sem.brandPrimary;
    } else {
      borderColor = sem.brandTertiary;
    }
    final bg = hasError ? sem.statusErrorLight : sem.rootSurfaceCard;
    final textColor = hasError ? sem.textHeading : sem.textMain;
    final iconColor =
        hasError ? sem.statusErrorDark : sem.brandTertiaryHighlight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            widget.field.label,
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: sem.textMain,
            ),
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _ctrl,
          focusNode: _focus,
          onChanged: widget.onChanged,
          style: GoogleFonts.roboto(fontSize: 16, color: textColor),
          cursorColor: sem.brandPrimary,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: bg,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(Icons.edit, size: 14, color: iconColor),
            ),
            suffixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: borderColor, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: borderColor, width: 2),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              widget.field.error!,
              style: GoogleFonts.roboto(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: sem.statusErrorDark,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({required this.enabled, this.onTap});
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final sem = Theme.of(context).transflo;
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: FilledButton(
        onPressed: enabled ? onTap : null,
        style: FilledButton.styleFrom(
          backgroundColor: sem.brandSecondaryLight,
          foregroundColor: sem.brandPrimaryDark,
          disabledBackgroundColor: sem.rootSurfaceGround,
          disabledForegroundColor: sem.brandTertiary,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: enabled
                ? BorderSide(color: sem.brandSecondaryHighlight, width: 1)
                : BorderSide.none,
          ),
          textStyle: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        child: const Text('Confirm'),
      ),
    );
  }
}
