import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'providers/background_music_provider.dart';
import 'services/database_service.dart';
import 'services/analytics_service.dart';
import 'config/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Blokada orientacji - tylko tryb pionowy
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Inicjalizacja Supabase (jeśli skonfigurowany)
  await _initializeSupabase();

  runApp(
    const ProviderScope(
      child: TarnasKidsApp(),
    ),
  );
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
    await _ensureAnonymousAuth();

    // Zainicjalizuj DatabaseService
    DatabaseService.initialize(Supabase.instance.client);

    // Zainicjalizuj AnalyticsService
    AnalyticsService.instance.initialize(Supabase.instance.client);

    debugPrint('Supabase zainicjalizowany pomyślnie');
  } catch (e) {
    debugPrint('Błąd inicjalizacji Supabase: $e');
    // Aplikacja działa bez bazy - nagrody tylko lokalnie
  }
}

/// Zapewnia anonimowe uwierzytelnienie użytkownika
Future<void> _ensureAnonymousAuth() async {
  final supabase = Supabase.instance.client;

  // Sprawdź czy użytkownik jest już zalogowany
  final currentSession = supabase.auth.currentSession;

  if (currentSession == null) {
    // Brak sesji - zaloguj anonimowo
    debugPrint('Brak sesji - logowanie anonimowe...');

    final response = await supabase.auth.signInAnonymously();

    if (response.user != null) {
      debugPrint('Zalogowano anonimowo. User ID: ${response.user!.id}');
    } else {
      debugPrint('Błąd logowania anonimowego');
    }
  } else {
    // Sesja istnieje
    debugPrint('Sesja aktywna. User ID: ${currentSession.user.id}');
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
