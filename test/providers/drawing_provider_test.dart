import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talu_kids/models/drawing_point.dart';
import 'package:talu_kids/providers/drawing_provider.dart';

void main() {
  group('DrawingState', () {
    group('konstruktor domyslny', () {
      test('powinien miec puste linie', () {
        const state = DrawingState();

        expect(state.lines, isEmpty);
      });

      test('powinien miec null currentLine', () {
        const state = DrawingState();

        expect(state.currentLine, isNull);
      });

      test('powinien miec czarny kolor domyslny', () {
        const state = DrawingState();

        expect(state.selectedColor, Colors.black);
      });

      test('powinien miec domyslna grubosc 5.0', () {
        const state = DrawingState();

        expect(state.strokeWidth, 5.0);
      });

      test('powinien miec domyslne narzedzie brush', () {
        const state = DrawingState();

        expect(state.selectedTool, DrawingTool.brush);
      });

      test('powinien miec pusta historie cofania', () {
        const state = DrawingState();

        expect(state.undoHistory, isEmpty);
      });
    });

    group('copyWith', () {
      test('powinien skopiowac z nowymi liniami', () {
        const original = DrawingState();
        final line = DrawingLine(
          points: const [],
          color: Colors.red,
          strokeWidth: 3.0,
        );
        final copied = original.copyWith(lines: [line]);

        expect(copied.lines.length, 1);
        expect(copied.lines.first.color, Colors.red);
        expect(copied.selectedColor, Colors.black);
      });

      test('powinien skopiowac z nowym kolorem', () {
        const original = DrawingState();
        final copied = original.copyWith(selectedColor: Colors.blue);

        expect(copied.selectedColor, Colors.blue);
        expect(copied.strokeWidth, 5.0);
      });

      test('powinien skopiowac z nowa gruboscia', () {
        const original = DrawingState();
        final copied = original.copyWith(strokeWidth: 10.0);

        expect(copied.strokeWidth, 10.0);
        expect(copied.selectedColor, Colors.black);
      });

      test('powinien skopiowac z nowym narzedziem', () {
        const original = DrawingState();
        final copied = original.copyWith(selectedTool: DrawingTool.eraser);

        expect(copied.selectedTool, DrawingTool.eraser);
      });

      test('powinien wyczyScic currentLine gdy clearCurrentLine true', () {
        final line = DrawingLine(
          points: const [],
          color: Colors.red,
          strokeWidth: 3.0,
        );
        final original = DrawingState(currentLine: line);
        final copied = original.copyWith(clearCurrentLine: true);

        expect(copied.currentLine, isNull);
      });

      test('powinien zachowac currentLine bez clearCurrentLine', () {
        final line = DrawingLine(
          points: const [],
          color: Colors.red,
          strokeWidth: 3.0,
        );
        final original = DrawingState(currentLine: line);
        final copied = original.copyWith(selectedColor: Colors.blue);

        expect(copied.currentLine, isNotNull);
        expect(copied.currentLine!.color, Colors.red);
      });

      test('powinien skopiowac z nowa historia cofania', () {
        const original = DrawingState();
        final line = DrawingLine(
          points: const [],
          color: Colors.green,
          strokeWidth: 5.0,
        );
        final copied = original.copyWith(undoHistory: [line]);

        expect(copied.undoHistory.length, 1);
      });

      test('powinien zachowac niemutowalnosc - oryginalna lista nie zmieniona', () {
        final line = DrawingLine(
          points: const [],
          color: Colors.red,
          strokeWidth: 3.0,
        );
        final original = DrawingState(lines: [line]);
        final copied = original.copyWith(
          lines: [...original.lines, line],
        );

        expect(original.lines.length, 1);
        expect(copied.lines.length, 2);
      });
    });
  });

  group('DrawingNotifier', () {
    late DrawingNotifier notifier;

    setUp(() {
      notifier = DrawingNotifier();
    });

    tearDown(() {
      notifier.dispose();
    });

    group('stan poczatkowy', () {
      test('powinien zaczac z pustym stanem', () {
        expect(notifier.state.lines, isEmpty);
        expect(notifier.state.currentLine, isNull);
        expect(notifier.state.selectedColor, Colors.black);
        expect(notifier.state.strokeWidth, 5.0);
        expect(notifier.state.selectedTool, DrawingTool.brush);
        expect(notifier.state.undoHistory, isEmpty);
      });
    });

    group('startLine', () {
      test('powinien utworzyc nowa linie z jednym punktem', () {
        const point = Offset(10.0, 20.0);
        notifier.startLine(point);

        expect(notifier.state.currentLine, isNotNull);
        expect(notifier.state.currentLine!.points.length, 1);
        expect(notifier.state.currentLine!.points.first.offset, point);
      });

      test('powinien uzyc wybranego koloru dla nowej linii', () {
        notifier.setColor(Colors.red);
        notifier.startLine(const Offset(10.0, 20.0));

        expect(notifier.state.currentLine!.color, Colors.red);
        expect(notifier.state.currentLine!.points.first.color, Colors.red);
      });

      test('powinien uzyc wybranej grubosci dla nowej linii', () {
        notifier.setStrokeWidth(12.0);
        notifier.startLine(const Offset(10.0, 20.0));

        expect(notifier.state.currentLine!.strokeWidth, 12.0);
        expect(notifier.state.currentLine!.points.first.strokeWidth, 12.0);
      });

      test('powinien uzyc wybranego narzedzia dla nowej linii', () {
        notifier.setTool(DrawingTool.spray);
        notifier.startLine(const Offset(10.0, 20.0));

        expect(notifier.state.currentLine!.tool, DrawingTool.spray);
      });
    });

    group('addPoint', () {
      test('powinien dodac punkt do aktualnej linii', () {
        notifier.startLine(const Offset(10.0, 20.0));
        notifier.addPoint(const Offset(30.0, 40.0));

        expect(notifier.state.currentLine!.points.length, 2);
        expect(notifier.state.currentLine!.points.last.offset, const Offset(30.0, 40.0));
      });

      test('powinien dodac wiele punktow', () {
        notifier.startLine(const Offset(0.0, 0.0));
        notifier.addPoint(const Offset(10.0, 10.0));
        notifier.addPoint(const Offset(20.0, 20.0));
        notifier.addPoint(const Offset(30.0, 30.0));

        expect(notifier.state.currentLine!.points.length, 4);
      });

      test('powinien nic nie robic gdy brak currentLine', () {
        notifier.addPoint(const Offset(10.0, 20.0));

        expect(notifier.state.currentLine, isNull);
      });

      test('powinien uzyc aktualnego koloru i grubosci dla nowego punktu', () {
        notifier.startLine(const Offset(0.0, 0.0));
        // Kolor i grubosc punktu sa brane z aktualnego stanu
        notifier.addPoint(const Offset(10.0, 10.0));

        final lastPoint = notifier.state.currentLine!.points.last;
        expect(lastPoint.color, Colors.black);
        expect(lastPoint.strokeWidth, 5.0);
      });
    });

    group('endLine', () {
      test('powinien przeniesc currentLine do lines', () {
        notifier.startLine(const Offset(0.0, 0.0));
        notifier.addPoint(const Offset(10.0, 10.0));
        notifier.endLine();

        expect(notifier.state.lines.length, 1);
        expect(notifier.state.currentLine, isNull);
      });

      test('powinien wyczyScic historie cofania po nowym rysunku', () {
        // Narysuj i cofnij
        notifier.startLine(const Offset(0.0, 0.0));
        notifier.endLine();
        notifier.undo();
        expect(notifier.state.undoHistory.length, 1);

        // Narysuj nowa linie
        notifier.startLine(const Offset(10.0, 10.0));
        notifier.endLine();

        // Historia cofania powinna byc wyczyszczona
        expect(notifier.state.undoHistory, isEmpty);
      });

      test('powinien nic nie robic gdy brak currentLine', () {
        notifier.endLine();

        expect(notifier.state.lines, isEmpty);
        expect(notifier.state.currentLine, isNull);
      });

      test('powinien zachowac istniejace linie', () {
        notifier.startLine(const Offset(0.0, 0.0));
        notifier.endLine();

        notifier.startLine(const Offset(10.0, 10.0));
        notifier.endLine();

        expect(notifier.state.lines.length, 2);
      });
    });

    group('pelny flow: startLine -> addPoint -> endLine', () {
      test('powinien narysowac kompletna linie', () {
        notifier.setColor(Colors.red);
        notifier.setStrokeWidth(8.0);
        notifier.setTool(DrawingTool.crayon);

        notifier.startLine(const Offset(0.0, 0.0));
        notifier.addPoint(const Offset(50.0, 50.0));
        notifier.addPoint(const Offset(100.0, 100.0));
        notifier.endLine();

        expect(notifier.state.lines.length, 1);
        expect(notifier.state.currentLine, isNull);

        final line = notifier.state.lines.first;
        expect(line.points.length, 3);
        expect(line.color, Colors.red);
        expect(line.strokeWidth, 8.0);
        expect(line.tool, DrawingTool.crayon);
      });
    });

    group('setColor', () {
      test('powinien zmienic wybrany kolor', () {
        notifier.setColor(Colors.purple);

        expect(notifier.state.selectedColor, Colors.purple);
      });

      test('powinien nie zmieniac innych wlasciwosci', () {
        notifier.setColor(Colors.green);

        expect(notifier.state.strokeWidth, 5.0);
        expect(notifier.state.selectedTool, DrawingTool.brush);
        expect(notifier.state.lines, isEmpty);
      });
    });

    group('setStrokeWidth', () {
      test('powinien zmienic grubosc pedzla', () {
        notifier.setStrokeWidth(16.0);

        expect(notifier.state.strokeWidth, 16.0);
      });

      test('powinien nie zmieniac innych wlasciwosci', () {
        notifier.setStrokeWidth(24.0);

        expect(notifier.state.selectedColor, Colors.black);
        expect(notifier.state.selectedTool, DrawingTool.brush);
      });
    });

    group('setTool', () {
      test('powinien zmienic narzedzie na eraser', () {
        notifier.setTool(DrawingTool.eraser);

        expect(notifier.state.selectedTool, DrawingTool.eraser);
      });

      test('powinien zmienic narzedzie na spray', () {
        notifier.setTool(DrawingTool.spray);

        expect(notifier.state.selectedTool, DrawingTool.spray);
      });

      test('powinien zmienic narzedzie na crayon', () {
        notifier.setTool(DrawingTool.crayon);

        expect(notifier.state.selectedTool, DrawingTool.crayon);
      });

      test('powinien nie zmieniac innych wlasciwosci', () {
        notifier.setTool(DrawingTool.eraser);

        expect(notifier.state.selectedColor, Colors.black);
        expect(notifier.state.strokeWidth, 5.0);
      });
    });

    group('undo', () {
      test('powinien cofnac ostatnia linie', () {
        notifier.startLine(const Offset(0.0, 0.0));
        notifier.endLine();
        notifier.startLine(const Offset(10.0, 10.0));
        notifier.endLine();

        expect(notifier.state.lines.length, 2);

        notifier.undo();

        expect(notifier.state.lines.length, 1);
      });

      test('powinien dodac cofnieta linie do undoHistory', () {
        notifier.startLine(const Offset(0.0, 0.0));
        notifier.endLine();

        notifier.undo();

        expect(notifier.state.undoHistory.length, 1);
        expect(notifier.state.lines, isEmpty);
      });

      test('powinien nic nie robic gdy brak linii (pusta lista)', () {
        notifier.undo();

        expect(notifier.state.lines, isEmpty);
        expect(notifier.state.undoHistory, isEmpty);
      });

      test('powinien umozliwic wielokrotne cofanie', () {
        notifier.startLine(const Offset(0.0, 0.0));
        notifier.endLine();
        notifier.startLine(const Offset(10.0, 10.0));
        notifier.endLine();
        notifier.startLine(const Offset(20.0, 20.0));
        notifier.endLine();

        notifier.undo();
        notifier.undo();
        notifier.undo();

        expect(notifier.state.lines, isEmpty);
        expect(notifier.state.undoHistory.length, 3);
      });

      test('powinien zachowac kolejnosc w undoHistory (LIFO)', () {
        notifier.setColor(Colors.red);
        notifier.startLine(const Offset(0.0, 0.0));
        notifier.endLine();

        notifier.setColor(Colors.blue);
        notifier.startLine(const Offset(10.0, 10.0));
        notifier.endLine();

        notifier.undo();

        // Ostatnia cofnieta to niebieska
        expect(notifier.state.undoHistory.last.color, Colors.blue);
      });
    });

    group('redo', () {
      test('powinien przywrocic cofnieta linie', () {
        notifier.startLine(const Offset(0.0, 0.0));
        notifier.endLine();

        notifier.undo();
        expect(notifier.state.lines, isEmpty);

        notifier.redo();
        expect(notifier.state.lines.length, 1);
      });

      test('powinien usunac przywrocona linie z undoHistory', () {
        notifier.startLine(const Offset(0.0, 0.0));
        notifier.endLine();

        notifier.undo();
        expect(notifier.state.undoHistory.length, 1);

        notifier.redo();
        expect(notifier.state.undoHistory, isEmpty);
      });

      test('powinien nic nie robic gdy undoHistory jest pusta', () {
        notifier.redo();

        expect(notifier.state.lines, isEmpty);
        expect(notifier.state.undoHistory, isEmpty);
      });

      test('powinien umozliwic wielokrotne redo', () {
        notifier.startLine(const Offset(0.0, 0.0));
        notifier.endLine();
        notifier.startLine(const Offset(10.0, 10.0));
        notifier.endLine();

        notifier.undo();
        notifier.undo();

        notifier.redo();
        notifier.redo();

        expect(notifier.state.lines.length, 2);
        expect(notifier.state.undoHistory, isEmpty);
      });
    });

    group('undo/redo cykl', () {
      test('powinien poprawnie obslugiwac cykl undo -> redo -> undo', () {
        notifier.startLine(const Offset(0.0, 0.0));
        notifier.endLine();

        notifier.undo();
        expect(notifier.state.lines, isEmpty);

        notifier.redo();
        expect(notifier.state.lines.length, 1);

        notifier.undo();
        expect(notifier.state.lines, isEmpty);
      });

      test('nowy rysunek powinien wyczyScic undoHistory', () {
        notifier.startLine(const Offset(0.0, 0.0));
        notifier.endLine();
        notifier.undo();
        expect(notifier.state.undoHistory.length, 1);

        // Narysuj nowa linie - redo powinno byc niedostepne
        notifier.startLine(const Offset(5.0, 5.0));
        notifier.endLine();

        expect(notifier.state.undoHistory, isEmpty);

        // Redo nie powinno nic robic
        notifier.redo();
        expect(notifier.state.lines.length, 1);
      });
    });

    group('clear', () {
      test('powinien zresetowac do stanu poczatkowego', () {
        notifier.setColor(Colors.red);
        notifier.setStrokeWidth(12.0);
        notifier.setTool(DrawingTool.spray);
        notifier.startLine(const Offset(0.0, 0.0));
        notifier.endLine();

        notifier.clear();

        expect(notifier.state.lines, isEmpty);
        expect(notifier.state.currentLine, isNull);
        expect(notifier.state.selectedColor, Colors.black);
        expect(notifier.state.strokeWidth, 5.0);
        expect(notifier.state.selectedTool, DrawingTool.brush);
        expect(notifier.state.undoHistory, isEmpty);
      });

      test('powinien dzialac na pustym stanie', () {
        notifier.clear();

        expect(notifier.state.lines, isEmpty);
        expect(notifier.state.currentLine, isNull);
      });

      test('powinien wyczyScic historie cofania', () {
        notifier.startLine(const Offset(0.0, 0.0));
        notifier.endLine();
        notifier.undo();

        notifier.clear();

        expect(notifier.state.undoHistory, isEmpty);
      });
    });
  });

  group('DrawingLine', () {
    group('copyWith', () {
      test('powinien skopiowac z nowymi punktami', () {
        final original = DrawingLine(
          points: const [
            DrawingPoint(offset: Offset.zero, color: Colors.red, strokeWidth: 5.0),
          ],
          color: Colors.red,
          strokeWidth: 5.0,
        );
        final newPoints = [
          const DrawingPoint(offset: Offset.zero, color: Colors.red, strokeWidth: 5.0),
          const DrawingPoint(offset: Offset(10, 10), color: Colors.red, strokeWidth: 5.0),
        ];
        final copied = original.copyWith(points: newPoints);

        expect(copied.points.length, 2);
        expect(copied.color, Colors.red);
      });

      test('powinien skopiowac z nowym kolorem', () {
        final original = DrawingLine(
          points: const [],
          color: Colors.red,
          strokeWidth: 5.0,
        );
        final copied = original.copyWith(color: Colors.blue);

        expect(copied.color, Colors.blue);
        expect(copied.strokeWidth, 5.0);
      });

      test('powinien skopiowac z nowym narzedziem', () {
        final original = DrawingLine(
          points: const [],
          color: Colors.red,
          strokeWidth: 5.0,
          tool: DrawingTool.brush,
        );
        final copied = original.copyWith(tool: DrawingTool.eraser);

        expect(copied.tool, DrawingTool.eraser);
      });
    });
  });

  group('DrawingTool enum', () {
    test('powinien miec 4 narzedzia', () {
      expect(DrawingTool.values.length, 4);
    });

    test('powinien zawierac brush, crayon, spray, eraser', () {
      expect(DrawingTool.values, contains(DrawingTool.brush));
      expect(DrawingTool.values, contains(DrawingTool.crayon));
      expect(DrawingTool.values, contains(DrawingTool.spray));
      expect(DrawingTool.values, contains(DrawingTool.eraser));
    });
  });

  group('availableColors', () {
    test('powinien miec 10 kolorow', () {
      expect(availableColors.length, 10);
    });

    test('powinien zawierac czarny i bialy', () {
      expect(availableColors, contains(Colors.black));
      expect(availableColors, contains(Colors.white));
    });
  });

  group('availableStrokeWidths', () {
    test('powinien miec 5 grubosci', () {
      expect(availableStrokeWidths.length, 5);
    });

    test('powinien byc posortowany rosnaco', () {
      for (int i = 0; i < availableStrokeWidths.length - 1; i++) {
        expect(availableStrokeWidths[i] < availableStrokeWidths[i + 1], true);
      }
    });

    test('wszystkie wartosci powinny byc dodatnie', () {
      for (final width in availableStrokeWidths) {
        expect(width, greaterThan(0.0));
      }
    });
  });

  group('availableTools', () {
    test('powinien miec 4 narzedzia', () {
      expect(availableTools.length, 4);
    });

    test('kazde narzedzie powinno miec nazwe i sciezke ikony', () {
      for (final tool in availableTools) {
        expect(tool.name, isNotEmpty);
        expect(tool.iconPath, isNotEmpty);
      }
    });
  });
}
