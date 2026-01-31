import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/tracing_path.dart';
import '../services/sound_effects_controller.dart';
import '../theme/app_theme.dart';

// ============================================
// SYSTEM CZĄSTECZEK (Particle System)
// ============================================

/// Pojedyncza cząsteczka w eksplozji
class _Particle {
  Offset position;
  Offset velocity;
  Color color;
  double opacity;
  double size;
  double lifetime;
  double age;

  _Particle({
    required this.position,
    required this.velocity,
    required this.color,
    this.opacity = 1.0,
    this.size = 8.0,
    this.lifetime = 0.8,
    this.age = 0.0,
  });

  /// Aktualizuje stan cząsteczki
  /// Zwraca true jeśli cząsteczka nadal żyje
  bool update(double dt) {
    age += dt;
    if (age >= lifetime) return false;

    // Ruch
    position = position + velocity * dt;

    // Spowolnienie (friction)
    velocity = velocity * 0.95;

    // Fade out
    opacity = 1.0 - (age / lifetime);

    // Zmniejszanie rozmiaru
    size = size * (1.0 - age / lifetime * 0.5);

    return true;
  }

  /// Czy cząsteczka jeszcze żyje
  bool get isAlive => age < lifetime;
}

/// Menedżer cząsteczek - zarządza wszystkimi aktywnymi cząsteczkami
class _ParticleManager {
  final List<_Particle> _particles = [];
  final math.Random _random = math.Random();

  /// Paleta kolorów dla cząsteczek (kolory aplikacji)
  static final List<Color> _colors = [
    AppTheme.primaryColor,      // Zielony
    AppTheme.accentColor,       // Pomarańczowy
    AppTheme.yellowColor,       // Żółty
    AppTheme.purpleColor,       // Fioletowy
    Colors.pink,                // Różowy
    Colors.cyan,                // Cyjan
  ];

  /// Paleta kolorów dla trail (subtelniejsze, pastelowe)
  static final List<Color> _trailColors = [
    const Color(0xFFFFD54F),  // Złoty
    const Color(0xFF4FC3F7),  // Jasny niebieski
    const Color(0xFFBA68C8),  // Jasny fiolet
    const Color(0xFF81C784),  // Jasny zielony
    const Color(0xFFFFAB91),  // Łososiowy
  ];

  /// Generuje eksplozję cząsteczek w danym punkcie
  void explodeAt(Offset position, {int count = 8}) {
    for (int i = 0; i < count; i++) {
      // Losowy kąt i prędkość
      final angle = _random.nextDouble() * 2 * math.pi;
      final speed = 80 + _random.nextDouble() * 120; // 80-200 px/s

      final velocity = Offset(
        math.cos(angle) * speed,
        math.sin(angle) * speed,
      );

      // Losowy kolor z palety
      final color = _colors[_random.nextInt(_colors.length)];

      // Losowy rozmiar
      final size = 6.0 + _random.nextDouble() * 6.0; // 6-12 px

      _particles.add(_Particle(
        position: position,
        velocity: velocity,
        color: color,
        size: size,
        lifetime: 0.6 + _random.nextDouble() * 0.4, // 0.6-1.0s
      ));
    }
  }

  /// SPARKLING TRAIL: Generuje pojedynczą iskierkę śladu za palcem
  /// Mniejsza, krótsza żywotność, delikatniejszy ruch
  void addTrailSparkle(Offset position) {
    // Losowy kąt (bardziej w górę/boki, mniej w dół)
    final angle = -math.pi / 2 + (_random.nextDouble() - 0.5) * math.pi;
    final speed = 20 + _random.nextDouble() * 40; // 20-60 px/s (wolniej)

    final velocity = Offset(
      math.cos(angle) * speed,
      math.sin(angle) * speed,
    );

    // Losowy kolor z palety trail
    final color = _trailColors[_random.nextInt(_trailColors.length)];

    // Mały rozmiar (iskierka)
    final size = 3.0 + _random.nextDouble() * 4.0; // 3-7 px

    _particles.add(_Particle(
      position: position + Offset(
        (_random.nextDouble() - 0.5) * 10, // Lekki offset od palca
        (_random.nextDouble() - 0.5) * 10,
      ),
      velocity: velocity,
      color: color,
      size: size,
      lifetime: 0.3 + _random.nextDouble() * 0.3, // 0.3-0.6s (krótko)
    ));
  }

  /// Aktualizuje wszystkie cząsteczki
  void update(double dt) {
    _particles.removeWhere((p) => !p.update(dt));
  }

  /// Czy są aktywne cząsteczki
  bool get hasParticles => _particles.isNotEmpty;

  /// Lista aktywnych cząsteczek (do renderowania)
  List<_Particle> get particles => _particles;

  /// Czyści wszystkie cząsteczki
  void clear() => _particles.clear();
}

/// Punkt na sciezce do rysowania
class TracingPoint {
  final Offset position;
  final bool isBreak; // Czy to przerwa w linii (podniesienie palca)

  const TracingPoint(this.position, {this.isBreak = false});
}

/// Wzor/sciezka do odrysowania
class TracingPattern {
  final String name;
  final Path path;
  final String? hint; // Podpowiedz dla dziecka
  final Offset? _explicitEndPoint; // Ręcznie ustawiony punkt końcowy
  final List<Waypoint>? waypoints; // Opcjonalne waypoints do walidacji sekwencyjnej
  final bool showWaypoints; // Czy pokazywać waypoints na ekranie

  const TracingPattern({
    required this.name,
    required this.path,
    this.hint,
    Offset? endPoint,
    this.waypoints,
    this.showWaypoints = false, // Domyślnie ukryte
  }) : _explicitEndPoint = endPoint;

  /// FINISH LINE: Punkt końcowy do weryfikacji
  /// Jeśli nie ustawiono ręcznie - automatycznie oblicza jako punkt
  /// najbardziej wysunięty w prawo (przy remisie - najniżej/na dół)
  Offset? get endPoint {
    if (_explicitEndPoint != null) return _explicitEndPoint;
    return _calculateEndPointFromPath();
  }

  /// Oblicza punkt końcowy z path - najbardziej w prawo, potem na dół
  Offset? _calculateEndPointFromPath() {
    final pathMetrics = path.computeMetrics();
    Offset? bestPoint;

    for (final metric in pathMetrics) {
      double distance = 0;
      while (distance <= metric.length) {
        final tangent = metric.getTangentForOffset(distance);
        if (tangent != null) {
          final point = tangent.position;
          if (bestPoint == null) {
            bestPoint = point;
          } else {
            // Priorytet: najbardziej w prawo, przy remisie - najniżej
            if (point.dx > bestPoint.dx ||
                (point.dx == bestPoint.dx && point.dy > bestPoint.dy)) {
              bestPoint = point;
            }
          }
        }
        distance += 5.0;
      }
    }

    return bestPoint;
  }

  /// Czy ten pattern ma waypoints do walidacji sekwencyjnej
  bool get hasWaypoints => waypoints != null && waypoints!.isNotEmpty;

  /// Tworzy TracingPath z waypointów (dla nowej logiki walidacji)
  TracingPath? toTracingPath() {
    if (!hasWaypoints) return null;
    return TracingPath(
      id: name.toLowerCase().replaceAll(' ', '_'),
      name: name,
      hint: hint,
      waypoints: waypoints!,
    );
  }
}

/// Canvas do rysowania po sladzie
class TracingCanvas extends StatefulWidget {
  final TracingPattern pattern;
  final Color traceColor;
  final Color drawColor;
  final double traceWidth;
  final double drawWidth;
  final VoidCallback? onComplete;

  const TracingCanvas({
    super.key,
    required this.pattern,
    this.traceColor = Colors.grey,
    this.drawColor = const Color(0xFF42A5F5), // Jasny niebieski
    this.traceWidth = 8.0,
    this.drawWidth = 14.0,
    this.onComplete,
  });

  @override
  State<TracingCanvas> createState() => TracingCanvasState();
}

/// Wynik oceny rysunku
class TracingScore {
  final double accuracy;     // 0-100, jak blisko sciezki
  final double coverage;     // 0-100, ile sciezki pokryto
  final int errorCount;      // liczba punktow poza tolerancja
  final int totalDrawnPoints; // ile punktow narysowano
  final double? endPointDistance; // Odległość ostatniego punktu od punktu końcowego

  // Nowe pola dla walidacji waypointów
  final WaypointValidationResult? waypointResult; // Wynik walidacji waypointów

  const TracingScore({
    required this.accuracy,
    required this.coverage,
    required this.errorCount,
    required this.totalDrawnPoints,
    this.endPointDistance,
    this.waypointResult,
  });

  /// Czy rysunek jest wystarczajaco dobry:
  /// Jeśli wzór ma waypoints - sprawdza czy wszystkie zaliczone
  /// W przeciwnym razie używa tradycyjnych kryteriów
  bool get isGoodEnough {
    // Jeśli mamy waypoints - używamy nowej logiki
    if (waypointResult != null) {
      // Zaliczone jeśli ukończono >= 80% waypointów
      return waypointResult!.progress >= 0.8;
    }

    // Tradycyjna logika (bez waypointów)
    final basicCriteria = accuracy >= 70 && coverage >= 40 && totalDrawnPoints >= 20;

    // Jeśli nie ma zdefiniowanego endPoint - użyj tylko podstawowych kryteriów
    if (endPointDistance == null) return basicCriteria;

    // FINISH LINE: ostatni punkt musi być blisko punktu końcowego
    return basicCriteria && endPointDistance! <= 35.0;
  }

  /// Srednia ocena
  double get overallScore {
    if (waypointResult != null) {
      // Dla waypointów - używaj procentu ukończenia
      return waypointResult!.progress * 100;
    }
    return (accuracy + coverage) / 2;
  }

  @override
  String toString() {
    final waypointInfo = waypointResult != null
        ? ', waypoints: ${waypointResult!.reachedWaypoints}/${waypointResult!.totalWaypoints}'
        : '';
    return 'TracingScore(accuracy: ${accuracy.toStringAsFixed(1)}%, '
        'coverage: ${coverage.toStringAsFixed(1)}%, '
        'errors: $errorCount, '
        'points: $totalDrawnPoints, '
        'endDist: ${endPointDistance?.toStringAsFixed(1) ?? "N/A"}$waypointInfo, '
        'isGood: $isGoodEnough)';
  }
}

class TracingCanvasState extends State<TracingCanvas>
    with SingleTickerProviderStateMixin {
  /// OPTYMALIZACJA: Tylko punkty aktualnej (niezakończonej) linii
  List<TracingPoint> _currentStrokePoints = [];

  /// OPTYMALIZACJA: Wszystkie zakończone linie "wypalone" do obrazu
  ui.Image? _bakedImage;

  /// Wszystkie punkty (do obliczeń score) - nie do renderowania
  List<TracingPoint> _allPointsForScoring = [];

  /// Rozmiar canvasa (do bake'owania)
  Size _canvasSize = Size.zero;

  // ============================================
  // JUICINESS: Animacje i cząsteczki
  // ============================================

  /// Kontroler animacji dla pulsowania waypointów
  late AnimationController _pulseController;

  /// Animacja pulsowania (0.0 - 1.0)
  late Animation<double> _pulseAnimation;

  /// Menedżer cząsteczek
  final _ParticleManager _particleManager = _ParticleManager();

  /// Indeks aktualnie osiągniętego waypointa (real-time tracking)
  int _reachedWaypointIndex = 0;

  /// Ostatni czas aktualizacji cząsteczek
  DateTime _lastParticleUpdate = DateTime.now();

  /// SPARKLING TRAIL: Licznik do throttle'owania iskierek (co N-ty punkt)
  int _trailSparkleCounter = 0;

  /// SPARKLING TRAIL: Co ile punktów generować iskierkę (3 = co 3. punkt)
  static const int _trailSparkleInterval = 3;

  @override
  void initState() {
    super.initState();

    // Kontroler animacji pulsowania (powtarza w nieskończoność)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    // Animacja pulsowania: skala 1.0 -> 1.3 -> 1.0
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  /// Wyczysc rysowane linie
  void clear() {
    setState(() {
      _currentStrokePoints = [];
      _allPointsForScoring = [];
      _bakedImage?.dispose();
      _bakedImage = null;
      _reachedWaypointIndex = 0;
      _trailSparkleCounter = 0;
      _particleManager.clear();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bakedImage?.dispose();
    super.dispose();
  }

  /// OPTYMALIZACJA: "Wypala" zakończoną linię do obrazu
  Future<void> _bakeCurrentStroke() async {
    if (_currentStrokePoints.isEmpty || _canvasSize == Size.zero) return;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Narysuj poprzedni baked image (jeśli istnieje)
    if (_bakedImage != null) {
      canvas.drawImage(_bakedImage!, Offset.zero, Paint());
    }

    // Narysuj aktualną linię
    final drawPaint = Paint()
      ..color = widget.drawColor
      ..strokeWidth = widget.drawWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    bool isFirstPoint = true;

    for (final point in _currentStrokePoints) {
      if (point.isBreak) continue;

      if (isFirstPoint) {
        path.moveTo(point.position.dx, point.position.dy);
        isFirstPoint = false;
      } else {
        path.lineTo(point.position.dx, point.position.dy);
      }
    }

    if (!isFirstPoint) {
      canvas.drawPath(path, drawPaint);
    }

    // Zakończ nagrywanie i stwórz obraz
    final picture = recorder.endRecording();
    final newImage = await picture.toImage(
      _canvasSize.width.toInt(),
      _canvasSize.height.toInt(),
    );

    // Zwolnij stary obraz
    _bakedImage?.dispose();

    setState(() {
      _bakedImage = newImage;
      _currentStrokePoints = [];
    });
  }

  /// Oblicza wynik rysunku - porownuje z wzorem
  TracingScore calculateScore() {
    // OPTYMALIZACJA: Użyj _allPointsForScoring (wszystkie punkty do obliczeń)
    final allPoints = [..._allPointsForScoring, ..._currentStrokePoints];

    if (allPoints.isEmpty) {
      return const TracingScore(
        accuracy: 0,
        coverage: 0,
        errorCount: 0,
        totalDrawnPoints: 0,
      );
    }

    final pathMetrics = widget.pattern.path.computeMetrics();

    // Zbierz punkty wzoru (co 5 pikseli)
    final List<Offset> patternPoints = [];
    for (final metric in pathMetrics) {
      double distance = 0;
      while (distance < metric.length) {
        final tangent = metric.getTangentForOffset(distance);
        if (tangent != null) {
          patternPoints.add(tangent.position);
        }
        distance += 5.0; // Probkuj co 5 pikseli
      }
    }

    if (patternPoints.isEmpty) {
      return const TracingScore(
        accuracy: 100,
        coverage: 0,
        errorCount: 0,
        totalDrawnPoints: 0,
      );
    }

    // Tolerancja - maksymalna odleglosc od wzoru (w pikselach)
    const double tolerance = 35.0;

    // Zbierz narysowane punkty (bez przerw)
    final drawnPositions = allPoints
        .where((p) => !p.isBreak)
        .map((p) => p.position)
        .toList();

    if (drawnPositions.isEmpty) {
      return const TracingScore(
        accuracy: 0,
        coverage: 0,
        errorCount: 0,
        totalDrawnPoints: 0,
      );
    }

    // 1. Oblicz accuracy - ile narysowanych punktow jest blisko wzoru
    int pointsOnPath = 0;
    int errorCount = 0;

    for (final drawn in drawnPositions) {
      double minDistance = double.infinity;
      for (final pattern in patternPoints) {
        final dist = (drawn - pattern).distance;
        if (dist < minDistance) {
          minDistance = dist;
        }
      }

      if (minDistance <= tolerance) {
        pointsOnPath++;
      } else {
        errorCount++;
      }
    }

    final accuracy = drawnPositions.isNotEmpty
        ? (pointsOnPath / drawnPositions.length) * 100
        : 0.0;

    // 2. Oblicz coverage - ile punktow wzoru zostalo pokrytych
    int coveredPoints = 0;

    for (final pattern in patternPoints) {
      bool isCovered = false;
      for (final drawn in drawnPositions) {
        if ((pattern - drawn).distance <= tolerance) {
          isCovered = true;
          break;
        }
      }
      if (isCovered) {
        coveredPoints++;
      }
    }

    final coverage = patternPoints.isNotEmpty
        ? (coveredPoints / patternPoints.length) * 100
        : 0.0;

    // 3. FINISH LINE: Oblicz odległość ostatniego punktu od endPoint
    double? endPointDistance;
    if (widget.pattern.endPoint != null && drawnPositions.isNotEmpty) {
      final lastDrawnPoint = drawnPositions.last;
      endPointDistance = (lastDrawnPoint - widget.pattern.endPoint!).distance;
    }

    // 4. WAYPOINTS: Walidacja sekwencyjna waypointów (jeśli zdefiniowane)
    WaypointValidationResult? waypointResult;
    if (widget.pattern.hasWaypoints && _canvasSize != Size.zero) {
      final tracingPath = widget.pattern.toTracingPath();
      if (tracingPath != null) {
        waypointResult = tracingPath.validateProgress(drawnPositions, _canvasSize);
      }
    }

    return TracingScore(
      accuracy: accuracy.clamp(0.0, 100.0),
      coverage: coverage.clamp(0.0, 100.0),
      errorCount: errorCount,
      totalDrawnPoints: drawnPositions.length,
      endPointDistance: endPointDistance,
      waypointResult: waypointResult,
    );
  }

  /// Czy uzytkownik narysował cokolwiek
  bool get hasDrawing {
    final allPoints = [..._allPointsForScoring, ..._currentStrokePoints];
    return allPoints.any((p) => !p.isBreak);
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _currentStrokePoints = [TracingPoint(details.localPosition)];
    });
    // Sprawdź waypoint przy starcie
    _checkWaypointHit(details.localPosition);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _currentStrokePoints = List.from(_currentStrokePoints)
        ..add(TracingPoint(details.localPosition));
    });

    // JUICINESS: Sprawdź czy trafiono waypoint w czasie rzeczywistym
    _checkWaypointHit(details.localPosition);

    // SPARKLING TRAIL: Generuj iskierkę co N-ty punkt
    _trailSparkleCounter++;
    if (_trailSparkleCounter >= _trailSparkleInterval) {
      _trailSparkleCounter = 0;
      _particleManager.addTrailSparkle(details.localPosition);
    }

    // Aktualizuj cząsteczki
    _updateParticles();
  }

  void _onPanEnd(DragEndDetails details) {
    if (_currentStrokePoints.isNotEmpty) {
      // Dodaj break point i zapisz do historii scoringu
      final breakPoint = TracingPoint(_currentStrokePoints.last.position, isBreak: true);
      _allPointsForScoring = [..._allPointsForScoring, ..._currentStrokePoints, breakPoint];

      // OPTYMALIZACJA: "Wypal" zakończoną linię do obrazu
      _bakeCurrentStroke();
    }
  }

  // ============================================
  // JUICINESS: Wykrywanie waypointów i efekty
  // ============================================

  /// Sprawdza czy palec trafił w następny oczekiwany waypoint
  void _checkWaypointHit(Offset position) {
    if (!widget.pattern.hasWaypoints || _canvasSize == Size.zero) return;

    final waypoints = widget.pattern.waypoints!;
    if (_reachedWaypointIndex >= waypoints.length) return;

    // Pobierz następny oczekiwany waypoint
    final nextWaypoint = waypoints[_reachedWaypointIndex];
    final waypointOffset = nextWaypoint.toOffset(_canvasSize);

    // Promień trafienia (35px - spójne z TracingPath.hitRadiusPx)
    const hitRadius = 35.0;

    final distance = (position - waypointOffset).distance;

    if (distance <= hitRadius) {
      // TRAFIONO WAYPOINT!
      _onWaypointHit(waypointOffset);
      _reachedWaypointIndex++;

      // Rekurencyjnie sprawdź czy trafiono też następny (np. przy szybkim ruchu)
      if (_reachedWaypointIndex < waypoints.length) {
        _checkWaypointHit(position);
      } else {
        // WSZYSTKIE WAYPOINTY ZALICZONE - dźwięk sukcesu!
        SoundEffectsController().playSuccess();
      }
    }
  }

  /// Wywoływane gdy użytkownik trafi w waypoint
  void _onWaypointHit(Offset waypointPosition) {
    // 1. HAPTIC FEEDBACK - wibracja
    HapticFeedback.lightImpact();

    // 2. PARTICLE EXPLOSION - eksplozja cząsteczek
    _particleManager.explodeAt(waypointPosition, count: 8);

    // Odśwież UI
    setState(() {});
  }

  /// Aktualizuje cząsteczki (delta time)
  void _updateParticles() {
    if (!_particleManager.hasParticles) return;

    final now = DateTime.now();
    final dt = (now.difference(_lastParticleUpdate).inMicroseconds) / 1000000.0;
    _lastParticleUpdate = now;

    _particleManager.update(dt);

    // Kontynuuj animację jeśli są cząsteczki
    if (_particleManager.hasParticles) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Zapisz rozmiar do bake'owania
        _canvasSize = Size(constraints.maxWidth, constraints.maxHeight);

        return GestureDetector(
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          behavior: HitTestBehavior.opaque, // Wazne! Reaguj na dotyk w calym obszarze
          child: Container(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            color: Colors.white,
            // OPTYMALIZACJA: RepaintBoundary izoluje przerysowania
            child: RepaintBoundary(
              // AnimatedBuilder dla animacji pulsowania
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _TracingPainter(
                      pattern: widget.pattern,
                      currentStrokePoints: _currentStrokePoints,
                      bakedImage: _bakedImage,
                      traceColor: widget.traceColor,
                      drawColor: widget.drawColor,
                      traceWidth: widget.traceWidth,
                      drawWidth: widget.drawWidth,
                      // JUICINESS: Nowe parametry
                      particles: _particleManager.particles,
                      pulseValue: _pulseAnimation.value,
                      reachedWaypointIndex: _reachedWaypointIndex,
                    ),
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

/// OPTYMALIZACJA: Malarz do rysowania wzoru i sladu
/// Używa baked image dla zakończonych linii + rysuje tylko aktualną linię
class _TracingPainter extends CustomPainter {
  final TracingPattern pattern;
  final List<TracingPoint> currentStrokePoints; // Tylko aktualna linia
  final ui.Image? bakedImage; // Wypalone poprzednie linie
  final Color traceColor;
  final Color drawColor;
  final double traceWidth;
  final double drawWidth;

  // JUICINESS: Nowe parametry
  final List<_Particle> particles;
  final double pulseValue; // 1.0 - 1.3 dla animacji pulsowania
  final int reachedWaypointIndex; // Ile waypointów zaliczono

  _TracingPainter({
    required this.pattern,
    required this.currentStrokePoints,
    required this.bakedImage,
    required this.traceColor,
    required this.drawColor,
    required this.traceWidth,
    required this.drawWidth,
    this.particles = const [],
    this.pulseValue = 1.0,
    this.reachedWaypointIndex = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Rysuj wzor (linia przerywana szara)
    _drawPattern(canvas, size);

    // 1b. JUICINESS: Rysuj waypoints z animacją (zawsze gdy są zdefiniowane)
    if (pattern.hasWaypoints) {
      _drawAnimatedWaypoints(canvas, size);
    }

    // 2. OPTYMALIZACJA: Narysuj wypalone linie (jeden obraz zamiast wielu ścieżek)
    if (bakedImage != null) {
      canvas.drawImage(bakedImage!, Offset.zero, Paint());
    }

    // 3. Rysuj aktualną linię (tylko podczas rysowania)
    _drawCurrentStroke(canvas);

    // 4. JUICINESS: Rysuj cząsteczki (na wierzchu)
    _drawParticles(canvas);
  }

  /// JUICINESS: Rysuje waypoints z animacją
  /// - Zaliczone: zielone, mniejsze (fade out efekt)
  /// - Aktywny (następny): pulsuje, jasny kolor
  /// - Przyszłe: szare, subtelne
  void _drawAnimatedWaypoints(Canvas canvas, Size size) {
    final waypoints = pattern.waypoints!;

    for (int i = 0; i < waypoints.length; i++) {
      final wp = waypoints[i];
      final offset = wp.toOffset(size);

      // Określ stan waypointa
      final isReached = i < reachedWaypointIndex;
      final isActive = i == reachedWaypointIndex;
      final isFuture = i > reachedWaypointIndex;

      // ZALICZONE - zielone z efektem "zaznaczenia"
      if (isReached) {
        // Zielone kółko (mniejsze, fade)
        final paint = Paint()
          ..color = Colors.green.withAlpha(180)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(offset, 10.0, paint);

        // Biały checkmark wewnątrz
        final checkPaint = Paint()
          ..color = Colors.white
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

        final checkPath = Path()
          ..moveTo(offset.dx - 4, offset.dy)
          ..lineTo(offset.dx - 1, offset.dy + 3)
          ..lineTo(offset.dx + 5, offset.dy - 3);

        canvas.drawPath(checkPath, checkPaint);
      }
      // AKTYWNY - pulsujący, przyciągający uwagę
      else if (isActive) {
        // Zewnętrzna poświata (glow)
        final glowRadius = 18.0 * pulseValue;
        final glowPaint = Paint()
          ..color = AppTheme.accentColor.withAlpha(80)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(offset, glowRadius, glowPaint);

        // Główne kółko (pulsujące)
        final mainRadius = 12.0 * pulseValue;
        final mainPaint = Paint()
          ..color = AppTheme.accentColor
          ..style = PaintingStyle.fill;

        canvas.drawCircle(offset, mainRadius, mainPaint);

        // Biała obwódka
        final borderPaint = Paint()
          ..color = Colors.white
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke;

        canvas.drawCircle(offset, mainRadius, borderPaint);

        // Strzałka/cel w środku (opcjonalnie)
        final centerPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

        canvas.drawCircle(offset, 3.0, centerPaint);
      }
      // PRZYSZŁE - subtelne, szare
      else if (isFuture) {
        // Szare kółko z obwódką
        final futurePaint = Paint()
          ..color = Colors.grey.withAlpha(60)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(offset, 8.0, futurePaint);

        // Delikatna obwódka
        final borderPaint = Paint()
          ..color = Colors.grey.withAlpha(100)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;

        canvas.drawCircle(offset, 8.0, borderPaint);
      }
    }
  }

  /// JUICINESS: Rysuje cząsteczki eksplozji
  void _drawParticles(Canvas canvas) {
    for (final particle in particles) {
      if (!particle.isAlive) continue;

      final paint = Paint()
        ..color = particle.color.withAlpha((particle.opacity * 255).toInt())
        ..style = PaintingStyle.fill;

      // Rysuj cząsteczkę jako gwiazdkę lub kółko
      _drawStar(canvas, particle.position, particle.size, paint);
    }
  }

  /// Rysuje małą gwiazdkę (6 ramion)
  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    const int points = 6;
    final outerRadius = size;
    final innerRadius = size * 0.4;

    for (int i = 0; i < points * 2; i++) {
      final angle = (i * math.pi / points) - math.pi / 2;
      final radius = i.isEven ? outerRadius : innerRadius;
      final x = center.dx + math.cos(angle) * radius;
      final y = center.dy + math.sin(angle) * radius;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawPattern(Canvas canvas, Size size) {
    final tracePaint = Paint()
      ..color = traceColor.withAlpha(128)
      ..strokeWidth = traceWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Efekt przerywanej linii
    const dashWidth = 12.0;
    const dashSpace = 8.0;

    final pathMetrics = pattern.path.computeMetrics();
    for (final metric in pathMetrics) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dashWidth).clamp(0.0, metric.length);
        final extractPath = metric.extractPath(distance, end);
        canvas.drawPath(extractPath, tracePaint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  /// OPTYMALIZACJA: Rysuje tylko aktualną linię (nie wszystkie historyczne punkty)
  void _drawCurrentStroke(Canvas canvas) {
    if (currentStrokePoints.isEmpty) return;

    final drawPaint = Paint()
      ..color = drawColor
      ..strokeWidth = drawWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    bool isFirstPoint = true;

    for (final point in currentStrokePoints) {
      if (point.isBreak) continue;

      if (isFirstPoint) {
        path.moveTo(point.position.dx, point.position.dy);
        isFirstPoint = false;
      } else {
        path.lineTo(point.position.dx, point.position.dy);
      }
    }

    if (!isFirstPoint) {
      canvas.drawPath(path, drawPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TracingPainter oldDelegate) {
    // OPTYMALIZACJA: Przerysuj gdy zmieni się:
    // - aktualna linia
    // - baked image
    // - cząsteczki (JUICINESS)
    // - animacja pulsowania (JUICINESS)
    // - osiągnięte waypointy (JUICINESS)
    return currentStrokePoints.length != oldDelegate.currentStrokePoints.length ||
        bakedImage != oldDelegate.bakedImage ||
        particles.length != oldDelegate.particles.length ||
        pulseValue != oldDelegate.pulseValue ||
        reachedWaypointIndex != oldDelegate.reachedWaypointIndex;
  }
}
