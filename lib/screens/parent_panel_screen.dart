import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../providers/pet_provider.dart';
import '../services/sound_effects_service.dart';

/// Panel Rodzica - statystyki dziecka
class ParentPanelScreen extends ConsumerStatefulWidget {
  const ParentPanelScreen({super.key});

  @override
  ConsumerState<ParentPanelScreen> createState() => _ParentPanelScreenState();
}

class _ParentPanelScreenState extends ConsumerState<ParentPanelScreen> {
  bool _isLoading = true;
  Map<String, int> _gameStats = {};
  int _totalRewards = 0;
  int _totalGamesPlayed = 0;
  String _favoriteGame = '';

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Pobierz statystyki gier z analytics_events
      final gameStartEvents = await supabase
          .from('analytics_events')
          .select('parameters')
          .eq('user_id', userId)
          .eq('event_name', 'game_start');

      final rewardEvents = await supabase
          .from('analytics_events')
          .select('id')
          .eq('user_id', userId)
          .eq('event_name', 'reward_earned');

      // Przetwórz statystyki gier
      final Map<String, int> gameCount = {};
      for (final event in gameStartEvents) {
        final params = event['parameters'] as Map<String, dynamic>?;
        if (params != null && params['game_name'] != null) {
          final gameName = params['game_name'] as String;
          gameCount[gameName] = (gameCount[gameName] ?? 0) + 1;
        }
      }

      // Znajdź ulubioną grę
      String favorite = '';
      int maxPlays = 0;
      gameCount.forEach((game, count) {
        if (count > maxPlays) {
          maxPlays = count;
          favorite = game;
        }
      });

      setState(() {
        _gameStats = gameCount;
        _totalGamesPlayed = gameCount.values.fold(0, (a, b) => a + b);
        _totalRewards = rewardEvents.length;
        _favoriteGame = favorite;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('[PARENT_PANEL] Błąd ładowania statystyk: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final petState = ref.watch(petProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('📊 ', style: TextStyle(fontSize: 24)),
            Text('Panel Rodzica'),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            SoundEffectsService.instance.playClick();
            context.pop();
          },
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppTheme.primaryColor),
                  SizedBox(height: 16),
                  Text('Ładowanie statystyk...'),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadStatistics,
              color: AppTheme.primaryColor,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Nagłówek
                  _buildInfoBanner(),
                  const SizedBox(height: 20),

                  // Statystyki Zwierzaka
                  _buildPetStatsCard(petState),
                  const SizedBox(height: 16),

                  // Statystyki Gier
                  _buildGameStatsCard(),
                  const SizedBox(height: 16),

                  // Nagrody
                  _buildRewardsCard(),
                  const SizedBox(height: 16),

                  // Top Gry
                  if (_gameStats.isNotEmpty) _buildTopGamesCard(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentColor.withOpacity(0.15),
            AppTheme.greenColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.accentColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('💡', style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Tu możesz sprawdzić postępy swojego dziecka w nauce i zabawie.',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textColor,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetStatsCard(PetState petState) {
    final evolutionPercent = _getEvolutionPercent(petState);
    final stageName = _getStageName(petState.evolutionStage);
    final nextStageName = _getNextStageName(petState.evolutionStage);

    return _buildCard(
      emoji: '🥚',
      title: 'Zwierzak',
      color: AppTheme.yellowColor,
      child: Column(
        children: [
          // Etap ewolucji
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Etap: $stageName',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (nextStageName.isNotEmpty)
                    Text(
                      'Następny: $nextStageName',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textLightColor,
                      ),
                    ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.yellowColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${petState.evolutionPoints} pkt',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.yellowColor.withOpacity(0.9),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Pasek postępu
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Postęp do następnego etapu',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textLightColor,
                    ),
                  ),
                  Text(
                    '${(evolutionPercent * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: evolutionPercent,
                  minHeight: 12,
                  backgroundColor: AppTheme.yellowColor.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation(AppTheme.yellowColor),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Statystyki zdrowia
          Row(
            children: [
              _buildMiniStat('🍎', 'Głód', petState.hunger),
              _buildMiniStat('😊', 'Humor', petState.happiness),
              _buildMiniStat('⚡', 'Energia', petState.energy),
              _buildMiniStat('🛁', 'Higiena', petState.hygiene),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String emoji, String label, double value) {
    final color = value > 60
        ? AppTheme.greenColor
        : value > 30
            ? AppTheme.yellowColor
            : Colors.red.shade400;

    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            '${value.round()}%',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.textLightColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameStatsCard() {
    return _buildCard(
      emoji: '🎮',
      title: 'Aktywność',
      color: AppTheme.primaryColor,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatBox(
                  value: _totalGamesPlayed.toString(),
                  label: 'Gier zagrano',
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatBox(
                  value: _totalRewards.toString(),
                  label: 'Nagród zdobyto',
                  color: AppTheme.accentColor,
                ),
              ),
            ],
          ),
          if (_favoriteGame.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.purpleColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ulubiona gra',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textLightColor,
                          ),
                        ),
                        Text(
                          _translateGameName(_favoriteGame),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.purpleColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_gameStats[_favoriteGame] ?? 0}x',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.purpleColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatBox({
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textLightColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsCard() {
    return _buildCard(
      emoji: '🏆',
      title: 'Nagrody',
      color: AppTheme.accentColor,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.yellowColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text('🍪', style: TextStyle(fontSize: 36)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_totalRewards smakołyków',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _totalRewards == 0
                      ? 'Jeszcze nic nie zebrano'
                      : _totalRewards < 5
                          ? 'Dobry początek!'
                          : _totalRewards < 20
                              ? 'Świetnie idzie!'
                              : 'Wspaniały kolekcjoner!',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textLightColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopGamesCard() {
    // Sortuj gry według popularności
    final sortedGames = _gameStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topGames = sortedGames.take(5).toList();

    return _buildCard(
      emoji: '📈',
      title: 'Ranking Gier',
      color: AppTheme.purpleColor,
      child: Column(
        children: topGames.asMap().entries.map((entry) {
          final index = entry.key;
          final game = entry.value;
          final medal = index == 0
              ? '🥇'
              : index == 1
                  ? '🥈'
                  : index == 2
                      ? '🥉'
                      : '▫️';

          return Padding(
            padding: EdgeInsets.only(bottom: index < topGames.length - 1 ? 12 : 0),
            child: Row(
              children: [
                Text(medal, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _translateGameName(game.key),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${game.value}x',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCard({
    required String emoji,
    required String title,
    required Color color,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  // === Helpers ===

  double _getEvolutionPercent(PetState petState) {
    final points = petState.evolutionPoints;
    switch (petState.evolutionStage) {
      case EvolutionStage.egg:
        return (points / 150).clamp(0.0, 1.0);
      case EvolutionStage.firstCrack:
        return ((points - 150) / 200).clamp(0.0, 1.0); // 150-350
      case EvolutionStage.secondCrack:
        return ((points - 350) / 250).clamp(0.0, 1.0); // 350-600
      case EvolutionStage.hatched:
        return 1.0;
    }
  }

  String _getStageName(EvolutionStage stage) {
    switch (stage) {
      case EvolutionStage.egg:
        return 'Jajko';
      case EvolutionStage.firstCrack:
        return 'Pęknięcie';
      case EvolutionStage.secondCrack:
        return 'Prawie gotowe!';
      case EvolutionStage.hatched:
        return 'Wykluty! 🐣';
    }
  }

  String _getNextStageName(EvolutionStage stage) {
    switch (stage) {
      case EvolutionStage.egg:
        return 'Pierwsze pęknięcie (151 pkt)';
      case EvolutionStage.firstCrack:
        return 'Drugie pęknięcie (351 pkt)';
      case EvolutionStage.secondCrack:
        return 'Wyklucie (601 pkt)';
      case EvolutionStage.hatched:
        return '';
    }
  }

  String _translateGameName(String name) {
    final translations = {
      'maze': 'Labirynt',
      'matching': 'Memory',
      'dots': 'Połącz kropki',
      'tracing': 'Rysowanie',
      'coloring': 'Kolorowanie',
      'letters': 'Literki',
      'numbers': 'Cyferki',
      'colors': 'Kolory',
      'animals': 'Zwierzątka',
      'shapes': 'Kształty',
      'syllables': 'Sylaby',
      'piano': 'Pianinko',
      'drums': 'Perkusja',
      'balloon_pop': 'Baloniki',
    };
    return translations[name] ?? name;
  }
}
