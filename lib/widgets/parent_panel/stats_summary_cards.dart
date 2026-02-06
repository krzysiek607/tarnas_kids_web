import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Grid of statistics summary cards:
/// - Total games played
/// - Total rewards earned
/// - Current streak
/// - Average daily sessions (from 7-day data)
class StatsSummaryCards extends StatelessWidget {
  final int totalGamesPlayed;
  final int totalRewards;
  final int currentStreak;
  final Map<String, int> dailySessions;

  const StatsSummaryCards({
    super.key,
    required this.totalGamesPlayed,
    required this.totalRewards,
    required this.currentStreak,
    required this.dailySessions,
  });

  @override
  Widget build(BuildContext context) {
    final avgDaily = _calculateAverageDaily();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                emoji: '\u{1F3AE}',
                value: totalGamesPlayed.toString(),
                label: 'Gier zagrano',
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                emoji: '\u{1F36A}',
                value: totalRewards.toString(),
                label: 'Nagrod zdobyto',
                color: AppTheme.accentColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                emoji: '\u{1F525}',
                value: '$currentStreak ${_dayLabel(currentStreak)}',
                label: 'Seria z rzedu',
                color: AppTheme.yellowColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                emoji: '\u{1F4C8}',
                value: avgDaily,
                label: 'Srednia/dzien',
                color: AppTheme.purpleColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _calculateAverageDaily() {
    if (dailySessions.isEmpty) return '0';
    final total = dailySessions.values.fold(0, (a, b) => a + b);
    final daysWithActivity = dailySessions.values.where((v) => v > 0).length;
    if (daysWithActivity == 0) return '0';
    final avg = total / daysWithActivity;
    if (avg == avg.roundToDouble()) return avg.round().toString();
    return avg.toStringAsFixed(1);
  }

  String _dayLabel(int count) {
    if (count == 1) return 'dzien';
    return 'dni';
  }
}

/// Individual stat card with emoji, value, and label
class _StatCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.emoji,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textLightColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
