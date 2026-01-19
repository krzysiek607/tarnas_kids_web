import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'providers/background_music_provider.dart';
import 'services/database_service.dart';
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
    print('Supabase nie skonfigurowany - nagrody działają lokalnie');
    return;
  }

  try {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );

    // Zainicjalizuj DatabaseService
    DatabaseService.initialize(Supabase.instance.client);
    print('Supabase zainicjalizowany pomyślnie');
  } catch (e) {
    print('Błąd inicjalizacji Supabase: $e');
    // Aplikacja działa bez bazy - nagrody tylko lokalnie
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
