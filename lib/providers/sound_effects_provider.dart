import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/sound_effects_service.dart';

/// Stan dźwięków UI
class SoundEffectsState {
  final bool isEnabled;
  final double volume;

  const SoundEffectsState({
    this.isEnabled = true,
    this.volume = 1.0,
  });

  SoundEffectsState copyWith({
    bool? isEnabled,
    double? volume,
  }) {
    return SoundEffectsState(
      isEnabled: isEnabled ?? this.isEnabled,
      volume: volume ?? this.volume,
    );
  }
}

/// Notifier zarządzający stanem dźwięków UI z persystencją
class SoundEffectsNotifier extends StateNotifier<SoundEffectsState> {
  SoundEffectsNotifier() : super(const SoundEffectsState()) {
    _loadFromPrefs();
  }

  static const String _enabledKey = 'sound_effects_enabled';
  static const String _volumeKey = 'sound_effects_volume';

  final SoundEffectsService _service = SoundEffectsService.instance;

  /// Ładuje ustawienia z SharedPreferences
  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isEnabled = prefs.getBool(_enabledKey) ?? true;
      final volume = prefs.getDouble(_volumeKey) ?? 1.0;

      state = SoundEffectsState(
        isEnabled: isEnabled,
        volume: volume,
      );

      // Synchronizuj z serwisem
      _service.setMuted(!isEnabled);
      await _service.setVolume(volume);
    } catch (e) {
      // Ignoruj błędy - użyj domyślnych wartości
    }
  }

  /// Przełącza dźwięki włącz/wyłącz
  Future<void> toggleSound() async {
    final newEnabled = !state.isEnabled;
    state = state.copyWith(isEnabled: newEnabled);

    _service.setMuted(!newEnabled);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_enabledKey, newEnabled);
    } catch (e) {
      // Ignoruj błędy zapisu
    }
  }

  /// Ustawia głośność (0.0 - 1.0)
  Future<void> setVolume(double volume) async {
    final clampedVolume = volume.clamp(0.0, 1.0);
    state = state.copyWith(volume: clampedVolume);

    await _service.setVolume(clampedVolume);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_volumeKey, clampedVolume);
    } catch (e) {
      // Ignoruj błędy zapisu
    }
  }

  /// Odtwarza dźwięk kliknięcia
  Future<void> playClick() async {
    if (state.isEnabled) {
      await _service.playClick();
    }
  }

  /// Odtwarza dźwięk sukcesu
  Future<void> playSuccess() async {
    if (state.isEnabled) {
      await _service.playSuccess();
    }
  }

  /// Odtwarza dźwięk błędu
  Future<void> playError() async {
    if (state.isEnabled) {
      await _service.playError();
    }
  }
}

/// Provider stanu dźwięków UI
final soundEffectsProvider =
    StateNotifierProvider<SoundEffectsNotifier, SoundEffectsState>((ref) {
  return SoundEffectsNotifier();
});
