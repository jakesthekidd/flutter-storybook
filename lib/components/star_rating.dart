import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StarRating extends StatefulWidget {
  const StarRating({
    super.key,
    this.initialRating = 0,
    this.starCount = 5,
    this.size = 36,
    this.label,
    this.onChanged,
  });

  final int initialRating;
  final int starCount;
  final double size;
  final String? label;
  final ValueChanged<int>? onChanged;

  @override
  State<StarRating> createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating> {
  late int _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMuted =
        isDark ? const Color(0xFF535B6D) : const Color(0xFFA9B3C2);
    final textMain =
        isDark ? const Color(0xFFE6E8EE) : const Color(0xFF3D3D3D);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: textMain,
            ),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.starCount, (i) {
            final filled = i < _rating;
            return GestureDetector(
              onTap: () {
                setState(() => _rating = i + 1);
                widget.onChanged?.call(i + 1);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  filled ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: widget.size,
                  color: filled
                      ? const Color(0xFFFFA300)
                      : textMuted,
                ),
              ),
            );
          }),
        ),
        if (_rating > 0) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Bad',
                style: GoogleFonts.roboto(fontSize: 12, color: textMuted),
              ),
              const SizedBox(width: 80),
              Text(
                'Great',
                style: GoogleFonts.roboto(fontSize: 12, color: textMuted),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
