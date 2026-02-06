import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/tracing_path.dart';
import '../../widgets/tracing_canvas.dart';
import 'tracing_game_screen.dart';

/// Ekran gry "Szlaczki" - nauka motoryki małej
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
      rewardType: 'patterns',
      enableRewards: true,
    );
  }

  List<TracingPattern> _createPatterns(double width) {
    final centerY = 160.0; // Środek w pionie (przesunięty w dół dla większych wzorów)
    final margin = 35.0;
    final usableWidth = width - margin * 2;

    return [
      // ============================================
      // PODSTAWOWE LINIE
      // ============================================

      // 1. Linia prosta pozioma
      TracingPattern(
        name: 'Linia prosta',
        hint: 'Narysuj prostą linię od lewej do prawej',
        path: _createStraightLine(margin, centerY, usableWidth),
        waypoints: _straightLineWaypoints(margin, centerY, usableWidth),
      ),

      // 2. Linia pionowa
      TracingPattern(
        name: 'Linia pionowa',
        hint: 'Prosta linia z góry na dół',
        path: _createVerticalLine(width / 2, 50, 260),
        waypoints: _verticalLineWaypoints(width / 2, 50, 260),
      ),

      // 3. Linia ukośna (w dół)
      TracingPattern(
        name: 'Ukośna w dół',
        hint: 'Linia z lewego górnego do prawego dolnego',
        path: _createDiagonalLine(margin, 60, usableWidth, 200, down: true),
        waypoints: _diagonalLineWaypoints(margin, 60, usableWidth, 200, down: true),
      ),

      // 4. Linia ukośna (w górę)
      TracingPattern(
        name: 'Ukośna w górę',
        hint: 'Linia z lewego dolnego do prawego górnego',
        path: _createDiagonalLine(margin, 260, usableWidth, 200, down: false),
        waypoints: _diagonalLineWaypoints(margin, 260, usableWidth, 200, down: false),
      ),

      // ============================================
      // FALE I ZYGZAKI
      // ============================================

      // 5. Fala (3 fale)
      TracingPattern(
        name: 'Fala',
        hint: 'Płynnie faluj w górę i w dół',
        path: _createWave(margin, centerY, usableWidth, waves: 3, amplitude: 55),
        waypoints: _waveWaypoints(margin, centerY, usableWidth, waves: 3, amplitude: 55),
      ),

      // 6. Duża fala (2 fale)
      TracingPattern(
        name: 'Duża fala',
        hint: 'Płynna, szeroka fala',
        path: _createWave(margin, centerY, usableWidth, waves: 2, amplitude: 80),
        waypoints: _waveWaypoints(margin, centerY, usableWidth, waves: 2, amplitude: 80),
      ),

      // 7. Mała fala (5 fal)
      TracingPattern(
        name: 'Mała fala',
        hint: 'Szybkie, krótkie fale',
        path: _createWave(margin, centerY, usableWidth, waves: 5, amplitude: 35),
        waypoints: _waveWaypoints(margin, centerY, usableWidth, waves: 5, amplitude: 35),
      ),

      // 8. Zygzak
      TracingPattern(
        name: 'Zygzak',
        hint: 'Ostre zakręty w górę i w dół',
        path: _createZigzag(margin, centerY, usableWidth, peaks: 4, amplitude: 55),
        waypoints: _zigzagWaypoints(margin, centerY, usableWidth, peaks: 4, amplitude: 55),
      ),

      // 9. Duży zygzak
      TracingPattern(
        name: 'Duży zygzak',
        hint: 'Głębokie, ostre zakręty',
        path: _createZigzag(margin, centerY, usableWidth, peaks: 3, amplitude: 75),
        waypoints: _zigzagWaypoints(margin, centerY, usableWidth, peaks: 3, amplitude: 75),
      ),

      // 10. Małe zęby
      TracingPattern(
        name: 'Małe zęby',
        hint: 'Ostre małe trójkąty',
        path: _createZigzag(margin, centerY, usableWidth, peaks: 6, amplitude: 35),
        waypoints: _zigzagWaypoints(margin, centerY, usableWidth, peaks: 6, amplitude: 35),
      ),

      // ============================================
      // ŁUKI I PÓŁKOLA
      // ============================================

      // 11. Łuki (górne)
      TracingPattern(
        name: 'Łuki',
        hint: 'Półkola jak mosty',
        path: _createArcs(margin, centerY + 40, usableWidth, arcs: 4, amplitude: 60, up: true),
        waypoints: _arcsWaypoints(margin, centerY + 40, usableWidth, arcs: 4, amplitude: 60, up: true),
      ),

      // 12. Odwrócone łuki (dolne)
      TracingPattern(
        name: 'Miseczki',
        hint: 'Półkola jak miseczki',
        path: _createArcs(margin, centerY - 40, usableWidth, arcs: 4, amplitude: 60, up: false),
        waypoints: _arcsWaypoints(margin, centerY - 40, usableWidth, arcs: 4, amplitude: 60, up: false),
      ),

      // 13. Duże łuki
      TracingPattern(
        name: 'Duże łuki',
        hint: 'Szerokie, płynne mosty',
        path: _createArcs(margin, centerY + 50, usableWidth, arcs: 2, amplitude: 90, up: true),
        waypoints: _arcsWaypoints(margin, centerY + 50, usableWidth, arcs: 2, amplitude: 90, up: true),
      ),

      // ============================================
      // PĘTLE I SPIRALE
      // ============================================

      // 14. Pętelki
      TracingPattern(
        name: 'Pętelki',
        hint: 'Małe kółeczka jedno za drugim',
        path: _createLoops(margin, centerY, usableWidth, loops: 4),
        waypoints: _loopsWaypoints(margin, centerY, usableWidth, loops: 4),
      ),

      // 15. Duże pętelki
      TracingPattern(
        name: 'Duże pętelki',
        hint: 'Duże, okrągłe kółka',
        path: _createLoops(margin, centerY, usableWidth, loops: 3),
        waypoints: _loopsWaypoints(margin, centerY, usableWidth, loops: 3),
      ),

      // 16. Spirala
      TracingPattern(
        name: 'Spirala',
        hint: 'Zacznij od środka i kręć na zewnątrz',
        path: _createSpiral(width / 2, centerY, 100),
        waypoints: _spiralWaypoints(width / 2, centerY, 100),
      ),

      // 17. Ósemka
      TracingPattern(
        name: 'Ósemka',
        hint: 'Narysuj leżącą ósemkę',
        path: _createFigureEight(width / 2, centerY, 75),
        waypoints: _figureEightWaypoints(width / 2, centerY, 75),
      ),

      // ============================================
      // SCHODY I KSZTAŁTY
      // ============================================

      // 18. Schody
      TracingPattern(
        name: 'Schody',
        hint: 'Rysuj stopnie schodów',
        path: _createStairs(margin, 250, usableWidth, steps: 5, stepHeight: 38),
        waypoints: _stairsWaypoints(margin, 250, usableWidth, steps: 5, stepHeight: 38),
      ),

      // 19. Schody w dół
      TracingPattern(
        name: 'Schody w dół',
        hint: 'Schodź po stopniach w dół',
        path: _createStairsDown(margin, 60, usableWidth, steps: 5, stepHeight: 38),
        waypoints: _stairsDownWaypoints(margin, 60, usableWidth, steps: 5, stepHeight: 38),
      ),

      // 20. Trójkąty
      TracingPattern(
        name: 'Trójkąty',
        hint: 'Szczyty gór jeden za drugim',
        path: _createTriangles(margin, centerY + 50, usableWidth, count: 4, height: 80),
        waypoints: _trianglesWaypoints(margin, centerY + 50, usableWidth, count: 4, height: 80),
      ),

      // 21. Kwadraty
      TracingPattern(
        name: 'Kwadraty',
        hint: 'Rysuj kwadraciki w rzędzie',
        path: _createSquares(margin, centerY, usableWidth, count: 3, size: 70),
        waypoints: _squaresWaypoints(margin, centerY, usableWidth, count: 3, size: 70),
      ),

      // 22. Romby
      TracingPattern(
        name: 'Romby',
        hint: 'Rysuj romby jeden za drugim',
        path: _createDiamonds(margin, centerY, usableWidth, count: 3, size: 70),
        waypoints: _diamondsWaypoints(margin, centerY, usableWidth, count: 3, size: 70),
      ),

      // ============================================
      // LITEROPODOBNE WZORY
      // ============================================

      // 23. Wzór U-U-U
      TracingPattern(
        name: 'Wzór U',
        hint: 'Literki U jedna za drugą',
        path: _createUPattern(margin, centerY - 40, usableWidth, count: 4, height: 70),
        waypoints: _uPatternWaypoints(margin, centerY - 40, usableWidth, count: 4, height: 70),
      ),

      // 24. Wzór M-M-M
      TracingPattern(
        name: 'Wzór M',
        hint: 'Literki M jedna za drugą',
        path: _createMPattern(margin, centerY + 40, usableWidth, count: 3, height: 70),
        waypoints: _mPatternWaypoints(margin, centerY + 40, usableWidth, count: 3, height: 70),
      ),

      // 25. Chmurki
      TracingPattern(
        name: 'Chmurki',
        hint: 'Puchate chmurki w rzędzie',
        path: _createClouds(margin, centerY, usableWidth, count: 3),
        waypoints: _cloudsWaypoints(margin, centerY, usableWidth, count: 3),
      ),
    ];
  }

  // ============================================
  // GENERATORY ŚCIEŻEK (Path)
  // ============================================

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

  /// Linia ukośna
  Path _createDiagonalLine(double startX, double startY, double width, double height, {bool down = true}) {
    return Path()
      ..moveTo(startX, startY)
      ..lineTo(startX + width, down ? startY + height : startY - height);
  }

  /// Fala sinusoidalna
  Path _createWave(double startX, double centerY, double width,
      {int waves = 3, double amplitude = 55}) {
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
      {int peaks = 4, double amplitude = 55}) {
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

  /// Łuki (półkola)
  Path _createArcs(double startX, double baseY, double width,
      {int arcs = 4, double amplitude = 60, bool up = true}) {
    final path = Path();
    final arcWidth = width / arcs;

    path.moveTo(startX, baseY);

    for (int i = 0; i < arcs; i++) {
      final x1 = startX + i * arcWidth;
      final x2 = startX + (i + 0.5) * arcWidth;
      final x3 = startX + (i + 1) * arcWidth;
      final peakY = up ? baseY - amplitude : baseY + amplitude;

      path.quadraticBezierTo(x2, peakY, x3, baseY);
    }

    return path;
  }

  /// Pętelki (małe koła)
  Path _createLoops(double startX, double centerY, double width, {int loops = 4}) {
    final path = Path();
    final loopWidth = width / loops;
    final radius = loopWidth / 2 * 0.7;

    path.moveTo(startX, centerY);

    for (int i = 0; i < loops; i++) {
      final cx = startX + i * loopWidth + loopWidth / 2;

      path.addOval(Rect.fromCircle(
        center: Offset(cx, centerY),
        radius: radius,
      ));

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

  /// Schody (w górę)
  Path _createStairs(double startX, double startY, double width,
      {int steps = 5, double stepHeight = 38}) {
    final path = Path();
    final stepWidth = width / steps;

    path.moveTo(startX, startY);

    for (int i = 0; i < steps; i++) {
      path.lineTo(startX + (i + 1) * stepWidth, startY - i * stepHeight);
      if (i < steps - 1) {
        path.lineTo(startX + (i + 1) * stepWidth, startY - (i + 1) * stepHeight);
      }
    }

    return path;
  }

  /// Schody (w dół)
  Path _createStairsDown(double startX, double startY, double width,
      {int steps = 5, double stepHeight = 38}) {
    final path = Path();
    final stepWidth = width / steps;

    path.moveTo(startX, startY);

    for (int i = 0; i < steps; i++) {
      path.lineTo(startX + (i + 1) * stepWidth, startY + i * stepHeight);
      if (i < steps - 1) {
        path.lineTo(startX + (i + 1) * stepWidth, startY + (i + 1) * stepHeight);
      }
    }

    return path;
  }

  /// Ósemka (leżąca)
  Path _createFigureEight(double cx, double cy, double radius) {
    final path = Path();
    const steps = 100;

    for (int i = 0; i <= steps; i++) {
      final t = i / steps * 2 * pi;
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

  /// Trójkąty
  Path _createTriangles(double startX, double baseY, double width,
      {int count = 4, double height = 80}) {
    final path = Path();
    final triWidth = width / count;

    path.moveTo(startX, baseY);

    for (int i = 0; i < count; i++) {
      final peakX = startX + (i + 0.5) * triWidth;
      final endX = startX + (i + 1) * triWidth;

      path.lineTo(peakX, baseY - height);
      path.lineTo(endX, baseY);
    }

    return path;
  }

  /// Kwadraty
  Path _createSquares(double startX, double centerY, double width,
      {int count = 3, double size = 70}) {
    final path = Path();
    final spacing = (width - count * size) / (count + 1);
    final halfSize = size / 2;

    for (int i = 0; i < count; i++) {
      final cx = startX + spacing * (i + 1) + size * i + halfSize;

      path.moveTo(cx - halfSize, centerY - halfSize);
      path.lineTo(cx + halfSize, centerY - halfSize);
      path.lineTo(cx + halfSize, centerY + halfSize);
      path.lineTo(cx - halfSize, centerY + halfSize);
      path.close();
    }

    return path;
  }

  /// Romby
  Path _createDiamonds(double startX, double centerY, double width,
      {int count = 3, double size = 70}) {
    final path = Path();
    final spacing = (width - count * size) / (count + 1);
    final halfSize = size / 2;

    for (int i = 0; i < count; i++) {
      final cx = startX + spacing * (i + 1) + size * i + halfSize;

      path.moveTo(cx, centerY - halfSize);
      path.lineTo(cx + halfSize, centerY);
      path.lineTo(cx, centerY + halfSize);
      path.lineTo(cx - halfSize, centerY);
      path.close();
    }

    return path;
  }

  /// Wzór U-U-U
  Path _createUPattern(double startX, double topY, double width,
      {int count = 4, double height = 70}) {
    final path = Path();
    final uWidth = width / count;

    path.moveTo(startX, topY);

    for (int i = 0; i < count; i++) {
      final x1 = startX + i * uWidth;
      final x2 = startX + (i + 0.5) * uWidth;
      final x3 = startX + (i + 1) * uWidth;
      final bottomY = topY + height;

      path.lineTo(x1, bottomY);
      path.quadraticBezierTo(x2, bottomY + 20, x3, bottomY);
      path.lineTo(x3, topY);
    }

    return path;
  }

  /// Wzór M-M-M
  Path _createMPattern(double startX, double bottomY, double width,
      {int count = 3, double height = 70}) {
    final path = Path();
    final mWidth = width / count;

    path.moveTo(startX, bottomY);

    for (int i = 0; i < count; i++) {
      final x1 = startX + i * mWidth;
      final x2 = startX + (i + 0.25) * mWidth;
      final x3 = startX + (i + 0.5) * mWidth;
      final x4 = startX + (i + 0.75) * mWidth;
      final x5 = startX + (i + 1) * mWidth;
      final topY = bottomY - height;

      path.lineTo(x1, topY);
      path.lineTo(x2, topY + height * 0.4);
      path.lineTo(x3, topY);
      path.lineTo(x4, topY + height * 0.4);
      path.lineTo(x5, topY);
      path.lineTo(x5, bottomY);
    }

    return path;
  }

  /// Chmurki
  Path _createClouds(double startX, double centerY, double width, {int count = 3}) {
    final path = Path();
    final cloudWidth = width / count;
    final radius = cloudWidth * 0.25;

    for (int i = 0; i < count; i++) {
      final cx = startX + (i + 0.5) * cloudWidth;

      // Trzy nakładające się kółka tworzą chmurkę
      path.addOval(Rect.fromCircle(center: Offset(cx - radius * 0.8, centerY), radius: radius * 0.9));
      path.addOval(Rect.fromCircle(center: Offset(cx, centerY - radius * 0.3), radius: radius));
      path.addOval(Rect.fromCircle(center: Offset(cx + radius * 0.8, centerY), radius: radius * 0.9));
    }

    return path;
  }

  // ============================================
  // GENERATORY WAYPOINTÓW
  // ============================================

  /// Waypoints dla linii prostej
  List<Waypoint> _straightLineWaypoints(double startX, double y, double width) {
    const count = 6;
    return List.generate(count, (i) {
      final x = startX + (i / (count - 1)) * width;
      return Waypoint.pixels(x, y, isStartPoint: i == 0, isEndPoint: i == count - 1);
    });
  }

  /// Waypoints dla linii pionowej
  List<Waypoint> _verticalLineWaypoints(double x, double startY, double height) {
    const count = 6;
    return List.generate(count, (i) {
      final y = startY + (i / (count - 1)) * height;
      return Waypoint.pixels(x, y, isStartPoint: i == 0, isEndPoint: i == count - 1);
    });
  }

  /// Waypoints dla linii ukośnej
  List<Waypoint> _diagonalLineWaypoints(double startX, double startY, double width, double height, {bool down = true}) {
    const count = 6;
    return List.generate(count, (i) {
      final t = i / (count - 1);
      final x = startX + t * width;
      final y = down ? startY + t * height : startY - t * height;
      return Waypoint.pixels(x, y, isStartPoint: i == 0, isEndPoint: i == count - 1);
    });
  }

  /// Waypoints dla fali
  List<Waypoint> _waveWaypoints(double startX, double centerY, double width,
      {int waves = 3, double amplitude = 55}) {
    final waypoints = <Waypoint>[];
    final waveWidth = width / waves;
    const double amplitudeFactor = 0.55;
    const double peakXFactor = 0.30;
    const double valleyXFactor = 0.70;

    waypoints.add(Waypoint.pixels(startX, centerY, isStartPoint: true));

    for (int i = 0; i < waves; i++) {
      final peakX = startX + i * waveWidth + waveWidth * peakXFactor;
      final peakY = centerY - amplitude * amplitudeFactor;
      waypoints.add(Waypoint.pixels(peakX, peakY));

      final valleyX = startX + i * waveWidth + waveWidth * valleyXFactor;
      final valleyY = centerY + amplitude * amplitudeFactor;
      waypoints.add(Waypoint.pixels(valleyX, valleyY));
    }

    waypoints.add(Waypoint.pixels(startX + width, centerY, isEndPoint: true));
    return waypoints;
  }

  /// Waypoints dla zygzaka
  List<Waypoint> _zigzagWaypoints(double startX, double centerY, double width,
      {int peaks = 4, double amplitude = 55}) {
    final waypoints = <Waypoint>[];
    final segmentWidth = width / (peaks * 2);

    waypoints.add(Waypoint.pixels(startX, centerY, isStartPoint: true));

    for (int i = 0; i < peaks * 2; i++) {
      final x = startX + (i + 1) * segmentWidth;
      final y = i.isEven ? centerY - amplitude : centerY + amplitude;
      waypoints.add(Waypoint.pixels(x, y, isEndPoint: i == peaks * 2 - 1));
    }

    return waypoints;
  }

  /// Waypoints dla łuków
  List<Waypoint> _arcsWaypoints(double startX, double baseY, double width,
      {int arcs = 4, double amplitude = 60, bool up = true}) {
    final waypoints = <Waypoint>[];
    final arcWidth = width / arcs;

    waypoints.add(Waypoint.pixels(startX, baseY, isStartPoint: true));

    for (int i = 0; i < arcs; i++) {
      final peakX = startX + (i + 0.5) * arcWidth;
      final peakY = up ? baseY - amplitude : baseY + amplitude;
      waypoints.add(Waypoint.pixels(peakX, peakY));

      final endX = startX + (i + 1) * arcWidth;
      waypoints.add(Waypoint.pixels(endX, baseY, isEndPoint: i == arcs - 1));
    }

    return waypoints;
  }

  /// Waypoints dla pętelek
  List<Waypoint> _loopsWaypoints(double startX, double centerY, double width, {int loops = 4}) {
    final waypoints = <Waypoint>[];
    final loopWidth = width / loops;
    final radius = loopWidth / 2 * 0.7;
    const int pointsPerLoop = 6;

    for (int loopIndex = 0; loopIndex < loops; loopIndex++) {
      final cx = startX + loopIndex * loopWidth + loopWidth / 2;

      for (int i = 0; i < pointsPerLoop; i++) {
        final angle = -pi / 2 + (i / pointsPerLoop) * 2 * pi;
        final x = cx + cos(angle) * radius;
        final y = centerY + sin(angle) * radius;

        final isFirst = loopIndex == 0 && i == 0;
        final isLast = loopIndex == loops - 1 && i == pointsPerLoop - 1;

        waypoints.add(Waypoint.pixels(x, y, isStartPoint: isFirst, isEndPoint: isLast));
      }
    }

    return waypoints;
  }

  /// Waypoints dla spirali
  List<Waypoint> _spiralWaypoints(double cx, double cy, double maxRadius) {
    final waypoints = <Waypoint>[];
    const int turns = 3;
    const int pointsPerTurn = 8;
    final int totalPoints = turns * pointsPerTurn + 1;

    for (int i = 0; i <= totalPoints - 1; i++) {
      final t = i / (totalPoints - 1);
      final angle = t * turns * 2 * pi;
      final radius = t * maxRadius;

      final x = cx + cos(angle) * radius;
      final y = cy + sin(angle) * radius;

      waypoints.add(Waypoint.pixels(x, y, isStartPoint: i == 0, isEndPoint: i == totalPoints - 1));
    }

    return waypoints;
  }

  /// Waypoints dla schodów (w górę)
  List<Waypoint> _stairsWaypoints(double startX, double startY, double width,
      {int steps = 5, double stepHeight = 38}) {
    final waypoints = <Waypoint>[];
    final stepWidth = width / steps;

    waypoints.add(Waypoint.pixels(startX, startY, isStartPoint: true));

    for (int i = 0; i < steps; i++) {
      final x = startX + (i + 1) * stepWidth;
      final y = startY - i * stepHeight;
      waypoints.add(Waypoint.pixels(x, y));

      if (i < steps - 1) {
        waypoints.add(Waypoint.pixels(x, startY - (i + 1) * stepHeight));
      }
    }

    waypoints.last = Waypoint.pixels(waypoints.last.x, waypoints.last.y, isEndPoint: true);
    return waypoints;
  }

  /// Waypoints dla schodów (w dół)
  List<Waypoint> _stairsDownWaypoints(double startX, double startY, double width,
      {int steps = 5, double stepHeight = 38}) {
    final waypoints = <Waypoint>[];
    final stepWidth = width / steps;

    waypoints.add(Waypoint.pixels(startX, startY, isStartPoint: true));

    for (int i = 0; i < steps; i++) {
      final x = startX + (i + 1) * stepWidth;
      final y = startY + i * stepHeight;
      waypoints.add(Waypoint.pixels(x, y));

      if (i < steps - 1) {
        waypoints.add(Waypoint.pixels(x, startY + (i + 1) * stepHeight));
      }
    }

    waypoints.last = Waypoint.pixels(waypoints.last.x, waypoints.last.y, isEndPoint: true);
    return waypoints;
  }

  /// Waypoints dla ósemki
  List<Waypoint> _figureEightWaypoints(double cx, double cy, double radius) {
    final waypoints = <Waypoint>[];
    final radiusX = radius * 1.5;
    final radiusY = radius / 2;
    const int totalPoints = 12;

    for (int i = 0; i < totalPoints; i++) {
      final t = i / totalPoints * 2 * pi;
      final x = cx + radiusX * cos(t);
      final y = cy + radiusY * sin(2 * t);

      waypoints.add(Waypoint.pixels(x, y, isStartPoint: i == 0));
    }

    waypoints.add(Waypoint.pixels(cx + radiusX, cy, isEndPoint: true));
    return waypoints;
  }

  /// Waypoints dla trójkątów
  List<Waypoint> _trianglesWaypoints(double startX, double baseY, double width,
      {int count = 4, double height = 80}) {
    final waypoints = <Waypoint>[];
    final triWidth = width / count;

    waypoints.add(Waypoint.pixels(startX, baseY, isStartPoint: true));

    for (int i = 0; i < count; i++) {
      final peakX = startX + (i + 0.5) * triWidth;
      final endX = startX + (i + 1) * triWidth;

      waypoints.add(Waypoint.pixels(peakX, baseY - height));
      waypoints.add(Waypoint.pixels(endX, baseY, isEndPoint: i == count - 1));
    }

    return waypoints;
  }

  /// Waypoints dla kwadratów
  List<Waypoint> _squaresWaypoints(double startX, double centerY, double width,
      {int count = 3, double size = 70}) {
    final waypoints = <Waypoint>[];
    final spacing = (width - count * size) / (count + 1);
    final halfSize = size / 2;

    for (int i = 0; i < count; i++) {
      final cx = startX + spacing * (i + 1) + size * i + halfSize;
      final isFirst = i == 0;
      final isLast = i == count - 1;

      waypoints.add(Waypoint.pixels(cx - halfSize, centerY - halfSize, isStartPoint: isFirst));
      waypoints.add(Waypoint.pixels(cx + halfSize, centerY - halfSize));
      waypoints.add(Waypoint.pixels(cx + halfSize, centerY + halfSize));
      waypoints.add(Waypoint.pixels(cx - halfSize, centerY + halfSize, isEndPoint: isLast));
    }

    return waypoints;
  }

  /// Waypoints dla rombów
  List<Waypoint> _diamondsWaypoints(double startX, double centerY, double width,
      {int count = 3, double size = 70}) {
    final waypoints = <Waypoint>[];
    final spacing = (width - count * size) / (count + 1);
    final halfSize = size / 2;

    for (int i = 0; i < count; i++) {
      final cx = startX + spacing * (i + 1) + size * i + halfSize;
      final isFirst = i == 0;
      final isLast = i == count - 1;

      waypoints.add(Waypoint.pixels(cx, centerY - halfSize, isStartPoint: isFirst));
      waypoints.add(Waypoint.pixels(cx + halfSize, centerY));
      waypoints.add(Waypoint.pixels(cx, centerY + halfSize));
      waypoints.add(Waypoint.pixels(cx - halfSize, centerY, isEndPoint: isLast));
    }

    return waypoints;
  }

  /// Waypoints dla wzoru U
  List<Waypoint> _uPatternWaypoints(double startX, double topY, double width,
      {int count = 4, double height = 70}) {
    final waypoints = <Waypoint>[];
    final uWidth = width / count;
    final bottomY = topY + height;

    waypoints.add(Waypoint.pixels(startX, topY, isStartPoint: true));

    for (int i = 0; i < count; i++) {
      final x1 = startX + i * uWidth;
      final x2 = startX + (i + 0.5) * uWidth;
      final x3 = startX + (i + 1) * uWidth;

      waypoints.add(Waypoint.pixels(x1, bottomY));
      waypoints.add(Waypoint.pixels(x2, bottomY + 15));
      waypoints.add(Waypoint.pixels(x3, bottomY));
      waypoints.add(Waypoint.pixels(x3, topY, isEndPoint: i == count - 1));
    }

    return waypoints;
  }

  /// Waypoints dla wzoru M
  List<Waypoint> _mPatternWaypoints(double startX, double bottomY, double width,
      {int count = 3, double height = 70}) {
    final waypoints = <Waypoint>[];
    final mWidth = width / count;
    final topY = bottomY - height;

    waypoints.add(Waypoint.pixels(startX, bottomY, isStartPoint: true));

    for (int i = 0; i < count; i++) {
      final x1 = startX + i * mWidth;
      final x3 = startX + (i + 0.5) * mWidth;
      final x5 = startX + (i + 1) * mWidth;

      waypoints.add(Waypoint.pixels(x1, topY));
      waypoints.add(Waypoint.pixels(x3, topY + height * 0.4));
      waypoints.add(Waypoint.pixels(x5, topY));
      waypoints.add(Waypoint.pixels(x5, bottomY, isEndPoint: i == count - 1));
    }

    return waypoints;
  }

  /// Waypoints dla chmurek
  List<Waypoint> _cloudsWaypoints(double startX, double centerY, double width, {int count = 3}) {
    final waypoints = <Waypoint>[];
    final cloudWidth = width / count;
    final radius = cloudWidth * 0.25;

    for (int i = 0; i < count; i++) {
      final cx = startX + (i + 0.5) * cloudWidth;
      final isFirst = i == 0;
      final isLast = i == count - 1;

      // Lewa część chmurki
      waypoints.add(Waypoint.pixels(cx - radius * 1.5, centerY, isStartPoint: isFirst));
      // Góra chmurki
      waypoints.add(Waypoint.pixels(cx, centerY - radius * 0.8));
      // Prawa część chmurki
      waypoints.add(Waypoint.pixels(cx + radius * 1.5, centerY, isEndPoint: isLast));
    }

    return waypoints;
  }
}
