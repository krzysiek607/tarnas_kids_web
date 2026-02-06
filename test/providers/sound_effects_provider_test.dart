import 'package:flutter_test/flutter_test.dart';
import 'package:talu_kids/providers/sound_effects_provider.dart';

void main() {
  group('SoundEffectsState', () {
    group('konstruktor domyslny', () {
      test('powinien byc wlaczony domyslnie', () {
        const state = SoundEffectsState();

        expect(state.isEnabled, true);
      });

      test('powinien miec domyslna glosnosc 1.0', () {
        const state = SoundEffectsState();

        expect(state.volume, 1.0);
      });
    });

    group('konstruktor z parametrami', () {
      test('powinien przyjac isEnabled = false', () {
        const state = SoundEffectsState(isEnabled: false);

        expect(state.isEnabled, false);
      });

      test('powinien przyjac dowolna glosnosc', () {
        const state = SoundEffectsState(volume: 0.5);

        expect(state.volume, 0.5);
      });

      test('powinien przyjac glosnosc 0.0', () {
        const state = SoundEffectsState(volume: 0.0);

        expect(state.volume, 0.0);
      });
    });

    group('copyWith', () {
      test('powinien skopiowac z nowym isEnabled', () {
        const original = SoundEffectsState(isEnabled: true);
        final copied = original.copyWith(isEnabled: false);

        expect(copied.isEnabled, false);
        expect(copied.volume, 1.0);
      });

      test('powinien skopiowac z nowa glosnoscia', () {
        const original = SoundEffectsState(volume: 1.0);
        final copied = original.copyWith(volume: 0.3);

        expect(copied.volume, 0.3);
        expect(copied.isEnabled, true);
      });

      test('powinien zachowac wartosci gdy nie podano parametrow', () {
        const original = SoundEffectsState(isEnabled: false, volume: 0.7);
        final copied = original.copyWith();

        expect(copied.isEnabled, false);
        expect(copied.volume, 0.7);
      });

      test('powinien skopiowac oba parametry naraz', () {
        const original = SoundEffectsState(isEnabled: true, volume: 1.0);
        final copied = original.copyWith(isEnabled: false, volume: 0.2);

        expect(copied.isEnabled, false);
        expect(copied.volume, 0.2);
      });

      test('powinien zachowac niemutowalnosc - oryginal nie zmieniony', () {
        const original = SoundEffectsState(isEnabled: true, volume: 1.0);
        final copied = original.copyWith(isEnabled: false, volume: 0.5);

        expect(original.isEnabled, true);
        expect(original.volume, 1.0);
        expect(copied.isEnabled, false);
        expect(copied.volume, 0.5);
      });
    });

    group('przejscia stanow (symulacja toggle)', () {
      test('wlaczony -> wylaczony', () {
        const enabled = SoundEffectsState(isEnabled: true);
        final disabled = enabled.copyWith(isEnabled: !enabled.isEnabled);

        expect(disabled.isEnabled, false);
      });

      test('wylaczony -> wlaczony', () {
        const disabled = SoundEffectsState(isEnabled: false);
        final enabled = disabled.copyWith(isEnabled: !disabled.isEnabled);

        expect(enabled.isEnabled, true);
      });

      test('cykl toggle: on -> off -> on', () {
        const state1 = SoundEffectsState(isEnabled: true);
        final state2 = state1.copyWith(isEnabled: !state1.isEnabled);
        final state3 = state2.copyWith(isEnabled: !state2.isEnabled);

        expect(state1.isEnabled, true);
        expect(state2.isEnabled, false);
        expect(state3.isEnabled, true);
      });
    });

    group('glosnosc - edge cases', () {
      test('powinien akceptowac glosnosc 0.0', () {
        const state = SoundEffectsState(volume: 0.0);
        expect(state.volume, 0.0);
      });

      test('powinien akceptowac glosnosc 1.0', () {
        const state = SoundEffectsState(volume: 1.0);
        expect(state.volume, 1.0);
      });

      test('powinien akceptowac glosnosc 0.5', () {
        const state = SoundEffectsState(volume: 0.5);
        expect(state.volume, 0.5);
      });

      test('clamp symulacja - wartosci spoza zakresu', () {
        // SoundEffectsNotifier.setVolume() robi clamp,
        // ale sam State nie clampuje - testujemy logike clamp
        const volume = 1.5;
        final clamped = volume.clamp(0.0, 1.0);
        expect(clamped, 1.0);

        const volumeNeg = -0.5;
        final clampedNeg = volumeNeg.clamp(0.0, 1.0);
        expect(clampedNeg, 0.0);
      });

      test('clamp zachowuje wartosci w zakresie', () {
        const volume = 0.7;
        final clamped = volume.clamp(0.0, 1.0);
        expect(clamped, 0.7);
      });
    });

    group('kombinacje stanow', () {
      test('wylaczony z glosnoscia 0', () {
        const state = SoundEffectsState(isEnabled: false, volume: 0.0);

        expect(state.isEnabled, false);
        expect(state.volume, 0.0);
      });

      test('wlaczony z pelna glosnoscia', () {
        const state = SoundEffectsState(isEnabled: true, volume: 1.0);

        expect(state.isEnabled, true);
        expect(state.volume, 1.0);
      });

      test('wlaczony z zerowa glosnoscia (wyciszony ale nie off)', () {
        const state = SoundEffectsState(isEnabled: true, volume: 0.0);

        expect(state.isEnabled, true);
        expect(state.volume, 0.0);
      });
    });
  });
}
