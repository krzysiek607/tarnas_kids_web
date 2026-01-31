import 'dart:ui';

/// Pojedynczy punkt kontrolny na ścieżce do odrysowania
/// Współrzędne mogą być znormalizowane (0.0-1.0) lub absolutne (piksele)
class Waypoint {
  final double x;
  final double y;
  final bool isStartPoint; // Czy to punkt startowy
  final bool isEndPoint; // Czy to punkt końcowy
  final bool isNormalized; // true = znormalizowane (0.0-1.0), false = piksele

  const Waypoint(
    this.x,
    this.y, {
    this.isStartPoint = false,
    this.isEndPoint = false,
    this.isNormalized = true,
  });

  /// Waypoint w pikselach (absolutne współrzędne canvas)
  const Waypoint.pixels(
    this.x,
    this.y, {
    this.isStartPoint = false,
    this.isEndPoint = false,
  }) : isNormalized = false;

  /// Konwertuje współrzędne na rzeczywiste piksele
  /// Dla znormalizowanych - mnoży przez canvasSize
  /// Dla absolutnych - zwraca bezpośrednio
  Offset toOffset(Size canvasSize) {
    if (isNormalized) {
      return Offset(x * canvasSize.width, y * canvasSize.height);
    }
    return Offset(x, y);
  }

  /// Tworzy znormalizowany Waypoint z pikseli
  static Waypoint fromPixels(Offset offset, Size canvasSize, {
    bool isStartPoint = false,
    bool isEndPoint = false,
  }) {
    return Waypoint(
      offset.dx / canvasSize.width,
      offset.dy / canvasSize.height,
      isStartPoint: isStartPoint,
      isEndPoint: isEndPoint,
    );
  }

  @override
  String toString() => 'Waypoint($x, $y, start: $isStartPoint, end: $isEndPoint, px: ${!isNormalized})';
}

/// Wynik walidacji postępu rysowania
class WaypointValidationResult {
  final int totalWaypoints;      // Łączna liczba waypointów
  final int reachedWaypoints;    // Ile waypointów zaliczono
  final int currentWaypointIndex; // Indeks aktualnie oczekiwanego waypoint
  final double distanceToNext;   // Odległość do następnego waypoint (piksele)
  final bool isComplete;         // Czy wszystkie waypoints zaliczone
  final bool isOnTrack;          // Czy użytkownik jest blisko ścieżki

  const WaypointValidationResult({
    required this.totalWaypoints,
    required this.reachedWaypoints,
    required this.currentWaypointIndex,
    required this.distanceToNext,
    required this.isComplete,
    required this.isOnTrack,
  });

  /// Procent ukończenia (0.0 - 1.0)
  double get progress => totalWaypoints > 0 ? reachedWaypoints / totalWaypoints : 0.0;

  /// Procent ukończenia (0 - 100)
  int get progressPercent => (progress * 100).round();

  @override
  String toString() =>
      'WaypointValidation(reached: $reachedWaypoints/$totalWaypoints, '
      'progress: $progressPercent%, complete: $isComplete, onTrack: $isOnTrack)';
}

/// Ścieżka do odrysowania z waypointami (punktami kontrolnymi)
/// Waypoints muszą być zaliczone w kolejności - wymusza poprawny kierunek rysowania
class TracingPath {
  final String id;           // Unikalny identyfikator (np. 'letter_A', 'pattern_wave')
  final String name;         // Nazwa wyświetlana użytkownikowi
  final String? hint;        // Opcjonalna podpowiedź
  final List<Waypoint> waypoints; // Punkty kontrolne do zaliczenia w kolejności
  final double hitRadiusPx;  // Promień zaliczenia waypoint w pikselach
  final double maxErrorPx;   // Maksymalna odległość od ścieżki w pikselach

  const TracingPath({
    required this.id,
    required this.name,
    required this.waypoints,
    this.hint,
    this.hitRadiusPx = 35.0,  // 35 pikseli (spójne z istniejącą tolerancją)
    this.maxErrorPx = 50.0,   // 50 pikseli marginesu błędu
  });

  /// Waliduje postęp rysowania użytkownika
  /// [userPath] - lista punktów narysowanych przez użytkownika (w pikselach)
  /// [canvasSize] - rozmiar canvas (do konwersji współrzędnych)
  WaypointValidationResult validateProgress(
    List<Offset> userPath,
    Size canvasSize,
  ) {
    if (waypoints.isEmpty) {
      return const WaypointValidationResult(
        totalWaypoints: 0,
        reachedWaypoints: 0,
        currentWaypointIndex: 0,
        distanceToNext: 0,
        isComplete: true,
        isOnTrack: true,
      );
    }

    if (userPath.isEmpty) {
      return WaypointValidationResult(
        totalWaypoints: waypoints.length,
        reachedWaypoints: 0,
        currentWaypointIndex: 0,
        distanceToNext: double.infinity,
        isComplete: false,
        isOnTrack: false,
      );
    }

    final hitRadiusPixels = hitRadiusPx;
    final maxErrorPixels = maxErrorPx;

    int reachedCount = 0;
    int currentWaypointIndex = 0;

    // Sprawdź każdy waypoint w kolejności
    for (int i = 0; i < waypoints.length; i++) {
      final waypointOffset = waypoints[i].toOffset(canvasSize);
      bool reached = false;

      // Sprawdź czy którykolwiek punkt użytkownika jest wystarczająco blisko
      for (final userPoint in userPath) {
        final distance = (userPoint - waypointOffset).distance;
        if (distance <= hitRadiusPixels) {
          reached = true;
          break;
        }
      }

      if (reached) {
        reachedCount++;
        currentWaypointIndex = i + 1;
      } else {
        // Zatrzymaj się na pierwszym niezaliczonym waypoint
        break;
      }
    }

    // Oblicz odległość do następnego waypoint
    double distanceToNext = 0;
    if (currentWaypointIndex < waypoints.length && userPath.isNotEmpty) {
      final nextWaypoint = waypoints[currentWaypointIndex].toOffset(canvasSize);
      final lastUserPoint = userPath.last;
      distanceToNext = (lastUserPoint - nextWaypoint).distance;
    }

    // Sprawdź czy użytkownik jest blisko ścieżki (między waypointami)
    bool isOnTrack = true;
    if (userPath.isNotEmpty && currentWaypointIndex > 0 && currentWaypointIndex < waypoints.length) {
      final lastUserPoint = userPath.last;
      final prevWaypoint = waypoints[currentWaypointIndex - 1].toOffset(canvasSize);
      final nextWaypoint = waypoints[currentWaypointIndex].toOffset(canvasSize);

      // Oblicz odległość od linii między poprzednim a następnym waypoint
      final distanceFromLine = _pointToLineDistance(lastUserPoint, prevWaypoint, nextWaypoint);
      isOnTrack = distanceFromLine <= maxErrorPixels;
    }

    return WaypointValidationResult(
      totalWaypoints: waypoints.length,
      reachedWaypoints: reachedCount,
      currentWaypointIndex: currentWaypointIndex,
      distanceToNext: distanceToNext,
      isComplete: reachedCount >= waypoints.length,
      isOnTrack: isOnTrack,
    );
  }

  /// Sprawdza czy dany punkt jest przy następnym oczekiwanym waypoint
  /// Zwraca true jeśli punkt jest w promieniu hitRadiusPx
  bool isAtNextWaypoint(Offset point, int currentIndex, Size canvasSize) {
    if (currentIndex >= waypoints.length) return false;

    final waypointOffset = waypoints[currentIndex].toOffset(canvasSize);
    return (point - waypointOffset).distance <= hitRadiusPx;
  }

  /// Sprawdza czy punkt jest zbyt daleko od ścieżki (błąd)
  /// [point] - aktualny punkt użytkownika
  /// [currentIndex] - indeks aktualnie oczekiwanego waypoint
  bool isOffTrack(Offset point, int currentIndex, Size canvasSize) {
    if (currentIndex <= 0 || currentIndex >= waypoints.length) return false;

    final prevWaypoint = waypoints[currentIndex - 1].toOffset(canvasSize);
    final nextWaypoint = waypoints[currentIndex].toOffset(canvasSize);

    final distance = _pointToLineDistance(point, prevWaypoint, nextWaypoint);
    return distance > maxErrorPx;
  }

  /// Oblicza odległość punktu od odcinka linii
  static double _pointToLineDistance(Offset point, Offset lineStart, Offset lineEnd) {
    final lineLengthSquared = (lineEnd - lineStart).distanceSquared;

    if (lineLengthSquared == 0) {
      // Linia jest punktem
      return (point - lineStart).distance;
    }

    // Oblicz projekcję punktu na linię
    final t = ((point - lineStart).dx * (lineEnd - lineStart).dx +
               (point - lineStart).dy * (lineEnd - lineStart).dy) / lineLengthSquared;

    // Ogranicz t do [0, 1] (punkt na odcinku)
    final tClamped = t.clamp(0.0, 1.0);

    // Znajdź najbliższy punkt na odcinku
    final projection = Offset(
      lineStart.dx + tClamped * (lineEnd.dx - lineStart.dx),
      lineStart.dy + tClamped * (lineEnd.dy - lineStart.dy),
    );

    return (point - projection).distance;
  }

  /// Generuje waypoints z istniejącego Path (dla wstecznej kompatybilności)
  /// Próbkuje path co określoną liczbę punktów
  static List<Waypoint> generateFromPath(
    Path path,
    Size canvasSize, {
    int sampleCount = 10,
  }) {
    final waypoints = <Waypoint>[];
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      final step = metric.length / (sampleCount - 1);

      for (int i = 0; i < sampleCount; i++) {
        final distance = i * step;
        final tangent = metric.getTangentForOffset(distance.clamp(0, metric.length));

        if (tangent != null) {
          waypoints.add(Waypoint.fromPixels(
            tangent.position,
            canvasSize,
            isStartPoint: i == 0,
            isEndPoint: i == sampleCount - 1,
          ));
        }
      }
    }

    return waypoints;
  }

  @override
  String toString() => 'TracingPath($id, waypoints: ${waypoints.length})';
}

// ============================================
// PREDEFINIOWANE ŚCIEŻKI DLA LITER
// ============================================

/// Fabryka waypointów dla polskich liter
/// Wszystkie współrzędne znormalizowane (0.0-1.0)
class LetterWaypoints {
  /// Litera A (duża) - dwie skośne linie i poprzeczka
  static List<Waypoint> get bigA => const [
    // Lewa noga (od dołu do góry)
    Waypoint(0.15, 0.85, isStartPoint: true),
    Waypoint(0.3, 0.5),
    Waypoint(0.5, 0.15),
    // Prawa noga (od góry do dołu)
    Waypoint(0.7, 0.5),
    Waypoint(0.85, 0.85),
    // Poprzeczka
    Waypoint(0.3, 0.6),
    Waypoint(0.7, 0.6, isEndPoint: true),
  ];

  /// Litera A (mała) - kółko i kreska
  static List<Waypoint> get smallA => const [
    // Kółko (start od prawej strony)
    Waypoint(0.7, 0.5, isStartPoint: true),
    Waypoint(0.5, 0.3),
    Waypoint(0.3, 0.5),
    Waypoint(0.5, 0.7),
    Waypoint(0.7, 0.5),
    // Kreska w dół
    Waypoint(0.7, 0.7),
    Waypoint(0.7, 0.9, isEndPoint: true),
  ];

  /// Litera B (duża) - kreska pionowa i dwa brzuszki
  static List<Waypoint> get bigB => const [
    // Kreska pionowa
    Waypoint(0.2, 0.15, isStartPoint: true),
    Waypoint(0.2, 0.5),
    Waypoint(0.2, 0.85),
    // Górny brzuszek
    Waypoint(0.2, 0.15),
    Waypoint(0.6, 0.15),
    Waypoint(0.7, 0.3),
    Waypoint(0.6, 0.5),
    Waypoint(0.2, 0.5),
    // Dolny brzuszek
    Waypoint(0.65, 0.5),
    Waypoint(0.75, 0.67),
    Waypoint(0.65, 0.85),
    Waypoint(0.2, 0.85, isEndPoint: true),
  ];

  /// Litera C (duża) - półkole
  static List<Waypoint> get bigC => const [
    Waypoint(0.8, 0.25, isStartPoint: true),
    Waypoint(0.5, 0.15),
    Waypoint(0.25, 0.35),
    Waypoint(0.2, 0.5),
    Waypoint(0.25, 0.65),
    Waypoint(0.5, 0.85),
    Waypoint(0.8, 0.75, isEndPoint: true),
  ];
}

/// Fabryka waypointów dla szlaczków
class PatternWaypoints {
  /// Linia prosta pozioma
  static List<Waypoint> get straightLine => const [
    Waypoint(0.1, 0.5, isStartPoint: true),
    Waypoint(0.3, 0.5),
    Waypoint(0.5, 0.5),
    Waypoint(0.7, 0.5),
    Waypoint(0.9, 0.5, isEndPoint: true),
  ];

  /// Fala (3 fale)
  static List<Waypoint> get wave => const [
    Waypoint(0.1, 0.5, isStartPoint: true),
    // Fala 1
    Waypoint(0.2, 0.3),
    Waypoint(0.3, 0.7),
    // Fala 2
    Waypoint(0.45, 0.3),
    Waypoint(0.55, 0.7),
    // Fala 3
    Waypoint(0.7, 0.3),
    Waypoint(0.8, 0.7),
    Waypoint(0.9, 0.5, isEndPoint: true),
  ];

  /// Zygzak
  static List<Waypoint> get zigzag => const [
    Waypoint(0.1, 0.5, isStartPoint: true),
    Waypoint(0.2, 0.2),
    Waypoint(0.35, 0.8),
    Waypoint(0.5, 0.2),
    Waypoint(0.65, 0.8),
    Waypoint(0.8, 0.2),
    Waypoint(0.9, 0.5, isEndPoint: true),
  ];

  /// Pętelki (kółka)
  static List<Waypoint> get loops => const [
    Waypoint(0.15, 0.5, isStartPoint: true),
    // Kółko 1
    Waypoint(0.2, 0.3),
    Waypoint(0.3, 0.5),
    Waypoint(0.2, 0.7),
    Waypoint(0.15, 0.5),
    // Kółko 2
    Waypoint(0.45, 0.3),
    Waypoint(0.55, 0.5),
    Waypoint(0.45, 0.7),
    Waypoint(0.4, 0.5),
    // Kółko 3
    Waypoint(0.7, 0.3),
    Waypoint(0.8, 0.5),
    Waypoint(0.7, 0.7),
    Waypoint(0.65, 0.5, isEndPoint: true),
  ];

  /// Spirala
  static List<Waypoint> get spiral => const [
    Waypoint(0.5, 0.5, isStartPoint: true),
    // Pierwsza pętla (mała)
    Waypoint(0.55, 0.45),
    Waypoint(0.5, 0.4),
    Waypoint(0.45, 0.45),
    Waypoint(0.45, 0.55),
    // Druga pętla (średnia)
    Waypoint(0.55, 0.6),
    Waypoint(0.6, 0.5),
    Waypoint(0.55, 0.35),
    Waypoint(0.4, 0.35),
    Waypoint(0.35, 0.5),
    // Trzecia pętla (duża)
    Waypoint(0.4, 0.7),
    Waypoint(0.6, 0.75),
    Waypoint(0.75, 0.5),
    Waypoint(0.6, 0.25, isEndPoint: true),
  ];
}
