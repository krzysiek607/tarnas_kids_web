import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tarnas_kids/screens/home_screen.dart';
import 'package:tarnas_kids/screens/learning_screen.dart';
import 'package:tarnas_kids/screens/fun_screen.dart';
import 'package:tarnas_kids/screens/pet_screen.dart';
import 'package:tarnas_kids/screens/settings_screen.dart';
import 'package:tarnas_kids/screens/parent_panel_screen.dart';
import 'package:tarnas_kids/screens/drawing_screen.dart';
import 'package:tarnas_kids/screens/games/maze_game_screen.dart';
import 'package:tarnas_kids/screens/games/matching_game_screen.dart';
import 'package:tarnas_kids/screens/games/dots_game_screen.dart';
import 'package:tarnas_kids/theme/app_theme.dart';
import 'package:tarnas_kids/providers/pet_provider.dart';
import 'package:tarnas_kids/providers/background_music_provider.dart';

/// Sets up SharedPreferences mock for testing.
///
/// Must be called before [createTestApp] to ensure
/// providers that depend on SharedPreferences work correctly.
/// The mock provides default pet state values so PetNotifier
/// initializes with known, deterministic values.
Future<void> initializeTestDependencies() async {
  SharedPreferences.setMockInitialValues({
    'pet_hunger': 80.0,
    'pet_happiness': 80.0,
    'pet_energy': 80.0,
    'pet_hygiene': 80.0,
    'pet_lastUpdate': DateTime.now().toIso8601String(),
    'pet_evolutionPoints': 0,
  });
}

/// Creates a GoRouter configured for integration tests.
///
/// Starts at [initialRoute] (defaults to '/home') and includes
/// all app routes without the preloader screen. Route transitions
/// use simple builders (no fade/custom transitions) to speed up
/// test execution and avoid animation timing issues.
GoRouter createTestRouter({String initialRoute = '/home'}) {
  return GoRouter(
    initialLocation: initialRoute,
    routes: [
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/learning',
        name: 'learning',
        builder: (context, state) => const LearningScreen(),
      ),
      GoRoute(
        path: '/pet',
        name: 'pet',
        builder: (context, state) => const PetScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/parent-panel',
        name: 'parent-panel',
        builder: (context, state) => const ParentPanelScreen(),
      ),
      GoRoute(
        path: '/drawing',
        name: 'drawing',
        builder: (context, state) => const DrawingScreen(),
      ),
      GoRoute(
        path: '/fun',
        name: 'fun',
        builder: (context, state) => const FunScreen(),
        routes: [
          GoRoute(
            path: 'maze',
            name: 'maze',
            builder: (context, state) => const MazeGameScreen(),
          ),
          GoRoute(
            path: 'matching',
            name: 'matching',
            builder: (context, state) => const MatchingGameScreen(),
          ),
          GoRoute(
            path: 'dots',
            name: 'dots',
            builder: (context, state) => const DotsGameScreen(),
          ),
        ],
      ),
    ],
  );
}

/// Creates a fully wrapped test app with ProviderScope and MaterialApp.router.
///
/// This bypasses the preloader, Supabase initialization, Firebase, and
/// audio services that are not available in a test environment.
///
/// The real [PetNotifier] and [BackgroundMusicNotifier] are used, but they
/// operate in a test-safe mode because:
/// - SharedPreferences is mocked with deterministic initial values
/// - DatabaseService.isInitialized returns false (never initialized in tests)
/// - Audio players will silently fail (no audio context available)
///
/// The [initialRoute] parameter controls which screen to start on.
/// Optional [overrides] allow injecting custom providers for specific tests.
Widget createTestApp({
  String initialRoute = '/home',
  List<Override> overrides = const [],
}) {
  final router = createTestRouter(initialRoute: initialRoute);

  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Tarnas Kids Test',
      theme: AppTheme.theme,
      routerConfig: router,
    ),
  );
}

/// Creates a test app using the real providers backed by mocked storage.
///
/// The real PetNotifier is used (backed by mock SharedPreferences), and
/// the real BackgroundMusicNotifier is used (audio calls will be no-ops
/// in the test environment since there is no audio context).
///
/// This is the recommended way to create a test app for most integration
/// tests, as it closely mimics real app behavior without external services.
Widget createTestAppWithMockedProviders({
  String initialRoute = '/home',
}) {
  // No overrides needed - the real providers work with mocked SharedPreferences
  // and without DatabaseService/Firebase/Supabase initialized
  return createTestApp(
    initialRoute: initialRoute,
  );
}

/// Returns a [ProviderContainer] for directly reading and manipulating
/// provider state in tests without building widgets.
///
/// Usage:
/// ```dart
/// final container = createTestContainer();
/// final petState = container.read(petProvider);
/// container.read(petProvider.notifier).feed();
/// ```
ProviderContainer createTestContainer({
  List<Override> overrides = const [],
}) {
  return ProviderContainer(overrides: overrides);
}
