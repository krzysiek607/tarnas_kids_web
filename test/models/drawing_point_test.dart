import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tarnas_kids/models/drawing_point.dart';

void main() {
  // ============================================
  // DrawingTool enum
  // ============================================
  group('DrawingTool', () {
    test('should have exactly 4 values', () {
      expect(DrawingTool.values.length, 4);
    });

    test('should contain brush, crayon, spray, eraser', () {
      expect(DrawingTool.values, contains(DrawingTool.brush));
      expect(DrawingTool.values, contains(DrawingTool.crayon));
      expect(DrawingTool.values, contains(DrawingTool.spray));
      expect(DrawingTool.values, contains(DrawingTool.eraser));
    });
  });

  // ============================================
  // DrawingPoint
  // ============================================
  group('DrawingPoint', () {
    test('should create with required parameters', () {
      const point = DrawingPoint(
        offset: Offset(10.0, 20.0),
        color: Colors.red,
        strokeWidth: 3.0,
      );

      expect(point.offset, const Offset(10.0, 20.0));
      expect(point.color, Colors.red);
      expect(point.strokeWidth, 3.0);
    });

    test('should store offset with zero coordinates', () {
      const point = DrawingPoint(
        offset: Offset.zero,
        color: Colors.black,
        strokeWidth: 1.0,
      );

      expect(point.offset, Offset.zero);
      expect(point.offset.dx, 0.0);
      expect(point.offset.dy, 0.0);
    });

    test('should store negative offset coordinates', () {
      const point = DrawingPoint(
        offset: Offset(-5.0, -10.0),
        color: Colors.blue,
        strokeWidth: 2.0,
      );

      expect(point.offset.dx, -5.0);
      expect(point.offset.dy, -10.0);
    });

    test('should store large offset values', () {
      const point = DrawingPoint(
        offset: Offset(9999.0, 9999.0),
        color: Colors.green,
        strokeWidth: 100.0,
      );

      expect(point.offset.dx, 9999.0);
      expect(point.offset.dy, 9999.0);
      expect(point.strokeWidth, 100.0);
    });

    test('should store custom color with alpha', () {
      const customColor = Color(0x80FF0000); // Red with 50% opacity
      const point = DrawingPoint(
        offset: Offset(1.0, 1.0),
        color: customColor,
        strokeWidth: 5.0,
      );

      expect(point.color, customColor);
      expect(point.color.a, closeTo(0.502, 0.01));
    });

    test('should store very small strokeWidth', () {
      const point = DrawingPoint(
        offset: Offset(0.0, 0.0),
        color: Colors.black,
        strokeWidth: 0.1,
      );

      expect(point.strokeWidth, 0.1);
    });

    test('should be const constructible', () {
      // Verifying const construction compiles and works
      const p1 = DrawingPoint(
        offset: Offset(1.0, 2.0),
        color: Color(0xFF000000),
        strokeWidth: 3.0,
      );
      const p2 = DrawingPoint(
        offset: Offset(1.0, 2.0),
        color: Color(0xFF000000),
        strokeWidth: 3.0,
      );

      // Const instances with identical values are the same object
      expect(identical(p1, p2), isTrue);
    });

    test('should have final (immutable) fields', () {
      const point = DrawingPoint(
        offset: Offset(5.0, 10.0),
        color: Colors.red,
        strokeWidth: 2.0,
      );

      // Fields are final - we verify by reading them (mutation would be compile error)
      expect(point.offset, const Offset(5.0, 10.0));
      expect(point.color, Colors.red);
      expect(point.strokeWidth, 2.0);
    });
  });

  // ============================================
  // DrawingLine
  // ============================================
  group('DrawingLine', () {
    test('should create with required parameters and default tool', () {
      const line = DrawingLine(
        points: [],
        color: Colors.blue,
        strokeWidth: 5.0,
      );

      expect(line.points, isEmpty);
      expect(line.color, Colors.blue);
      expect(line.strokeWidth, 5.0);
      expect(line.tool, DrawingTool.brush); // default value
    });

    test('should create with explicit tool parameter', () {
      const line = DrawingLine(
        points: [],
        color: Colors.red,
        strokeWidth: 3.0,
        tool: DrawingTool.crayon,
      );

      expect(line.tool, DrawingTool.crayon);
    });

    test('should create with all drawing tools', () {
      for (final tool in DrawingTool.values) {
        final line = DrawingLine(
          points: const [],
          color: Colors.black,
          strokeWidth: 1.0,
          tool: tool,
        );
        expect(line.tool, tool);
      }
    });

    test('should store multiple points', () {
      const points = [
        DrawingPoint(
          offset: Offset(0.0, 0.0),
          color: Colors.red,
          strokeWidth: 2.0,
        ),
        DrawingPoint(
          offset: Offset(10.0, 10.0),
          color: Colors.red,
          strokeWidth: 2.0,
        ),
        DrawingPoint(
          offset: Offset(20.0, 20.0),
          color: Colors.red,
          strokeWidth: 2.0,
        ),
      ];

      const line = DrawingLine(
        points: points,
        color: Colors.red,
        strokeWidth: 2.0,
      );

      expect(line.points.length, 3);
      expect(line.points[0].offset, const Offset(0.0, 0.0));
      expect(line.points[1].offset, const Offset(10.0, 10.0));
      expect(line.points[2].offset, const Offset(20.0, 20.0));
    });

    group('copyWith', () {
      const originalLine = DrawingLine(
        points: [
          DrawingPoint(
            offset: Offset(1.0, 1.0),
            color: Colors.red,
            strokeWidth: 2.0,
          ),
        ],
        color: Colors.red,
        strokeWidth: 2.0,
        tool: DrawingTool.brush,
      );

      test('should return new instance with updated color', () {
        final copied = originalLine.copyWith(color: Colors.blue);

        expect(copied.color, Colors.blue);
        expect(copied.strokeWidth, originalLine.strokeWidth);
        expect(copied.tool, originalLine.tool);
        expect(copied.points.length, originalLine.points.length);
      });

      test('should return new instance with updated strokeWidth', () {
        final copied = originalLine.copyWith(strokeWidth: 10.0);

        expect(copied.strokeWidth, 10.0);
        expect(copied.color, originalLine.color);
        expect(copied.tool, originalLine.tool);
      });

      test('should return new instance with updated tool', () {
        final copied = originalLine.copyWith(tool: DrawingTool.spray);

        expect(copied.tool, DrawingTool.spray);
        expect(copied.color, originalLine.color);
        expect(copied.strokeWidth, originalLine.strokeWidth);
      });

      test('should return new instance with updated points', () {
        const newPoints = [
          DrawingPoint(
            offset: Offset(50.0, 50.0),
            color: Colors.green,
            strokeWidth: 5.0,
          ),
        ];

        final copied = originalLine.copyWith(points: newPoints);

        expect(copied.points.length, 1);
        expect(copied.points[0].offset, const Offset(50.0, 50.0));
        expect(copied.color, originalLine.color);
      });

      test('should return copy with all fields unchanged when no args', () {
        final copied = originalLine.copyWith();

        expect(copied.color, originalLine.color);
        expect(copied.strokeWidth, originalLine.strokeWidth);
        expect(copied.tool, originalLine.tool);
        expect(copied.points.length, originalLine.points.length);
      });

      test('should return new instance with all fields updated', () {
        const newPoints = <DrawingPoint>[];

        final copied = originalLine.copyWith(
          points: newPoints,
          color: Colors.purple,
          strokeWidth: 99.0,
          tool: DrawingTool.eraser,
        );

        expect(copied.points, isEmpty);
        expect(copied.color, Colors.purple);
        expect(copied.strokeWidth, 99.0);
        expect(copied.tool, DrawingTool.eraser);
      });

      test('should not mutate the original instance', () {
        originalLine.copyWith(
          color: Colors.yellow,
          strokeWidth: 50.0,
          tool: DrawingTool.eraser,
        );

        // Original remains unchanged
        expect(originalLine.color, Colors.red);
        expect(originalLine.strokeWidth, 2.0);
        expect(originalLine.tool, DrawingTool.brush);
      });
    });

    test('should be const constructible with empty points', () {
      const line1 = DrawingLine(
        points: [],
        color: Color(0xFF000000),
        strokeWidth: 1.0,
      );
      const line2 = DrawingLine(
        points: [],
        color: Color(0xFF000000),
        strokeWidth: 1.0,
      );

      expect(identical(line1, line2), isTrue);
    });
  });
}
