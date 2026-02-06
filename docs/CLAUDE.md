# CLAUDE.md - Instrukcje dla Claude Code

## PRZY KAZDYM URUCHOMIENIU

1. Przeczytaj ten plik, aby zrozumiec kontekst projektu
2. Sprawdz `docs/BACKLOG.md` aby zobaczyc aktywne zadania
3. Przejrzyj `docs/DECISIONS.md` dla kontekstu architektonicznego
4. Uruchom `flutter analyze` aby sprawdzic stan kodu
5. Sprawdz czy sa nowe zaleznosci do zainstalowania: `flutter pub get`

## OPIS PROJEKTU

**Nazwa:** TaLu Kids
**Typ:** Aplikacja mobilna Flutter dla dzieci 4-8 lat
**Cel:** Interaktywna aplikacja edukacyjna/rozrywkowa

### Stack Technologiczny

#### Framework
- Flutter 3.10.4+
- Dart 3.10.4+

#### Zaleznosci (obecne)
- `cupertino_icons: ^1.0.8` - iOS style icons
- `audioplayers: ^6.1.0` - odtwarzanie dzwiekow

#### Zaleznosci (planowane - patrz DECISIONS.md)
- State Management: Riverpod (do zainstalowania)
- Routing: go_router (do zainstalowania)
- UI Framework: Material Design 3 (wbudowany)
- Lokalizacja: flutter_localizations (do zainstalowania)

## STRUKTURA PROJEKTU

```
lib/
├── main.dart               # Punkt wejscia aplikacji
├── screens/                # Ekrany aplikacji
│   ├── home_screen.dart    # Ekran glowny z 3 przyciskami
│   ├── drawing_screen.dart # Ekran rysowania (placeholder)
│   ├── learning_screen.dart# Ekran nauki (placeholder)
│   └── fun_screen.dart     # Ekran zabawy (placeholder)
├── widgets/                # Wspoldzielone widgety
│   └── big_button.dart     # Duzy przycisk dla dzieci
└── theme/                  # Theme i style
    └── app_theme.dart      # Kolory, typografia, style
```

## KLUCZOWE PLIKI

- `lib/main.dart` - Punkt wejscia, TaLuKidsApp widget
- `lib/screens/home_screen.dart` - Ekran glowny z przyciskami nawigacyjnymi
- `lib/widgets/big_button.dart` - Reuzywaalny przycisk z animacja
- `lib/theme/app_theme.dart` - Kolory, gradienty, typografia
- `pubspec.yaml` - Konfiguracja projektu i zaleznosci
- `docs/BACKLOG.md` - Backlog projektu
- `docs/DECISIONS.md` - Decyzje architektoniczne

## WAZNE KOMENDY

### Flutter
```bash
# Analiza kodu
flutter analyze

# Formatowanie kodu
flutter format .

# Uruchomienie aplikacji
flutter run

# Testy
flutter test

# Build
flutter build apk        # Android
flutter build ios        # iOS
flutter build windows    # Windows
```

### Git
```bash
# Status
git status

# Commit (zawsze uzywaj konwencji conventional commits)
git commit -m "feat: opis zmian"
git commit -m "fix: opis naprawy"
git commit -m "docs: aktualizacja dokumentacji"

# Push
git push origin main
```

## ZASADY KODOWANIA

### Konwencje
1. Uzywaj `const` konstruktorow tam gdzie to mozliwe (performance)
2. Uzywaj `super.key` zamiast `Key? key` w konstruktorach
3. Uzywaj `flutter_lints` dla spojnosci kodu
4. Unikaj `print()` w kodzie produkcyjnym - uzywaj `debugPrint()` lub logger
5. Wszystkie strings do lokalizacji (przygotowanie na i18n)
6. Uzywaj Material Design 3 API (bez deprecated members)

### AppTheme
Wszystkie style powinny byc w `lib/theme/app_theme.dart`:
- Kolory: `AppTheme.primaryColor`, `AppTheme.accentColor`, etc.
- Gradienty: `AppTheme.primaryGradient`, `AppTheme.accentGradient`, etc.
- Spacing: `AppTheme.spacingSmall`, `AppTheme.spacingMedium`, etc.
- Cienie: `AppTheme.cardShadow`, `AppTheme.buttonShadowPressed`

### Struktura ekranu
Kazdy nowy ekran powinien:
1. Byc w folderze `lib/screens/`
2. Uzywac `AppTheme.backgroundColor` jako tlo
3. Miec AppBar z przyciskiem powrotu
4. Byc responsywny (SafeArea, ConstrainedBox)

## ZNANE PROBLEMY

Brak znanych problemow - flutter analyze zwraca 0 issues.

## NOTATKI

- Aplikacja jest na wczesnym etapie rozwoju
- Ekrany Drawing, Learning, Fun sa placeholderami
- Nastepny krok: implementacja ekranu Rysowanie
- Planowane: Riverpod dla state management, go_router dla nawigacji
