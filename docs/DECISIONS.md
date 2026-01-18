# DECISIONS - Architecture Decision Records (ADR)

Ten dokument zawiera wszystkie istotne decyzje architektoniczne podjęte w projekcie Tarnas Kids.

---

## ADR-001: Feature-Based Architecture

**Status:** Zaproponowane
**Data:** 2026-01-09
**Decydent:** Team / Claude Code

### Kontekst
Projekt Tarnas Kids jest na wczesnym etapie rozwoju. Obecna struktura (wszystko w main.dart) nie skaluje się dobrze. Potrzebujemy architektury, która:
- Oddziela różne części aplikacji
- Ułatwia współpracę wielu developerów
- Umożliwia łatwe testowanie
- Jest zgodna z najlepszymi praktykami Flutter

### Decyzja
Używamy **feature-based architecture** z podziałem na warstwy (data, domain, presentation).

Struktura:
```
lib/
├── core/              # Współdzielone podstawy
├── features/          # Funkcjonalności (np. drawing, games)
│   └── [feature]/
│       ├── data/      # API, local storage
│       ├── domain/    # Business logic, models
│       └── presentation/  # UI, widgets, state
├── shared/            # Reużywalne komponenty
└── main.dart
```

### Konsekwencje

**Pozytywne:**
- Klarowna separacja odpowiedzialności
- Łatwiejsze testowanie (mocki, unit tests)
- Skalowalne dla większych zespołów
- Nowe feature'y nie wpływają na inne

**Negatywne:**
- Więcej boilerplate'u na początku
- Wymaga dyscypliny w utrzymaniu struktury
- Krzywa uczenia się dla nowych devów

### Alternatywy
- **Flat structure** - wszystko w lib/ (zbyt chaotyczne)
- **Layer-first** - lib/data/, lib/domain/, lib/ui/ (trudniejsze odnalezienie feature'ów)
- **MVC/MVVM** - przestarzałe dla Flutter

---

## ADR-002: State Management - Riverpod

**Status:** Zaproponowane
**Data:** 2026-01-09
**Decydent:** Team / Claude Code

### Kontekst
Flutter wymaga rozwiązania do zarządzania stanem aplikacji. Potrzebujemy czegoś:
- Wydajnego
- Testowalnego
- Z dobrą dokumentacją
- Przyjaznego dla początkujących (ale potężnego)

### Decyzja
Używamy **Riverpod 2.x** jako głównego rozwiązania do state management.

Pakiety:
```yaml
dependencies:
  flutter_riverpod: ^2.5.0

dev_dependencies:
  riverpod_generator: ^2.4.0
  build_runner: ^2.4.0
```

### Konsekwencje

**Pozytywne:**
- Compile-time safety
- Łatwe testowanie (bez context)
- Auto-dispose (brak memory leaks)
- Code generation redukuje boilerplate
- Najnowsze best practices od Flutter team

**Negatywne:**
- Wymaga nauki nowego API
- Code generation dodaje krok do buildu
- Więcej plików (providers osobno)

### Alternatywy
- **Provider** - starszy, mniej features
- **Bloc** - więcej boilerplate'u, overkill dla prostej aplikacji
- **GetX** - złe praktyki, tight coupling
- **setState** - nie skaluje się

---

## ADR-003: Routing - go_router

**Status:** Zaproponowane
**Data:** 2026-01-09
**Decydent:** Team / Claude Code

### Kontekst
Aplikacja będzie miała wiele ekranów (rysowanie, gry, ustawienia). Potrzebujemy:
- Deklaratywnego routingu
- Deep linking support
- Type-safe navigation
- Integracji z Material/Cupertino

### Decyzja
Używamy **go_router 14.x** jako rozwiązania do nawigacji.

```yaml
dependencies:
  go_router: ^14.0.0
```

### Konsekwencje

**Pozytywne:**
- Rekomendowane przez Flutter team
- Obsługuje deep links out-of-the-box
- Deklaratywny routing (łatwiejszy do zrozumienia)
- Guards dla protected routes
- URL-based navigation (przygotowanie na web)

**Negatywne:**
- Bardziej verbose niż Navigator 1.0
- Wymaga nauki nowego API

### Alternatywy
- **Navigator 1.0** - imperatywny, przestarzały
- **Navigator 2.0** - zbyt niskopoziomowy
- **auto_route** - dodatkowa zależność, podobne możliwości

---

## ADR-004: UI Framework - Material Design 3

**Status:** Zaproponowane
**Data:** 2026-01-09
**Decydent:** Team / Claude Code

### Kontekst
Aplikacja dla dzieci wymaga:
- Jasnych, kolorowych UI
- Dużych, łatwych do kliknięcia przycisków
- Przyjaznego, nowoczesnego wyglądu
- Wsparcia dla różnych rozmiarów ekranów

### Decyzja
Używamy **Material Design 3** (wbudowany w Flutter) jako głównego UI framework.

Nie używamy Forui, ponieważ:
- MD3 jest wbudowany (zero dependencies)
- MD3 ma lepsze wsparcie społeczności
- MD3 jest stabilny i dobrze przetestowany

Konfiguracja:
```dart
MaterialApp(
  theme: ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
  ),
)
```

### Konsekwencje

**Pozytywne:**
- Zero dodatkowych zależności
- Świetna dokumentacja
- Huge community support
- Adaptive dla różnych platform
- Accessibility out-of-the-box

**Negatywne:**
- Może wymagać custom komponentów dla unikalnego UI
- Mniej "unique" wygląd (ale dla dzieci prostota = lepiej)

### Alternatywy
- **Forui** - dodatkowa zależność, mniej mature
- **Cupertino** - iOS-only vibe, mniej kolorowe
- **Custom UI** - za dużo pracy

---

## ADR-005: Lokalizacja - flutter_localizations

**Status:** Zaproponowane
**Data:** 2026-01-09
**Decydent:** Team / Claude Code

### Kontekst
Aplikacja może być używana przez dzieci z różnych krajów. Nawet jeśli teraz jest tylko polski, warto od razu przygotować infrastrukturę.

### Decyzja
Używamy **flutter_localizations** (wbudowany) + **intl** dla lokalizacji.

```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0
```

### Konsekwencje

**Pozytywne:**
- Oficjalne rozwiązanie od Flutter
- Wsparcie dla plurals, formatowania dat, etc.
- Łatwe dodawanie języków w przyszłości
- Tools support (IDE plugins)

**Negatywne:**
- Wymaga generowania kodu (flutter gen-l10n)
- Dodatkowy krok w workflow

### Alternatywy
- **easy_localization** - runtime loading, ale external dependency
- **Hardcoded strings** - nie skaluje się, bad practice

---

## ADR-006: Backend - Supabase

**Status:** Propozycja / Do dyskusji
**Data:** 2026-01-09
**Decydent:** Team / Claude Code

### Kontekst
Jeśli aplikacja będzie wymagała:
- Zapisywania postępów dzieci
- Synchronizacji między urządzeniami
- Multiplayer features
- Content management

### Decyzja (propozycja)
Rozważamy **Supabase** jako backend-as-a-service.

```yaml
dependencies:
  supabase_flutter: ^2.5.0
```

### Konsekwencje

**Pozytywne:**
- Postgres database (robust)
- Real-time subscriptions
- Authentication out-of-the-box
- Storage dla zdjęć/audio
- Row Level Security (privacy dla dzieci!)
- Darmowy tier

**Negatywne:**
- Vendor lock-in (ale open-source, można self-host)
- Wymaga nauki SQL
- Koszt przy dużej skali

### Alternatywy
- **Firebase** - łatwiejszy, ale drodszy, NoSQL
- **Custom REST API** - za dużo pracy
- **Local-only** - brak sync, brak cloud features

### Status
⚠️ **TO DO:** Ustalić czy aplikacja potrzebuje backend. Jeśli tak, zaimplementować w kolejnym milestone.

---

## ADR-007: Audio - audioplayers

**Status:** Zaakceptowane (już zaimplementowane)
**Data:** 2026-01-09
**Decydent:** Team

### Kontekst
Aplikacja już używa `audioplayers: ^6.1.0` do odtwarzania dźwięków.

### Decyzja
Pozostajemy przy **audioplayers** jako głównej bibliotece do audio.

### Konsekwencje

**Pozytywne:**
- Cross-platform (iOS, Android, Web, Desktop)
- Prosty API
- Obsługuje wiele formatów

**Negatywne:**
- Czasami problemy z latency (dla gier może być lepszy flame_audio)

### Przyszłość
Jeśli dodamy gry wymagające precyzyjnego audio (rhythm games), rozważyć **flame_audio** lub **just_audio**.

---

## Szablon dla nowych ADR

```markdown
## ADR-XXX: [Tytuł decyzji]

**Status:** [Zaproponowane / Zaakceptowane / Odrzucone / Zastąpione przez ADR-YYY]
**Data:** YYYY-MM-DD
**Decydent:** [Kto podjął decyzję]

### Kontekst
[Dlaczego musimy podjąć tę decyzję? Jaki problem rozwiązujemy?]

### Decyzja
[Co dokładnie decydujemy? Konkretne rozwiązanie.]

### Konsekwencje

**Pozytywne:**
- [Lista pozytywnych skutków]

**Negatywne:**
- [Lista negatywnych skutków / trade-offs]

### Alternatywy
- [Inne opcje które rozważaliśmy i dlaczego je odrzuciliśmy]
```

---

## Proces aktualizacji ADR

1. Gdy podejmujesz ważną decyzję architektoniczną, dodaj nowy ADR
2. Numeruj kolejno (ADR-001, ADR-002...)
3. Jeśli zmieniasz decyzję, NIE usuwaj starego ADR - oznacz jako "Zastąpione przez ADR-XXX"
4. Zawsze aktualizuj datę i status
5. Linki do ADR w komentarzach kodu: `// See ADR-002 for state management choice`
