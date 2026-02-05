import 'dart:math';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:tarnas_kids/models/tracing_path.dart';

void main() {
  // ============================================
  // Waypoint
  // ============================================
  group('Waypoint', () {
    group('constructor (normalized)', () {
      test('should create with coordinates and default flags', () {
        const wp = Waypoint(0.5, 0.7);

        expect(wp.x, 0.5);
        expect(wp.y, 0.7);
        expect(wp.isStartPoint, isFalse);
        expect(wp.isEndPoint, isFalse);
        expect(wp.isNormalized, isTrue);
      });

      test('should create with isStartPoint flag', () {
        const wp = Waypoint(0.0, 0.0, isStartPoint: true);

        expect(wp.isStartPoint, isTrue);
        expect(wp.isEndPoint, isFalse);
      });

      test('should create with isEndPoint flag', () {
        const wp = Waypoint(1.0, 1.0, isEndPoint: true);

        expect(wp.isEndPoint, isTrue);
        expect(wp.isStartPoint, isFalse);
      });

      test('should create with both start and end flags', () {
        const wp = Waypoint(0.5, 0.5, isStartPoint: true, isEndPoint: true);

        expect(wp.isStartPoint, isTrue);
        expect(wp.isEndPoint, isTrue);
      });

      test('should default isNormalized to true', () {
        const wp = Waypoint(0.3, 0.8);
        expect(wp.isNormalized, isTrue);
      });

      test('should be const constructible', () {
        const wp1 = Waypoint(0.5, 0.5);
        const wp2 = Waypoint(0.5, 0.5);
        expect(identical(wp1, wp2), isTrue);
      });
    });

    group('Waypoint.pixels constructor', () {
      test('should create pixel-based waypoint', () {
        const wp = Waypoint.pixels(100.0, 200.0);

        expect(wp.x, 100.0);
        expect(wp.y, 200.0);
        expect(wp.isNormalized, isFalse);
        expect(wp.isStartPoint, isFalse);
        expect(wp.isEndPoint, isFalse);
      });

      test('should create pixel waypoint with start flag', () {
        const wp = Waypoint.pixels(0.0, 0.0, isStartPoint: true);

        expect(wp.isStartPoint, isTrue);
        expect(wp.isNormalized, isFalse);
      });

      test('should create pixel waypoint with end flag', () {
        const wp = Waypoint.pixels(300.0, 400.0, isEndPoint: true);

        expect(wp.isEndPoint, isTrue);
        expect(wp.isNormalized, isFalse);
      });
    });

    group('toOffset', () {
      test('should convert normalized coordinates to pixels', () {
        const wp = Waypoint(0.5, 0.25);
        const canvasSize = Size(400.0, 800.0);

        final offset = wp.toOffset(canvasSize);

        expect(offset.dx, 200.0); // 0.5 * 400
        expect(offset.dy, 200.0); // 0.25 * 800
      });

      test('should convert (0, 0) normalized to (0, 0) pixels', () {
        const wp = Waypoint(0.0, 0.0);
        const canvasSize = Size(300.0, 300.0);

        final offset = wp.toOffset(canvasSize);

        expect(offset.dx, 0.0);
        expect(offset.dy, 0.0);
      });

      test('should convert (1, 1) normalized to canvas bottom-right', () {
        const wp = Waypoint(1.0, 1.0);
        const canvasSize = Size(500.0, 600.0);

        final offset = wp.toOffset(canvasSize);

        expect(offset.dx, 500.0);
        expect(offset.dy, 600.0);
      });

      test('should return pixel coordinates directly for non-normalized', () {
        const wp = Waypoint.pixels(150.0, 250.0);
        const canvasSize = Size(400.0, 800.0);

        final offset = wp.toOffset(canvasSize);

        // Pixel waypoints ignore canvas size
        expect(offset.dx, 150.0);
        expect(offset.dy, 250.0);
      });

      test('should handle non-square canvas for normalized coords', () {
        const wp = Waypoint(0.5, 0.5);
        const canvasSize = Size(200.0, 600.0);

        final offset = wp.toOffset(canvasSize);

        expect(offset.dx, 100.0); // 0.5 * 200
        expect(offset.dy, 300.0); // 0.5 * 600
      });
    });

    group('fromPixels', () {
      test('should create normalized waypoint from pixel offset', () {
        final wp = Waypoint.fromPixels(
          const Offset(200.0, 400.0),
          const Size(400.0, 800.0),
        );

        expect(wp.x, 0.5); // 200 / 400
        expect(wp.y, 0.5); // 400 / 800
        expect(wp.isNormalized, isTrue);
        expect(wp.isStartPoint, isFalse);
        expect(wp.isEndPoint, isFalse);
      });

      test('should create start point from pixels', () {
        final wp = Waypoint.fromPixels(
          const Offset(0.0, 0.0),
          const Size(100.0, 100.0),
          isStartPoint: true,
        );

        expect(wp.x, 0.0);
        expect(wp.y, 0.0);
        expect(wp.isStartPoint, isTrue);
      });

      test('should create end point from pixels', () {
        final wp = Waypoint.fromPixels(
          const Offset(100.0, 100.0),
          const Size(100.0, 100.0),
          isEndPoint: true,
        );

        expect(wp.x, 1.0);
        expect(wp.y, 1.0);
        expect(wp.isEndPoint, isTrue);
      });

      test('should handle non-square canvas', () {
        final wp = Waypoint.fromPixels(
          const Offset(100.0, 300.0),
          const Size(200.0, 600.0),
        );

        expect(wp.x, 0.5);
        expect(wp.y, 0.5);
      });

      test('should round-trip: fromPixels -> toOffset returns original', () {
        const originalOffset = Offset(123.0, 456.0);
        const canvasSize = Size(500.0, 800.0);

        final wp = Waypoint.fromPixels(originalOffset, canvasSize);
        final result = wp.toOffset(canvasSize);

        expect(result.dx, closeTo(originalOffset.dx, 0.001));
        expect(result.dy, closeTo(originalOffset.dy, 0.001));
      });
    });

    group('toString', () {
      test('should include coordinates and flags for normalized', () {
        const wp = Waypoint(0.5, 0.7, isStartPoint: true);
        final str = wp.toString();

        expect(str, contains('0.5'));
        expect(str, contains('0.7'));
        expect(str, contains('start: true'));
        expect(str, contains('end: false'));
        expect(str, contains('px: false')); // isNormalized == true => !isNormalized == false
      });

      test('should show px: true for pixel waypoints', () {
        const wp = Waypoint.pixels(100, 200);
        final str = wp.toString();

        expect(str, contains('px: true'));
      });
    });
  });

  // ============================================
  // WaypointValidationResult
  // ============================================
  group('WaypointValidationResult', () {
    group('progress', () {
      test('should return 0.0 when no waypoints reached', () {
        const result = WaypointValidationResult(
          totalWaypoints: 10,
          reachedWaypoints: 0,
          currentWaypointIndex: 0,
          distanceToNext: 100.0,
          isComplete: false,
          isOnTrack: true,
        );

        expect(result.progress, 0.0);
      });

      test('should return 0.5 when half waypoints reached', () {
        const result = WaypointValidationResult(
          totalWaypoints: 10,
          reachedWaypoints: 5,
          currentWaypointIndex: 5,
          distanceToNext: 50.0,
          isComplete: false,
          isOnTrack: true,
        );

        expect(result.progress, 0.5);
      });

      test('should return 1.0 when all waypoints reached', () {
        const result = WaypointValidationResult(
          totalWaypoints: 8,
          reachedWaypoints: 8,
          currentWaypointIndex: 8,
          distanceToNext: 0.0,
          isComplete: true,
          isOnTrack: true,
        );

        expect(result.progress, 1.0);
      });

      test('should return 0.0 when totalWaypoints is 0', () {
        const result = WaypointValidationResult(
          totalWaypoints: 0,
          reachedWaypoints: 0,
          currentWaypointIndex: 0,
          distanceToNext: 0.0,
          isComplete: true,
          isOnTrack: true,
        );

        expect(result.progress, 0.0);
      });

      test('should handle fractional progress (1/3)', () {
        const result = WaypointValidationResult(
          totalWaypoints: 3,
          reachedWaypoints: 1,
          currentWaypointIndex: 1,
          distanceToNext: 30.0,
          isComplete: false,
          isOnTrack: true,
        );

        expect(result.progress, closeTo(0.3333, 0.001));
      });
    });

    group('progressPercent', () {
      test('should return 0 for no progress', () {
        const result = WaypointValidationResult(
          totalWaypoints: 5,
          reachedWaypoints: 0,
          currentWaypointIndex: 0,
          distanceToNext: 100.0,
          isComplete: false,
          isOnTrack: false,
        );

        expect(result.progressPercent, 0);
      });

      test('should return 50 for half progress', () {
        const result = WaypointValidationResult(
          totalWaypoints: 4,
          reachedWaypoints: 2,
          currentWaypointIndex: 2,
          distanceToNext: 30.0,
          isComplete: false,
          isOnTrack: true,
        );

        expect(result.progressPercent, 50);
      });

      test('should return 100 for complete', () {
        const result = WaypointValidationResult(
          totalWaypoints: 6,
          reachedWaypoints: 6,
          currentWaypointIndex: 6,
          distanceToNext: 0.0,
          isComplete: true,
          isOnTrack: true,
        );

        expect(result.progressPercent, 100);
      });

      test('should round correctly for 1/3 (33%)', () {
        const result = WaypointValidationResult(
          totalWaypoints: 3,
          reachedWaypoints: 1,
          currentWaypointIndex: 1,
          distanceToNext: 30.0,
          isComplete: false,
          isOnTrack: true,
        );

        expect(result.progressPercent, 33);
      });

      test('should round correctly for 2/3 (67%)', () {
        const result = WaypointValidationResult(
          totalWaypoints: 3,
          reachedWaypoints: 2,
          currentWaypointIndex: 2,
          distanceToNext: 15.0,
          isComplete: false,
          isOnTrack: true,
        );

        expect(result.progressPercent, 67);
      });
    });

    group('toString', () {
      test('should contain progress info', () {
        const result = WaypointValidationResult(
          totalWaypoints: 10,
          reachedWaypoints: 3,
          currentWaypointIndex: 3,
          distanceToNext: 25.0,
          isComplete: false,
          isOnTrack: true,
        );

        final str = result.toString();
        expect(str, contains('3/10'));
        expect(str, contains('30%'));
        expect(str, contains('complete: false'));
        expect(str, contains('onTrack: true'));
      });
    });
  });

  // ============================================
  // TracingPath
  // ============================================
  group('TracingPath', () {
    // Shared test data
    const canvasSize = Size(400.0, 400.0);

    TracingPath createSimplePath({
      double hitRadiusPx = 22.0,
      double maxErrorPx = 50.0,
    }) {
      return TracingPath(
        id: 'test_path',
        name: 'Test Path',
        waypoints: const [
          Waypoint(0.0, 0.0, isStartPoint: true), // (0, 0) on 400x400
          Waypoint(0.5, 0.0),                      // (200, 0)
          Waypoint(1.0, 0.0, isEndPoint: true),     // (400, 0)
        ],
        hitRadiusPx: hitRadiusPx,
        maxErrorPx: maxErrorPx,
      );
    }

    group('constructor', () {
      test('should create with required parameters and defaults', () {
        const path = TracingPath(
          id: 'letter_A',
          name: 'Litera A',
          waypoints: [],
        );

        expect(path.id, 'letter_A');
        expect(path.name, 'Litera A');
        expect(path.hint, isNull);
        expect(path.waypoints, isEmpty);
        expect(path.hitRadiusPx, 22.0);
        expect(path.maxErrorPx, 50.0);
      });

      test('should create with all parameters', () {
        const path = TracingPath(
          id: 'pattern_wave',
          name: 'Fala',
          hint: 'Rysuj od lewej do prawej',
          waypoints: [
            Waypoint(0.1, 0.5, isStartPoint: true),
            Waypoint(0.9, 0.5, isEndPoint: true),
          ],
          hitRadiusPx: 30.0,
          maxErrorPx: 60.0,
        );

        expect(path.id, 'pattern_wave');
        expect(path.name, 'Fala');
        expect(path.hint, 'Rysuj od lewej do prawej');
        expect(path.waypoints.length, 2);
        expect(path.hitRadiusPx, 30.0);
        expect(path.maxErrorPx, 60.0);
      });

      test('should have correct default hitRadiusPx of 22', () {
        const path = TracingPath(
          id: 'test',
          name: 'Test',
          waypoints: [],
        );
        expect(path.hitRadiusPx, 22.0);
      });

      test('should have correct default maxErrorPx of 50', () {
        const path = TracingPath(
          id: 'test',
          name: 'Test',
          waypoints: [],
        );
        expect(path.maxErrorPx, 50.0);
      });
    });

    group('toString', () {
      test('should include id and waypoint count', () {
        const path = TracingPath(
          id: 'my_path',
          name: 'My Path',
          waypoints: [
            Waypoint(0.0, 0.0),
            Waypoint(1.0, 1.0),
          ],
        );

        expect(path.toString(), 'TracingPath(my_path, waypoints: 2)');
      });

      test('should show 0 waypoints for empty path', () {
        const path = TracingPath(
          id: 'empty',
          name: 'Empty',
          waypoints: [],
        );

        expect(path.toString(), 'TracingPath(empty, waypoints: 0)');
      });
    });

    // ============================================
    // isAtNextWaypoint
    // ============================================
    group('isAtNextWaypoint', () {
      test('should return true when point is exactly on waypoint', () {
        final path = createSimplePath();

        // Waypoint 0 is at (0, 0) on 400x400 canvas
        final result = path.isAtNextWaypoint(
          const Offset(0.0, 0.0),
          0,
          canvasSize,
        );

        expect(result, isTrue);
      });

      test('should return true when point is within hit radius', () {
        final path = createSimplePath(hitRadiusPx: 22.0);

        // Waypoint 0 is at (0, 0), point at (10, 10)
        // Distance = sqrt(100 + 100) = sqrt(200) ~= 14.14 < 22
        final result = path.isAtNextWaypoint(
          const Offset(10.0, 10.0),
          0,
          canvasSize,
        );

        expect(result, isTrue);
      });

      test('should return true at exact boundary of hit radius', () {
        final path = createSimplePath(hitRadiusPx: 5.0);

        // Waypoint 1 is at (200, 0), point at (205, 0)
        // Distance = 5.0 == hitRadius
        final result = path.isAtNextWaypoint(
          const Offset(205.0, 0.0),
          1,
          canvasSize,
        );

        expect(result, isTrue);
      });

      test('should return false when point is just outside hit radius', () {
        final path = createSimplePath(hitRadiusPx: 5.0);

        // Waypoint 1 is at (200, 0), point at (205.1, 0)
        // Distance = 5.1 > 5.0
        final result = path.isAtNextWaypoint(
          const Offset(205.1, 0.0),
          1,
          canvasSize,
        );

        expect(result, isFalse);
      });

      test('should return false when currentIndex exceeds waypoint count', () {
        final path = createSimplePath();

        final result = path.isAtNextWaypoint(
          const Offset(0.0, 0.0),
          3, // only 3 waypoints (indices 0, 1, 2)
          canvasSize,
        );

        expect(result, isFalse);
      });

      test('should return false when currentIndex equals waypoint count', () {
        final path = createSimplePath();

        final result = path.isAtNextWaypoint(
          const Offset(0.0, 0.0),
          3, // equals waypoints.length
          canvasSize,
        );

        expect(result, isFalse);
      });

      test('should use diagonal distance correctly', () {
        final path = createSimplePath(hitRadiusPx: 5.0);

        // Waypoint 0 at (0,0), point at (3, 4) => distance = 5.0 (3-4-5 triangle)
        final result = path.isAtNextWaypoint(
          const Offset(3.0, 4.0),
          0,
          canvasSize,
        );

        expect(result, isTrue);
      });

      test('should fail for diagonal distance just outside', () {
        final path = createSimplePath(hitRadiusPx: 4.99);

        // Waypoint 0 at (0,0), point at (3, 4) => distance = 5.0 > 4.99
        final result = path.isAtNextWaypoint(
          const Offset(3.0, 4.0),
          0,
          canvasSize,
        );

        expect(result, isFalse);
      });

      test('should work with normalized waypoints on non-square canvas', () {
        const nonSquareCanvas = Size(200.0, 600.0);
        const path = TracingPath(
          id: 'test',
          name: 'Test',
          waypoints: [
            Waypoint(0.5, 0.5), // => (100, 300) on 200x600 canvas
          ],
          hitRadiusPx: 10.0,
        );

        // Point at (105, 300), distance = 5 < 10
        final result = path.isAtNextWaypoint(
          const Offset(105.0, 300.0),
          0,
          nonSquareCanvas,
        );

        expect(result, isTrue);
      });

      test('should work with pixel-based waypoints ignoring canvas size', () {
        const path = TracingPath(
          id: 'test',
          name: 'Test',
          waypoints: [
            Waypoint.pixels(100.0, 100.0),
          ],
          hitRadiusPx: 15.0,
        );

        // Pixel waypoints use absolute coords regardless of canvas
        final result = path.isAtNextWaypoint(
          const Offset(110.0, 100.0),
          0,
          canvasSize,
        );

        // Distance = 10 < 15
        expect(result, isTrue);
      });
    });

    // ============================================
    // isOffTrack
    // ============================================
    group('isOffTrack', () {
      test('should return false when currentIndex is 0', () {
        final path = createSimplePath();

        // At first waypoint, cannot be off track (no previous segment)
        final result = path.isOffTrack(
          const Offset(999.0, 999.0),
          0,
          canvasSize,
        );

        expect(result, isFalse);
      });

      test('should return false when currentIndex exceeds waypoint count', () {
        final path = createSimplePath();

        final result = path.isOffTrack(
          const Offset(999.0, 999.0),
          3, // >= waypoints.length
          canvasSize,
        );

        expect(result, isFalse);
      });

      test('should return false when point is on the line between waypoints', () {
        final path = createSimplePath(maxErrorPx: 50.0);

        // Between waypoint 0 (0,0) and waypoint 1 (200,0)
        // Point at (100, 0) is exactly on the line
        final result = path.isOffTrack(
          const Offset(100.0, 0.0),
          1,
          canvasSize,
        );

        expect(result, isFalse);
      });

      test('should return false when point is within maxError from line', () {
        final path = createSimplePath(maxErrorPx: 50.0);

        // Line from (0,0) to (200,0), point at (100, 30)
        // Distance from horizontal line = 30 < 50
        final result = path.isOffTrack(
          const Offset(100.0, 30.0),
          1,
          canvasSize,
        );

        expect(result, isFalse);
      });

      test('should return true when point is beyond maxError from line', () {
        final path = createSimplePath(maxErrorPx: 50.0);

        // Line from (0,0) to (200,0), point at (100, 51)
        // Distance from horizontal line = 51 > 50
        final result = path.isOffTrack(
          const Offset(100.0, 51.0),
          1,
          canvasSize,
        );

        expect(result, isTrue);
      });

      test('should return false at exact boundary of maxError', () {
        final path = createSimplePath(maxErrorPx: 50.0);

        // Line from (0,0) to (200,0), point at (100, 50)
        // Distance = 50.0, not > 50.0 (boundary: not off track)
        final result = path.isOffTrack(
          const Offset(100.0, 50.0),
          1,
          canvasSize,
        );

        expect(result, isFalse);
      });

      test('should handle perpendicular distance to diagonal line', () {
        const path = TracingPath(
          id: 'diag',
          name: 'Diagonal',
          waypoints: [
            Waypoint.pixels(0.0, 0.0, isStartPoint: true),
            Waypoint.pixels(100.0, 100.0, isEndPoint: true),
          ],
          maxErrorPx: 10.0,
        );

        // Line from (0,0) to (100,100) is y = x
        // Point at (0, 10): closest on segment is (5, 5)
        // Distance = sqrt(25 + 25) = sqrt(50) ~= 7.07 < 10
        final result = path.isOffTrack(
          const Offset(0.0, 10.0),
          1,
          canvasSize,
        );

        expect(result, isFalse);
      });

      test('should detect off-track for point far from diagonal', () {
        const path = TracingPath(
          id: 'diag',
          name: 'Diagonal',
          waypoints: [
            Waypoint.pixels(0.0, 0.0, isStartPoint: true),
            Waypoint.pixels(100.0, 100.0, isEndPoint: true),
          ],
          maxErrorPx: 5.0,
        );

        // Point at (0, 50), line from (0,0) to (100,100)
        // Projection t = (0*100 + 50*100) / 20000 = 5000/20000 = 0.25
        // Nearest point on line: (25, 25)
        // Distance = sqrt(625 + 625) = sqrt(1250) ~= 35.36 > 5
        final result = path.isOffTrack(
          const Offset(0.0, 50.0),
          1,
          canvasSize,
        );

        expect(result, isTrue);
      });
    });

    // ============================================
    // validateProgress
    // ============================================
    group('validateProgress', () {
      group('edge cases', () {
        test('should handle empty waypoints', () {
          const path = TracingPath(
            id: 'empty',
            name: 'Empty',
            waypoints: [],
          );

          final result = path.validateProgress(
            [const Offset(100.0, 100.0)],
            canvasSize,
          );

          expect(result.totalWaypoints, 0);
          expect(result.reachedWaypoints, 0);
          expect(result.currentWaypointIndex, 0);
          expect(result.distanceToNext, 0.0);
          expect(result.isComplete, isTrue);
          expect(result.isOnTrack, isTrue);
        });

        test('should handle empty user path', () {
          final path = createSimplePath();

          final result = path.validateProgress(
            [],
            canvasSize,
          );

          expect(result.totalWaypoints, 3);
          expect(result.reachedWaypoints, 0);
          expect(result.currentWaypointIndex, 0);
          expect(result.distanceToNext, double.infinity);
          expect(result.isComplete, isFalse);
          expect(result.isOnTrack, isFalse);
        });

        test('should handle both empty waypoints and empty user path', () {
          const path = TracingPath(
            id: 'empty',
            name: 'Empty',
            waypoints: [],
          );

          final result = path.validateProgress([], canvasSize);

          expect(result.totalWaypoints, 0);
          expect(result.isComplete, isTrue);
          expect(result.isOnTrack, isTrue);
        });
      });

      group('waypoint reaching', () {
        test('should reach first waypoint when user draws near it', () {
          final path = createSimplePath(hitRadiusPx: 22.0);

          // Waypoint 0 at (0,0), user point at (10, 10), dist ~= 14.14 < 22
          final result = path.validateProgress(
            [const Offset(10.0, 10.0)],
            canvasSize,
          );

          expect(result.reachedWaypoints, 1);
          expect(result.currentWaypointIndex, 1);
          expect(result.isComplete, isFalse);
        });

        test('should reach multiple waypoints in sequence', () {
          final path = createSimplePath(hitRadiusPx: 22.0);

          // Waypoints: (0,0), (200,0), (400,0)
          final result = path.validateProgress(
            [
              const Offset(5.0, 0.0),   // near (0,0) -> reach wp 0
              const Offset(100.0, 0.0),  // between
              const Offset(195.0, 0.0),  // near (200,0) -> reach wp 1
              const Offset(300.0, 0.0),  // between
              const Offset(398.0, 0.0),  // near (400,0) -> reach wp 2
            ],
            canvasSize,
          );

          expect(result.reachedWaypoints, 3);
          expect(result.isComplete, isTrue);
        });

        test('should stop at first unreached waypoint', () {
          final path = createSimplePath(hitRadiusPx: 10.0);

          // Waypoints: (0,0), (200,0), (400,0)
          // User reaches wp 0 but skips wp 1, goes straight to wp 2
          final result = path.validateProgress(
            [
              const Offset(5.0, 0.0),   // near (0,0) -> reach wp 0
              const Offset(395.0, 0.0),  // near (400,0) but wp 1 not reached
            ],
            canvasSize,
          );

          // Should stop at wp 1 (not reached)
          expect(result.reachedWaypoints, 1);
          expect(result.currentWaypointIndex, 1);
          expect(result.isComplete, isFalse);
        });

        test('should not reach any waypoint when user draws far away', () {
          final path = createSimplePath(hitRadiusPx: 10.0);

          // All waypoints are at y=0, user draws at y=200
          final result = path.validateProgress(
            [
              const Offset(0.0, 200.0),
              const Offset(200.0, 200.0),
              const Offset(400.0, 200.0),
            ],
            canvasSize,
          );

          expect(result.reachedWaypoints, 0);
          expect(result.currentWaypointIndex, 0);
          expect(result.isComplete, isFalse);
        });
      });

      group('distanceToNext calculation', () {
        test('should calculate distance to first waypoint', () {
          final path = createSimplePath();

          // User at (100, 0), next waypoint is wp 0 at (0, 0)
          // But user does not reach wp 0 (distance = 100 > 22 default)
          final result = path.validateProgress(
            [const Offset(100.0, 0.0)],
            canvasSize,
          );

          // distanceToNext is from last user point to next unreached waypoint
          expect(result.distanceToNext, 100.0);
        });

        test('should calculate distance to second waypoint after reaching first', () {
          final path = createSimplePath(hitRadiusPx: 22.0);

          // User reaches wp 0 at (0,0), last point at (50,0)
          // Next is wp 1 at (200,0)
          final result = path.validateProgress(
            [
              const Offset(5.0, 0.0),  // reaches wp 0
              const Offset(50.0, 0.0), // last point
            ],
            canvasSize,
          );

          expect(result.reachedWaypoints, 1);
          // Distance from (50,0) to (200,0) = 150
          expect(result.distanceToNext, 150.0);
        });

        test('should have 0 distanceToNext when all waypoints complete', () {
          final path = createSimplePath(hitRadiusPx: 22.0);

          final result = path.validateProgress(
            [
              const Offset(0.0, 0.0),
              const Offset(200.0, 0.0),
              const Offset(400.0, 0.0),
            ],
            canvasSize,
          );

          expect(result.isComplete, isTrue);
          // When all waypoints reached, currentWaypointIndex == waypoints.length
          // The distance calculation branch is skipped, distanceToNext stays 0
          expect(result.distanceToNext, 0.0);
        });
      });

      group('isOnTrack detection', () {
        test('should be on track when user follows the path', () {
          final path = createSimplePath(
            hitRadiusPx: 22.0,
            maxErrorPx: 50.0,
          );

          // Waypoints: (0,0), (200,0), (400,0)
          // User reaches wp 0, last point close to line
          final result = path.validateProgress(
            [
              const Offset(5.0, 0.0),   // reaches wp 0
              const Offset(100.0, 10.0), // 10px from line, < 50px maxError
            ],
            canvasSize,
          );

          expect(result.reachedWaypoints, 1);
          expect(result.isOnTrack, isTrue);
        });

        test('should be off track when user deviates too much', () {
          final path = createSimplePath(
            hitRadiusPx: 22.0,
            maxErrorPx: 50.0,
          );

          // Waypoints: (0,0), (200,0), (400,0) - horizontal line
          // User reaches wp 0, then moves far from path
          final result = path.validateProgress(
            [
              const Offset(5.0, 0.0),    // reaches wp 0
              const Offset(100.0, 60.0),  // 60px from horizontal line, > 50px
            ],
            canvasSize,
          );

          expect(result.reachedWaypoints, 1);
          expect(result.isOnTrack, isFalse);
        });

        test('should be on track when no waypoints reached yet (default)', () {
          final path = createSimplePath();

          // User has not reached any waypoint, isOnTrack check is skipped
          // because currentWaypointIndex <= 0
          final result = path.validateProgress(
            [const Offset(999.0, 999.0)],
            canvasSize,
          );

          expect(result.reachedWaypoints, 0);
          // isOnTrack remains true (default) when currentWaypointIndex is 0
          expect(result.isOnTrack, isTrue);
        });

        test('should be on track when all waypoints completed', () {
          final path = createSimplePath(hitRadiusPx: 22.0);

          // All waypoints reached, currentWaypointIndex == waypoints.length
          // isOnTrack check is skipped
          final result = path.validateProgress(
            [
              const Offset(0.0, 0.0),
              const Offset(200.0, 0.0),
              const Offset(400.0, 0.0),
            ],
            canvasSize,
          );

          expect(result.isComplete, isTrue);
          expect(result.isOnTrack, isTrue);
        });
      });

      group('progress and progressPercent via validateProgress', () {
        test('should report 0% with no reached waypoints', () {
          final path = createSimplePath();

          final result = path.validateProgress(
            [const Offset(999.0, 999.0)],
            canvasSize,
          );

          expect(result.progress, 0.0);
          expect(result.progressPercent, 0);
        });

        test('should report 33% with 1 of 3 waypoints reached', () {
          final path = createSimplePath(hitRadiusPx: 22.0);

          final result = path.validateProgress(
            [const Offset(5.0, 0.0)], // reaches wp 0 only
            canvasSize,
          );

          expect(result.reachedWaypoints, 1);
          expect(result.totalWaypoints, 3);
          expect(result.progressPercent, 33);
        });

        test('should report 67% with 2 of 3 waypoints reached', () {
          final path = createSimplePath(hitRadiusPx: 22.0);

          final result = path.validateProgress(
            [
              const Offset(5.0, 0.0),   // reaches wp 0
              const Offset(195.0, 0.0),  // reaches wp 1
            ],
            canvasSize,
          );

          expect(result.reachedWaypoints, 2);
          expect(result.progressPercent, 67);
        });

        test('should report 100% when all waypoints reached', () {
          final path = createSimplePath(hitRadiusPx: 22.0);

          final result = path.validateProgress(
            [
              const Offset(0.0, 0.0),
              const Offset(200.0, 0.0),
              const Offset(400.0, 0.0),
            ],
            canvasSize,
          );

          expect(result.progressPercent, 100);
        });
      });

      group('complex scenarios', () {
        test('should handle single waypoint path', () {
          const path = TracingPath(
            id: 'single',
            name: 'Single Point',
            waypoints: [
              Waypoint(0.5, 0.5, isStartPoint: true, isEndPoint: true),
            ],
            hitRadiusPx: 20.0,
          );

          // Waypoint at (200, 200) on 400x400
          final result = path.validateProgress(
            [const Offset(200.0, 200.0)],
            canvasSize,
          );

          expect(result.totalWaypoints, 1);
          expect(result.reachedWaypoints, 1);
          expect(result.isComplete, isTrue);
          expect(result.progress, 1.0);
        });

        test('should handle many user points reaching a single waypoint', () {
          const path = TracingPath(
            id: 'test',
            name: 'Test',
            waypoints: [
              Waypoint.pixels(100.0, 100.0, isStartPoint: true),
              Waypoint.pixels(200.0, 100.0, isEndPoint: true),
            ],
            hitRadiusPx: 15.0,
          );

          // Many points near waypoint 0
          final result = path.validateProgress(
            [
              const Offset(90.0, 100.0),
              const Offset(95.0, 100.0),
              const Offset(100.0, 100.0), // exactly on wp 0
              const Offset(105.0, 100.0),
              const Offset(110.0, 100.0),
            ],
            canvasSize,
          );

          expect(result.reachedWaypoints, 1); // only wp 0, not wp 1
          expect(result.isComplete, isFalse);
        });

        test('should detect reaching waypoint from any user point, not just last', () {
          final path = createSimplePath(hitRadiusPx: 10.0);

          // User first point reaches wp 0 at (0,0), second is far
          // The algorithm checks ALL user points against each waypoint
          final result = path.validateProgress(
            [
              const Offset(5.0, 0.0),     // near wp 0 (0,0) -> reached
              const Offset(200.0, 200.0),  // not near wp 1 (200,0)
            ],
            canvasSize,
          );

          expect(result.reachedWaypoints, 1);
        });

        test('should use LetterWaypoints.bigA with realistic user path', () {
          final path = TracingPath(
            id: 'letter_A',
            name: 'Litera A',
            waypoints: LetterWaypoints.bigA,
            hitRadiusPx: 30.0,
          );

          const canvas = Size(300.0, 300.0);

          // First waypoint at (0.15, 0.85) => (45, 255)
          // Second at (0.3, 0.5) => (90, 150)
          final result = path.validateProgress(
            [
              const Offset(45.0, 255.0),  // exactly on wp 0
              const Offset(60.0, 210.0),  // on the way
              const Offset(90.0, 150.0),  // exactly on wp 1
            ],
            canvas,
          );

          expect(result.reachedWaypoints, 2);
          expect(result.totalWaypoints, LetterWaypoints.bigA.length);
        });
      });
    });

    // ============================================
    // _pointToLineDistance (tested indirectly)
    // ============================================
    group('point to line distance (tested via isOffTrack)', () {
      test('should compute 0 distance for point on horizontal line', () {
        const path = TracingPath(
          id: 'h',
          name: 'Horizontal',
          waypoints: [
            Waypoint.pixels(0.0, 100.0, isStartPoint: true),
            Waypoint.pixels(200.0, 100.0, isEndPoint: true),
          ],
          maxErrorPx: 1.0, // very tight tolerance
        );

        // Point exactly on the line
        final result = path.isOffTrack(
          const Offset(100.0, 100.0),
          1,
          canvasSize,
        );

        expect(result, isFalse);
      });

      test('should compute correct distance for point above horizontal line', () {
        const path = TracingPath(
          id: 'h',
          name: 'Horizontal',
          waypoints: [
            Waypoint.pixels(0.0, 100.0, isStartPoint: true),
            Waypoint.pixels(200.0, 100.0, isEndPoint: true),
          ],
          maxErrorPx: 25.0,
        );

        // Point 30px above the line
        final result = path.isOffTrack(
          const Offset(100.0, 70.0),
          1,
          canvasSize,
        );

        // Distance = 30 > 25
        expect(result, isTrue);
      });

      test('should compute correct distance for point on vertical line', () {
        const path = TracingPath(
          id: 'v',
          name: 'Vertical',
          waypoints: [
            Waypoint.pixels(100.0, 0.0, isStartPoint: true),
            Waypoint.pixels(100.0, 200.0, isEndPoint: true),
          ],
          maxErrorPx: 20.0,
        );

        // Point 15px right of vertical line
        final result = path.isOffTrack(
          const Offset(115.0, 100.0),
          1,
          canvasSize,
        );

        // Distance = 15 < 20
        expect(result, isFalse);
      });

      test('should handle degenerate line (start == end)', () {
        const path = TracingPath(
          id: 'point',
          name: 'Point',
          waypoints: [
            Waypoint.pixels(100.0, 100.0, isStartPoint: true),
            Waypoint.pixels(100.0, 100.0, isEndPoint: true),
          ],
          maxErrorPx: 10.0,
        );

        // When line is a point, distance = point-to-point distance
        // Point at (107, 100), distance = 7 < 10
        final result = path.isOffTrack(
          const Offset(107.0, 100.0),
          1,
          canvasSize,
        );

        expect(result, isFalse);
      });

      test('should handle degenerate line with point far away', () {
        const path = TracingPath(
          id: 'point',
          name: 'Point',
          waypoints: [
            Waypoint.pixels(100.0, 100.0, isStartPoint: true),
            Waypoint.pixels(100.0, 100.0, isEndPoint: true),
          ],
          maxErrorPx: 10.0,
        );

        // Distance from (100,100) to (120,100) = 20 > 10
        final result = path.isOffTrack(
          const Offset(120.0, 100.0),
          1,
          canvasSize,
        );

        expect(result, isTrue);
      });

      test('should compute distance to line endpoint (not infinite line)', () {
        // Tests that projection is clamped to segment [0, 1]
        const path = TracingPath(
          id: 'seg',
          name: 'Segment',
          waypoints: [
            Waypoint.pixels(0.0, 0.0, isStartPoint: true),
            Waypoint.pixels(100.0, 0.0, isEndPoint: true),
          ],
          maxErrorPx: 5.0,
        );

        // Point at (150, 0) is beyond the end of segment
        // Closest point on segment is (100, 0)
        // Distance = 50 > 5
        final result = path.isOffTrack(
          const Offset(150.0, 0.0),
          1,
          canvasSize,
        );

        expect(result, isTrue);
      });

      test('should compute distance to segment start when projection is negative', () {
        const path = TracingPath(
          id: 'seg',
          name: 'Segment',
          waypoints: [
            Waypoint.pixels(100.0, 0.0, isStartPoint: true),
            Waypoint.pixels(200.0, 0.0, isEndPoint: true),
          ],
          maxErrorPx: 5.0,
        );

        // Point at (50, 0) is before the start of segment
        // Closest point on segment is (100, 0) (clamped to t=0)
        // Distance = 50 > 5
        final result = path.isOffTrack(
          const Offset(50.0, 0.0),
          1,
          canvasSize,
        );

        expect(result, isTrue);
      });

      test('should compute known 3-4-5 triangle distance', () {
        const path = TracingPath(
          id: 'seg',
          name: 'Segment',
          waypoints: [
            Waypoint.pixels(0.0, 0.0, isStartPoint: true),
            Waypoint.pixels(100.0, 0.0, isEndPoint: true),
          ],
          maxErrorPx: 4.5,
        );

        // Point at (50, 4): perpendicular distance to horizontal line = 4
        // 4 < 4.5 => not off track
        final resultInside = path.isOffTrack(
          const Offset(50.0, 4.0),
          1,
          canvasSize,
        );
        expect(resultInside, isFalse);

        // Point at (50, 5): perpendicular distance = 5
        // 5 > 4.5 => off track
        final resultOutside = path.isOffTrack(
          const Offset(50.0, 5.0),
          1,
          canvasSize,
        );
        expect(resultOutside, isTrue);
      });

      test('should compute distance to 45-degree diagonal line', () {
        // Line from (0,0) to (100,100)
        // Point at (50, 0)
        // Projection: t = (50*100 + 0*100) / 20000 = 0.25
        // Nearest: (25, 25)
        // Distance = sqrt(625 + 625) = sqrt(1250) ~= 35.36
        const path = TracingPath(
          id: 'diag',
          name: 'Diagonal',
          waypoints: [
            Waypoint.pixels(0.0, 0.0, isStartPoint: true),
            Waypoint.pixels(100.0, 100.0, isEndPoint: true),
          ],
          maxErrorPx: 36.0, // just above 35.36
        );

        final result = path.isOffTrack(
          const Offset(50.0, 0.0),
          1,
          canvasSize,
        );

        // Distance ~= 35.36 < 36 => not off track
        expect(result, isFalse);

        // Now with tighter tolerance
        const pathTight = TracingPath(
          id: 'diag',
          name: 'Diagonal',
          waypoints: [
            Waypoint.pixels(0.0, 0.0, isStartPoint: true),
            Waypoint.pixels(100.0, 100.0, isEndPoint: true),
          ],
          maxErrorPx: 35.0, // just below 35.36
        );

        final resultTight = pathTight.isOffTrack(
          const Offset(50.0, 0.0),
          1,
          canvasSize,
        );

        // Distance ~= 35.36 > 35 => off track
        expect(resultTight, isTrue);
      });
    });

    // ============================================
    // generateFromPath (static method)
    // ============================================
    group('generateFromPath', () {
      test('should return empty list for empty path', () {
        final emptyPath = Path();
        final waypoints = TracingPath.generateFromPath(
          emptyPath,
          canvasSize,
        );

        expect(waypoints, isEmpty);
      });

      test('should generate waypoints from simple line path', () {
        final linePath = Path()
          ..moveTo(0, 0)
          ..lineTo(400, 0);

        final waypoints = TracingPath.generateFromPath(
          linePath,
          canvasSize,
          sampleCount: 5,
        );

        expect(waypoints.length, 5);
        // First should be start point
        expect(waypoints.first.isStartPoint, isTrue);
        // Last should be end point
        expect(waypoints.last.isEndPoint, isTrue);
        // All should be normalized
        for (final wp in waypoints) {
          expect(wp.isNormalized, isTrue);
        }
      });

      test('should mark first waypoint as start point', () {
        final path = Path()
          ..moveTo(0, 0)
          ..lineTo(100, 100);

        final waypoints = TracingPath.generateFromPath(
          path,
          canvasSize,
          sampleCount: 3,
        );

        expect(waypoints.first.isStartPoint, isTrue);
        expect(waypoints.first.isEndPoint, isFalse);
      });

      test('should mark last waypoint as end point', () {
        final path = Path()
          ..moveTo(0, 0)
          ..lineTo(100, 100);

        final waypoints = TracingPath.generateFromPath(
          path,
          canvasSize,
          sampleCount: 3,
        );

        expect(waypoints.last.isEndPoint, isTrue);
        expect(waypoints.last.isStartPoint, isFalse);
      });

      test('should generate correct number of samples', () {
        final path = Path()
          ..moveTo(0, 0)
          ..lineTo(300, 0);

        final waypoints3 = TracingPath.generateFromPath(
          path,
          canvasSize,
          sampleCount: 3,
        );
        expect(waypoints3.length, 3);

        final waypoints10 = TracingPath.generateFromPath(
          path,
          canvasSize,
          sampleCount: 10,
        );
        expect(waypoints10.length, 10);
      });

      test('should produce normalized coordinates within 0-1 range for path inside canvas', () {
        final path = Path()
          ..moveTo(0, 0)
          ..lineTo(400, 400);

        final waypoints = TracingPath.generateFromPath(
          path,
          canvasSize,
          sampleCount: 5,
        );

        for (final wp in waypoints) {
          expect(wp.x, greaterThanOrEqualTo(0.0));
          expect(wp.x, lessThanOrEqualTo(1.0));
          expect(wp.y, greaterThanOrEqualTo(0.0));
          expect(wp.y, lessThanOrEqualTo(1.0));
        }
      });

      test('should produce evenly spaced waypoints for straight line', () {
        final path = Path()
          ..moveTo(0, 0)
          ..lineTo(400, 0); // horizontal line, length = 400

        final waypoints = TracingPath.generateFromPath(
          path,
          canvasSize,
          sampleCount: 5,
        );

        // Expected normalized x: 0, 0.25, 0.5, 0.75, 1.0
        expect(waypoints[0].x, closeTo(0.0, 0.01));
        expect(waypoints[1].x, closeTo(0.25, 0.01));
        expect(waypoints[2].x, closeTo(0.5, 0.01));
        expect(waypoints[3].x, closeTo(0.75, 0.01));
        expect(waypoints[4].x, closeTo(1.0, 0.01));

        // All y should be 0
        for (final wp in waypoints) {
          expect(wp.y, closeTo(0.0, 0.01));
        }
      });

      test('should default to 10 sample points', () {
        final path = Path()
          ..moveTo(0, 0)
          ..lineTo(100, 100);

        final waypoints = TracingPath.generateFromPath(
          path,
          canvasSize,
        );

        expect(waypoints.length, 10);
      });

      test('should handle curved path (quadratic bezier)', () {
        final path = Path()
          ..moveTo(0, 200)
          ..quadraticBezierTo(200, 0, 400, 200);

        final waypoints = TracingPath.generateFromPath(
          path,
          canvasSize,
          sampleCount: 5,
        );

        expect(waypoints.length, 5);
        // Start at (0, 200) => normalized (0, 0.5)
        expect(waypoints.first.x, closeTo(0.0, 0.01));
        expect(waypoints.first.y, closeTo(0.5, 0.01));
        // End at (400, 200) => normalized (1.0, 0.5)
        expect(waypoints.last.x, closeTo(1.0, 0.01));
        expect(waypoints.last.y, closeTo(0.5, 0.01));
      });
    });
  });

  // ============================================
  // LetterWaypoints (predefined letter paths)
  // ============================================
  group('LetterWaypoints', () {
    test('bigA should have correct start and end points', () {
      final waypoints = LetterWaypoints.bigA;

      expect(waypoints.first.isStartPoint, isTrue);
      expect(waypoints.last.isEndPoint, isTrue);
    });

    test('bigA should have 7 waypoints', () {
      expect(LetterWaypoints.bigA.length, 7);
    });

    test('bigA waypoints should all be normalized', () {
      for (final wp in LetterWaypoints.bigA) {
        expect(wp.isNormalized, isTrue);
        expect(wp.x, greaterThanOrEqualTo(0.0));
        expect(wp.x, lessThanOrEqualTo(1.0));
        expect(wp.y, greaterThanOrEqualTo(0.0));
        expect(wp.y, lessThanOrEqualTo(1.0));
      }
    });

    test('smallA should have correct start and end points', () {
      final waypoints = LetterWaypoints.smallA;

      expect(waypoints.first.isStartPoint, isTrue);
      expect(waypoints.last.isEndPoint, isTrue);
    });

    test('smallA should have 7 waypoints', () {
      expect(LetterWaypoints.smallA.length, 7);
    });

    test('bigB should have correct start and end points', () {
      final waypoints = LetterWaypoints.bigB;

      expect(waypoints.first.isStartPoint, isTrue);
      expect(waypoints.last.isEndPoint, isTrue);
    });

    test('bigB should have 12 waypoints', () {
      expect(LetterWaypoints.bigB.length, 12);
    });

    test('bigC should have correct start and end points', () {
      final waypoints = LetterWaypoints.bigC;

      expect(waypoints.first.isStartPoint, isTrue);
      expect(waypoints.last.isEndPoint, isTrue);
    });

    test('bigC should have 7 waypoints', () {
      expect(LetterWaypoints.bigC.length, 7);
    });

    test('all letter waypoints should be in normalized range', () {
      final allLetters = [
        LetterWaypoints.bigA,
        LetterWaypoints.smallA,
        LetterWaypoints.bigB,
        LetterWaypoints.bigC,
      ];

      for (final letter in allLetters) {
        for (final wp in letter) {
          expect(wp.x, greaterThanOrEqualTo(0.0),
              reason: 'x should be >= 0 in ${wp.toString()}');
          expect(wp.x, lessThanOrEqualTo(1.0),
              reason: 'x should be <= 1 in ${wp.toString()}');
          expect(wp.y, greaterThanOrEqualTo(0.0),
              reason: 'y should be >= 0 in ${wp.toString()}');
          expect(wp.y, lessThanOrEqualTo(1.0),
              reason: 'y should be <= 1 in ${wp.toString()}');
        }
      }
    });
  });

  // ============================================
  // PatternWaypoints (predefined pattern paths)
  // ============================================
  group('PatternWaypoints', () {
    group('straightLine', () {
      test('should have 5 waypoints', () {
        expect(PatternWaypoints.straightLine.length, 5);
      });

      test('should have start and end flags', () {
        final wps = PatternWaypoints.straightLine;
        expect(wps.first.isStartPoint, isTrue);
        expect(wps.last.isEndPoint, isTrue);
      });

      test('should all be at y=0.5 (horizontal)', () {
        for (final wp in PatternWaypoints.straightLine) {
          expect(wp.y, 0.5);
        }
      });

      test('should be ordered left to right (increasing x)', () {
        final wps = PatternWaypoints.straightLine;
        for (int i = 1; i < wps.length; i++) {
          expect(wps[i].x, greaterThanOrEqualTo(wps[i - 1].x));
        }
      });
    });

    group('wave', () {
      test('should have 8 waypoints', () {
        expect(PatternWaypoints.wave.length, 8);
      });

      test('should have start and end flags', () {
        final wps = PatternWaypoints.wave;
        expect(wps.first.isStartPoint, isTrue);
        expect(wps.last.isEndPoint, isTrue);
      });

      test('should have alternating y values (wave pattern)', () {
        final wps = PatternWaypoints.wave;
        // After first point, peaks should be at y=0.3 and valleys at y=0.7
        expect(wps[1].y, 0.3); // peak
        expect(wps[2].y, 0.7); // valley
        expect(wps[3].y, 0.3); // peak
        expect(wps[4].y, 0.7); // valley
      });
    });

    group('zigzag', () {
      test('should have 7 waypoints', () {
        expect(PatternWaypoints.zigzag.length, 7);
      });

      test('should have start and end flags', () {
        final wps = PatternWaypoints.zigzag;
        expect(wps.first.isStartPoint, isTrue);
        expect(wps.last.isEndPoint, isTrue);
      });
    });

    group('loops', () {
      test('should have 13 waypoints', () {
        expect(PatternWaypoints.loops.length, 13);
      });

      test('should have start and end flags', () {
        final wps = PatternWaypoints.loops;
        expect(wps.first.isStartPoint, isTrue);
        expect(wps.last.isEndPoint, isTrue);
      });
    });

    group('spiral', () {
      test('should have 14 waypoints', () {
        expect(PatternWaypoints.spiral.length, 14);
      });

      test('should have start and end flags', () {
        final wps = PatternWaypoints.spiral;
        expect(wps.first.isStartPoint, isTrue);
        expect(wps.last.isEndPoint, isTrue);
      });

      test('should start at center (0.5, 0.5)', () {
        final wps = PatternWaypoints.spiral;
        expect(wps.first.x, 0.5);
        expect(wps.first.y, 0.5);
      });
    });

    test('all pattern waypoints should be in normalized range', () {
      final allPatterns = [
        PatternWaypoints.straightLine,
        PatternWaypoints.wave,
        PatternWaypoints.zigzag,
        PatternWaypoints.loops,
        PatternWaypoints.spiral,
      ];

      for (final pattern in allPatterns) {
        for (final wp in pattern) {
          expect(wp.x, greaterThanOrEqualTo(0.0));
          expect(wp.x, lessThanOrEqualTo(1.0));
          expect(wp.y, greaterThanOrEqualTo(0.0));
          expect(wp.y, lessThanOrEqualTo(1.0));
        }
      }
    });

    test('all patterns should start with isStartPoint and end with isEndPoint', () {
      final allPatterns = [
        PatternWaypoints.straightLine,
        PatternWaypoints.wave,
        PatternWaypoints.zigzag,
        PatternWaypoints.loops,
        PatternWaypoints.spiral,
      ];

      for (final pattern in allPatterns) {
        expect(pattern.first.isStartPoint, isTrue,
            reason: 'Pattern should start with isStartPoint');
        expect(pattern.last.isEndPoint, isTrue,
            reason: 'Pattern should end with isEndPoint');
      }
    });
  });
}
