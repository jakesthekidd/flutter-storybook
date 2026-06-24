import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'status_icon.dart';

class _P {
  const _P(this.isDark);
  final bool isDark;
  Color get surface0 => isDark ? Colors.black : Colors.white;
  Color get surface100 => isDark ? const Color(0xFF0E1116) : const Color(0xFFF7F8F9);
  Color get surface200 => isDark ? const Color(0xFF181C24) : const Color(0xFFF3F5F7);
  Color get surface300 => isDark ? const Color(0xFF232833) : const Color(0xFFEFF2F4);
  Color get surface600 => isDark ? const Color(0xFF535B6D) : const Color(0xFFA9B3C2);
  Color get surface900 => isDark ? const Color(0xFFADB5C2) : const Color(0xFF5A626F);
  Color get textMain => isDark ? const Color(0xFFE6E8EE) : const Color(0xFF3D3D3D);
  Color get textMid => isDark ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.5);
  Color get textDark => isDark ? Colors.white : Colors.black;
  Color get surfaceBorder => isDark ? const Color(0xFF2E3441) : const Color(0xFFE2E6EB);
  Color get cyan100 => isDark ? const Color(0xFF2E5262) : const Color(0xFFE3F5FD);
  Color get cyan300 => isDark ? const Color(0xFF447B92) : const Color(0xFFAAE1F8);
  Color get blue600 => isDark ? const Color(0xFF5090C9) : const Color(0xFF2068A8);
  Color get blueText => const Color(0xFFD3E3F1);
}

// ── WorkflowSegmentPanel ──────────────────────────────────────────────────────

class WorkflowSegmentPanel extends StatefulWidget {
  const WorkflowSegmentPanel({
    super.key,
    required this.title,
    this.status = StatusIconState.notDone,
    this.initialExpanded = false,
    this.children = const [],
    this.onNextTap,
  });

  final String title;
  final StatusIconState status;
  final bool initialExpanded;
  final List<Widget> children;
  final VoidCallback? onNextTap;

  @override
  State<WorkflowSegmentPanel> createState() => _WorkflowSegmentPanelState();
}

class _WorkflowSegmentPanelState extends State<WorkflowSegmentPanel> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initialExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final p = _P(isDark);
    final isLocked = widget.status == StatusIconState.locked;

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SegmentHeader(
            title: widget.title,
            status: widget.status,
            expanded: _expanded,
            p: p,
            onTap: () => setState(() => _expanded = !_expanded),
          ),
          if (_expanded) _buildBody(p, isLocked),
        ],
      ),
    );
  }

  Widget _buildBody(_P p, bool isLocked) {
    Widget body = Container(
      color: p.surface200,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...widget.children.expand(
            (child) => [child, const SizedBox(height: 24)],
          ),
          SizedBox(
            height: 44,
            child: FilledButton(
              onPressed: isLocked ? null : widget.onNextTap,
              style: FilledButton.styleFrom(
                backgroundColor: p.blue600,
                foregroundColor: p.blueText,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Text(
                'Next',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (isLocked) {
      body = IgnorePointer(child: Opacity(opacity: 0.45, child: body));
    }
    return body;
  }
}

class _SegmentHeader extends StatelessWidget {
  const _SegmentHeader({
    required this.title,
    required this.status,
    required this.expanded,
    required this.p,
    required this.onTap,
  });

  final String title;
  final StatusIconState status;
  final bool expanded;
  final _P p;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: p.surface0,
      border: Border(top: BorderSide(color: p.surfaceBorder)),
      borderRadius: expanded
          ? const BorderRadius.vertical(bottom: Radius.circular(8))
          : null,
      boxShadow: expanded
          ? [
              BoxShadow(
                color: const Color(0xFF091A28).withValues(alpha: 0.15),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ]
          : null,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: decoration,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            StatusIcon(state: status, size: 21),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title.toUpperCase(),
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: p.textDark,
                ),
              ),
            ),
            Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                color: expanded ? p.cyan100 : p.surface100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                expanded ? Icons.expand_more : Icons.chevron_right,
                size: 12,
                color: p.textMain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── WorkflowStepPanel ─────────────────────────────────────────────────────────

class WorkflowStepPanel extends StatefulWidget {
  const WorkflowStepPanel({
    super.key,
    required this.title,
    this.status = StatusIconState.notDone,
    this.optional = false,
    this.initialExpanded = false,
    this.children = const [],
    this.onSubmitTap,
  });

  final String title;
  final StatusIconState status;
  final bool optional;
  final bool initialExpanded;
  final List<Widget> children;
  final VoidCallback? onSubmitTap;

  @override
  State<WorkflowStepPanel> createState() => _WorkflowStepPanelState();
}

class _WorkflowStepPanelState extends State<WorkflowStepPanel> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initialExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final p = _P(isDark);
    final isLocked = widget.status == StatusIconState.locked;
    final isActive = widget.status == StatusIconState.active;

    final border = (_expanded && isActive)
        ? Border.all(color: p.cyan300)
        : Border.all(color: p.surface100);

    final boxShadow = (_expanded && isActive)
        ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(1, 1),
            ),
          ]
        : null;

    return Container(
      decoration: BoxDecoration(
        color: p.surface0,
        borderRadius: BorderRadius.circular(7),
        border: border,
        boxShadow: boxShadow,
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(p, isLocked),
          if (_expanded) _buildBody(p, isLocked),
        ],
      ),
    );
  }

  Widget _buildHeader(_P p, bool isLocked) {
    return GestureDetector(
      onTap: isLocked ? null : () => setState(() => _expanded = !_expanded),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            StatusIcon(state: widget.status, size: 21),
            const SizedBox(width: 10),
            Text(
              widget.title.toUpperCase(),
              style: GoogleFonts.roboto(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: p.textMid,
              ),
            ),
            const Spacer(),
            if (widget.optional) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: p.surface300,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Text(
                  'OPTIONAL',
                  style: GoogleFonts.roboto(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: p.surface900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Icon(
              _expanded ? Icons.expand_more : Icons.chevron_right,
              size: 16,
              color: p.textMid,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(_P p, bool isLocked) {
    Widget body = Container(
      color: p.surface100,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...widget.children.expand(
            (child) => [child, const SizedBox(height: 16)],
          ),
          SizedBox(
            height: 44,
            child: OutlinedButton(
              onPressed: isLocked ? null : widget.onSubmitTap,
              style: OutlinedButton.styleFrom(
                backgroundColor: p.cyan100,
                side: const BorderSide(color: Color(0xFFB8E6F9)),
                foregroundColor: p.isDark
                    ? const Color(0xFF94BBDE)
                    : const Color(0xFF12395C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Text(
                'Submit',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (isLocked) {
      body = IgnorePointer(child: Opacity(opacity: 0.45, child: body));
    }
    return body;
  }
}
