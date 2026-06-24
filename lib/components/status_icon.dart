import 'package:flutter/material.dart';

enum StatusIconState {
  notDone,
  active,
  done,
  skipped,
  locked,
  warning,
}

/// Circular workflow-step status indicator.
///
/// Matches the six states from the Loads Refactor design (node 5521-161344).
/// Reads [Theme.of(context).brightness] for automatic light/dark switching.
class StatusIcon extends StatelessWidget {
  const StatusIcon({
    super.key,
    required this.state,
    this.size = 21,
  });

  final StatusIconState state;

  /// Diameter in logical pixels. Defaults to 21 (the Figma spec size).
  final double size;

  // ── Design tokens ─────────────────────────────────────────────────────────
  static const _blue = Color(0xFF2474BB);
  static const _grey75 = Color(0xFFA9B3C2);
  static const _orange = Color(0xFFFFA300);
  static const _orangeLight = Color(0xFFFFE8BF);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(width: size, height: size, child: _build(isDark));
  }

  Widget _build(bool isDark) {
    switch (state) {
      case StatusIconState.notDone:
        return _ring(
          fill: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          border: Border.all(
            color: isDark ? const Color(0xFF444444) : _grey75,
            width: 1.5,
          ),
        );

      case StatusIconState.active:
        return _ring(
          fill: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          border: Border.all(color: _blue, width: 2),
          child: _dot(_blue),
        );

      case StatusIconState.done:
        return _ring(
          fill: _blue,
          child: Icon(Icons.check, color: Colors.white, size: size * 0.55),
        );

      case StatusIconState.skipped:
        return _ring(
          fill: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          border: Border.all(
            color: isDark ? const Color(0xFF444444) : _grey75,
            width: 1.5,
          ),
          child: _dot(isDark ? const Color(0xFF555555) : _grey75),
        );

      case StatusIconState.locked:
        return _ring(
          fill: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          border: Border.all(
            color: isDark ? const Color(0xFF444444) : _grey75,
            width: 1.5,
          ),
          child: Icon(
            Icons.lock,
            color: isDark ? const Color(0xFF888888) : _grey75,
            size: size * 0.52,
          ),
        );

      case StatusIconState.warning:
        return _ring(
          fill: isDark ? const Color(0xFF3D2800) : _orangeLight,
          child: Icon(
            Icons.warning_rounded,
            color: _orange,
            size: size * 0.65,
          ),
        );
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _ring({required Color fill, Border? border, Widget? child}) {
    return Container(
      decoration: BoxDecoration(
        color: fill,
        border: border,
        shape: BoxShape.circle,
      ),
      child: child != null ? Center(child: child) : null,
    );
  }

  Widget _dot(Color color) {
    return Center(
      child: SizedBox(
        width: size * 0.43,
        height: size * 0.43,
        child: Container(
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
