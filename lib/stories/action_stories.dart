import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:storybook_flutter/storybook_flutter.dart';

import '../components/swipe_button.dart';

final actionStories = <Story>[
  // ── Side By Side Buttons ──────────────────────────────────────────────────
  Story(
    name: 'Actions/Side By Side Buttons',
    description:
        'Decline/Accept pill button pair. Decline is outlined; Accept is filled. '
        'Both are fully pill-shaped.',
    builder: (context) {
      final declineLabel = context.knobs
          .text(label: 'Decline label', initial: 'Decline');
      final acceptLabel =
          context.knobs.text(label: 'Accept label', initial: 'Accept');
      final enabled =
          context.knobs.boolean(label: 'Enabled', initial: true);
      return Padding(
        padding: const EdgeInsets.all(24),
        child: _SideBySideButtons(
          declineLabel: declineLabel,
          acceptLabel: acceptLabel,
          enabled: enabled,
        ),
      );
    },
  ),

  // ── Swipe Button ──────────────────────────────────────────────────────────
  Story(
    name: 'Actions/Swipe Button',
    description:
        'Drag the thumb from left to right to confirm an action. '
        'Releasing before the threshold snaps back.',
    builder: (context) {
      final label = context.knobs.text(
          label: 'Label', initial: 'Swipe to confirm');
      final enabled =
          context.knobs.boolean(label: 'Enabled', initial: true);
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: SizedBox(
          width: 340,
          child: SwipeButton(label: label, enabled: enabled),
        ),
      );
    },
  ),

  // ── Navigation FAB ────────────────────────────────────────────────────────
  Story(
    name: 'Actions/Navigation FAB',
    description:
        'Floating action button for primary navigation or location actions.',
    builder: (context) => const Padding(
      padding: EdgeInsets.all(40),
      child: _NavFab(),
    ),
  ),

  // ── Check Call ───────────────────────────────────────────────────────────
  Story(
    name: 'Actions/Check Call',
    description:
        'Driver check-call card. Logs the driver\'s current location '
        'and time with dispatch.',
    builder: (context) => SizedBox(
      width: 360,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _CheckCallCard(),
      ),
    ),
  ),

  // ── Smart SMS ─────────────────────────────────────────────────────────────
  Story(
    name: 'Actions/Smart SMS',
    description:
        'Quick SMS composition card. Select a contact and send a '
        'pre-filled or custom message.',
    builder: (context) => SizedBox(
      width: 360,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _SmsSendCard(),
      ),
    ),
  ),
];

// ── Side By Side Buttons ──────────────────────────────────────────────────────

class _SideBySideButtons extends StatelessWidget {
  const _SideBySideButtons({
    required this.declineLabel,
    required this.acceptLabel,
    this.enabled = true,
  });
  final String declineLabel;
  final String acceptLabel;
  final bool enabled;

  static const _blue = Color(0xFF2068A8);
  static const _blueLight = Color(0xFFE3F5FD);
  static const _blueBorder = Color(0xFFAAE1F8);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: enabled ? () {} : null,
              icon: const Icon(Icons.close, size: 18),
              label: Text(declineLabel,
                  style: GoogleFonts.roboto(
                      fontSize: 15, fontWeight: FontWeight.w500)),
              style: OutlinedButton.styleFrom(
                backgroundColor: _blueLight,
                foregroundColor: _blue,
                side: const BorderSide(color: _blueBorder, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 48,
            child: FilledButton.icon(
              onPressed: enabled ? () {} : null,
              icon: const Icon(Icons.check, size: 18),
              label: Text(acceptLabel,
                  style: GoogleFonts.roboto(
                      fontSize: 15, fontWeight: FontWeight.w500)),
              style: FilledButton.styleFrom(
                backgroundColor: _blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Navigation FAB ────────────────────────────────────────────────────────────

class _NavFab extends StatelessWidget {
  const _NavFab();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF4BA3C7),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4BA3C7).withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(Icons.navigation_rounded,
          color: Colors.white, size: 28),
    );
  }
}

// ── Check Call Card ───────────────────────────────────────────────────────────

class _CheckCallCard extends StatefulWidget {
  @override
  State<_CheckCallCard> createState() => _CheckCallCardState();
}

class _CheckCallCardState extends State<_CheckCallCard> {
  bool _sent = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface0 = isDark ? const Color(0xFF0E1116) : Colors.white;
    final surfaceBorder =
        isDark ? const Color(0xFF2E3441) : const Color(0xFFE2E6EB);
    final textMain =
        isDark ? const Color(0xFFE6E8EE) : const Color(0xFF3D3D3D);
    final textMuted =
        isDark ? const Color(0xFF535B6D) : const Color(0xFFA9B3C2);
    const blue = Color(0xFF2474BB);

    return Container(
      decoration: BoxDecoration(
        color: surface0,
        border: Border.all(color: surfaceBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1A2E45)
                      : const Color(0xFFD1E8F7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.phone_in_talk_outlined,
                    color: blue, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                'Check Call',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textMain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  color: blue, size: 16),
              const SizedBox(width: 6),
              Text(
                'Current location will be sent',
                style: GoogleFonts.roboto(
                    fontSize: 14, color: textMuted),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.access_time, color: blue, size: 16),
              const SizedBox(width: 6),
              Text(
                'Timestamp: now',
                style: GoogleFonts.roboto(
                    fontSize: 14, color: textMuted),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_sent)
            Row(
              children: [
                const Icon(Icons.check_circle,
                    color: Color(0xFF00BF30), size: 18),
                const SizedBox(width: 6),
                Text('Check call sent',
                    style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: const Color(0xFF00BF30),
                        fontWeight: FontWeight.w500)),
              ],
            )
          else
            SizedBox(
              height: 44,
              child: FilledButton(
                onPressed: () => setState(() => _sent = true),
                style: FilledButton.styleFrom(
                  backgroundColor: blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
                child: Text('Send Check Call',
                    style: GoogleFonts.roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Smart SMS Card ────────────────────────────────────────────────────────────

class _SmsSendCard extends StatefulWidget {
  @override
  State<_SmsSendCard> createState() => _SmsSendCardState();
}

class _SmsSendCardState extends State<_SmsSendCard> {
  final _msgCtrl = TextEditingController(
      text: 'Please confirm your location by sending a check call.');
  bool _sent = false;

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface0 = isDark ? const Color(0xFF0E1116) : Colors.white;
    final surface100 =
        isDark ? const Color(0xFF181C24) : const Color(0xFFF7F8F9);
    final surfaceBorder =
        isDark ? const Color(0xFF2E3441) : const Color(0xFFE2E6EB);
    final textMain =
        isDark ? const Color(0xFFE6E8EE) : const Color(0xFF3D3D3D);
    final textMuted =
        isDark ? const Color(0xFF535B6D) : const Color(0xFFA9B3C2);
    const blue = Color(0xFF2474BB);

    return Container(
      decoration: BoxDecoration(
        color: surface0,
        border: Border.all(color: surfaceBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1A2E45)
                      : const Color(0xFFD1E8F7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.sms_outlined,
                    color: blue, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                'Smart SMS',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textMain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: surface100,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: surfaceBorder),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.person_outline,
                    color: Color(0xFF2474BB), size: 18),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dispatcher',
                        style: GoogleFonts.roboto(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: textMain)),
                    Text('+1 (800) 555-0192',
                        style: GoogleFonts.roboto(
                            fontSize: 12, color: textMuted)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _msgCtrl,
            maxLines: 3,
            style: GoogleFonts.roboto(fontSize: 14, color: textMain),
            decoration: InputDecoration(
              filled: true,
              fillColor: surface100,
              hintText: 'Type a message…',
              hintStyle:
                  GoogleFonts.roboto(fontSize: 14, color: textMuted),
              contentPadding: const EdgeInsets.all(12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: surfaceBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide:
                    const BorderSide(color: blue, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_sent)
            Row(
              children: [
                const Icon(Icons.check_circle,
                    color: Color(0xFF00BF30), size: 18),
                const SizedBox(width: 6),
                Text('SMS sent',
                    style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: const Color(0xFF00BF30),
                        fontWeight: FontWeight.w500)),
              ],
            )
          else
            SizedBox(
              height: 44,
              child: FilledButton.icon(
                onPressed: () => setState(() => _sent = true),
                icon: const Icon(Icons.send, size: 16),
                label: Text('Send SMS',
                    style: GoogleFonts.roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
                style: FilledButton.styleFrom(
                  backgroundColor: blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
