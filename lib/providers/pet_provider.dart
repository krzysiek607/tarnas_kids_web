import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_service.dart';

/// Etapy ewolucji jajka (Fazy)
enum EvolutionStage {
  egg,          // Faza 1: 0-30 pkt - Jajko
  firstCrack,   // Faza 2: 31-70 pkt - Pierwsze pęknięcie
  secondCrack,  // Faza 3: 71-100 pkt - Drugie pęknięcie
  hatched,      // Faza 4: >100 pkt - Wyklucie
}

/// Stan zwierzaka Tamagotchi
class PetState {
  final double hunger;      // 0-100, 100 = najedzony
  final double happiness;   // 0-100, 100 = szczesliwy
  final double energy;      // 0-100, 100 = wypoczety
  final double hygiene;     // 0-100, 100 = czysty
  final bool isSleeping;
  final String currentMood;
  final DateTime lastUpdateTime;
  final DateTime? sleepStartTime; // Czas rozpoczęcia snu (time-based)
  final int evolutionPoints;      // Punkty ewolucji jajka (0-100+)
  final DateTime? ranAwayAt;      // Kiedy zwierzak uciekł (null = nie uciekł)

  const PetState({
    this.hunger = 80.0,
    this.happiness = 80.0,
    this.energy = 80.0,
    this.hygiene = 80.0,
    this.isSleeping = false,
    this.currentMood = 'happy',
    required this.lastUpdateTime,
    this.sleepStartTime,
    this.evolutionPoints = 0,
    this.ranAwayAt,
  });

  /// Czy zwierzak uciekł?
  bool get hasRunAway => ranAwayAt != null;

  PetState copyWith({
    double? hunger,
    double? happiness,
    double? energy,
    double? hygiene,
    bool? isSleeping,
    String? currentMood,
    DateTime? lastUpdateTime,
    DateTime? sleepStartTime,
    bool clearSleepStartTime = false,
    int? evolutionPoints,
    DateTime? ranAwayAt,
    bool clearRanAwayAt = false,
  }) {
    return PetState(
      hunger: hunger ?? this.hunger,
      happiness: happiness ?? this.happiness,
      energy: energy ?? this.energy,
      hygiene: hygiene ?? this.hygiene,
      isSleeping: isSleeping ?? this.isSleeping,
      currentMood: currentMood ?? this.currentMood,
      lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
      sleepStartTime: clearSleepStartTime ? null : (sleepStartTime ?? this.sleepStartTime),
      evolutionPoints: evolutionPoints ?? this.evolutionPoints,
      ranAwayAt: clearRanAwayAt ? null : (ranAwayAt ?? this.ranAwayAt),
    );
  }

  /// Oblicza minuty snu od sleepStartTime
  int get minutesSleeping {
    if (sleepStartTime == null) return 0;
    return DateTime.now().difference(sleepStartTime!).inMinutes;
  }

  /// Srednia wszystkich statystyk
  double get overallHealth => (hunger + happiness + energy + hygiene) / 4;

  /// Etap ewolucji na podstawie punktów
  /// Progi zbalansowane dla kilku dni/tygodni gry:
  /// - Faza 1 (Jajko): 0-150 pkt
  /// - Faza 2 (Pęknięcie 1): 151-350 pkt
  /// - Faza 3 (Pęknięcie 2): 351-600 pkt
  /// - Faza 4 (Wyklucie): >600 pkt
  EvolutionStage get evolutionStage {
    if (evolutionPoints > 600) return EvolutionStage.hatched;
    if (evolutionPoints > 350) return EvolutionStage.secondCrack;
    if (evolutionPoints > 150) return EvolutionStage.firstCrack;
    return EvolutionStage.egg;
  }

  /// Oblicz nastroj na podstawie statystyk
  String calculateMood() {
    if (isSleeping) return 'sleeping';
    if (overallHealth < 20) return 'sad';
    if (hunger < 30) return 'hungry';
    if (energy < 30) return 'tired';
    if (hygiene < 30) return 'dirty';
    if (overallHealth > 70) return 'happy';
    return 'neutral';
  }

  Map<String, dynamic> toJson() {
    return {
      'hunger': hunger,
      'happiness': happiness,
      'energy': energy,
      'hygiene': hygiene,
      'isSleeping': isSleeping,
      'lastUpdateTime': lastUpdateTime.toIso8601String(),
      'evolutionPoints': evolutionPoints,
    };
  }

  factory PetState.fromJson(Map<String, dynamic> json) {
    return PetState(
      hunger: (json['hunger'] as num?)?.toDouble() ?? 80.0,
      happiness: (json['happiness'] as num?)?.toDouble() ?? 80.0,
      energy: (json['energy'] as num?)?.toDouble() ?? 80.0,
      hygiene: (json['hygiene'] as num?)?.toDouble() ?? 80.0,
      isSleeping: json['isSleeping'] as bool? ?? false,
      lastUpdateTime: json['lastUpdateTime'] != null
          ? DateTime.parse(json['lastUpdateTime'] as String)
          : DateTime.now(),
      evolutionPoints: (json['evolutionPoints'] as int?) ?? 0,
    );
  }
}

/// Notifier do zarzadzania stanem zwierzaka
class PetNotifier extends StateNotifier<PetState> {
  Timer? _tickTimer;
  Timer? _sleepTimer;

  // Stale do konfiguracji
  static const double tickDecayRate = 0.5;        // Ile spada co tick (wolniejszy spadek)
  static const int tickIntervalSeconds = 10;      // Tick co 10 sekund
  static const double offlineDecayPerHour = 2.0;  // Ile spada na godzine offline
  static const int sleepDurationSeconds = 15;     // Czas snu w sekundach
  static const int runAwayThresholdHours = 72;    // Po ilu godzinach zwierzak ucieka (3 dni)

  PetNotifier() : super(PetState(lastUpdateTime: DateTime.now())) {
    _loadState();
  }

  /// Laduje stan z SharedPreferences (cache) i Supabase (source of truth)
  /// Cache zapewnia natychmiastowy poprawny stan UI przy starcie
  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();

    final hungerVal = prefs.getDouble('pet_hunger');
    final happinessVal = prefs.getDouble('pet_happiness');
    final energyVal = prefs.getDouble('pet_energy');
    final hygieneVal = prefs.getDouble('pet_hygiene');
    final lastUpdateStr = prefs.getString('pet_lastUpdate');

    double loadedEnergy = energyVal ?? 80.0;
    bool isSleeping = false;
    DateTime? sleepStartTime;

    // KROK 1: Wczytaj evolutionPoints z CACHE (SharedPreferences) - natychmiastowy UI
    int evolutionPoints = prefs.getInt('pet_evolutionPoints') ?? 0;
    if (kDebugMode) {
      debugPrint('[PET] Cache: evolutionPoints = $evolutionPoints');
    }

    // KROK 2: Pobierz dane z Supabase (source of truth) - może nadpisać cache
    if (DatabaseService.isInitialized) {
      try {
        // Sprawdź czy zwierzak śpi
        sleepStartTime = await DatabaseService.instance.getSleepStartTime();
        if (sleepStartTime != null) {
          isSleeping = true;
          final minutesSlept = DateTime.now().difference(sleepStartTime).inMinutes;
          loadedEnergy = (loadedEnergy + minutesSlept).clamp(0.0, 100.0);
          if (kDebugMode) {
            debugPrint('[PET] Zwierzak śpi od $minutesSlept minut, energia: $loadedEnergy');
          }
        }

        // Pobierz punkty ewolucji z Supabase (source of truth)
        final supabasePoints = await DatabaseService.instance.getEvolutionPoints();
        if (kDebugMode) {
          debugPrint('[PET] Supabase: evolutionPoints = $supabasePoints');
        }

        // Użyj większej wartości (zabezpieczenie przed utratą danych)
        if (supabasePoints > evolutionPoints) {
          evolutionPoints = supabasePoints;
          // Zaktualizuj cache z danymi z Supabase
          await prefs.setInt('pet_evolutionPoints', evolutionPoints);
          if (kDebugMode) {
            debugPrint('[PET] Zaktualizowano cache z Supabase: $evolutionPoints');
          }
        } else if (evolutionPoints > supabasePoints && evolutionPoints > 0) {
          // Cache ma więcej punktów niż Supabase - może być problem z sync
          if (kDebugMode) {
            debugPrint('[PET] Cache ($evolutionPoints) > Supabase ($supabasePoints) - używam cache');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[PET] Błąd ładowania z Supabase: $e - używam cache: $evolutionPoints');
        }
      }
    }

    if (hungerVal != null && lastUpdateStr != null) {
      final lastUpdate = DateTime.parse(lastUpdateStr);
      final now = DateTime.now();
      final hoursPassed = now.difference(lastUpdate).inHours;

      // === MECHANIKA UCIECZKI ===
      // Jeśli minęło więcej niż 72h (3 dni), zwierzak uciekł
      if (hoursPassed >= runAwayThresholdHours && evolutionPoints > 0) {
        final ranAwayTime = lastUpdate.add(Duration(hours: runAwayThresholdHours));
        if (kDebugMode) {
          debugPrint('[PET] UCIECZKA! Zwierzak uciekł po ${runAwayThresholdHours}h nieobecności!');
          debugPrint('[PET] Ostatnia wizyta: $lastUpdate, uciekł: $ranAwayTime');
        }

        state = PetState(
          lastUpdateTime: now,
          ranAwayAt: ranAwayTime,
          evolutionPoints: evolutionPoints, // Zachowaj info ile miał punktów
        );

        // Nie startuj tickera - czekaj na acknowledgeRunaway()
        return;
      }

      // Normalny przypadek - oblicz spadek statystyk
      final hoursPassedDouble = now.difference(lastUpdate).inMinutes / 60.0;
      final decay = isSleeping ? 0.0 : hoursPassedDouble * offlineDecayPerHour;

      state = PetState(
        hunger: (hungerVal - decay).clamp(0.0, 100.0),
        happiness: ((happinessVal ?? 80.0) - decay).clamp(0.0, 100.0),
        energy: loadedEnergy.clamp(0.0, 100.0),
        hygiene: ((hygieneVal ?? 80.0) - decay * 0.7).clamp(0.0, 100.0),
        isSleeping: isSleeping,
        sleepStartTime: sleepStartTime,
        lastUpdateTime: now,
        evolutionPoints: evolutionPoints,
      );

      if (kDebugMode) {
        debugPrint('[PET] Stan załadowany: evolutionPoints=$evolutionPoints (stage: ${state.evolutionStage})');
      }
      _updateMood();
    } else {
      // Nowy użytkownik - sprawdź czy śpi
      state = PetState(
        isSleeping: isSleeping,
        sleepStartTime: sleepStartTime,
        lastUpdateTime: DateTime.now(),
        evolutionPoints: evolutionPoints,
      );
    }

    _startTick();
  }

  /// Zapisuje stan do SharedPreferences (cache/backup)
  /// evolutionPoints zapisywane również do Supabase w metodach feed/wash/play
  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('pet_hunger', state.hunger);
    await prefs.setDouble('pet_happiness', state.happiness);
    await prefs.setDouble('pet_energy', state.energy);
    await prefs.setDouble('pet_hygiene', state.hygiene);
    await prefs.setString('pet_lastUpdate', DateTime.now().toIso8601String());
    // CACHE: evolutionPoints zapisywane lokalnie jako backup
    await prefs.setInt('pet_evolutionPoints', state.evolutionPoints);
    if (kDebugMode) {
      debugPrint('[PET] _saveState: evolutionPoints cache = ${state.evolutionPoints}');
    }
  }

  /// Startuje timer tiku
  void _startTick() {
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(
      Duration(seconds: tickIntervalSeconds),
      (_) => _onTick(),
    );
  }

  /// Tick - automatyczny spadek statystyk
  void _onTick() {
    if (state.isSleeping) {
      // Podczas snu - oblicz aktualną energię na podstawie czasu snu (time-based)
      // 1 minuta = 1 punkt energii
      if (state.sleepStartTime != null) {
        final minutesSlept = DateTime.now().difference(state.sleepStartTime!).inMinutes;
        final currentEnergy = (state.energy + minutesSlept.toDouble()).clamp(0.0, 100.0);

        // Aktualizuj tylko jeśli energia się zmieniła (żeby nie spamować)
        if ((currentEnergy - state.energy).abs() >= 1.0) {
          state = state.copyWith(
            energy: currentEnergy,
            lastUpdateTime: DateTime.now(),
          );
        }
      }
    } else {
      // Normalny spadek statystyk
      state = state.copyWith(
        hunger: (state.hunger - tickDecayRate).clamp(0.0, 100.0),
        happiness: (state.happiness - tickDecayRate * 0.8).clamp(0.0, 100.0),
        energy: (state.energy - tickDecayRate * 0.5).clamp(0.0, 100.0),
        hygiene: (state.hygiene - tickDecayRate * 0.6).clamp(0.0, 100.0),
        lastUpdateTime: DateTime.now(),
      );
    }

    _updateMood();
    _saveState();
  }

  /// Aktualizuje nastroj na podstawie statystyk
  void _updateMood() {
    final newMood = state.calculateMood();
    if (newMood != state.currentMood) {
      state = state.copyWith(currentMood: newMood);
    }
  }

  // === AKCJE GRACZA ===

  /// Nakarm zwierzaka (+3 evolution points)
  Future<void> feed() async {
    if (state.isSleeping) return;

    // Zapisz do Supabase i pobierz nową wartość
    int newPoints = state.evolutionPoints + 3;
    if (DatabaseService.isInitialized) {
      newPoints = await DatabaseService.instance.addEvolutionPoints(3);
    }

    state = state.copyWith(
      hunger: (state.hunger + 15.0).clamp(0.0, 100.0),
      currentMood: 'eating',
      lastUpdateTime: DateTime.now(),
      evolutionPoints: newPoints,
    );

    if (kDebugMode) {
      debugPrint('[PET] Feed: evolutionPoints = $newPoints (stage: ${state.evolutionStage})');
    }

    // Wroc do normalnego nastroju po chwili
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _updateMood();
    });

    _saveState();
  }

  /// Baw sie ze zwierzakiem (+1 evolution point)
  Future<void> play() async {
    if (state.isSleeping) return;
    if (state.energy < 10) return; // Za malo energii

    // Zapisz do Supabase i pobierz nową wartość
    int newPoints = state.evolutionPoints + 1;
    if (DatabaseService.isInitialized) {
      newPoints = await DatabaseService.instance.addEvolutionPoints(1);
    }

    state = state.copyWith(
      happiness: (state.happiness + 12.0).clamp(0.0, 100.0),
      energy: (state.energy - 8.0).clamp(0.0, 100.0),
      currentMood: 'playing',
      lastUpdateTime: DateTime.now(),
      evolutionPoints: newPoints,
    );

    if (kDebugMode) {
      debugPrint('[PET] Play: evolutionPoints = $newPoints (stage: ${state.evolutionStage})');
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _updateMood();
    });

    _saveState();
  }

  /// Poloz zwierzaka spac (time-based)
  Future<void> sleep() async {
    if (state.isSleeping) return;

    final now = DateTime.now();

    // Zapisz czas rozpoczęcia snu w bazie
    if (DatabaseService.isInitialized) {
      await DatabaseService.instance.startSleep();
    }

    state = state.copyWith(
      isSleeping: true,
      sleepStartTime: now,
      currentMood: 'sleeping',
      lastUpdateTime: now,
    );

    // NIE używamy już automatycznego timera - użytkownik sam budzi zwierzaka
    // lub energia regeneruje się przez czas (1 min = 1 punkt)

    _saveState();
    if (kDebugMode) {
      debugPrint('[PET] Zwierzak zasnął o ${now.toIso8601String()}');
    }
  }

  /// Obudz zwierzaka (time-based - oblicza energię na podstawie czasu snu)
  Future<void> wakeUp() async {
    if (!state.isSleeping) return;

    int minutesSlept = 0;
    double energyGained = 0;

    // Oblicz czas snu z bazy lub lokalnie
    if (DatabaseService.isInitialized) {
      minutesSlept = await DatabaseService.instance.wakeUpAndCalculateEnergy();
    } else if (state.sleepStartTime != null) {
      minutesSlept = DateTime.now().difference(state.sleepStartTime!).inMinutes;
    }

    // 1 minuta snu = 1 punkt energii
    energyGained = minutesSlept.toDouble();
    final newEnergy = (state.energy + energyGained).clamp(0.0, 100.0);

    state = state.copyWith(
      isSleeping: false,
      clearSleepStartTime: true,
      energy: newEnergy,
      lastUpdateTime: DateTime.now(),
    );

    _updateMood();
    _saveState();

    if (kDebugMode) {
      debugPrint('[PET] Zwierzak obudzony! Spał $minutesSlept min, +$energyGained energii, teraz: $newEnergy');
    }
  }

  /// Umyj zwierzaka (+2 evolution points)
  Future<void> wash() async {
    if (state.isSleeping) return;

    // Zapisz do Supabase i pobierz nową wartość
    int newPoints = state.evolutionPoints + 2;
    if (DatabaseService.isInitialized) {
      newPoints = await DatabaseService.instance.addEvolutionPoints(2);
    }

    state = state.copyWith(
      hygiene: (state.hygiene + 18.0).clamp(0.0, 100.0),
      currentMood: 'bathing',
      lastUpdateTime: DateTime.now(),
      evolutionPoints: newPoints,
    );

    if (kDebugMode) {
      debugPrint('[PET] Wash: evolutionPoints = $newPoints (stage: ${state.evolutionStage})');
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _updateMood();
    });

    _saveState();
  }

  /// Potwierdź że użytkownik zobaczył wiadomość o ucieczce i zacznij nową grę
  Future<void> acknowledgeRunaway() async {
    if (!state.hasRunAway) return;

    if (kDebugMode) {
      debugPrint('[PET] Użytkownik zaakceptował ucieczkę. Nowe jajko!');
    }

    // Resetuj punkty ewolucji w Supabase
    if (DatabaseService.isInitialized) {
      await DatabaseService.instance.resetEvolutionPoints();
    }

    // Zacznij od nowego jajka
    state = PetState(
      hunger: 80.0,
      happiness: 80.0,
      energy: 80.0,
      hygiene: 80.0,
      isSleeping: false,
      currentMood: 'happy',
      lastUpdateTime: DateTime.now(),
      evolutionPoints: 0,
      // ranAwayAt = null (domyślnie)
    );

    _saveState();
    _startTick();
  }

  /// Resetuj zwierzaka (nowa gra)
  Future<void> reset() async {
    _sleepTimer?.cancel();

    // Resetuj punkty ewolucji w Supabase
    if (DatabaseService.isInitialized) {
      await DatabaseService.instance.resetEvolutionPoints();
    }

    state = PetState(
      hunger: 80.0,
      happiness: 80.0,
      energy: 80.0,
      hygiene: 80.0,
      isSleeping: false,
      currentMood: 'happy',
      lastUpdateTime: DateTime.now(),
      evolutionPoints: 0,
    );
    if (kDebugMode) {
      debugPrint('[PET] Reset: evolutionPoints = 0');
    }
    _saveState();
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _sleepTimer?.cancel();
    _saveState();
    super.dispose();
  }
}

/// Provider dla stanu zwierzaka
final petProvider = StateNotifierProvider<PetNotifier, PetState>(
  (ref) => PetNotifier(),
);
