import 'package:flutter/material.dart';

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

  const TracingPattern({
    required this.name,
    required this.path,
    this.hint,
  });
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

class TracingCanvasState extends State<TracingCanvas> {
  List<TracingPoint> _drawnPoints = [];

  /// Wyczysc rysowane linie
  void clear() {
    setState(() {
      _drawnPoints = [];
    });
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _drawnPoints = List.from(_drawnPoints)
        ..add(TracingPoint(details.localPosition));
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _drawnPoints = List.from(_drawnPoints)
        ..add(TracingPoint(details.localPosition));
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      if (_drawnPoints.isNotEmpty) {
        _drawnPoints = List.from(_drawnPoints)
          ..add(TracingPoint(_drawnPoints.last.position, isBreak: true));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          behavior: HitTestBehavior.opaque, // Wazne! Reaguj na dotyk w calym obszarze
          child: Container(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            color: Colors.white,
            child: CustomPaint(
              painter: _TracingPainter(
                pattern: widget.pattern,
                drawnPoints: _drawnPoints,
                traceColor: widget.traceColor,
                drawColor: widget.drawColor,
                traceWidth: widget.traceWidth,
                drawWidth: widget.drawWidth,
              ),
              size: Size(constraints.maxWidth, constraints.maxHeight),
            ),
          ),
        );
      },
    );
  }
}

/// Malarz do rysowania wzoru i sladu
class _TracingPainter extends CustomPainter {
  final TracingPattern pattern;
  final List<TracingPoint> drawnPoints;
  final Color traceColor;
  final Color drawColor;
  final double traceWidth;
  final double drawWidth;

  _TracingPainter({
    required this.pattern,
    required this.drawnPoints,
    required this.traceColor,
    required this.drawColor,
    required this.traceWidth,
    required this.drawWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Rysuj wzor (linia przerywana szara)
    _drawPattern(canvas, size);

    // 2. Rysuj to co narysowalo dziecko (na wierzchu)
    _drawUserPath(canvas);
  }

  void _drawPattern(Canvas canvas, Size size) {
    final tracePaint = Paint()
      ..color = traceColor.withOpacity(0.5)
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

  void _drawUserPath(Canvas canvas) {
    if (drawnPoints.isEmpty) return;

    final drawPaint = Paint()
      ..color = drawColor
      ..strokeWidth = drawWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round // Zaokraglone konce
      ..strokeJoin = StrokeJoin.round;

    Path currentPath = Path();
    bool isFirstPoint = true;

    for (int i = 0; i < drawnPoints.length; i++) {
      final point = drawnPoints[i];

      if (point.isBreak) {
        // Rysuj dotychczasowa sciezke i zacznij nowa
        if (!isFirstPoint) {
          canvas.drawPath(currentPath, drawPaint);
        }
        currentPath = Path();
        isFirstPoint = true;
        continue;
      }

      if (isFirstPoint) {
        currentPath.moveTo(point.position.dx, point.position.dy);
        isFirstPoint = false;
      } else {
        currentPath.lineTo(point.position.dx, point.position.dy);
      }
    }

    // Narysuj ostatnia sciezke
    if (!isFirstPoint) {
      canvas.drawPath(currentPath, drawPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TracingPainter oldDelegate) {
    // Zawsze odrysuj gdy zmieni sie liczba punktow lub wzor
    return true;
  }
}
