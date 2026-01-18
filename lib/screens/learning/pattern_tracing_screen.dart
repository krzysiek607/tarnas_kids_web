import 'dart:math';
import 'package:flutter/material.dart';
import '../../widgets/tracing_canvas.dart';
import 'tracing_game_screen.dart';

/// Ekran gry "Szlaczki" - nauka motoryki malej
class PatternTracingScreen extends StatelessWidget {
  const PatternTracingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width - 64; // margin 32 * 2
    final patterns = _createPatterns(screenWidth);

    return TracingGameScreen(
      title: 'Szlaczki',
      emoji: '〰️',
      patterns: patterns,
      drawColor: Colors.blue,
    );
  }

  List<TracingPattern> _createPatterns(double width) {
    final centerY = 150.0; // Srodek w pionie
    final margin = 40.0;
    final usableWidth = width - margin * 2;

    return [
      // 1. Linia prosta pozioma
      TracingPattern(
        name: 'Linia prosta',
        hint: 'Narysuj prosta linie od lewej do prawej',
        path: _createStraightLine(margin, centerY, usableWidth),
      ),

      // 2. Fala
      TracingPattern(
        name: 'Fala',
        hint: 'Plynnie faluj w gore i w dol',
        path: _createWave(margin, centerY, usableWidth, waves: 3),
      ),

      // 3. Zygzak
      TracingPattern(
        name: 'Zygzak',
        hint: 'Ostre zakrety w gore i w dol',
        path: _createZigzag(margin, centerY, usableWidth, peaks: 4),
      ),

      // 4. Petelki
      TracingPattern(
        name: 'Petelki',
        hint: 'Male koleczka jedno za drugim',
        path: _createLoops(margin, centerY, usableWidth, loops: 4),
      ),

      // 5. Linia pionowa
      TracingPattern(
        name: 'Linia pionowa',
        hint: 'Prosta linia z gory na dol',
        path: _createVerticalLine(width / 2, 60, 240),
      ),

      // 6. Spirala
      TracingPattern(
        name: 'Spirala',
        hint: 'Zacznij od srodka i krec na zewnatrz',
        path: _createSpiral(width / 2, centerY, 80),
      ),

      // 7. Schody
      TracingPattern(
        name: 'Schody',
        hint: 'Rysuj stopnie schodow',
        path: _createStairs(margin, 220, usableWidth, steps: 5),
      ),

      // 8. Duza fala
      TracingPattern(
        name: 'Duza fala',
        hint: 'Plynna, szeroka fala',
        path: _createWave(margin, centerY, usableWidth, waves: 2, amplitude: 60),
      ),

      // 9. Male zeby
      TracingPattern(
        name: 'Male zeby',
        hint: 'Ostre male trojkaty',
        path: _createZigzag(margin, centerY, usableWidth, peaks: 8, amplitude: 25),
      ),

      // 10. Osmka
      TracingPattern(
        name: 'Osmka',
        hint: 'Narysuj lezaca osemke',
        path: _createFigureEight(width / 2, centerY, 60),
      ),
    ];
  }

  /// Linia prosta pozioma
  Path _createStraightLine(double startX, double y, double width) {
    return Path()
      ..moveTo(startX, y)
      ..lineTo(startX + width, y);
  }

  /// Linia pionowa
  Path _createVerticalLine(double x, double startY, double height) {
    return Path()
      ..moveTo(x, startY)
      ..lineTo(x, startY + height);
  }

  /// Fala sinusoidalna
  Path _createWave(double startX, double centerY, double width,
      {int waves = 3, double amplitude = 40}) {
    final path = Path();
    final waveWidth = width / waves;

    path.moveTo(startX, centerY);

    for (int i = 0; i < waves; i++) {
      final x1 = startX + i * waveWidth + waveWidth * 0.25;
      final x2 = startX + i * waveWidth + waveWidth * 0.75;
      final x3 = startX + (i + 1) * waveWidth;

      path.cubicTo(
        x1, centerY - amplitude,
        x2, centerY + amplitude,
        x3, centerY,
      );
    }

    return path;
  }

  /// Zygzak
  Path _createZigzag(double startX, double centerY, double width,
      {int peaks = 4, double amplitude = 40}) {
    final path = Path();
    final segmentWidth = width / (peaks * 2);

    path.moveTo(startX, centerY);

    for (int i = 0; i < peaks * 2; i++) {
      final x = startX + (i + 1) * segmentWidth;
      final y = i.isEven ? centerY - amplitude : centerY + amplitude;
      path.lineTo(x, y);
    }

    return path;
  }

  /// Petelki (male kola)
  Path _createLoops(double startX, double centerY, double width, {int loops = 4}) {
    final path = Path();
    final loopWidth = width / loops;
    final radius = loopWidth / 2 * 0.7;

    path.moveTo(startX, centerY);

    for (int i = 0; i < loops; i++) {
      final cx = startX + i * loopWidth + loopWidth / 2;

      // Rysuj petelke (kolo)
      path.addOval(Rect.fromCircle(
        center: Offset(cx, centerY),
        radius: radius,
      ));

      // Przejdz do nastepnej pozycji
      if (i < loops - 1) {
        path.moveTo(cx + radius, centerY);
      }
    }

    return path;
  }

  /// Spirala
  Path _createSpiral(double cx, double cy, double maxRadius) {
    final path = Path();
    const turns = 3;
    const steps = 100;

    for (int i = 0; i <= steps; i++) {
      final t = i / steps;
      final angle = t * turns * 2 * pi;
      final radius = t * maxRadius;

      final x = cx + cos(angle) * radius;
      final y = cy + sin(angle) * radius;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    return path;
  }

  /// Schody
  Path _createStairs(double startX, double startY, double width, {int steps = 5}) {
    final path = Path();
    final stepWidth = width / steps;
    final stepHeight = 30.0;

    path.moveTo(startX, startY);

    for (int i = 0; i < steps; i++) {
      // Pozioma linia
      path.lineTo(startX + (i + 1) * stepWidth, startY - i * stepHeight);
      // Pionowa linia (jesli nie ostatni)
      if (i < steps - 1) {
        path.lineTo(startX + (i + 1) * stepWidth, startY - (i + 1) * stepHeight);
      }
    }

    return path;
  }

  /// Osmka (lezaca)
  Path _createFigureEight(double cx, double cy, double radius) {
    final path = Path();
    const steps = 100;

    for (int i = 0; i <= steps; i++) {
      final t = i / steps * 2 * pi;
      // Parametryczna osmka (lemniskata)
      final x = cx + radius * 1.5 * cos(t);
      final y = cy + radius * sin(2 * t) / 2;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    return path;
  }
}
