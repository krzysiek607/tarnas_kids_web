import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/pet_provider.dart';
import '../../theme/app_theme.dart';
import 'favorite_games_card.dart';

/// Button to export/share statistics as a formatted text summary.
/// Uses share_plus to invoke system share sheet.
class ExportStatsButton extends StatelessWidget {
  final int totalGamesPlayed;
  final int totalRewards;
  final int currentStreak;
  final String favoriteGame;
  final Map<String, int> gameStats;
  final PetState petState;

  const ExportStatsButton({
    super.key,
    required this.totalGamesPlayed,
    required this.totalRewards,
    required this.currentStreak,
    required this.favoriteGame,
    required this.gameStats,
    required this.petState,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _shareStats(context),
        icon: const Icon(Icons.share_rounded, size: 20),
        label: const Text(
          'Udostepnij statystyki',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accentColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  Future<void> _shareStats(BuildContext context) async {
    try {
      final text = _buildShareText();
      await Share.share(text);
    } catch (_) {
      // Silently ignore share errors - not critical
    }
  }

  String _buildShareText() {
    final stageName = _getStageName(petState.evolutionStage);
    final favGameTranslated = favoriteGame.isNotEmpty
        ? FavoriteGamesCard.translateGameName(favoriteGame)
        : 'brak';

    final buffer = StringBuffer();
    buffer.writeln('TaLu Kids - Statystyki');
    buffer.writeln('========================');
    buffer.writeln('');
    buffer.writeln('Gier zagrano: $totalGamesPlayed');
    buffer.writeln('Nagrod zdobyto: $totalRewards');
    buffer.writeln('Seria z rzedu: $currentStreak ${currentStreak == 1 ? 'dzien' : 'dni'}');
    buffer.writeln('Ulubiona gra: $favGameTranslated');
    buffer.writeln('');
    buffer.writeln('Zwierzak:');
    buffer.writeln('  Etap: $stageName');
    buffer.writeln('  Punkty ewolucji: ${petState.evolutionPoints}');
    buffer.writeln('');

    if (gameStats.isNotEmpty) {
      buffer.writeln('Ranking gier:');
      final sorted = gameStats.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final top = sorted.take(5);
      for (final game in top) {
        final name = FavoriteGamesCard.translateGameName(game.key);
        buffer.writeln('  - $name: ${game.value}x');
      }
    }

    return buffer.toString();
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
        return 'Wykluty!';
    }
  }
}
