import 'package:flutter_test/flutter_test.dart';
import 'package:talu_kids/providers/background_music_provider.dart';

void main() {
  group('BackgroundMusicState', () {
    group('konstruktor domyslny', () {
      test('powinien nie grac domyslnie', () {
        const state = BackgroundMusicState();

        expect(state.isPlaying, false);
      });

      test('powinien miec domyslna glosnosc 0.5', () {
        const state = BackgroundMusicState();

        expect(state.volume, 0.5);
      });

      test('powinien nie miec bledu domyslnie', () {
        const state = BackgroundMusicState();

        expect(state.error, isNull);
      });

      test('powinien nie byc wyciszony przez uzytkownika domyslnie', () {
        const state = BackgroundMusicState();

        expect(state.userMuted, false);
      });
    });

    group('konstruktor z parametrami', () {
      test('powinien przyjac isPlaying = true', () {
        const state = BackgroundMusicState(isPlaying: true);

        expect(state.isPlaying, true);
      });

      test('powinien przyjac dowolna glosnosc', () {
        const state = BackgroundMusicState(volume: 0.8);

        expect(state.volume, 0.8);
      });

      test('powinien przyjac blad', () {
        const state = BackgroundMusicState(error: 'Audio niedostepne');

        expect(state.error, 'Audio niedostepne');
      });

      test('powinien przyjac userMuted = true', () {
        const state = BackgroundMusicState(userMuted: true);

        expect(state.userMuted, true);
      });
    });

    group('copyWith', () {
      test('powinien skopiowac z nowym isPlaying', () {
        const original = BackgroundMusicState();
        final copied = original.copyWith(isPlaying: true);

        expect(copied.isPlaying, true);
        expect(copied.volume, 0.5);
        expect(copied.error, isNull);
        expect(copied.userMuted, false);
      });

      test('powinien skopiowac z nowa glosnoscia', () {
        const original = BackgroundMusicState(volume: 0.5);
        final copied = original.copyWith(volume: 0.8);

        expect(copied.volume, 0.8);
        expect(copied.isPlaying, false);
      });

      test('powinien skopiowac z bledem', () {
        const original = BackgroundMusicState();
        final copied = original.copyWith(error: 'Blad audio');

        expect(copied.error, 'Blad audio');
      });

      test('powinien wyczyScic blad przez ustawienie null', () {
        const original = BackgroundMusicState(error: 'Stary blad');
        // error jest nullable, copyWith ustawia error: error (bez ?? this.error)
        final copied = original.copyWith(error: null);

        expect(copied.error, isNull);
      });

      test('powinien skopiowac z userMuted', () {
        const original = BackgroundMusicState(userMuted: false);
        final copied = original.copyWith(userMuted: true);

        expect(copied.userMuted, true);
      });

      test('powinien zachowac wartosci gdy nie podano parametrow', () {
        const original = BackgroundMusicState(
          isPlaying: true,
          volume: 0.7,
          userMuted: true,
        );
        final copied = original.copyWith();

        expect(copied.isPlaying, true);
        expect(copied.volume, 0.7);
        expect(copied.userMuted, true);
      });

      test('powinien zachowac niemutowalnosc', () {
        const original = BackgroundMusicState(isPlaying: false, volume: 0.5);
        final copied = original.copyWith(isPlaying: true, volume: 1.0);

        expect(original.isPlaying, false);
        expect(original.volume, 0.5);
        expect(copied.isPlaying, true);
        expect(copied.volume, 1.0);
      });
    });

    group('przejscia stanow - play/pause', () {
      test('stop -> play', () {
        const stopped = BackgroundMusicState(isPlaying: false);
        final playing = stopped.copyWith(isPlaying: true);

        expect(playing.isPlaying, true);
      });

      test('play -> pause', () {
        const playing = BackgroundMusicState(isPlaying: true);
        final paused = playing.copyWith(isPlaying: false);

        expect(paused.isPlaying, false);
      });

      test('cykl: stop -> play -> pause -> play', () {
        const state1 = BackgroundMusicState(isPlaying: false);
        final state2 = state1.copyWith(isPlaying: true);
        final state3 = state2.copyWith(isPlaying: false);
        final state4 = state3.copyWith(isPlaying: true);

        expect(state1.isPlaying, false);
        expect(state2.isPlaying, true);
        expect(state3.isPlaying, false);
        expect(state4.isPlaying, true);
      });
    });

    group('przejscia stanow - toggle (userMuted)', () {
      test('toggle wylacza - ustawia userMuted i zatrzymuje', () {
        const playing = BackgroundMusicState(isPlaying: true, userMuted: false);

        // Symulacja toggle() gdy gra:
        // 1. Ustaw userMuted = true
        // 2. pause() -> isPlaying = false
        final muted = playing.copyWith(userMuted: true);
        final paused = muted.copyWith(isPlaying: false);

        expect(paused.isPlaying, false);
        expect(paused.userMuted, true);
      });

      test('toggle wlacza - usuwa userMuted i startuje', () {
        const paused = BackgroundMusicState(isPlaying: false, userMuted: true);

        // Symulacja toggle() gdy nie gra:
        // 1. Ustaw userMuted = false
        // 2. play() -> isPlaying = true
        final unmuted = paused.copyWith(userMuted: false);
        final playing = unmuted.copyWith(isPlaying: true);

        expect(playing.isPlaying, true);
        expect(playing.userMuted, false);
      });
    });

    group('przejscia stanow - onAppPaused/onAppResumed', () {
      test('app paused zatrzymuje muzyke', () {
        const playing = BackgroundMusicState(isPlaying: true, userMuted: false);
        final paused = playing.copyWith(isPlaying: false);

        expect(paused.isPlaying, false);
        expect(paused.userMuted, false); // userMuted nie zmieniony
      });

      test('app resumed wznawia jesli userMuted = false', () {
        const paused = BackgroundMusicState(isPlaying: false, userMuted: false);
        final resumed = paused.copyWith(isPlaying: true);

        expect(resumed.isPlaying, true);
      });

      test('app resumed NIE wznawia jesli userMuted = true', () {
        const paused = BackgroundMusicState(isPlaying: false, userMuted: true);

        // Stan nie zmienia sie - nie wznawiamy
        expect(paused.isPlaying, false);
        expect(paused.userMuted, true);
      });
    });

    group('obsluga bledow', () {
      test('blad przy play', () {
        const state = BackgroundMusicState();
        final withError = state.copyWith(
          isPlaying: false,
          error: 'Audio play error: Platform not supported',
        );

        expect(withError.isPlaying, false);
        expect(withError.error, isNotNull);
        expect(withError.error, contains('Audio play error'));
      });

      test('wyczyszczenie bledu po udanym play', () {
        const withError = BackgroundMusicState(
          isPlaying: false,
          error: 'Stary blad',
        );
        final recovered = withError.copyWith(isPlaying: true, error: null);

        expect(recovered.isPlaying, true);
        expect(recovered.error, isNull);
      });

      test('blad platformy nie zmienia userMuted', () {
        const state = BackgroundMusicState(userMuted: false);
        final withError = state.copyWith(
          error: 'Audio niedostepne na tej platformie',
        );

        expect(withError.userMuted, false);
        expect(withError.error, isNotNull);
      });
    });

    group('glosnosc', () {
      test('domyslna glosnosc to 0.5', () {
        const state = BackgroundMusicState();
        expect(state.volume, 0.5);
      });

      test('zmiana glosnosci zachowuje isPlaying', () {
        const state = BackgroundMusicState(isPlaying: true, volume: 0.5);
        final changed = state.copyWith(volume: 0.8);

        expect(changed.volume, 0.8);
        expect(changed.isPlaying, true);
      });

      test('glosnosc 0.0', () {
        const state = BackgroundMusicState(volume: 0.0);
        expect(state.volume, 0.0);
      });

      test('glosnosc 1.0', () {
        const state = BackgroundMusicState(volume: 1.0);
        expect(state.volume, 1.0);
      });
    });

    group('kombinacje stanow', () {
      test('gra z pelna glosnoscia', () {
        const state = BackgroundMusicState(
          isPlaying: true,
          volume: 1.0,
          userMuted: false,
        );

        expect(state.isPlaying, true);
        expect(state.volume, 1.0);
        expect(state.userMuted, false);
        expect(state.error, isNull);
      });

      test('wyciszony przez uzytkownika z bledem', () {
        const state = BackgroundMusicState(
          isPlaying: false,
          volume: 0.5,
          userMuted: true,
          error: 'Jakis blad',
        );

        expect(state.isPlaying, false);
        expect(state.userMuted, true);
        expect(state.error, 'Jakis blad');
      });

      test('gra z niska glosnoscia i bez bledu', () {
        const state = BackgroundMusicState(
          isPlaying: true,
          volume: 0.1,
          userMuted: false,
          error: null,
        );

        expect(state.isPlaying, true);
        expect(state.volume, 0.1);
        expect(state.error, isNull);
      });
    });
  });
}
