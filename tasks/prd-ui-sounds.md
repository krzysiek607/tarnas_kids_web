# PRD: Dźwięki UI (UI Sound Effects)

## Introduction

Dodanie dźwięków interfejsu użytkownika do aplikacji Tarnas Kids. Dźwięki będą odtwarzane przy interakcjach użytkownika (kliknięcia przycisków, sukces w grze, błąd). Poprawi to immersję i feedback dla dzieci.

## Goals

- Dodać dźwięki kliknięcia przycisków w całej aplikacji
- Dodać dźwięk sukcesu przy ukończeniu zadania/rundy
- Dodać dźwięk błędu przy nieprawidłowej odpowiedzi
- Zapewnić możliwość wyłączenia dźwięków niezależnie od muzyki
- Zachować niskie zużycie zasobów (preload, cache)

## User Stories

### US-001: Serwis dźwięków UI
**Description:** Jako developer, potrzebuję serwisu do zarządzania dźwiękami UI, aby móc je łatwo odtwarzać z dowolnego miejsca aplikacji.

**Acceptance Criteria:**
- [ ] Utworzyć plik `lib/services/sound_effects_service.dart`
- [ ] Singleton pattern (SoundEffectsService.instance)
- [ ] Metody: playClick(), playSuccess(), playError()
- [ ] Preload dźwięków przy inicjalizacji
- [ ] Obsługa włączania/wyłączania dźwięków (isMuted)
- [ ] Typecheck passes (flutter analyze)

### US-002: Provider stanu dźwięków
**Description:** Jako developer, potrzebuję providera Riverpod do zarządzania stanem dźwięków UI.

**Acceptance Criteria:**
- [ ] Utworzyć plik `lib/providers/sound_effects_provider.dart`
- [ ] Stan: isSoundEnabled (bool), volume (double 0-1)
- [ ] Persystencja w SharedPreferences
- [ ] Metody: toggleSound(), setVolume()
- [ ] Typecheck passes (flutter analyze)

### US-003: Pliki dźwiękowe
**Description:** Jako developer, potrzebuję plików dźwiękowych dla UI.

**Acceptance Criteria:**
- [ ] Dodać plik `assets/sounds/click.mp3` (krótki, przyjazny dźwięk kliknięcia)
- [ ] Dodać plik `assets/sounds/success.mp3` (radosny dźwięk sukcesu)
- [ ] Dodać plik `assets/sounds/error.mp3` (delikatny dźwięk błędu, nie straszny)
- [ ] Zarejestrować pliki w pubspec.yaml
- [ ] Typecheck passes (flutter analyze)

### US-004: Integracja dźwięku kliknięcia w HomeScreen
**Description:** Jako użytkownik, chcę słyszeć dźwięk przy kliknięciu przycisków menu głównego.

**Acceptance Criteria:**
- [ ] Dodać dźwięk kliknięcia do 4 przycisków menu (Przygoda, Nauka, Zabawa, Zwierzak)
- [ ] Dodać dźwięk do przycisku muzyki
- [ ] Dźwięk odtwarzany przed nawigacją
- [ ] Typecheck passes (flutter analyze)

### US-005: Integracja dźwięku sukcesu w grach
**Description:** Jako użytkownik, chcę słyszeć dźwięk sukcesu gdy ukończę rundę/poziom w grze.

**Acceptance Criteria:**
- [ ] Dodać dźwięk sukcesu w MazeGameScreen (przy ukończeniu poziomu)
- [ ] Dodać dźwięk sukcesu w DotsGameScreen (przy trafieniu kropki)
- [ ] Dodać dźwięk sukcesu w MatchingGameScreen (przy dopasowaniu pary)
- [ ] Typecheck passes (flutter analyze)

### US-006: Integracja dźwięku sukcesu w modułach nauki
**Description:** Jako użytkownik, chcę słyszeć dźwięk sukcesu gdy poprawnie ukończę zadanie edukacyjne.

**Acceptance Criteria:**
- [ ] Dodać dźwięk sukcesu w PatternTracingScreen
- [ ] Dodać dźwięk sukcesu w LetterTracingScreen
- [ ] Dodać dźwięk sukcesu w FindLetterScreen
- [ ] Dodać dźwięk sukcesu w CountingGameScreen
- [ ] Dodać dźwięk sukcesu w ConnectSyllablesScreen
- [ ] Dodać dźwięk sukcesu w SequenceGameScreen
- [ ] Typecheck passes (flutter analyze)

### US-007: Integracja dźwięku błędu
**Description:** Jako użytkownik, chcę słyszeć delikatny dźwięk gdy popełnię błąd.

**Acceptance Criteria:**
- [ ] Dodać dźwięk błędu w FindLetterScreen (zła odpowiedź)
- [ ] Dodać dźwięk błędu w MatchingGameScreen (złe dopasowanie)
- [ ] Dodać dźwięk błędu w ConnectSyllablesScreen (zła kolejność)
- [ ] Dźwięk delikatny, nie straszący dzieci
- [ ] Typecheck passes (flutter analyze)

## Functional Requirements

- FR-1: SoundEffectsService jako singleton z metodami playClick(), playSuccess(), playError()
- FR-2: Preload wszystkich dźwięków przy starcie aplikacji
- FR-3: Osobne ustawienie dźwięków UI od muzyki w tle
- FR-4: Dźwięki krótkie (< 1 sekunda dla click, < 2 sekundy dla success/error)
- FR-5: Głośność dźwięków UI regulowana niezależnie od muzyki

## Non-Goals

- Brak dźwięków mowy/narracji
- Brak dźwięków ambient/tła
- Brak haptic feedback (wibracje)
- Brak dźwięków dla zwierzaka (osobna funkcjonalność)

## Technical Considerations

- Użyć audioplayers package (już w projekcie)
- Cache AudioPlayer instances dla szybkiego odtwarzania
- Dispose przy zamknięciu aplikacji
- Nie blokować UI przy odtwarzaniu

## Success Metrics

- Dźwięki odtwarzają się natychmiast (< 50ms delay)
- Brak lagów/zacinania przy odtwarzaniu
- Możliwość wyłączenia bez restartu aplikacji

## Open Questions

- Czy dodać ustawienie głośności dźwięków w ustawieniach?
- Czy dźwięki powinny działać gdy aplikacja jest w tle?
