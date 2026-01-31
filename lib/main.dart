import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'providers/background_music_provider.dart';
import 'services/database_service.dart';
import 'services/analytics_service.dart';
import 'services/sound_effects_controller.dart';
import 'config/supabase_config.dart';

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

  runApp(
    const ProviderScope(
      child: TarnasKidsApp(),
    ),
  );
}

/// Inicjalizuje Firebase
Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp();
    debugPrint('[FIREBASE] Zainicjalizowany');
  } catch (e) {
    debugPrint('[FIREBASE] Błąd inicjalizacji: $e');
  }
}

/// Inicjalizuje PostHog z session recording
Future<void> _initializePostHog() async {
  try {
    final config = PostHogConfig('phc_BL81wy8lEm6vrX1OVV2Y7oINDk99N1wubbhsLEVA3pg');
    config.host = 'https://eu.posthog.com';
    config.flushAt = 1; // DIAGNOSTYKA: Wysyłaj natychmiast każde zdarzenie
    config.captureApplicationLifecycleEvents = true;
    config.sessionReplay = true;
    config.sessionReplayConfig.maskAllTexts = false;
    config.sessionReplayConfig.maskAllImages = false;
    config.debug = true; // DIAGNOSTYKA: Włącz logi PostHog

    await Posthog().setup(config);
    debugPrint('[POSTHOG] Zainicjalizowany z session recording');
  } catch (e) {
    debugPrint('[POSTHOG] Błąd inicjalizacji: $e');
  }
}

/// Inicjalizuje Supabase jeśli konfiguracja jest dostępna
Future<void> _initializeSupabase() async {
  // Sprawdź czy konfiguracja jest ustawiona
  if (SupabaseConfig.url.isEmpty || SupabaseConfig.anonKey.isEmpty) {
    debugPrint('Supabase nie skonfigurowany - nagrody działają lokalnie');
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

    debugPrint('Supabase zainicjalizowany pomyślnie');
    debugPrint('Analityka gotowa. Dane płyną do Firebase i PostHog');
  } catch (e) {
    debugPrint('Błąd inicjalizacji Supabase: $e');
    // Aplikacja działa bez bazy - nagrody tylko lokalnie
  }
}

/// Zapewnia anonimowe uwierzytelnienie użytkownika
/// Zwraca User ID lub null w przypadku błędu
Future<String?> _ensureAnonymousAuth() async {
  final supabase = Supabase.instance.client;

  // Sprawdź czy użytkownik jest już zalogowany
  final currentSession = supabase.auth.currentSession;

  if (currentSession == null) {
    // Brak sesji - zaloguj anonimowo
    debugPrint('Brak sesji - logowanie anonimowe...');

    final response = await supabase.auth.signInAnonymously();

    if (response.user != null) {
      debugPrint('Zalogowano anonimowo. User ID: ${response.user!.id}');
      return response.user!.id;
    } else {
      debugPrint('Błąd logowania anonimowego');
      return null;
    }
  } else {
    // Sesja istnieje
    debugPrint('Sesja aktywna. User ID: ${currentSession.user.id}');
    return currentSession.user.id;
  }
}

class TarnasKidsApp extends ConsumerStatefulWidget {
  const TarnasKidsApp({super.key});

  @override
  ConsumerState<TarnasKidsApp> createState() => _TarnasKidsAppState();
}

class _TarnasKidsAppState extends ConsumerState<TarnasKidsApp>
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
      title: 'Tarnas Kids',
      theme: AppTheme.theme,
      routerConfig: appRouter,
    );
  }
}
