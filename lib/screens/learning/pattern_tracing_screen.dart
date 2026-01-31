import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/tracing_path.dart';
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
      rewardType: 'patterns',
      enableRewards: true,
    );
  }

  List<TracingPattern> _createPatterns(double width) {
    final centerY = 150.0; // Srodek w pionie
    final margin = 40.0;
    final usableWidth = width - margin * 2;

    return [
      // 1. Linia prosta pozioma - z waypointami
      TracingPattern(
        name: 'Linia prosta',
        hint: 'Narysuj prostą linię od lewej do prawej',
        path: _createStraightLine(margin, centerY, usableWidth),
        waypoints: _straightLineWaypoints(margin, centerY, usableWidth),
      ),

      // 2. Fala - z waypointami
      TracingPattern(
        name: 'Fala',
        hint: 'Płynnie faluj w górę i w dół',
        path: _createWave(margin, centerY, usableWidth, waves: 3),
        waypoints: _waveWaypoints(margin, centerY, usableWidth, waves: 3),
      ),

      // 3. Zygzak - z waypointami
      TracingPattern(
        name: 'Zygzak',
        hint: 'Ostre zakręty w górę i w dół',
        path: _createZigzag(margin, centerY, usableWidth, peaks: 4),
        waypoints: _zigzagWaypoints(margin, centerY, usableWidth, peaks: 4),
      ),

      // 4. Pętelki - z waypointami
      TracingPattern(
        name: 'Pętelki',
        hint: 'Małe kółeczka jedno za drugim',
        path: _createLoops(margin, centerY, usableWidth, loops: 4),
        waypoints: _loopsWaypoints(margin, centerY, usableWidth, loops: 4),
      ),

      // 5. Linia pionowa - z waypointami
      TracingPattern(
        name: 'Linia pionowa',
        hint: 'Prosta linia z góry na dół',
        path: _createVerticalLine(width / 2, 60, 240),
        waypoints: _verticalLineWaypoints(width / 2, 60, 240),
      ),

      // 6. Spirala - z waypointami
      TracingPattern(
        name: 'Spirala',
        hint: 'Zacznij od środka i kręć na zewnątrz',
        path: _createSpiral(width / 2, centerY, 80),
        waypoints: _spiralWaypoints(width / 2, centerY, 80),
      ),

      // 7. Schody - z waypointami
      TracingPattern(
        name: 'Schody',
        hint: 'Rysuj stopnie schodów',
        path: _createStairs(margin, 220, usableWidth, steps: 5),
        waypoints: _stairsWaypoints(margin, 220, usableWidth, steps: 5),
      ),

      // 8. Duża fala - z waypointami
      TracingPattern(
        name: 'Duża fala',
        hint: 'Płynna, szeroka fala',
        path: _createWave(margin, centerY, usableWidth, waves: 2, amplitude: 60),
        waypoints: _waveWaypoints(margin, centerY, usableWidth, waves: 2, amplitude: 60),
      ),

      // 9. Małe zęby - z waypointami
      TracingPattern(
        name: 'Małe zęby',
        hint: 'Ostre małe trójkąty',
        path: _createZigzag(margin, centerY, usableWidth, peaks: 8, amplitude: 25),
        waypoints: _zigzagWaypoints(margin, centerY, usableWidth, peaks: 8, amplitude: 25),
      ),

      // 10. Ósemka - z waypointami
      TracingPattern(
        name: 'Ósemka',
        hint: 'Narysuj leżącą ósemkę',
        path: _createFigureEight(width / 2, centerY, 60),
        waypoints: _figureEightWaypoints(width / 2, centerY, 60),
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

  // ============================================
  // WAYPOINTS DLA SZLACZKÓW
  // Waypoints w pikselach (absolutne, dopasowane do Path)
  // ============================================

  /// Waypoints dla linii prostej
  List<Waypoint> _straightLineWaypoints(double startX, double y, double width) {
    const count = 5;
    return List.generate(count, (i) {
      final x = startX + (i / (count - 1)) * width;
      return Waypoint.pixels(
        x, y,
        isStartPoint: i == 0,
        isEndPoint: i == count - 1,
      );
    });
  }

  /// Waypoints dla linii pionowej
  List<Waypoint> _verticalLineWaypoints(double x, double startY, double height) {
    const count = 5;
    return List.generate(count, (i) {
      final y = startY + (i / (count - 1)) * height;
      return Waypoint.pixels(
        x, y,
        isStartPoint: i == 0,
        isEndPoint: i == count - 1,
      );
    });
  }

  /// Waypoints dla fali
  /// UWAGA: Krzywa Beziera (cubicTo) ma punkty kontrolne, nie punkty NA krzywej.
  /// Rzeczywista amplituda krzywej to ~55% amplitudy punktów kontrolnych.
  /// Pozycje X szczytów/dołków są przesunięte względem punktów kontrolnych.
  List<Waypoint> _waveWaypoints(double startX, double centerY, double width,
      {int waves = 3, double amplitude = 40}) {
    final waypoints = <Waypoint>[];
    final waveWidth = width / waves;

    // Współczynnik korekcji dla krzywej Beziera:
    // - Rzeczywista amplituda ≈ 55% amplitudy punktów kontrolnych
    // - Pozycje X szczytów są przesunięte (0.30 zamiast 0.25, 0.70 zamiast 0.75)
    const double amplitudeFactor = 0.55;
    const double peakXFactor = 0.30;   // gdzie faktycznie jest szczyt
    const double valleyXFactor = 0.70; // gdzie faktycznie jest dołek

    // Punkt startowy
    waypoints.add(Waypoint.pixels(startX, centerY, isStartPoint: true));

    for (int i = 0; i < waves; i++) {
      // Szczyt fali (góra) - skorygowane współrzędne
      final peakX = startX + i * waveWidth + waveWidth * peakXFactor;
      final peakY = centerY - amplitude * amplitudeFactor;
      waypoints.add(Waypoint.pixels(peakX, peakY));

      // Dołek fali - skorygowane współrzędne
      final valleyX = startX + i * waveWidth + waveWidth * valleyXFactor;
      final valleyY = centerY + amplitude * amplitudeFactor;
      waypoints.add(Waypoint.pixels(valleyX, valleyY));
    }

    // Punkt końcowy
    waypoints.add(Waypoint.pixels(
      startX + width, centerY,
      isEndPoint: true,
    ));

    return waypoints;
  }

  /// Waypoints dla zygzaka
  List<Waypoint> _zigzagWaypoints(double startX, double centerY, double width,
      {int peaks = 4, double amplitude = 40}) {
    final waypoints = <Waypoint>[];
    final segmentWidth = width / (peaks * 2);

    waypoints.add(Waypoint.pixels(startX, centerY, isStartPoint: true));

    for (int i = 0; i < peaks * 2; i++) {
      final x = startX + (i + 1) * segmentWidth;
      final y = i.isEven ? centerY - amplitude : centerY + amplitude;
      waypoints.add(Waypoint.pixels(
        x, y,
        isEndPoint: i == peaks * 2 - 1,
      ));
    }

    return waypoints;
  }

  /// Waypoints dla schodów
  List<Waypoint> _stairsWaypoints(double startX, double startY, double width,
      {int steps = 5}) {
    final waypoints = <Waypoint>[];
    final stepWidth = width / steps;
    const stepHeight = 30.0;

    waypoints.add(Waypoint.pixels(startX, startY, isStartPoint: true));

    for (int i = 0; i < steps; i++) {
      // Koniec stopnia (poziomy)
      final x = startX + (i + 1) * stepWidth;
      final y = startY - i * stepHeight;
      waypoints.add(Waypoint.pixels(x, y));

      // Początek następnego stopnia (pionowy)
      if (i < steps - 1) {
        waypoints.add(Waypoint.pixels(x, startY - (i + 1) * stepHeight));
      }
    }

    waypoints.last = Waypoint.pixels(
      waypoints.last.x, waypoints.last.y,
      isEndPoint: true,
    );

    return waypoints;
  }

  /// Waypoints dla pętelek (kółek)
  /// Każde kółko ma 6 punktów (co 60°) dla płynnego śledzenia.
  List<Waypoint> _loopsWaypoints(double startX, double centerY, double width,
      {int loops = 4}) {
    final waypoints = <Waypoint>[];
    final loopWidth = width / loops;
    final radius = loopWidth / 2 * 0.7;  // Ten sam współczynnik co w _createLoops
    const int pointsPerLoop = 6;  // Punkty co 60°

    for (int loopIndex = 0; loopIndex < loops; loopIndex++) {
      final cx = startX + loopIndex * loopWidth + loopWidth / 2;

      // Punkty na okręgu (zaczynamy od góry i idziemy zgodnie z ruchem wskazówek)
      for (int i = 0; i < pointsPerLoop; i++) {
        // Kąt: zaczynamy od -π/2 (góra) i idziemy w prawo
        final angle = -pi / 2 + (i / pointsPerLoop) * 2 * pi;
        final x = cx + cos(angle) * radius;
        final y = centerY + sin(angle) * radius;

        final isFirst = loopIndex == 0 && i == 0;
        final isLast = loopIndex == loops - 1 && i == pointsPerLoop - 1;

        waypoints.add(Waypoint.pixels(
          x, y,
          isStartPoint: isFirst,
          isEndPoint: isLast,
        ));
      }
    }

    return waypoints;
  }

  /// Waypoints dla spirali
  /// Spirala idzie od środka (radius=0) do zewnątrz (maxRadius) przez 3 obroty.
  /// Gęsta sieć punktów co ~45° dla płynnego śledzenia.
  List<Waypoint> _spiralWaypoints(double cx, double cy, double maxRadius) {
    final waypoints = <Waypoint>[];
    const int turns = 3;          // Liczba obrotów (jak w _createSpiral)
    const int pointsPerTurn = 8;  // Punkty co 45°
    final int totalPoints = turns * pointsPerTurn + 1;

    for (int i = 0; i <= totalPoints - 1; i++) {
      final t = i / (totalPoints - 1);
      final angle = t * turns * 2 * pi;
      final radius = t * maxRadius;

      final x = cx + cos(angle) * radius;
      final y = cy + sin(angle) * radius;

      waypoints.add(Waypoint.pixels(
        x, y,
        isStartPoint: i == 0,
        isEndPoint: i == totalPoints - 1,
      ));
    }

    return waypoints;
  }

  /// Waypoints dla ósemki (leżącej, lemniskaty)
  /// Równanie parametryczne: x = cx + r*1.5*cos(t), y = cy + r*sin(2t)/2
  /// Kluczowe punkty: prawa strona → góra → środek → góra lewa → lewa strona
  ///                  → dół lewa → środek → dół prawa → powrót
  List<Waypoint> _figureEightWaypoints(double cx, double cy, double radius) {
    final waypoints = <Waypoint>[];

    // Współczynniki z _createFigureEight
    final radiusX = radius * 1.5;  // Rozciągnięcie w poziomie
    final radiusY = radius / 2;     // Amplituda w pionie

    // 12 punktów równomiernie rozłożonych na ósemce (co 30°)
    const int totalPoints = 12;

    for (int i = 0; i < totalPoints; i++) {
      final t = i / totalPoints * 2 * pi;

      final x = cx + radiusX * cos(t);
      final y = cy + radiusY * sin(2 * t);

      waypoints.add(Waypoint.pixels(
        x, y,
        isStartPoint: i == 0,
      ));
    }

    // Punkt końcowy = punkt startowy (zamknięta pętla)
    // Dodaj punkt końcowy blisko startu
    waypoints.add(Waypoint.pixels(
      cx + radiusX, cy,  // t=2π → ten sam punkt co t=0
      isEndPoint: true,
    ));

    return waypoints;
  }
}
