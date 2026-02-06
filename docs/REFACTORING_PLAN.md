# Plan Refaktoryzacji - Feature-Based Architecture

## 📦 1. Aktualizacja pubspec.yaml

### Zamień obecny pubspec.yaml na:

```yaml
name: talu_kids
description: "Interactive educational app for kids"
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.10.4

dependencies:
  flutter:
    sdk: flutter

  # UI
  cupertino_icons: ^1.0.8

  # State Management
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.4.0

  # Routing
  go_router: ^14.0.0

  # Audio
  audioplayers: ^6.1.0

  # Localization
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0

  # Utils
  logger: ^2.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0

  # Code generation
  build_runner: ^2.4.0
  riverpod_generator: ^2.4.0
  riverpod_lint: ^2.4.0

flutter:
  uses-material-design: true

  # Jeśli dodasz assety (dźwięki, obrazki)
  # assets:
  #   - assets/sounds/
  #   - assets/images/
```

### Po zapisaniu uruchom:
```bash
cd C:\Users\krzys\talu_kids
flutter pub get
```

---

## 🏗️ 2. Struktura folderów

### Utwórz foldery (skopiuj i uruchom w terminalu):

```bash
cd C:\Users\krzys\talu_kids\lib

# Core
mkdir core
mkdir core\config
mkdir core\router
mkdir core\theme
mkdir core\utils

# Features
mkdir features
mkdir features\home
mkdir features\home\presentation
mkdir features\home\presentation\pages
mkdir features\home\presentation\widgets

# Shared
mkdir shared
mkdir shared\widgets

# Assets (opcjonalnie)
cd ..
mkdir assets
mkdir assets\sounds
mkdir assets\images
```

---

## 📝 3. Migracja kodu - Krok po kroku

### KROK 1: Napraw test (PRIORYTET!)

**Plik:** `test/widget_test.dart`
**Linia:** 16
**Zmień:** `MyApp` → `TaLuKidsApp`

**Weryfikacja:**
```bash
flutter test
```

---

### KROK 2: Utwórz Theme

**Nowy plik:** `lib/core/theme/app_theme.dart`

```dart
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.lightBlueAccent,
      brightness: Brightness.light,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      bodyLarge: TextStyle(
        fontSize: 18,
        color: Colors.black87,
      ),
    ),
  );
}
```

---

### KROK 3: Utwórz Logger

**Nowy plik:** `lib/core/utils/logger.dart`

```dart
import 'package:logger/logger.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 80,
    colors: true,
    printEmojis: true,
  ),
);
```

---

### KROK 4: Przenieś BigButton

**Z:** `lib/main.dart` (linie 51-105)
**Do:** `lib/features/home/presentation/widgets/big_button.dart`

**Nowy plik:** `lib/features/home/presentation/widgets/big_button.dart`

```dart
import 'package:flutter/material.dart';
import '../../../../core/utils/logger.dart';

class BigButton extends StatefulWidget {
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const BigButton({
    super.key,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  State<BigButton> createState() => _BigButtonState();
}

class _BigButtonState extends State<BigButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _pressed = true);
        },
        onTapUp: (_) {
          setState(() => _pressed = false);
          logger.i('Button tapped: ${widget.icon}');  // ✅ Zamiast print()
          widget.onTap();
        },
        onTapCancel: () {
          setState(() => _pressed = false);
        },
        child: AnimatedScale(
          scale: _pressed ? 0.92 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            width: 220,
            height: 120,
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              widget.icon,
              color: Colors.white,
              size: 60,
            ),
          ),
        ),
      ),
    );
  }
}
```

---

### KROK 5: Przenieś HomeScreen

**Z:** `lib/main.dart` (linie 20-49)
**Do:** `lib/features/home/presentation/pages/home_page.dart`

**Nowy plik:** `lib/features/home/presentation/pages/home_page.dart`

```dart
import 'package:flutter/material.dart';
import '../widgets/big_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Hello Kid',
              style: TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 30),
            BigButton(
              color: Colors.blue,
              icon: Icons.brush,
              onTap: () {
                // TODO: Navigate to drawing screen
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### KROK 6: Utwórz Router

**Nowy plik:** `lib/core/router/app_router.dart`

```dart
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/pages/home_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
    // Dodaj więcej routes tutaj w przyszłości
  ],
);
```

---

### KROK 7: Zrefaktoruj main.dart

**Zamień:** `lib/main.dart` na:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(
    const ProviderScope(
      child: TaLuKidsApp(),
    ),
  );
}

class TaLuKidsApp extends StatelessWidget {
  const TaLuKidsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'TaLu Kids',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
```

---

## ✅ Weryfikacja po każdym kroku

### Po KROK 1-2:
```bash
flutter analyze
# Powinno być: 0 issues found
```

### Po KROK 3-7 (cała migracja):
```bash
flutter analyze
flutter test
flutter run
```

Wszystko powinno działać identycznie jak przed refaktoryzacją!

---

## 🎯 Kolejność wykonania

1. ✅ **KROK 1** - Napraw test (1 min)
2. ✅ **Zaktualizuj pubspec.yaml + flutter pub get** (2 min)
3. ✅ **Utwórz foldery** (1 min)
4. ✅ **KROK 2-3** - Theme + Logger (3 min)
5. ✅ **KROK 4-5** - Przenieś komponenty (5 min)
6. ✅ **KROK 6-7** - Router + Refactor main (5 min)
7. ✅ **Weryfikacja** (2 min)

**Łączny czas:** ~20 minut

---

## 🆘 Jeśli coś nie działa

### Import errors po migracji?
```bash
# Usuń cache i zbuduj ponownie
flutter clean
flutter pub get
flutter run
```

### Build runner errors z Riverpod?
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Test failures?
- Sprawdź czy `TaLuKidsApp` jest poprawnie zaimportowana w test
- Uruchom `flutter test -v` dla szczegółów

---

## 📚 Struktura finalna

Po zakończeniu będziesz mieć:

```
lib/
├── core/
│   ├── router/
│   │   └── app_router.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── utils/
│       └── logger.dart
├── features/
│   └── home/
│       └── presentation/
│           ├── pages/
│           │   └── home_page.dart
│           └── widgets/
│               └── big_button.dart
└── main.dart
```

**Wszystkie testy przechodzą ✅**
**Flutter analyze = 0 issues ✅**
**Aplikacja działa identycznie ✅**
**Gotowa struktura na nowe features ✅**
