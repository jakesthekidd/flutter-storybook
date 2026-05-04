import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../tokens/colors.dart';
import '../tokens/semantic_colors.dart';

enum CertifyLogsState { loading, uncertified, unverifiable, certified }

/// A multi-state status banner that prompts drivers to certify HOS logs.
/// Designed to feel reactive — color, size, icon, and content flow between
/// states with implicit animations rather than discrete page swaps.
class CertifyLogsBanner extends StatefulWidget {
  const CertifyLogsBanner({
    super.key,
    required this.state,
    this.expanded = true,
    this.required = true,
    this.daysCount = 14,
    this.verifiedAt,
    this.onCertifyTap,
    this.onSkipTap,
    this.onTryAgainTap,
    this.onSelfAttestTap,
    this.onExpandToggle,
  });

  final CertifyLogsState state;
  final bool expanded;
  final bool required;
  final int daysCount;
  final DateTime? verifiedAt;

  final VoidCallback? onCertifyTap;
  final VoidCallback? onSkipTap;
  final VoidCallback? onTryAgainTap;
  final VoidCallback? onSelfAttestTap;
  final VoidCallback? onExpandToggle;

  @override
  State<CertifyLogsBanner> createState() => _CertifyLogsBannerState();
}

class _CertifyLogsBannerState extends State<CertifyLogsBanner>
    with SingleTickerProviderStateMixin {
  // Liquid-glass-ish motion: longer durations + spring-y back-out for size,
  // gentler ease-in-out for color, plus a state-change "settle" pulse.
  static const _sizeMotion = Duration(milliseconds: 460);
  static const _colorMotion = Duration(milliseconds: 380);
  static const _iconMotion = Duration(milliseconds: 420);

  // Approximations of UIKit-style critically-damped springs.
  static const _spring = Cubic(0.22, 1.12, 0.36, 1.0); // gentle overshoot
  static const _smooth = Cubic(0.65, 0.0, 0.35, 1.0); // smooth ease-in-out

  late final AnimationController _settle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );

  @override
  void didUpdateWidget(covariant CertifyLogsBanner old) {
    super.didUpdateWidget(old);
    if (old.state != widget.state) {
      _settle.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _settle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = _paletteFor(widget.state, isDark);

    return AnimatedBuilder(
      animation: _settle,
      builder: (context, child) {
        // Tiny breathing scale on state change: 0.985 → 1.012 → 1.0
        // driven through a back-out curve so it feels like settling glass.
        final t = _spring.transform(_settle.value);
        final scale = 0.985 + (1.012 - 0.985) * (1 - (1 - t).abs()) +
            (1 - t) * 0.003;
        return Transform.scale(scale: scale.clamp(0.985, 1.012), child: child);
      },
      child: AnimatedContainer(
        duration: _colorMotion,
        curve: _smooth,
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
            BoxShadow(
              color: palette.headerBg.withValues(alpha: isDark ? 0.4 : 0.18),
              blurRadius: 18,
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
              motion: _iconMotion,
              colorMotion: _colorMotion,
              spring: _spring,
              smooth: _smooth,
            ),
            AnimatedSize(
              duration: _sizeMotion,
              curve: _spring,
              alignment: Alignment.topCenter,
              child: AnimatedSwitcher(
                duration: _iconMotion,
                switchInCurve: _spring,
                switchOutCurve: _smooth,
                transitionBuilder: (child, anim) {
                  final slide = Tween<Offset>(
                    begin: const Offset(0, -0.04),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: anim, curve: _spring));
                  final scale = Tween<double>(begin: 0.98, end: 1.0)
                      .animate(CurvedAnimation(parent: anim, curve: _spring));
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
                      required: widget.required,
                      daysCount: widget.daysCount,
                      verifiedAt: widget.verifiedAt,
                      onCertify: widget.onCertifyTap,
                      onSkip: widget.onSkipTap,
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
          icon: Icons.warning_amber_rounded,
          title: 'CERTIFY  LOGS',
        );
      case CertifyLogsState.certified:
        return _BannerPalette(
          headerBg: isDark ? const Color(0xFF006018) : TransfloColors.green100,
          bodyBg: isDark ? const Color(0xFF004C13) : TransfloColors.green50,
          accent: TransfloColors.green800,
          textOn: isDark ? const Color(0xFF50FF80) : TransfloColors.black900,
          icon: Icons.verified_user_outlined,
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
    required this.required,
    required this.daysCount,
    required this.verifiedAt,
    this.onCertify,
    this.onSkip,
    this.onTryAgain,
    this.onSelfAttest,
  });

  final CertifyLogsState state;
  final _BannerPalette palette;
  final bool required;
  final int daysCount;
  final DateTime? verifiedAt;
  final VoidCallback? onCertify;
  final VoidCallback? onSkip;
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
        return required
            ? 'To continue workflow you must certify your HOS logs from the previous $daysCount days'
            : 'Reminder: certify your HOS logs from the previous $daysCount days';
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
          if (!required) ...[
            const SizedBox(height: 8),
            _SkipTile(
              background: palette.headerBg,
              foreground: palette.textOn,
              onTap: onSkip,
            ),
          ],
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

class _SkipTile extends StatelessWidget {
  const _SkipTile({
    required this.background,
    required this.foreground,
    this.onTap,
  });
  final Color background;
  final Color foreground;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Skip For Now',
                  style: GoogleFonts.roboto(
                    color: foreground,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.chevron_right, size: 16, color: foreground),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
