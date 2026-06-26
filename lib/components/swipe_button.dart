import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SwipeButton extends StatefulWidget {
  const SwipeButton({
    super.key,
    this.label = 'Swipe to confirm',
    this.onConfirmed,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onConfirmed;
  final bool enabled;

  @override
  State<SwipeButton> createState() => _SwipeButtonState();
}

class _SwipeButtonState extends State<SwipeButton>
    with SingleTickerProviderStateMixin {
  double _dragPosition = 0;
  bool _confirmed = false;
  static const double _thumbSize = 48;
  static const double _height = 56;

  void _onDragUpdate(DragUpdateDetails details, double trackWidth) {
    if (!widget.enabled || _confirmed) return;
    setState(() {
      _dragPosition = (_dragPosition + details.delta.dx)
          .clamp(0.0, trackWidth - _thumbSize);
    });
  }

  void _onDragEnd(double trackWidth) {
    final threshold = (trackWidth - _thumbSize) * 0.85;
    if (_dragPosition >= threshold) {
      setState(() {
        _dragPosition = trackWidth - _thumbSize;
        _confirmed = true;
      });
      widget.onConfirmed?.call();
    } else {
      setState(() => _dragPosition = 0);
    }
  }

  void reset() => setState(() {
        _dragPosition = 0;
        _confirmed = false;
      });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final blue = isDark ? const Color(0xFF5090C9) : const Color(0xFF2068A8);
    const blueLight = Color(0xFFD3E3F1);

    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth;
        final progress = trackWidth > _thumbSize
            ? _dragPosition / (trackWidth - _thumbSize)
            : 0.0;

        return SizedBox(
          height: _height,
          child: Stack(
            children: [
              // Track
              Positioned.fill(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: _confirmed
                        ? blue
                        : (isDark
                            ? const Color(0xFF1A2E45)
                            : const Color(0xFFE3F5FD)),
                    borderRadius: BorderRadius.circular(28),
                    border: _confirmed
                        ? null
                        : Border.all(
                            color: isDark
                                ? const Color(0xFF2474BB)
                                : const Color(0xFFAAE1F8),
                          ),
                  ),
                ),
              ),
              // Fill progress indicator
              if (!_confirmed)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: _dragPosition + _thumbSize,
                  child: Container(
                    decoration: BoxDecoration(
                      color: blue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                ),
              // Label
              Center(
                child: Opacity(
                  opacity: _confirmed ? 0 : (1 - progress * 0.6),
                  child: Text(
                    widget.label,
                    style: GoogleFonts.roboto(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: blue,
                    ),
                  ),
                ),
              ),
              if (_confirmed)
                Center(
                  child: Icon(Icons.check_circle_rounded,
                      color: blueLight, size: 28),
                ),
              // Thumb
              if (!_confirmed)
                Positioned(
                  left: _dragPosition,
                  top: 4,
                  child: GestureDetector(
                    onHorizontalDragUpdate: widget.enabled
                        ? (d) => _onDragUpdate(d, trackWidth)
                        : null,
                    onHorizontalDragEnd: widget.enabled
                        ? (_) => _onDragEnd(trackWidth)
                        : null,
                    child: Container(
                      width: _thumbSize,
                      height: _thumbSize,
                      decoration: BoxDecoration(
                        color: widget.enabled ? blue : Colors.grey,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(Icons.chevron_right,
                          color: Colors.white, size: 28),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
