import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../tokens/colors.dart';
import '../tokens/semantic_colors.dart';

import 'certify_logs_controller.dart';

export 'certify_logs_state.dart';

/// A multi-state status banner that prompts drivers to certify HOS logs.
/// Designed to feel reactive — color, size, icon, and content flow between
/// states with implicit animations rather than discrete page swaps.
class CertifyLogsBanner extends StatefulWidget {
  const CertifyLogsBanner({
    super.key,
    required this.state,
    this.expanded = true,
    this.daysCount = 14,
    this.verifiedAt,
    this.onCertifyTap,
    this.onTryAgainTap,
    this.onSelfAttestTap,
    this.onExpandToggle,
  });

  /// Controlled variant — pulls `state`, `expanded`, and `verifiedAt` from a
  /// [CertifyLogsController] and wires the chevron tap to its toggle.
  /// Wrap in a [ListenableBuilder] so the banner rebuilds on controller updates.
  factory CertifyLogsBanner.controlled(
    CertifyLogsController controller, {
    Key? key,
    int daysCount = 14,
    VoidCallback? onCertifyTap,
    VoidCallback? onTryAgainTap,
    VoidCallback? onSelfAttestTap,
  }) {
    return CertifyLogsBanner(
      key: key,
      state: controller.state,
      expanded: controller.expanded,
      daysCount: daysCount,
      verifiedAt: controller.verifiedAt,
      onExpandToggle: controller.toggleExpanded,
      onCertifyTap: onCertifyTap,
      onTryAgainTap: onTryAgainTap,
      onSelfAttestTap: onSelfAttestTap,
    );
  }

  final CertifyLogsState state;
  final bool expanded;
  final int daysCount;
  final DateTime? verifiedAt;

  final VoidCallback? onCertifyTap;
  final VoidCallback? onTryAgainTap;
  final VoidCallback? onSelfAttestTap;
  final VoidCallback? onExpandToggle;

  @override
  State<CertifyLogsBanner> createState() => _CertifyLogsBannerState();
}

class _CertifyLogsBannerState extends State<CertifyLogsBanner>
    with TickerProviderStateMixin {
  // iOS Liquid Glass durations — quick enough to feel reactive,
  // long enough for the spring tail to read.
  static const _fast = Duration(milliseconds: 280);
  static const _medium = Duration(milliseconds: 360);
  static const _slow = Duration(milliseconds: 440);

  // Apple's classic spring curve — fast attack, soft tail, no overshoot.
  // Used for color, opacity, and translation everywhere except the arrival
  // settle, which gets a small overshoot.
  static const _liquid = Cubic(0.32, 0.72, 0, 1);
  // Subtle overshoot (~3%) for the state-arrival settle.
  static const _arrive = Cubic(0.34, 1.28, 0.64, 1);
  // Symmetric for color/opacity crossfades that should feel calm.
  static const _calm = Cubic(0.65, 0, 0.35, 1);

  // One-shot on every state change: scale + drop + glow envelope.
  late final AnimationController _settle = AnimationController(
    vsync: this,
    duration: _slow,
  )..value = 1.0;

  late final Animation<double> _pulseScale = Tween<double>(
    begin: 0.97,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _settle, curve: _arrive));

  late final Animation<double> _pulseDrop = Tween<double>(
    begin: -3,
    end: 0,
  ).animate(CurvedAnimation(parent: _settle, curve: _liquid));

  // Continuous breathing while the user has an action to take.
  // 1.0 → 1.015 → 1.0 with a slow sine; pairs with a glow that breathes too.
  late final AnimationController _ambient = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );

  // Multiplier 0..1: how strongly the ambient effect is applied.
  // Crossfades smoothly when entering/leaving needs-action states.
  late final AnimationController _ambientGain = AnimationController(
    vsync: this,
    duration: _slow,
    value: 0,
  );

  bool _needsAttention(CertifyLogsState s) =>
      s == CertifyLogsState.uncertified || s == CertifyLogsState.unverifiable;

  // Smooth 0..1..0 sine over the ambient cycle.
  double _ambientBreath() =>
      0.5 - 0.5 * math.cos(_ambient.value * 2 * math.pi);

  void _syncAmbient() {
    final shouldRun = _needsAttention(widget.state) && widget.expanded;
    if (shouldRun) {
      _ambientGain.forward();
      if (!_ambient.isAnimating) _ambient.repeat();
    } else {
      _ambientGain.reverse();
      // Let the ambient controller keep cycling so the gain fades out smoothly,
      // then stop it once gain reaches 0.
      _ambientGain.addStatusListener(_maybeStopAmbient);
    }
  }

  void _maybeStopAmbient(AnimationStatus s) {
    if (s == AnimationStatus.dismissed) {
      _ambient.stop();
      _ambient.value = 0;
      _ambientGain.removeStatusListener(_maybeStopAmbient);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncAmbient());
  }

  @override
  void didUpdateWidget(covariant CertifyLogsBanner old) {
    super.didUpdateWidget(old);
    if (old.state != widget.state) {
      _settle.forward(from: 0);
    }
    if (old.state != widget.state || old.expanded != widget.expanded) {
      _syncAmbient();
    }
  }

  @override
  void dispose() {
    _settle.dispose();
    _ambient.dispose();
    _ambientGain.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = _paletteFor(widget.state, isDark);
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    // Pass durations through; collapse to zero when the OS asks for
    // reduced motion so we still crossfade colors/opacity but skip
    // the springy translation/scale.
    final sizeMotion = reduceMotion ? Duration.zero : _slow;
    final colorMotion = reduceMotion ? _fast : _medium;
    final iconMotion = reduceMotion ? _fast : _medium;

    return AnimatedBuilder(
      animation: Listenable.merge([_settle, _ambient, _ambientGain]),
      builder: (context, child) {
        if (reduceMotion) return child!;
        final breath = _ambientBreath() * _ambientGain.value;
        final scale = _pulseScale.value * (1.0 + 0.015 * breath);
        return Transform.translate(
          offset: Offset(0, _pulseDrop.value),
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: AnimatedContainer(
        duration: colorMotion,
        curve: _calm,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.lerp(palette.bodyBg, Colors.white, isDark ? 0.02 : 0.04)!,
              palette.bodyBg,
            ],
          ),
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4)),
          boxShadow: [
            // Colored ambient glow — opacity breathes when needs-attention.
            BoxShadow(
              color: palette.headerBg.withValues(
                alpha: (isDark ? 0.40 : 0.18) +
                    (isDark ? 0.18 : 0.12) *
                        _ambientBreath() *
                        _ambientGain.value,
              ),
              blurRadius: 18 + 6 * _ambientBreath() * _ambientGain.value,
              offset: const Offset(0, 4),
              spreadRadius: -2,
            ),
            const BoxShadow(
              color: Color(0x14000000),
              blurRadius: 6,
              offset: Offset(1, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(
              palette: palette,
              state: widget.state,
              expanded: widget.expanded,
              onTap: widget.onExpandToggle,
              motion: iconMotion,
              colorMotion: colorMotion,
              spring: _liquid,
              smooth: _calm,
            ),
            AnimatedSize(
              duration: sizeMotion,
              curve: _arrive,
              alignment: Alignment.topCenter,
              child: AnimatedSwitcher(
                duration: iconMotion,
                switchInCurve: _liquid,
                switchOutCurve: _calm,
                transitionBuilder: (child, anim) {
                  final slide = Tween<Offset>(
                    begin: const Offset(0, -0.04),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: anim, curve: _liquid));
                  final scale = Tween<double>(begin: 0.98, end: 1.0)
                      .animate(CurvedAnimation(parent: anim, curve: _liquid));
                  return FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: slide,
                      child: ScaleTransition(
                        scale: scale,
                        child: SizeTransition(
                          sizeFactor: anim,
                          axisAlignment: -1,
                          child: child,
                        ),
                      ),
                    ),
                  );
                },
              child: widget.expanded
                  ? _Body(
                      key: ValueKey(widget.state),
                      state: widget.state,
                      palette: palette,
                      daysCount: widget.daysCount,
                      verifiedAt: widget.verifiedAt,
                      onCertify: widget.onCertifyTap,
                      onTryAgain: widget.onTryAgainTap,
                      onSelfAttest: widget.onSelfAttestTap,
                    )
                  : const SizedBox(width: double.infinity),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _BannerPalette _paletteFor(CertifyLogsState s, bool isDark) {
    // Light/dark hex pairs taken directly from the Figma variables export
    // (var(--orange-50/100), var(--red-50/100), var(--green-50/100), etc.).
    switch (s) {
      case CertifyLogsState.uncertified:
        return _BannerPalette(
          headerBg: isDark ? const Color(0xFF805200) : TransfloColors.orange100,
          bodyBg: isDark ? const Color(0xFF664100) : TransfloColors.orange50,
          accent: TransfloColors.orange500,
          textOn: isDark ? Colors.white : TransfloColors.black900,
          icon: Icons.fact_check_outlined,
          title: 'CERTIFY  LOGS',
        );
      case CertifyLogsState.unverifiable:
        return _BannerPalette(
          headerBg: isDark ? const Color(0xFF6D1016) : TransfloColors.red100,
          bodyBg: isDark ? const Color(0xFF570C12) : TransfloColors.red50,
          accent: TransfloColors.red500,
          textOn: isDark ? Colors.white : TransfloColors.black900,
          icon: Icons.cancel,
          title: 'CERTIFY  LOGS',
        );
      case CertifyLogsState.certified:
        return _BannerPalette(
          headerBg: isDark ? const Color(0xFF006018) : TransfloColors.green100,
          bodyBg: isDark ? const Color(0xFF004C13) : TransfloColors.green50,
          accent: TransfloColors.green800,
          textOn: isDark ? const Color(0xFF50FF80) : TransfloColors.black900,
          icon: Icons.check_circle,
          title: 'LOGS CERTIFIED',
        );
      case CertifyLogsState.loading:
        return _BannerPalette(
          headerBg: isDark ? TransfloColors.black800 : TransfloColors.surface100,
          bodyBg: isDark ? TransfloColors.black900 : TransfloColors.surface50,
          accent: TransfloColors.blue500,
          textOn: isDark ? Colors.white : TransfloColors.black900,
          icon: Icons.sync,
          title: 'CHECKING LOGS',
        );
    }
  }
}

class _BannerPalette {
  const _BannerPalette({
    required this.headerBg,
    required this.bodyBg,
    required this.accent,
    required this.textOn,
    required this.icon,
    required this.title,
  });
  final Color headerBg;
  final Color bodyBg;
  final Color accent;
  final Color textOn;
  final IconData icon;
  final String title;
}

class _Header extends StatelessWidget {
  const _Header({
    required this.palette,
    required this.state,
    required this.expanded,
    required this.motion,
    required this.colorMotion,
    required this.spring,
    required this.smooth,
    this.onTap,
  });

  final _BannerPalette palette;
  final CertifyLogsState state;
  final bool expanded;
  final Duration motion;
  final Duration colorMotion;
  final Curve spring;
  final Curve smooth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: colorMotion,
        curve: smooth,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          // Subtle top sheen — barely visible but adds the glassy quality.
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.lerp(palette.headerBg, Colors.white, 0.08)!,
              palette.headerBg,
            ],
          ),
        ),
        child: Row(
          children: [
            AnimatedSwitcher(
              duration: motion,
              switchInCurve: spring,
              switchOutCurve: smooth,
              transitionBuilder: (c, a) {
                final rotate = Tween<double>(begin: -0.08, end: 0)
                    .animate(CurvedAnimation(parent: a, curve: spring));
                return FadeTransition(
                  opacity: a,
                  child: RotationTransition(
                    turns: rotate,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.6, end: 1.0)
                          .animate(CurvedAnimation(parent: a, curve: spring)),
                      child: c,
                    ),
                  ),
                );
              },
              child: state == CertifyLogsState.loading
                  ? SizedBox(
                      key: const ValueKey('spinner'),
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(palette.accent),
                      ),
                    )
                  : Icon(
                      palette.icon,
                      key: ValueKey(palette.icon),
                      size: 16,
                      color: palette.textOn,
                    ),
            ),
            const SizedBox(width: 6),
            AnimatedSwitcher(
              duration: motion,
              switchInCurve: spring,
              switchOutCurve: smooth,
              transitionBuilder: (c, a) {
                final slide = Tween<Offset>(
                  begin: const Offset(-0.15, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: a, curve: spring));
                return FadeTransition(
                  opacity: a,
                  child: SlideTransition(position: slide, child: c),
                );
              },
              child: AnimatedDefaultTextStyle(
                duration: colorMotion,
                curve: smooth,
                key: ValueKey(palette.title),
                style: GoogleFonts.roboto(
                  color: palette.textOn,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  height: 1.5,
                ),
                child: Text(palette.title),
              ),
            ),
            const Spacer(),
            AnimatedRotation(
              duration: motion,
              curve: spring,
              turns: expanded ? 0.5 : 0,
              child: Icon(
                Icons.expand_more,
                size: 16,
                color: palette.textOn.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    super.key,
    required this.state,
    required this.palette,
    required this.daysCount,
    required this.verifiedAt,
    this.onCertify,
    this.onTryAgain,
    this.onSelfAttest,
  });

  final CertifyLogsState state;
  final _BannerPalette palette;
  final int daysCount;
  final DateTime? verifiedAt;
  final VoidCallback? onCertify;
  final VoidCallback? onTryAgain;
  final VoidCallback? onSelfAttest;

  @override
  Widget build(BuildContext context) {
    final sem = Theme.of(context).transflo;
    final message = _message();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (message != null) ...[
            const SizedBox(height: 8),
            Text(
              message,
              style: GoogleFonts.roboto(
                color: palette.textOn,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
          ],
          ..._actionsFor(sem),
        ],
      ),
    );
  }

  String? _message() {
    switch (state) {
      case CertifyLogsState.uncertified:
        return 'To continue workflow you must certify your HOS logs from the previous $daysCount days';
      case CertifyLogsState.unverifiable:
        return "Can't verify logs, confirm certified before continuing";
      case CertifyLogsState.certified:
        final ts = verifiedAt;
        final when = ts == null ? 'just now' : _relative(ts);
        return 'Verified $when. You\'re good to continue.';
      case CertifyLogsState.loading:
        return 'Checking certification status…';
    }
  }

  static String _relative(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} minute${diff.inMinutes == 1 ? '' : 's'} ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    }
    return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
  }

  List<Widget> _actionsFor(TransfloSemanticColors sem) {
    switch (state) {
      case CertifyLogsState.uncertified:
        return [
          _PrimaryCta(
            label: 'Certify Logs In Geotab',
            icon: Icons.fact_check_outlined,
            color: TransfloColors.blue500,
            foreground: Colors.white,
            onTap: onCertify,
          ),
        ];
      case CertifyLogsState.unverifiable:
        return [
          _OutlineCta(
            label: 'Try Again',
            icon: Icons.refresh,
            borderColor: TransfloColors.red500,
            foreground: const Color(0xFF3D3D3D),
            background: Colors.white,
            onTap: onTryAgain,
          ),
          const SizedBox(height: 8),
          _PrimaryCta(
            label: 'I Have Certified My Logs',
            icon: Icons.verified_user_outlined,
            color: TransfloColors.green800,
            foreground: Colors.white,
            onTap: onSelfAttest,
          ),
        ];
      case CertifyLogsState.certified:
        return const [];
      case CertifyLogsState.loading:
        return const [];
    }
  }
}

class _PrimaryCta extends StatelessWidget {
  const _PrimaryCta({
    required this.label,
    required this.icon,
    required this.color,
    required this.foreground,
    this.onTap,
  });
  final String label;
  final IconData icon;
  final Color color;
  final Color foreground;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: FilledButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 14),
        label: Text(label,
            style: GoogleFonts.roboto(
                fontSize: 14, fontWeight: FontWeight.w500)),
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: foreground,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
    );
  }
}

class _OutlineCta extends StatelessWidget {
  const _OutlineCta({
    required this.label,
    required this.icon,
    required this.borderColor,
    required this.foreground,
    required this.background,
    this.onTap,
  });
  final String label;
  final IconData icon;
  final Color borderColor;
  final Color foreground;
  final Color background;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 14, color: foreground),
        label: Text(label,
            style: GoogleFonts.roboto(
                fontSize: 14, fontWeight: FontWeight.w500, color: foreground)),
        style: OutlinedButton.styleFrom(
          backgroundColor: background,
          side: BorderSide(color: borderColor),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
    );
  }
}

