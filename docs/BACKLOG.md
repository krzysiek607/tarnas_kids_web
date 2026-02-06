# BACKLOG - TaLu Kids

**Ostatnia aktualizacja:** 2026-01-09

---

## W TRAKCIE

Brak aktywnych zadan.

---

## DO ZROBIENIA

### P0 - Krytyczne (musza byc zrobione przed pierwszym releasem)

- [ ] **Dodac state management (Riverpod)**
  - Zainstalowac flutter_riverpod
  - Utworzyc podstawowa strukture providerow
  - Dokumentacja w DECISIONS.md

- [ ] **Dodac routing (go_router)**
  - Zainstalowac go_router
  - Skonfigurowac podstawowe sciezki
  - Przygotowac nawigacje miedzy ekranami

- [ ] **Zaimplementowac ekran Rysowanie**
  - Canvas do rysowania palcem
  - Wybor kolorow
  - Rozne pedzle

- [ ] **Zaimplementowac ekran Nauka**
  - Nauka liter
  - Nauka cyfr
  - Interaktywne cwiczenia

- [ ] **Zaimplementowac ekran Zabawa**
  - Mini gry
  - Quizy
  - Puzzle

### P1 - Wazne (poprawiaja jakosc)

- [ ] **Dodac lokalizacje (i18n)**
  - flutter_localizations
  - Przygotowac strukture tlumaczen
  - Polski jako podstawowy jezyk

- [ ] **Dodac wiecej testow jednostkowych**
  - Testy dla BigButton
  - Testy dla wszystkich ekranow
  - Coverage > 70%

- [ ] **Dodac CI/CD**
  - GitHub Actions
  - Automatyczne testy
  - Automatyczny build

- [ ] **Dodac dzwieki**
  - Dzwiek klikniecia przyciskow
  - Dzwieki w grach
  - Muzyka w tle (opcjonalnie)

### P2 - Nice to have (przyszlosc)

- [ ] **Dodac analytics**
  - Firebase Analytics lub alternatywa
  - Tracking uzycia funkcji

- [ ] **Dodac crash reporting**
  - Firebase Crashlytics lub Sentry

- [ ] **Dodac onboarding**
  - Pierwszy ekran powitalny dla rodzicow/dzieci

- [ ] **Dodac settings screen**
  - Ustawienia dzwieku
  - Ustawienia jezykowe
  - Informacje o aplikacji

- [ ] **Dodac dark mode**
  - Automatyczne przelaczanie
  - Reczne przelaczanie

---

## UKONCZONE

- [x] **Zainicjalizowac Git repository** (2026-01-09)
- [x] **Utworzyc strukture docs/** (2026-01-09)
  - CLAUDE.md - instrukcje dla AI
  - BACKLOG.md - ten plik
  - DECISIONS.md - decyzje architektoniczne
- [x] **Naprawic test widget_test.dart** (2026-01-09)
  - Test sprawdza teraz nowy HomeScreen z "Witaj!"
  - Wszystkie testy przechodza
- [x] **Usunac print() z kodu produkcyjnego** (2026-01-09)
  - Nowy main.dart nie zawiera print()
- [x] **Dodac theme system (AppTheme)** (2026-01-09)
  - Material Design 3 colors
  - Typografia dla dzieci (duze, czytelne fonty)
  - Gradienty i cienie
- [x] **Utworzyc strukture ekranow** (2026-01-09)
  - lib/screens/home_screen.dart
  - lib/screens/drawing_screen.dart (placeholder)
  - lib/screens/learning_screen.dart (placeholder)
  - lib/screens/fun_screen.dart (placeholder)
- [x] **Utworzyc BigButton widget** (2026-01-09)
  - lib/widgets/big_button.dart
  - Animacja wciskania
  - Gradient i cien
  - Emoji i IconData support
- [x] **Naprawic deprecated API** (2026-01-09)
  - ColorScheme bez background/onBackground
  - withValues zamiast withOpacity
- [x] **0 bledow w flutter analyze** (2026-01-09)

---

## ZNANE BUGI

### Krytyczne
Brak.

### Srednie
Brak.

### Niskie
Brak.

---

## NOTATKI

### Konwencje priorytetow
- **P0**: Blocker - musi byc zrobione przed releasem
- **P1**: Wazne - znaczaco poprawia jakosc/UX
- **P2**: Nice to have - mozna dodac pozniej

### Aktualna struktura projektu
```
lib/
├── main.dart           # Punkt wejscia aplikacji
├── screens/
│   ├── home_screen.dart      # Ekran glowny z przyciskami
│   ├── drawing_screen.dart   # Ekran rysowania (placeholder)
│   ├── learning_screen.dart  # Ekran nauki (placeholder)
│   └── fun_screen.dart       # Ekran zabawy (placeholder)
├── widgets/
│   └── big_button.dart       # Duzy przycisk dla dzieci
└── theme/
    └── app_theme.dart        # Kolory, typografia, style
```

---

## MILESTONE 1: MVP (Minimum Viable Product)

Cel: Podstawowa aplikacja z wlasciwa architektura

Wymagania:
- [x] Git repository
- [x] Dokumentacja (docs/)
- [x] Struktura ekranow (screens/)
- [x] Theme system
- [x] Naprawione testy
- [x] Brak warningow w flutter analyze
- [ ] State management (Riverpod)
- [ ] Routing (go_router)
- [ ] Przynajmniej jeden dzialajacy ekran (Rysowanie)
