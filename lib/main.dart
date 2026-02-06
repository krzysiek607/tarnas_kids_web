import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'providers/background_music_provider.dart';
import 'services/database_service.dart';
import 'services/analytics_service.dart';
import 'services/sound_effects_controller.dart';
import 'config/supabase_config.dart';
import 'config/posthog_config.dart' as ph_config;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Blokada orientacji - tylko tryb pionowy
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Inicjalizacja Firebase
  await _initializeFirebase();

  // Inicjalizacja PostHog
  await _initializePostHog();

  // Inicjalizacja Supabase (jeśli skonfigurowany)
  await _initializeSupabase();

  // Przechwytywanie WSZYSTKICH błędów async (niezłapanych przez try-catch)
  runZonedGuarded(
    () {
      runApp(
        const ProviderScope(
          child: TaLuKidsApp(),
        ),
      );
    },
    (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: false);
    },
  );
}

/// Inicjalizuje Firebase + Crashlytics
Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp();

    // Crashlytics - przechwytuj błędy Flutter framework
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    // Przechwytuj błędy async z PlatformDispatcher (np. failed Future w izolatkach)
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    if (kDebugMode) {
      debugPrint('[FIREBASE] Zainicjalizowany z Crashlytics');
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('[FIREBASE] Błąd inicjalizacji: $e');
    }
  }
}

/// Inicjalizuje PostHog z session recording
Future<void> _initializePostHog() async {
  try {
    final config = PostHogConfig(ph_config.PostHogConfig.apiKey);
    config.host = ph_config.PostHogConfig.host;
    config.flushAt = 20;
    config.captureApplicationLifecycleEvents = true;
    config.debug = false;

    // Session Replay - nagrywanie sesji (bezpieczna konfiguracja)
    config.sessionReplay = true;
    config.sessionReplayConfig.maskAllTexts = true;
    config.sessionReplayConfig.maskAllImages = false;

    await Posthog().setup(config);
    if (kDebugMode) {
      debugPrint('[POSTHOG] Zainicjalizowany (events + session replay, texts masked)');
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('[POSTHOG] Błąd inicjalizacji: $e');
    }
  }
}

/// Inicjalizuje Supabase jeśli konfiguracja jest dostępna
Future<void> _initializeSupabase() async {
  // Sprawdź czy konfiguracja jest ustawiona
  if (SupabaseConfig.url.isEmpty || SupabaseConfig.anonKey.isEmpty) {
    if (kDebugMode) {
      debugPrint('Supabase nie skonfigurowany - nagrody działają lokalnie');
    }
    return;
  }

  try {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );

    // Anonymous Authentication - zaloguj użytkownika anonimowo
    final userId = await _ensureAnonymousAuth();

    // Zainicjalizuj DatabaseService
    DatabaseService.initialize(Supabase.instance.client);

    // Zainicjalizuj AnalyticsService z Supabase
    await AnalyticsService.instance.initialize(
      supabaseClient: Supabase.instance.client,
    );

    // Identyfikuj użytkownika w systemach analityki
    if (userId != null) {
      await AnalyticsService.instance.identifyUser(userId);
    }

    if (kDebugMode) {
      debugPrint('Supabase zainicjalizowany pomyślnie');
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Błąd inicjalizacji Supabase: $e');
    }
    // Aplikacja działa bez bazy - nagrody tylko lokalnie
  }
}

/// Zapewnia anonimowe uwierzytelnienie użytkownika
/// Zwraca User ID lub null w przypadku błędu
Future<String?> _ensureAnonymousAuth() async {
  try {
    final supabase = Supabase.instance.client;

    // Sprawdź czy użytkownik jest już zalogowany
    final currentSession = supabase.auth.currentSession;

    if (currentSession == null) {
      // Brak sesji - zaloguj anonimowo
      if (kDebugMode) {
        debugPrint('Brak sesji - logowanie anonimowe...');
      }

      final response = await supabase.auth.signInAnonymously();

      if (response.user != null) {
        if (kDebugMode) {
          debugPrint('Zalogowano anonimowo. User ID: ${response.user!.id}');
        }
        return response.user!.id;
      } else {
        if (kDebugMode) {
          debugPrint('Błąd logowania anonimowego');
        }
        return null;
      }
    } else {
      // Sesja istnieje
      if (kDebugMode) {
        debugPrint('Sesja aktywna. User ID: ${currentSession.user.id}');
      }
      return currentSession.user.id;
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Błąd uwierzytelniania: $e');
    }
    FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
    return null;
  }
}

class TaLuKidsApp extends ConsumerStatefulWidget {
  const TaLuKidsApp({super.key});

  @override
  ConsumerState<TaLuKidsApp> createState() => _TaLuKidsAppState();
}

class _TaLuKidsAppState extends ConsumerState<TaLuKidsApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Zarejestruj callbacki audio ducking po pierwszym renderze
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupAudioDucking();
    });
  }

  /// Konfiguruje audio ducking - wyciszanie muzyki podczas efektów dźwiękowych
  void _setupAudioDucking() {
    final musicNotifier = ref.read(backgroundMusicProvider.notifier);
    final musicState = ref.read(backgroundMusicProvider);

    SoundEffectsController().registerDuckingCallbacks(
      onDuckingStart: (volume) async {
        await musicNotifier.setVolume(volume);
      },
      onDuckingEnd: (volume) async {
        await musicNotifier.setVolume(volume);
      },
      originalVolume: musicState.volume,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    final musicNotifier = ref.read(backgroundMusicProvider.notifier);

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // Aplikacja przeszla w tlo - zatrzymaj muzyke
        musicNotifier.onAppPaused();
        break;
      case AppLifecycleState.resumed:
        // Aplikacja wrocila na pierwszy plan - wznow muzyke (jesli user nie wyciszyl)
        musicNotifier.onAppResumed();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'TaLu Kids',
      theme: AppTheme.theme,
      routerConfig: appRouter,
    );
  }
}
