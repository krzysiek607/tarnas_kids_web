import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Shimmer/skeleton loading placeholder for the parent panel statistics.
/// Shows grey pulsing rectangles mimicking the final card layout.
class StatsLoadingSkeleton extends StatefulWidget {
  const StatsLoadingSkeleton({super.key});

  @override
  State<StatsLoadingSkeleton> createState() => _StatsLoadingSkeletonState();
}

class _StatsLoadingSkeletonState extends State<StatsLoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final opacity = _animation.value;
        return Column(
          children: [
            _buildSkeletonCard(height: 120, opacity: opacity),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSkeletonCard(height: 100, opacity: opacity),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSkeletonCard(height: 100, opacity: opacity),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSkeletonCard(height: 100, opacity: opacity),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSkeletonCard(height: 100, opacity: opacity),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSkeletonCard(height: 200, opacity: opacity),
            const SizedBox(height: 16),
            _buildSkeletonCard(height: 160, opacity: opacity),
          ],
        );
      },
    );
  }

  Widget _buildSkeletonCard({
    required double height,
    required double opacity,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.textLightColor.withOpacity(opacity * 0.12),
        borderRadius: BorderRadius.circular(30),
      ),
    );
  }
}
