import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../providers/pet_provider.dart';
import '../services/database_service.dart';
import '../services/analytics_service.dart';
import '../widgets/evolution_overlay.dart';

/// Ekran gry Zwierzak (Tamagotchi)
class PetScreen extends ConsumerStatefulWidget {
  const PetScreen({super.key});

  @override
  ConsumerState<PetScreen> createState() => _PetScreenState();
}

class _PetScreenState extends ConsumerState<PetScreen> {
  bool _runawayDialogShown = false;

  // Stan dla Evolution Overlay
  bool _showEvolutionOverlay = false;
  EvolutionStage? _evolutionFromStage;
  EvolutionStage? _evolutionToStage;
  EvolutionStage? _lastKnownStage;

  @override
  void initState() {
    super.initState();
    // Ustaw początkowy stage po pierwszym renderze
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _lastKnownStage = ref.read(petProvider).evolutionStage;
    });
  }

  /// Sprawdza czy nastąpiła ewolucja i pokazuje overlay
  void _checkForEvolution(PetState petState) {
    if (_lastKnownStage == null) {
      _lastKnownStage = petState.evolutionStage;
      return;
    }

    final oldIndex = EvolutionStage.values.indexOf(_lastKnownStage!);
    final newIndex = EvolutionStage.values.indexOf(petState.evolutionStage);

    // Ewolucja do wyższej fazy
    if (newIndex > oldIndex && !_showEvolutionOverlay) {
      debugPrint('🌟 EVOLUTION DETECTED! ${_lastKnownStage} -> ${petState.evolutionStage}');
      setState(() {
        _evolutionFromStage = _lastKnownStage;
        _evolutionToStage = petState.evolutionStage;
        _showEvolutionOverlay = true;
      });
    }

    _lastKnownStage = petState.evolutionStage;
  }

  void _onEvolutionComplete() {
    setState(() {
      _showEvolutionOverlay = false;
      _evolutionFromStage = null;
      _evolutionToStage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final petState = ref.watch(petProvider);

    // Sprawdź ewolucję przy każdej zmianie stanu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForEvolution(petState);
    });

    // Pokaż dialog pożegnalny jeśli zwierzak uciekł (tylko raz)
    if (petState.hasRunAway && !_runawayDialogShown) {
      _runawayDialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showRunawayDialog(context, petState.evolutionPoints);
      });
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Bez tytułu - czysta górna belka
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () => _showResetDialog(context),
            tooltip: 'Resetuj',
          ),
        ],
      ),
      body: Stack(
        children: [
          // WARSTWA 1: Tło - grafika na całą powierzchnię
          Positioned.fill(
            child: Image.asset(
              'assets/images/petscreen_background.png',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          // WARSTWA 2: Zawartość ekranu
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Paski statystyk
                  _StatsPanel(petState: petState),

                  const SizedBox(height: 20),

                  // Kontener na animacje zwierzaka
                  Expanded(
                    child: _PetDisplay(
                      mood: petState.currentMood,
                      isSleeping: petState.isSleeping,
                      sleepStartTime: petState.sleepStartTime,
                      evolutionStage: petState.evolutionStage,
                      evolutionPoints: petState.evolutionPoints,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Ekwipunek - smakołyki do karmienia
                  _InventoryPanel(
                    onFeed: (rewardId) => _feedWithItem(context, rewardId),
                    isSleeping: petState.isSleeping,
                  ),

                  const SizedBox(height: 16),

                  // Przyciski akcji (bez karmienia - przeniesione do ekwipunku)
                  _ActionButtons(
                    petState: petState,
                    onPlay: () => ref.read(petProvider.notifier).play(),
                    onSleep: petState.isSleeping
                        ? () => ref.read(petProvider.notifier).wakeUp()
                        : () => ref.read(petProvider.notifier).sleep(),
                    onWash: () => ref.read(petProvider.notifier).wash(),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // EVOLUTION OVERLAY - pełnoekranowa animacja ewolucji
          if (_showEvolutionOverlay &&
              _evolutionFromStage != null &&
              _evolutionToStage != null)
            Positioned.fill(
              child: EvolutionOverlay(
                fromStage: _evolutionFromStage!,
                toStage: _evolutionToStage!,
                onComplete: _onEvolutionComplete,
              ),
            ),
        ],
      ),
    );
  }

  /// Karmi zwierzaka wybranym smakołykiem
  Future<void> _feedWithItem(BuildContext context, String rewardId) async {
    // Skonsumuj przedmiot BEZPOŚREDNIO z bazy - StreamBuilder automatycznie zaktualizuje UI
    final success = await DatabaseService.instance.consumeItem(rewardId);

    if (success) {
      // Nakarm zwierzaka
      ref.read(petProvider.notifier).feed();

      // Loguj zdarzenie analityczne
      analytics.logPetFed(rewardId);

      // Pokaż informację
      if (context.mounted) {
        final reward = availableRewards.firstWhere(
          (r) => r.id == rewardId,
          orElse: () => availableRewards.first,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Text(_getRewardEmoji(rewardId), style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Text('Mniam! ${reward.name}!'),
              ],
            ),
            backgroundColor: AppTheme.greenColor,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  String _getRewardEmoji(String rewardId) {
    switch (rewardId) {
      case 'cookie':
        return '🍪';
      case 'candy':
        return '🍬';
      case 'icecream':
        return '🍦';
      case 'chocolate':
        return '🍫';
      default:
        return '🍖';
    }
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Text('🔄', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            const Text('Nowa gra?'),
          ],
        ),
        content: const Text('Czy chcesz zaczac od nowa? Twoj zwierzak wrocido poczatkowego stanu.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Nie'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(petProvider.notifier).reset();
              Navigator.pop(ctx);
            },
            child: const Text('Tak'),
          ),
        ],
      ),
    );
  }

  /// Dialog pożegnalny - zwierzak uciekł po 72h nieobecności
  void _showRunawayDialog(BuildContext context, int evolutionPoints) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Column(
          children: [
            const Text('💌', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 12),
            Text(
              'List od Jajka',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Text(
                'Cześć!\n\n'
                'Czekałem na Ciebie, ale chyba byłeś bardzo zajęty. '
                'Postanowiłem wyruszyć na przygodę!\n\n'
                'Nie martw się - zostawiłem Ci nowe jajko. '
                'Może tym razem będziemy się częściej bawić?\n\n'
                '🌟 Do zobaczenia! 🌟',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: AppTheme.textColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Twój przyjaciel miał $evolutionPoints punktów',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textLightColor,
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ref.read(petProvider.notifier).acknowledgeRunaway();
                setState(() {
                  _runawayDialogShown = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Zaopiekuję się nowym jajkiem!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Panel ze statystykami
class _StatsPanel extends StatelessWidget {
  final PetState petState;

  const _StatsPanel({required this.petState});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // GLASSMORPHISM: Półprzezroczyste tło
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          _StatBar(
            label: 'Głód',
            value: petState.hunger,
            icon: '🍖',
            color: Colors.orange,
          ),
          const SizedBox(height: 12),
          _StatBar(
            label: 'Szczęście',
            value: petState.happiness,
            icon: '😊',
            color: Colors.pink,
          ),
          const SizedBox(height: 12),
          _StatBar(
            label: 'Energia',
            value: petState.energy,
            icon: '⚡',
            color: Colors.amber,
          ),
          const SizedBox(height: 12),
          _StatBar(
            label: 'Higiena',
            value: petState.hygiene,
            icon: '🧼',
            color: Colors.cyan,
          ),
        ],
      ),
    );
  }
}

/// Pojedynczy pasek statystyki
class _StatBar extends StatelessWidget {
  final String label;
  final double value;
  final String icon;
  final Color color;

  const _StatBar({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 8),
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textColor,
            ),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              // Tlo paska
              Container(
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              // Wypelnienie paska
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 16,
                width: (MediaQuery.of(context).size.width - 200) * (value / 100),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color,
                      color.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text(
            '${value.toInt()}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _getValueColor(value),
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Color _getValueColor(double value) {
    if (value < 30) return Colors.red;
    if (value < 50) return Colors.orange;
    return AppTheme.greenColor;
  }
}

/// Wyswietlanie zwierzaka
class _PetDisplay extends StatefulWidget {
  final String mood;
  final bool isSleeping;
  final DateTime? sleepStartTime;
  final EvolutionStage evolutionStage;
  final int evolutionPoints;

  const _PetDisplay({
    required this.mood,
    required this.isSleeping,
    this.sleepStartTime,
    required this.evolutionStage,
    required this.evolutionPoints,
  });

  @override
  State<_PetDisplay> createState() => _PetDisplayState();
}

class _PetDisplayState extends State<_PetDisplay> {
  /// Flaga animacji przejścia między fazami
  bool _isEvolving = false;

  /// Timer dla animacji przejścia
  Timer? _evolutionTimer;

  /// Czas trwania animacji przejścia (w sekundach)
  static const int _evolutionAnimationDuration = 4;

  @override
  void didUpdateWidget(covariant _PetDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Detekcja ewolucji - czy nastąpiła zmiana fazy?
    if (oldWidget.evolutionStage != widget.evolutionStage) {
      // Sprawdź czy to "upgrade" (np. z egg na firstCrack)
      final oldIndex = EvolutionStage.values.indexOf(oldWidget.evolutionStage);
      final newIndex = EvolutionStage.values.indexOf(widget.evolutionStage);

      if (newIndex > oldIndex) {
        // Ewolucja do wyższej fazy - uruchom animację przejścia
        _startEvolutionAnimation();
      }
    }
  }

  @override
  void dispose() {
    _evolutionTimer?.cancel();
    super.dispose();
  }

  /// Uruchamia animację przejścia między fazami
  void _startEvolutionAnimation() {
    debugPrint('🌟 EVOLUTION! Rozpoczynam animację przejścia do fazy: ${widget.evolutionStage}');

    setState(() {
      _isEvolving = true;
    });

    // Po zakończeniu animacji przejdź do normalnego stanu
    _evolutionTimer?.cancel();
    _evolutionTimer = Timer(
      Duration(seconds: _evolutionAnimationDuration),
      () {
        if (mounted) {
          debugPrint('🌟 EVOLUTION! Animacja zakończona - przechodzę do IDLE');
          setState(() {
            _isEvolving = false;
          });
        }
      },
    );
  }

  /// Formatuje czas snu jako "Xh Ym" lub "Xm"
  String _formatSleepTime() {
    if (widget.sleepStartTime == null) return '';
    final duration = DateTime.now().difference(widget.sleepStartTime!);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  /// Określa kategorię nastroju
  /// HAPPY = happy, playing, bathing, eating
  /// SAD = sad, hungry, tired, dirty
  /// IDLE = neutral, sleeping (i inne)
  String _getMoodCategory() {
    switch (widget.mood) {
      case 'happy':
      case 'playing':
      case 'bathing':
      case 'eating':
        return 'HAPPY';
      case 'sad':
      case 'hungry':
      case 'tired':
      case 'dirty':
        return 'SAD';
      default:
        return 'IDLE'; // neutral, sleeping, etc.
    }
  }

  /// Wybiera plik animacji na podstawie fazy ewolucji i nastroju
  ///
  /// NOWA Macierz wyboru (z animacją przejścia):
  /// | Faza              | EVOLVING              | IDLE                    | HAPPY                   | SAD                   |
  /// |-------------------|-----------------------|-------------------------|-------------------------|-----------------------|
  /// | 1 (0-30 pkt)      | -                     | Egg.webp                | happy_egg.webp          | sad_egg.webp          |
  /// | 2 (31-70 pkt)     | first_crack.webp      | first_crack_idle.webp   | first_crack_happy.webp  | first_crack_sad.webp  |
  /// | 3 (71-100 pkt)    | (placeholder)         | first_crack_idle.webp   | first_crack_happy.webp  | first_crack_sad.webp  |
  /// | 4 (>100 pkt)      | (placeholder)         | first_crack_idle.webp   | first_crack_happy.webp  | first_crack_sad.webp  |
  String _getEggAsset() {
    final moodCategory = _getMoodCategory();

    // PRIORYTET 1: Animacja przejścia (ewolucja w toku)
    if (_isEvolving) {
      debugPrint('🌟 EVOLVING: Wyświetlam animację przejścia dla fazy ${widget.evolutionStage}');
      // Animacja przejścia do Fazy 2
      if (widget.evolutionStage == EvolutionStage.firstCrack) {
        return 'assets/images/Creature/first_crack.webp';
      }
      // Placeholder dla wyższych faz (używamy first_crack.webp)
      return 'assets/images/Creature/first_crack.webp';
    }

    // Faza 4 - Wyklucie (>100 pkt)
    if (widget.evolutionStage == EvolutionStage.hatched) {
      debugPrint('🐣 HATCHING! evolutionPoints: ${widget.evolutionPoints}');
      // Placeholder - używamy assetów Fazy 2 do czasu stworzenia dedykowanych
      if (moodCategory == 'HAPPY') return 'assets/images/Creature/first_crack_happy.webp';
      if (moodCategory == 'SAD') return 'assets/images/Creature/first_crack_sad.webp';
      return 'assets/images/Creature/first_crack_idle.webp';
    }

    // Faza 3 - Drugie pęknięcie (71-100 pkt)
    if (widget.evolutionStage == EvolutionStage.secondCrack) {
      // Placeholder - używamy assetów Fazy 2 do czasu stworzenia dedykowanych
      if (moodCategory == 'HAPPY') return 'assets/images/Creature/first_crack_happy.webp';
      if (moodCategory == 'SAD') return 'assets/images/Creature/first_crack_sad.webp';
      return 'assets/images/Creature/first_crack_idle.webp';
    }

    // Faza 2 - Pierwsze pęknięcie (31-70 pkt) - KOMPLETNE ASSETY
    if (widget.evolutionStage == EvolutionStage.firstCrack) {
      if (moodCategory == 'HAPPY') return 'assets/images/Creature/first_crack_happy.webp';
      if (moodCategory == 'SAD') return 'assets/images/Creature/first_crack_sad.webp';
      return 'assets/images/Creature/first_crack_idle.webp';
    }

    // Faza 1 - Jajko (0-30 pkt)
    if (moodCategory == 'HAPPY') return 'assets/images/Creature/happy_egg.webp';
    if (moodCategory == 'SAD') return 'assets/images/Creature/sad_egg.webp';
    return 'assets/images/Creature/Egg.webp';
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.8, // 80% widoczności, 20% przezroczystości
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(_getEggAsset()),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
          children: [
            // Etykiety na wierzchu (na dole)
            Positioned(
              left: 0,
              right: 0,
              bottom: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Etykieta nastroju
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5), width: 1),
                    ),
                    child: Text(
                      _getMoodText(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor,
                      ),
                    ),
                  ),
                  // Wskaźnik czasu snu
                  if (widget.isSleeping && widget.sleepStartTime != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('💤', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(
                            'Śpi od ${_formatSleepTime()} (+${DateTime.now().difference(widget.sleepStartTime!).inMinutes} energii)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.indigo.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  String _getMoodText() {
    switch (widget.mood) {
      case 'happy':
        return 'Szczęśliwy!';
      case 'eating':
        return 'Mniam mniam!';
      case 'playing':
        return 'Zabawa!';
      case 'sleeping':
        return 'Zzz...';
      case 'tired':
        return 'Zmęczony...';
      case 'hungry':
        return 'Głodny!';
      case 'dirty':
        return 'Potrzebuje kąpieli!';
      case 'bathing':
        return 'Plusk plusk!';
      case 'sad':
        return 'Smutny...';
      case 'neutral':
        return 'W porządku';
      default:
        return 'Hej!';
    }
  }

}

/// Panel ekwipunku - smakołyki do karmienia
/// Używa StreamBuilder dla real-time aktualizacji z Supabase
class _InventoryPanel extends StatelessWidget {
  final Function(String rewardId) onFeed;
  final bool isSleeping;

  const _InventoryPanel({
    required this.onFeed,
    required this.isSleeping,
  });

  @override
  Widget build(BuildContext context) {
    // Jeśli baza nie jest dostępna - pokaż puste
    if (!DatabaseService.isInitialized) {
      return _buildPanel(context, {});
    }

    // StreamBuilder nasłuchuje BEZPOŚREDNIO zmian z Supabase
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: DatabaseService.instance.getInventoryStream(),
      builder: (context, snapshot) {
        // Oblicz liczniki z surowych danych
        final counts = snapshot.hasData
            ? DatabaseService.calculateCounts(snapshot.data!)
            : <String, int>{};

        debugPrint('[INVENTORY UI] Stream update: $counts');

        return _buildPanel(context, counts);
      },
    );
  }

  Widget _buildPanel(BuildContext context, Map<String, int> counts) {
    final isEmpty = counts.values.every((count) => count == 0);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // GLASSMORPHISM: Półprzezroczyste tło
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🎒', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                'Smakołyki',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
              const Spacer(),
              if (isEmpty)
                Text(
                  'Zbieraj w grach!',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textLightColor,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: availableRewards.map((reward) {
              final count = counts[reward.id] ?? 0;
              final canFeed = count > 0 && !isSleeping;

              return _FoodItem(
                key: ValueKey('food_${reward.id}_$count'),
                rewardId: reward.id,
                name: reward.name,
                count: count,
                enabled: canFeed,
                onTap: canFeed ? () => onFeed(reward.id) : null,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Pojedynczy przedmiot w ekwipunku
class _FoodItem extends StatelessWidget {
  final String rewardId;
  final String name;
  final int count;
  final bool enabled;
  final VoidCallback? onTap;

  const _FoodItem({
    super.key,
    required this.rewardId,
    required this.name,
    required this.count,
    required this.enabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled ? 1.0 : 0.4,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: enabled
                        ? _getRewardColor(rewardId).withOpacity(0.2)
                        : Colors.grey.shade200,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: enabled
                          ? _getRewardColor(rewardId)
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _getRewardEmoji(rewardId),
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                // Licznik
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: count > 0 ? AppTheme.primaryColor : Colors.grey,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              name,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: enabled ? AppTheme.textColor : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRewardEmoji(String rewardId) {
    switch (rewardId) {
      case 'cookie':
        return '🍪';
      case 'candy':
        return '🍬';
      case 'icecream':
        return '🍦';
      case 'chocolate':
        return '🍫';
      default:
        return '🍖';
    }
  }

  Color _getRewardColor(String rewardId) {
    switch (rewardId) {
      case 'cookie':
        return Colors.brown;
      case 'candy':
        return Colors.pink;
      case 'icecream':
        return Colors.cyan;
      case 'chocolate':
        return Colors.brown.shade700;
      default:
        return Colors.orange;
    }
  }
}

/// Przyciski akcji (bez karmienia - przeniesione do ekwipunku)
class _ActionButtons extends StatelessWidget {
  final PetState petState;
  final VoidCallback onPlay;
  final VoidCallback onSleep;
  final VoidCallback onWash;

  const _ActionButtons({
    required this.petState,
    required this.onPlay,
    required this.onSleep,
    required this.onWash,
  });

  @override
  Widget build(BuildContext context) {
    final isSleeping = petState.isSleeping;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ActionButton(
          icon: '🎾',
          label: 'Baw sie',
          color: Colors.pink,
          onTap: (isSleeping || petState.energy < 15) ? null : onPlay,
          disabled: isSleeping || petState.energy < 15,
        ),
        _ActionButton(
          icon: isSleeping ? '☀️' : '🛏️',
          label: isSleeping ? 'Obudz' : 'Spij',
          color: AppTheme.purpleColor,
          onTap: onSleep,
          disabled: false,
        ),
        _ActionButton(
          icon: '🧼',
          label: 'Umyj',
          color: AppTheme.accentColor,
          onTap: isSleeping ? null : onWash,
          disabled: isSleeping,
        ),
      ],
    );
  }
}

/// Pojedynczy przycisk akcji
class _ActionButton extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool disabled;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    required this.disabled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: disabled ? 0.4 : 1.0,
        child: Container(
          width: 75,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: disabled ? Colors.grey.shade300 : color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: disabled
                ? null
                : [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: disabled ? Colors.grey : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
