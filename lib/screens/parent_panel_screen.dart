import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../providers/pet_provider.dart';
import '../providers/parent_panel_provider.dart';
import '../services/sound_effects_service.dart';
import '../widgets/parent_panel/activity_chart_card.dart';
import '../widgets/parent_panel/favorite_games_card.dart';
import '../widgets/parent_panel/stats_summary_cards.dart';
import '../widgets/parent_panel/export_stats_button.dart';
import '../widgets/parent_panel/stats_loading_skeleton.dart';

/// Panel Rodzica - statystyki dziecka
class ParentPanelScreen extends ConsumerWidget {
  const ParentPanelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petState = ref.watch(petProvider);
    final stats = ref.watch(parentPanelProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('\u{1F4CA} ', style: TextStyle(fontSize: 24)),
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
      body: stats.isLoading
          ? const Padding(
              padding: EdgeInsets.all(20),
              child: StatsLoadingSkeleton(),
            )
          : RefreshIndicator(
              onRefresh: () =>
                  ref.read(parentPanelProvider.notifier).loadStatistics(),
              color: AppTheme.primaryColor,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Naglowek
                  const _InfoBanner(),
                  const SizedBox(height: 20),

                  // Statystyki Zwierzaka (zachowana istniejaca funkcjonalnosc)
                  _PetStatsCard(petState: petState),
                  const SizedBox(height: 16),

                  // Podsumowanie statystyk (nowe karty)
                  StatsSummaryCards(
                    totalGamesPlayed: stats.totalGamesPlayed,
                    totalRewards: stats.totalRewards,
                    currentStreak: stats.currentStreak,
                    dailySessions: stats.dailySessions,
                  ),
                  const SizedBox(height: 16),

                  // Wykres aktywnosci (ostatnie 7 dni)
                  ActivityChartCard(dailySessions: stats.dailySessions),
                  const SizedBox(height: 16),

                  // Ulubione gry z progress barami
                  if (stats.gameStats.isNotEmpty)
                    FavoriteGamesCard(gameStats: stats.gameStats),
                  if (stats.gameStats.isNotEmpty) const SizedBox(height: 16),

                  // Nagrody
                  _RewardsCard(totalRewards: stats.totalRewards),
                  const SizedBox(height: 20),

                  // Przycisk eksportu
                  ExportStatsButton(
                    totalGamesPlayed: stats.totalGamesPlayed,
                    totalRewards: stats.totalRewards,
                    currentStreak: stats.currentStreak,
                    favoriteGame: stats.favoriteGame,
                    gameStats: stats.gameStats,
                    petState: petState,
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}

// ============================================================
// EXTRACTED STATELESS WIDGETS
// ============================================================

/// Info banner at the top of the parent panel
class _InfoBanner extends StatelessWidget {
  const _InfoBanner();

  @override
  Widget build(BuildContext context) {
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
            child: const Text('\u{1F4A1}', style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Tu mozesz sprawdzic postepy swojego dziecka w nauce i zabawie.',
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
}

/// Pet statistics card showing evolution progress and health bars
class _PetStatsCard extends StatelessWidget {
  final PetState petState;

  const _PetStatsCard({required this.petState});

  @override
  Widget build(BuildContext context) {
    final evolutionPercent = _getEvolutionPercent(petState);
    final stageName = _getStageName(petState.evolutionStage);
    final nextStageName = _getNextStageName(petState.evolutionStage);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
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
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.yellowColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('\u{1F95A}', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              const Text(
                'Zwierzak',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),

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
                      'Nastepny: $nextStageName',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textLightColor,
                      ),
                    ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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

          // Pasek postepu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Postep do nastepnego etapu',
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

          const SizedBox(height: 20),

          // Statystyki zdrowia
          Row(
            children: [
              _buildMiniStat('\u{1F34E}', 'Glod', petState.hunger),
              _buildMiniStat('\u{1F60A}', 'Humor', petState.happiness),
              _buildMiniStat('\u{26A1}', 'Energia', petState.energy),
              _buildMiniStat('\u{1F6C1}', 'Higiena', petState.hygiene),
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

  double _getEvolutionPercent(PetState petState) {
    final points = petState.evolutionPoints;
    switch (petState.evolutionStage) {
      case EvolutionStage.egg:
        return (points / 150).clamp(0.0, 1.0);
      case EvolutionStage.firstCrack:
        return ((points - 150) / 200).clamp(0.0, 1.0);
      case EvolutionStage.secondCrack:
        return ((points - 350) / 250).clamp(0.0, 1.0);
      case EvolutionStage.hatched:
        return 1.0;
    }
  }

  String _getStageName(EvolutionStage stage) {
    switch (stage) {
      case EvolutionStage.egg:
        return 'Jajko';
      case EvolutionStage.firstCrack:
        return 'Pekniecie';
      case EvolutionStage.secondCrack:
        return 'Prawie gotowe!';
      case EvolutionStage.hatched:
        return 'Wykluty! \u{1F423}';
    }
  }

  String _getNextStageName(EvolutionStage stage) {
    switch (stage) {
      case EvolutionStage.egg:
        return 'Pierwsze pekniecie (151 pkt)';
      case EvolutionStage.firstCrack:
        return 'Drugie pekniecie (351 pkt)';
      case EvolutionStage.secondCrack:
        return 'Wyklucie (601 pkt)';
      case EvolutionStage.hatched:
        return '';
    }
  }
}

/// Rewards summary card
class _RewardsCard extends StatelessWidget {
  final int totalRewards;

  const _RewardsCard({required this.totalRewards});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
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
                  color: AppTheme.accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('\u{1F3C6}', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              const Text(
                'Nagrody',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.yellowColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text('\u{1F36A}', style: TextStyle(fontSize: 36)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$totalRewards smakolykow',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _rewardMessage(totalRewards),
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
        ],
      ),
    );
  }

  String _rewardMessage(int count) {
    if (count == 0) return 'Jeszcze nic nie zebrano';
    if (count < 5) return 'Dobry poczatek!';
    if (count < 20) return 'Swietnie idzie!';
    return 'Wspanialy kolekcjoner!';
  }
}
