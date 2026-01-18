import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'providers/background_music_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Blokada orientacji - tylko tryb pionowy
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(
    const ProviderScope(
      child: TarnasKidsApp(),
    ),
  );
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
