import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'parent_panel_card.dart';

/// Bar chart showing game sessions per day for the last 7 days.
/// X axis: Polish day abbreviations (Pon, Wt, Sr, Czw, Pt, Sob, Ndz)
/// Y axis: number of sessions
class ActivityChartCard extends StatelessWidget {
  /// Map of date keys (yyyy-MM-dd) to session counts, ordered chronologically
  final Map<String, int> dailySessions;

  const ActivityChartCard({
    super.key,
    required this.dailySessions,
  });

  @override
  Widget build(BuildContext context) {
    return ParentPanelCard(
      emoji: '\u{1F4CA}',
      title: 'Aktywnosc (7 dni)',
      color: AppTheme.accentColor,
      child: _buildChart(),
    );
  }

  Widget _buildChart() {
    final entries = dailySessions.entries.toList();
    final maxY = _calculateMaxY(entries);
    final hasData = entries.any((e) => e.value > 0);

    if (!hasData) {
      return SizedBox(
        height: 180,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '\u{1F3AE}',
                style: const TextStyle(fontSize: 36),
              ),
              const SizedBox(height: 8),
              Text(
                'Brak aktywnosci w ostatnich 7 dniach',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textLightColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          minY: 0,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipRoundedRadius: 12,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final count = rod.toY.round();
                return BarTooltipItem(
                  '$count ${_sessionLabel(count)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= entries.length) {
                    return const SizedBox.shrink();
                  }
                  final dateStr = entries[index].key;
                  final dayName = _polishDayAbbrev(dateStr);
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      dayName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textLightColor,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: _calculateInterval(maxY),
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox.shrink();
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textLightColor,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: _calculateInterval(maxY),
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.15),
                strokeWidth: 1,
              );
            },
          ),
          barGroups: _buildBarGroups(entries),
        ),
        duration: const Duration(milliseconds: 300),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(
    List<MapEntry<String, int>> entries,
  ) {
    return entries.asMap().entries.map((entry) {
      final index = entry.key;
      final sessions = entry.value.value.toDouble();
      final isToday = index == entries.length - 1;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: sessions,
            width: 22,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            gradient: LinearGradient(
              colors: isToday
                  ? [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.7)]
                  : [AppTheme.accentColor, AppTheme.accentColor.withOpacity(0.7)],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ],
      );
    }).toList();
  }

  double _calculateMaxY(List<MapEntry<String, int>> entries) {
    final maxVal = entries.fold<int>(0, (max, e) => e.value > max ? e.value : max);
    if (maxVal <= 0) return 5;
    if (maxVal <= 5) return (maxVal + 1).toDouble();
    return (maxVal * 1.2).ceilToDouble();
  }

  double _calculateInterval(double maxY) {
    if (maxY <= 5) return 1;
    if (maxY <= 10) return 2;
    if (maxY <= 20) return 5;
    return (maxY / 4).ceilToDouble();
  }

  /// Returns Polish day abbreviation from a date string (yyyy-MM-dd)
  String _polishDayAbbrev(String dateStr) {
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';

    const dayNames = ['Pon', 'Wt', 'Sr', 'Czw', 'Pt', 'Sob', 'Ndz'];
    // DateTime.weekday: 1 = Monday, 7 = Sunday
    return dayNames[date.weekday - 1];
  }

  String _sessionLabel(int count) {
    if (count == 1) return 'gra';
    if (count >= 2 && count <= 4) return 'gry';
    return 'gier';
  }
}
