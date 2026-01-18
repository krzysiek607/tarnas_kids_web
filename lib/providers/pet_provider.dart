import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stan zwierzaka Tamagotchi
class PetState {
  final double hunger;      // 0-100, 100 = najedzony
  final double happiness;   // 0-100, 100 = szczesliwy
  final double energy;      // 0-100, 100 = wypoczety
  final double hygiene;     // 0-100, 100 = czysty
  final bool isSleeping;
  final String currentMood;
  final DateTime lastUpdateTime;

  const PetState({
    this.hunger = 80.0,
    this.happiness = 80.0,
    this.energy = 80.0,
    this.hygiene = 80.0,
    this.isSleeping = false,
    this.currentMood = 'happy',
    required this.lastUpdateTime,
  });

  PetState copyWith({
    double? hunger,
    double? happiness,
    double? energy,
    double? hygiene,
    bool? isSleeping,
    String? currentMood,
    DateTime? lastUpdateTime,
  }) {
    return PetState(
      hunger: hunger ?? this.hunger,
      happiness: happiness ?? this.happiness,
      energy: energy ?? this.energy,
      hygiene: hygiene ?? this.hygiene,
      isSleeping: isSleeping ?? this.isSleeping,
      currentMood: currentMood ?? this.currentMood,
      lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
    );
  }

  /// Srednia wszystkich statystyk
  double get overallHealth => (hunger + happiness + energy + hygiene) / 4;

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

  PetNotifier() : super(PetState(lastUpdateTime: DateTime.now())) {
    _loadState();
  }

  /// Laduje stan z SharedPreferences
  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();

    final hungerVal = prefs.getDouble('pet_hunger');
    final happinessVal = prefs.getDouble('pet_happiness');
    final energyVal = prefs.getDouble('pet_energy');
    final hygieneVal = prefs.getDouble('pet_hygiene');
    final lastUpdateStr = prefs.getString('pet_lastUpdate');

    if (hungerVal != null && lastUpdateStr != null) {
      final lastUpdate = DateTime.parse(lastUpdateStr);
      final now = DateTime.now();
      final hoursPassed = now.difference(lastUpdate).inMinutes / 60.0;

      // Oblicz spadek statystyk za czas offline
      final decay = hoursPassed * offlineDecayPerHour;

      state = PetState(
        hunger: (hungerVal - decay).clamp(0.0, 100.0),
        happiness: ((happinessVal ?? 80.0) - decay).clamp(0.0, 100.0),
        energy: ((energyVal ?? 80.0) - decay * 0.5).clamp(0.0, 100.0), // Energia spada wolniej
        hygiene: ((hygieneVal ?? 80.0) - decay * 0.7).clamp(0.0, 100.0),
        isSleeping: false,
        lastUpdateTime: now,
      );

      _updateMood();
    }

    _startTick();
  }

  /// Zapisuje stan do SharedPreferences
  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('pet_hunger', state.hunger);
    await prefs.setDouble('pet_happiness', state.happiness);
    await prefs.setDouble('pet_energy', state.energy);
    await prefs.setDouble('pet_hygiene', state.hygiene);
    await prefs.setString('pet_lastUpdate', DateTime.now().toIso8601String());
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
      // Podczas snu regeneruj energie (wolniej)
      state = state.copyWith(
        energy: (state.energy + 2.0).clamp(0.0, 100.0),
        lastUpdateTime: DateTime.now(),
      );
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

  /// Nakarm zwierzaka
  void feed() {
    if (state.isSleeping) return;

    state = state.copyWith(
      hunger: (state.hunger + 15.0).clamp(0.0, 100.0),
      currentMood: 'eating',
      lastUpdateTime: DateTime.now(),
    );

    // Wroc do normalnego nastroju po chwili
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _updateMood();
    });

    _saveState();
  }

  /// Baw sie ze zwierzakiem
  void play() {
    if (state.isSleeping) return;
    if (state.energy < 10) return; // Za malo energii

    state = state.copyWith(
      happiness: (state.happiness + 12.0).clamp(0.0, 100.0),
      energy: (state.energy - 8.0).clamp(0.0, 100.0),
      currentMood: 'playing',
      lastUpdateTime: DateTime.now(),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _updateMood();
    });

    _saveState();
  }

  /// Poloz zwierzaka spac
  void sleep() {
    if (state.isSleeping) return;

    state = state.copyWith(
      isSleeping: true,
      currentMood: 'sleeping',
      lastUpdateTime: DateTime.now(),
    );

    // Obudz po czasie
    _sleepTimer?.cancel();
    _sleepTimer = Timer(Duration(seconds: sleepDurationSeconds), () {
      if (mounted) {
        wakeUp();
      }
    });

    _saveState();
  }

  /// Obudz zwierzaka
  void wakeUp() {
    _sleepTimer?.cancel();
    state = state.copyWith(
      isSleeping: false,
      energy: (state.energy + 20.0).clamp(0.0, 100.0),
      lastUpdateTime: DateTime.now(),
    );
    _updateMood();
    _saveState();
  }

  /// Umyj zwierzaka
  void wash() {
    if (state.isSleeping) return;

    state = state.copyWith(
      hygiene: (state.hygiene + 18.0).clamp(0.0, 100.0),
      currentMood: 'bathing',
      lastUpdateTime: DateTime.now(),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _updateMood();
    });

    _saveState();
  }

  /// Resetuj zwierzaka (nowa gra)
  void reset() {
    _sleepTimer?.cancel();
    state = PetState(
      hunger: 80.0,
      happiness: 80.0,
      energy: 80.0,
      hygiene: 80.0,
      isSleeping: false,
      currentMood: 'happy',
      lastUpdateTime: DateTime.now(),
    );
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
