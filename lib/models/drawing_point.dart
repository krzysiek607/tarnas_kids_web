import 'package:flutter/material.dart';

/// Typ narzedzia do rysowania
enum DrawingTool {
  brush,   // Pedzel - miekkie, gladkie linie
  crayon,  // Kredka - teksturowane linie
  spray,   // Spray - rozpylone punkty
  eraser,  // Gumka - wymazuje rysunki
}

/// Reprezentuje pojedynczy punkt na canvas
class DrawingPoint {
  final Offset offset;
  final Color color;
  final double strokeWidth;

  const DrawingPoint({
    required this.offset,
    required this.color,
    required this.strokeWidth,
  });
}

/// Reprezentuje linie (ciag punktow) na canvas
class DrawingLine {
  final List<DrawingPoint> points;
  final Color color;
  final double strokeWidth;
  final DrawingTool tool;

  const DrawingLine({
    required this.points,
    required this.color,
    required this.strokeWidth,
    this.tool = DrawingTool.brush,
  });

  DrawingLine copyWith({
    List<DrawingPoint>? points,
    Color? color,
    double? strokeWidth,
    DrawingTool? tool,
  }) {
    return DrawingLine(
      points: points ?? this.points,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      tool: tool ?? this.tool,
    );
  }
}
