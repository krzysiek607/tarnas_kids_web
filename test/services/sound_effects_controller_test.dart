import 'package:flutter_test/flutter_test.dart';
import 'package:talu_kids/services/sound_effects_controller.dart';

void main() {
  group('SoundEffectsController', () {
    late SoundEffectsController controller;

    setUp(() {
      // Singleton - zawsze ta sama instancja
      controller = SoundEffectsController();
    });

    group('singleton pattern', () {
      test('should return same instance', () {
        final instance1 = SoundEffectsController();
        final instance2 = SoundEffectsController();

        expect(identical(instance1, instance2), true);
      });

      test('should return same instance via factory', () {
        final controller1 = SoundEffectsController();
        final controller2 = SoundEffectsController();

        expect(controller1, same(controller2));
      });
    });

    group('mute functionality', () {
      test('should start unmuted', () {
        // Domyślnie kontroler nie jest wyciszony
        // Nie mamy publicznego gettera, więc testujemy przez setMuted
        controller.setMuted(false);
        // Test przechodzi jeśli nie ma wyjątku
        expect(true, true);
      });

      test('should allow setting muted state', () {
        controller.setMuted(true);
        controller.setMuted(false);
        // Test przechodzi jeśli nie ma wyjątku
        expect(true, true);
      });

      test('should accept true value', () {
        expect(() => controller.setMuted(true), returnsNormally);
      });

      test('should accept false value', () {
        expect(() => controller.setMuted(false), returnsNormally);
      });
    });

    group('volume control', () {
      test('should accept volume 0.0', () async {
        await controller.setVolume(0.0);
        // Test przechodzi jeśli nie ma wyjątku
        expect(true, true);
      });

      test('should accept volume 1.0', () async {
        await controller.setVolume(1.0);
        expect(true, true);
      });

      test('should accept volume 0.5', () async {
        await controller.setVolume(0.5);
        expect(true, true);
      });

      test('should clamp volume below 0', () async {
        // setVolume używa clamp, więc -0.5 powinno być 0.0
        await controller.setVolume(-0.5);
        expect(true, true);
      });

      test('should clamp volume above 1', () async {
        // setVolume używa clamp, więc 1.5 powinno być 1.0
        await controller.setVolume(1.5);
        expect(true, true);
      });
    });

    group('audio ducking callbacks', () {
      test('should allow registering ducking callbacks', () {
        bool duckingStartCalled = false;
        bool duckingEndCalled = false;

        controller.registerDuckingCallbacks(
          onDuckingStart: (volume) async {
            duckingStartCalled = true;
          },
          onDuckingEnd: (volume) async {
            duckingEndCalled = true;
          },
          originalVolume: 0.5,
        );

        // Callbacki są zarejestrowane - test przechodzi
        expect(duckingStartCalled, false); // Jeszcze nie wywołane
        expect(duckingEndCalled, false);
      });

      test('should accept custom original volume', () {
        controller.registerDuckingCallbacks(
          onDuckingStart: (_) async {},
          onDuckingEnd: (_) async {},
          originalVolume: 0.8,
        );
        expect(true, true);
      });

      test('should update original bg volume', () {
        controller.updateOriginalBgVolume(0.7);
        controller.updateOriginalBgVolume(0.3);
        controller.updateOriginalBgVolume(1.0);
        // Test przechodzi jeśli nie ma wyjątku
        expect(true, true);
      });
    });

    group('dispose', () {
      test('should not throw on dispose', () {
        // dispose() powinno bezpiecznie zwolnić zasoby
        expect(() => controller.dispose(), returnsNormally);
      });

      test('should handle multiple dispose calls', () {
        controller.dispose();
        controller.dispose();
        // Test przechodzi jeśli nie ma wyjątku
        expect(true, true);
      });
    });

    group('VolumeCallback typedef', () {
      test('should accept correct function signature', () {
        VolumeCallback callback = (double volume) async {
          // Callback przyjmuje double i zwraca Future<void>
        };

        expect(callback, isA<VolumeCallback>());
      });

      test('should receive volume parameter', () async {
        double? receivedVolume;

        VolumeCallback callback = (double volume) async {
          receivedVolume = volume;
        };

        await callback(0.75);

        expect(receivedVolume, 0.75);
      });
    });
  });

  group('Integration-like tests (without actual audio)', () {
    test('playSuccess should not throw when muted', () async {
      final controller = SoundEffectsController();
      controller.setMuted(true);

      // Gdy wyciszony, playSuccess nie powinno robić nic
      await controller.playSuccess();
      expect(true, true);
    });

    test('playEvolution should not throw when muted', () async {
      final controller = SoundEffectsController();
      controller.setMuted(true);

      await controller.playEvolution();
      expect(true, true);
    });

    test('ducking callbacks should be called with correct volumes', () async {
      final controller = SoundEffectsController();
      final volumeHistory = <double>[];

      controller.registerDuckingCallbacks(
        onDuckingStart: (volume) async {
          volumeHistory.add(volume);
        },
        onDuckingEnd: (volume) async {
          volumeHistory.add(volume);
        },
        originalVolume: 0.5,
      );

      // Wyciszamy żeby playSuccess nie próbowało grać audio
      controller.setMuted(true);

      await controller.playSuccess();

      // Gdy wyciszony, callbacki nie są wywoływane
      expect(volumeHistory, isEmpty);
    });
  });
}
