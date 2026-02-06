import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talu_kids/services/database_service.dart';
import 'package:talu_kids/services/sound_effects_service.dart';

/// Mock dla SharedPreferences
/// Uzywany w testach pet_provider i sound_effects_provider
class MockSharedPreferences extends Mock implements SharedPreferences {}

/// Mock dla SoundEffectsService (singleton)
/// Uzywany w testach sound_effects_provider
class MockSoundEffectsService extends Mock implements SoundEffectsService {}
