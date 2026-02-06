import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'parent_panel_card.dart';

/// Displays top 5 most played games with horizontal progress bars.
/// Each game shows its rank, translated name, play count, and a bar
/// proportional to the max play count.
class FavoriteGamesCard extends StatelessWidget {
  final Map<String, int> gameStats;

  const FavoriteGamesCard({
    super.key,
    required this.gameStats,
  });

  @override
  Widget build(BuildContext context) {
    if (gameStats.isEmpty) {
      return const SizedBox.shrink();
    }

    final sortedGames = gameStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topGames = sortedGames.take(5).toList();
    final maxCount = topGames.first.value;

    return ParentPanelCard(
      emoji: '\u{1F3C6}',
      title: 'Ulubione gry',
      color: AppTheme.purpleColor,
      child: Column(
        children: topGames.asMap().entries.map((entry) {
          final index = entry.key;
          final game = entry.value;
          final progress = maxCount > 0 ? game.value / maxCount : 0.0;
          final color = _rankColor(index);

          return Padding(
            padding: EdgeInsets.only(
              bottom: index < topGames.length - 1 ? 14 : 0,
            ),
            child: _buildGameRow(
              rank: index + 1,
              gameName: translateGameName(game.key),
              playCount: game.value,
              progress: progress,
              color: color,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGameRow({
    required int rank,
    required String gameName,
    required int playCount,
    required double progress,
    required Color color,
  }) {
    final medal = rank == 1
        ? '\u{1F947}'
        : rank == 2
            ? '\u{1F948}'
            : rank == 3
                ? '\u{1F949}'
                : '\u{25AB}\u{FE0F}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(medal, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                gameName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor,
                ),
              ),
            ),
            Text(
              '$playCount ${_playLabel(playCount)}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: color.withOpacity(0.12),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }

  Color _rankColor(int index) {
    const colors = [
      AppTheme.primaryColor,
      AppTheme.accentColor,
      AppTheme.purpleColor,
      AppTheme.yellowColor,
      AppTheme.greenColor,
    ];
    return colors[index % colors.length];
  }

  String _playLabel(int count) {
    if (count == 1) return 'raz';
    if (count >= 2 && count <= 4) return 'razy';
    return 'razy';
  }

  /// Translates internal game name to Polish display name
  static String translateGameName(String name) {
    const translations = {
      'maze': 'Labirynt',
      'matching': 'Memory',
      'dots': 'Polacz kropki',
      'tracing': 'Rysowanie',
      'coloring': 'Kolorowanie',
      'letters': 'Literki',
      'numbers': 'Cyferki',
      'colors': 'Kolory',
      'animals': 'Zwierzatka',
      'shapes': 'Ksztalty',
      'syllables': 'Sylaby',
      'piano': 'Pianinko',
      'drums': 'Perkusja',
      'balloon_pop': 'Baloniki',
    };
    return translations[name] ?? name;
  }
}
