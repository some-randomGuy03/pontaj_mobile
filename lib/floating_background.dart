import 'package:flutter/material.dart';
import 'dart:math' as math;

class FloatingBackgroundLetters extends StatefulWidget {
  final String text;
  final Color color;
  final double fontSize;

  const FloatingBackgroundLetters({
    Key? key,
    this.text = "CNVGA",
    this.color = const Color(0xFFFFFFFF),
    this.fontSize = 20, // Slightly smaller for "many letters"
  }) : super(key: key);

  @override
  State<FloatingBackgroundLetters> createState() => _FloatingBackgroundLettersState();
}

class _FloatingBackgroundLettersState extends State<FloatingBackgroundLetters> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20), // Smooth, slow conveyor belt
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _GridTextPainter(
              text: widget.text,
              color: widget.color.withOpacity(0.15), // "putin mai alb"
              fontSize: widget.fontSize,
              progress: _controller.value,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _GridTextPainter extends CustomPainter {
  final String text;
  final Color color;
  final double fontSize;
  final double progress;

  _GridTextPainter({
    required this.text,
    required this.color,
    required this.fontSize,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final textStyle = TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      fontFamily: 'Arial',
    );
    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Grid cell size (text size + spacing)
    final double spacingX = 60.0;
    final double spacingY = 60.0;
    final double cellW = textPainter.width + spacingX;
    final double cellH = textPainter.height + spacingY;

    // Calculate shift based on progress (0.0 to 1.0)
    // Moving diagonally: right and up
    final double dx = progress * cellW;
    final double dy = -progress * cellH;

    // Determine how many rows and columns we need to cover the screen
    // Add buffer to ensure seamless scrolling
    final int cols = (size.width / cellW).ceil() + 4;
    final int rows = (size.height / cellH).ceil() + 4;

    // Start drawing from negative coordinates to cover the incoming edge
    for (int i = -2; i < cols; i++) {
      for (int j = -2; j < rows; j++) {
        final double x = i * cellW + dx;
        final double y = j * cellH + dy;

        // Calculate opacity based on position
        // Create a radial-ish gradient effect from center
        double centerX = size.width / 2;
        double centerY = size.height / 2;
        double dist = math.sqrt(math.pow(x - centerX, 2) + math.pow(y - centerY, 2));
        double maxDist = math.sqrt(math.pow(size.width, 2) + math.pow(size.height, 2)) / 2;
        
        // Normalize distance 0.0 (center) to 1.0 (edge)
        double normDist = (dist / maxDist).clamp(0.0, 1.0);
        
        // Invert: 1.0 at center, 0.0 at edge
        // Add some noise/variation based on grid position
        double baseOpacity = 1.0 - normDist;
        double noise = math.sin(i * 0.5) * math.cos(j * 0.5) * 0.2; // +/- 0.2 variation
        double finalOpacity = (baseOpacity + noise).clamp(0.1, 0.8); // Keep it visible but subtle

        canvas.save();
        // Translate to the grid point
        canvas.translate(x, y);
        // Rotate the text itself
        canvas.rotate(-math.pi / 6); // -30 degrees
        
        // Paint with calculated opacity
        textPainter.text = TextSpan(
          text: text,
          style: textStyle.copyWith(color: color.withOpacity(color.opacity * finalOpacity)),
        );
        textPainter.layout();
        
        // Center the text at the point
        textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GridTextPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.text != text ||
           oldDelegate.color != color ||
           oldDelegate.fontSize != fontSize;
  }
}
