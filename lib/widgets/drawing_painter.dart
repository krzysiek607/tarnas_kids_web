import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:math';
import '../models/drawing_point.dart';

/// CustomPainter do renderowania linii na canvas
/// OPTYMALIZACJA: Obsługuje backing image dla wydajności
class DrawingPainter extends CustomPainter {
  final List<DrawingLine> lines;
  final DrawingLine? currentLine;
  final ui.Image? backingImage; // Wypalone poprzednie linie
  final int bakedLinesCount; // Ile linii jest już w backingImage

  DrawingPainter({
    required this.lines,
    this.currentLine,
    this.backingImage,
    this.bakedLinesCount = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. OPTYMALIZACJA: Narysuj backing image (już wypalone linie)
    if (backingImage != null) {
      canvas.drawImage(backingImage!, Offset.zero, Paint());
    }

    // 2. Rysuj tylko NOWE linie (po bakedLinesCount)
    for (int i = bakedLinesCount; i < lines.length; i++) {
      _drawLine(canvas, lines[i]);
    }

    // 3. Rysuj aktualna linie (w trakcie rysowania)
    if (currentLine != null) {
      _drawLine(canvas, currentLine!);
    }
  }

  void _drawLine(Canvas canvas, DrawingLine line) {
    if (line.points.isEmpty) return;

    switch (line.tool) {
      case DrawingTool.brush:
        _drawBrushLine(canvas, line);
        break;
      case DrawingTool.crayon:
        _drawCrayonLine(canvas, line);
        break;
      case DrawingTool.spray:
        _drawSprayLine(canvas, line);
        break;
      case DrawingTool.eraser:
        _drawEraserLine(canvas, line);
        break;
    }
  }


  /// Pedzel - miekkie, gladkie linie z przezroczystoscia
  void _drawBrushLine(Canvas canvas, DrawingLine line) {
    final paint = Paint()
      ..color = line.color.withOpacity(0.6)
      ..strokeWidth = line.strokeWidth * 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    if (line.points.length == 1) {
      canvas.drawCircle(
        line.points.first.offset,
        line.strokeWidth,
        paint..style = PaintingStyle.fill,
      );
      return;
    }

    final path = Path();
    path.moveTo(line.points.first.offset.dx, line.points.first.offset.dy);

    for (int i = 1; i < line.points.length; i++) {
      final p0 = line.points[i - 1].offset;
      final p1 = line.points[i].offset;
      final midPoint = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
      path.quadraticBezierTo(p0.dx, p0.dy, midPoint.dx, midPoint.dy);
    }

    final lastPoint = line.points.last.offset;
    path.lineTo(lastPoint.dx, lastPoint.dy);

    canvas.drawPath(path, paint);
  }

  /// Kredka - teksturowane linie
  void _drawCrayonLine(Canvas canvas, DrawingLine line) {
    final basePaint = Paint()
      ..color = line.color.withOpacity(0.8)
      ..strokeWidth = line.strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    if (line.points.length == 1) {
      canvas.drawCircle(
        line.points.first.offset,
        line.strokeWidth / 2,
        basePaint..style = PaintingStyle.fill,
      );
      return;
    }

    // Rysuj glowna linie
    for (int i = 1; i < line.points.length; i++) {
      final p0 = line.points[i - 1].offset;
      final p1 = line.points[i].offset;
      
      // Glowna linia
      canvas.drawLine(p0, p1, basePaint);
      
      // Dodaj teksture - male linie obok
      final random = Random(i);
      for (int j = 0; j < 3; j++) {
        final offsetX = (random.nextDouble() - 0.5) * line.strokeWidth * 0.5;
        final offsetY = (random.nextDouble() - 0.5) * line.strokeWidth * 0.5;
        final texturePaint = Paint()
          ..color = line.color.withOpacity(0.3 + random.nextDouble() * 0.3)
          ..strokeWidth = line.strokeWidth * 0.3
          ..strokeCap = StrokeCap.round;
        
        canvas.drawLine(
          Offset(p0.dx + offsetX, p0.dy + offsetY),
          Offset(p1.dx + offsetX, p1.dy + offsetY),
          texturePaint,
        );
      }
    }
  }

  /// Spray - rozpylone punkty
  void _drawSprayLine(Canvas canvas, DrawingLine line) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    for (final point in line.points) {
      final random = Random(point.offset.dx.toInt() ^ point.offset.dy.toInt());
      final sprayRadius = line.strokeWidth * 1.5;
      final dotCount = (line.strokeWidth * 3).toInt();

      for (int i = 0; i < dotCount; i++) {
        final angle = random.nextDouble() * 2 * pi;
        final radius = random.nextDouble() * sprayRadius;
        final dotSize = 1.0 + random.nextDouble() * 2;

        final dx = point.offset.dx + cos(angle) * radius;
        final dy = point.offset.dy + sin(angle) * radius;

        paint.color = line.color.withOpacity(0.3 + random.nextDouble() * 0.5);
        canvas.drawCircle(Offset(dx, dy), dotSize, paint);
      }
    }
  }

  /// Gumka - wymazuje rysunki (rysuje bialym kolorem)
  void _drawEraserLine(Canvas canvas, DrawingLine line) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = line.strokeWidth * 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    if (line.points.length == 1) {
      canvas.drawCircle(
        line.points.first.offset,
        line.strokeWidth,
        paint..style = PaintingStyle.fill,
      );
      return;
    }

    final path = Path();
    path.moveTo(line.points.first.offset.dx, line.points.first.offset.dy);

    for (int i = 1; i < line.points.length; i++) {
      final p0 = line.points[i - 1].offset;
      final p1 = line.points[i].offset;
      final midPoint = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
      path.quadraticBezierTo(p0.dx, p0.dy, midPoint.dx, midPoint.dy);
    }

    final lastPoint = line.points.last.offset;
    path.lineTo(lastPoint.dx, lastPoint.dy);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) {
    // OPTYMALIZACJA: Przerysuj tylko gdy zmieni się backing, nowe linie lub aktualna linia
    return oldDelegate.backingImage != backingImage ||
        oldDelegate.bakedLinesCount != bakedLinesCount ||
        oldDelegate.lines.length != lines.length ||
        oldDelegate.currentLine != currentLine ||
        (currentLine != null &&
            oldDelegate.currentLine != null &&
            currentLine!.points.length != oldDelegate.currentLine!.points.length);
  }
}
