# ZADANIA: Dźwięki UI (UI Sound Effects)

**PRD:** `tasks/prd-ui-sounds.md`
**Data utworzenia:** 31.01.2026
**Status:** Kod gotowy - czeka na assety (click.mp3, error.mp3)

---

## Zadania

- [x] 0.0 Utworzenie brancha
  - [x] 0.1 `git checkout -b feature/ui-sounds` (użyty istniejący ralph/ui-sounds)

- [x] 1.0 Setup infrastruktury dźwięków
  - [x] 1.1 Utworzyć `lib/services/sound_effects_service.dart` (już istniał)
    - Singleton pattern (SoundEffectsService.instance)
    - Metody: playClick(), playSuccess(), playError()
    - Preload dźwięków w init()
    - Obsługa isMuted
  - [x] 1.2 Utworzyć `lib/providers/sound_effects_provider.dart`
    - StateNotifier z isSoundEnabled (bool)
    - Persystencja w SharedPreferences
    - Metoda toggleSound()
  - [ ] 1.3 Dodać pliki dźwiękowe do `assets/sounds/` ⏳ (czeka na użytkownika)
    - click.mp3 (krótki, przyjazny) ❌
    - success.mp3 (już istnieje) ✅
    - error.mp3 (delikatny, nie straszny) ❌
  - [x] 1.4 Zarejestrować nowe assety w `pubspec.yaml` (już zarejestrowane)
  - [x] 1.5 Uruchomić `flutter analyze` - zero błędów krytycznych

- [x] 2.0 Integracja dźwięku kliknięcia w HomeScreen
  - [x] 2.1 Zaimportować SoundEffectsService w `home_screen.dart`
  - [x] 2.2 Dodać playClick() do przycisku "Przygoda"
  - [x] 2.3 Dodać playClick() do przycisku "Nauka"
  - [x] 2.4 Dodać playClick() do przycisku "Zabawa"
  - [x] 2.5 Dodać playClick() do przycisku "Zwierzak"
  - [x] 2.6 Dodać playClick() do przycisku muzyki
  - [x] 2.7 Uruchomić `flutter analyze` - naprawić błędy

- [x] 3.0 Integracja dźwięku sukcesu w grach (Zabawa)
  - [x] 3.1 MazeGameScreen - playSuccess() (już było)
  - [x] 3.2 DotsGameScreen - playSuccess() przy trafieniu kropki
  - [x] 3.3 MatchingGameScreen - playSuccess() (już było)
  - [x] 3.4 Uruchomić `flutter analyze` - naprawić błędy

- [x] 4.0 Integracja dźwięku sukcesu w modułach nauki
  - [x] 4.1 PatternTracingScreen - playSuccess() (w TracingCanvas)
  - [x] 4.2 LetterTracingScreen - playSuccess() (w TracingCanvas)
  - [x] 4.3 FindLetterScreen - playSuccess() (już było)
  - [x] 4.4 CountingGameScreen - playSuccess() (już było)
  - [x] 4.5 ConnectSyllablesScreen - playSuccess() (już było)
  - [x] 4.6 SequenceGameScreen - playSuccess() (już było)
  - [x] 4.7 Uruchomić `flutter analyze` - naprawić błędy

- [x] 5.0 Integracja dźwięku błędu
  - [x] 5.1 FindLetterScreen - playError() przy złej odpowiedzi
  - [x] 5.2 MatchingGameScreen - playError() przy złym dopasowaniu
  - [x] 5.3 ConnectSyllablesScreen - playError() przy złej kolejności
  - [x] 5.4 Uruchomić `flutter analyze` - naprawić błędy

- [ ] 6.0 Weryfikacja końcowa ⏳
  - [x] 6.1 Pełny `flutter analyze` - zero błędów krytycznych
  - [ ] 6.2 Test manualny wszystkich dźwięków na emulatorze
  - [ ] 6.3 Test toggle dźwięków (włącz/wyłącz)
  - [ ] 6.4 Test persystencji (restart aplikacji)
  - [ ] 6.5 Commit i merge do main

---

## Notatki

### Pliki do modyfikacji
- `lib/services/sound_effects_service.dart` (NOWY)
- `lib/providers/sound_effects_provider.dart` (NOWY)
- `lib/screens/home_screen.dart`
- `lib/screens/games/maze_game_screen.dart`
- `lib/screens/games/dots_game_screen.dart`
- `lib/screens/games/matching_game_screen.dart`
- `lib/screens/learning/pattern_tracing_screen.dart`
- `lib/screens/learning/letter_tracing_screen.dart`
- `lib/screens/learning/find_letter_screen.dart`
- `lib/screens/learning/counting_game_screen.dart`
- `lib/screens/learning/connect_syllables_screen.dart`
- `lib/screens/learning/sequence_game_screen.dart`
- `pubspec.yaml`

### Zależności
- Zadanie 1.0 musi być ukończone przed 2.0-5.0
- Zadania 2.0-5.0 mogą być realizowane równolegle
- Zadanie 6.0 na końcu

### Assety potrzebne od użytkownika
- `assets/sounds/click.mp3`
- `assets/sounds/error.mp3`
- (success.mp3 prawdopodobnie już istnieje)
