import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/drawing_point.dart';

/// Stan rysowania
class DrawingState {
  final List<DrawingLine> lines;
  final DrawingLine? currentLine;
  final Color selectedColor;
  final double strokeWidth;
  final DrawingTool selectedTool;
  final List<DrawingLine> undoHistory;

  const DrawingState({
    this.lines = const [],
    this.currentLine,
    this.selectedColor = Colors.black,
    this.strokeWidth = 5.0,
    this.selectedTool = DrawingTool.brush,
    this.undoHistory = const [],
  });

  DrawingState copyWith({
    List<DrawingLine>? lines,
    DrawingLine? currentLine,
    Color? selectedColor,
    double? strokeWidth,
    DrawingTool? selectedTool,
    List<DrawingLine>? undoHistory,
    bool clearCurrentLine = false,
  }) {
    return DrawingState(
      lines: lines ?? this.lines,
      currentLine: clearCurrentLine ? null : (currentLine ?? this.currentLine),
      selectedColor: selectedColor ?? this.selectedColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      selectedTool: selectedTool ?? this.selectedTool,
      undoHistory: undoHistory ?? this.undoHistory,
    );
  }
}

/// Notifier do zarzadzania stanem rysowania
class DrawingNotifier extends StateNotifier<DrawingState> {
  DrawingNotifier() : super(const DrawingState());

  /// Rozpoczyna nowa linie
  void startLine(Offset point) {
    final newPoint = DrawingPoint(
      offset: point,
      color: state.selectedColor,
      strokeWidth: state.strokeWidth,
    );

    final newLine = DrawingLine(
      points: [newPoint],
      color: state.selectedColor,
      strokeWidth: state.strokeWidth,
      tool: state.selectedTool,
    );

    state = state.copyWith(currentLine: newLine);
  }

  /// Dodaje punkt do aktualnej linii
  void addPoint(Offset point) {
    if (state.currentLine == null) return;

    final newPoint = DrawingPoint(
      offset: point,
      color: state.selectedColor,
      strokeWidth: state.strokeWidth,
    );

    final updatedPoints = [...state.currentLine!.points, newPoint];
    final updatedLine = state.currentLine!.copyWith(points: updatedPoints);

    state = state.copyWith(currentLine: updatedLine);
  }

  /// Konczy aktualna linie
  void endLine() {
    if (state.currentLine == null) return;

    state = state.copyWith(
      lines: [...state.lines, state.currentLine!],
      undoHistory: [], // czysc historie po nowym rysunku
      clearCurrentLine: true,
    );
  }

  /// Zmienia wybrany kolor
  void setColor(Color color) {
    state = state.copyWith(selectedColor: color);
  }

  /// Zmienia grubosc pedzla
  void setStrokeWidth(double width) {
    state = state.copyWith(strokeWidth: width);
  }

  /// Zmienia narzedzie
  void setTool(DrawingTool tool) {
    state = state.copyWith(selectedTool: tool);
  }

  /// Cofnij ostatnia linie
  void undo() {
    if (state.lines.isEmpty) return;

    final lastLine = state.lines.last;
    final newLines = state.lines.sublist(0, state.lines.length - 1);

    state = state.copyWith(
      lines: newLines,
      undoHistory: [...state.undoHistory, lastLine],
    );
  }

  /// Przywroc cofnieta linie
  void redo() {
    if (state.undoHistory.isEmpty) return;

    final lastUndo = state.undoHistory.last;
    final newUndoHistory = state.undoHistory.sublist(0, state.undoHistory.length - 1);

    state = state.copyWith(
      lines: [...state.lines, lastUndo],
      undoHistory: newUndoHistory,
    );
  }

  /// Czysci canvas
  void clear() {
    state = const DrawingState();
  }
}

/// Provider dla stanu rysowania
final drawingProvider = StateNotifierProvider<DrawingNotifier, DrawingState>(
  (ref) => DrawingNotifier(),
);

/// Dostepne kolory do rysowania
final availableColors = [
  Colors.black,
  Colors.red,
  Colors.orange,
  Colors.yellow,
  Colors.green,
  Colors.blue,
  Colors.purple,
  Colors.pink,
  Colors.brown,
  Colors.white,
];

/// Dostepne grubosci pedzla
final availableStrokeWidths = [3.0, 6.0, 10.0, 16.0, 24.0];

/// Informacje o narzedziu
class ToolInfo {
  final DrawingTool tool;
  final String name;
  final String iconPath;

  const ToolInfo(this.tool, this.name, this.iconPath);
}

/// Dostepne narzedzia
final availableTools = [
  ToolInfo(DrawingTool.brush, 'Pędzel', 'assets/images/icons/drawing_paintbrush.png'),
  ToolInfo(DrawingTool.crayon, 'Kredka', 'assets/images/icons/drawing_pencil.png'),
  ToolInfo(DrawingTool.spray, 'Spray', 'assets/images/icons/drawing_spray.png'),
  ToolInfo(DrawingTool.eraser, 'Gumka', 'assets/images/icons/drawing_eraser.png'),
];
