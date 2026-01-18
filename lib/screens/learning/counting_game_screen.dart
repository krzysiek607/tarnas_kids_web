import 'package:flutter/material.dart';
import 'dart:math';
import '../../theme/app_theme.dart';

class CountingGameScreen extends StatefulWidget {
  const CountingGameScreen({super.key});

  @override
  State<CountingGameScreen> createState() => _CountingGameScreenState();
}

class _CountingGameScreenState extends State<CountingGameScreen>
    with TickerProviderStateMixin {
  final Random random = Random();
  int round = 0;
  static const int maxRounds = 6;

  late int targetCount;
  int collectedCount = 0;
  late String currentEmoji;
  late List<_CollectableItem> items;
  bool showSuccess = false;

  late AnimationController _successController;
  late Animation<double> _successScale;
  late AnimationController _counterController;
  late Animation<double> _counterScale;

  final List<String> emojis = ['🍎', '🍌', '🍊', '🍇', '🍓', '⭐', '🌸', '🦋'];

  @override
  void initState() {
    super.initState();
    _successController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _successScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );
    _counterController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _counterScale = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _counterController, curve: Curves.easeOut),
    );
    _generateRound();
  }

  @override
  void dispose() {
    _successController.dispose();
    _counterController.dispose();
    super.dispose();
  }

  void _generateRound() {
    targetCount = 3 + random.nextInt(5);
    currentEmoji = emojis[random.nextInt(emojis.length)];
    items = [];
    for (int i = 0; i < targetCount; i++) {
      items.add(_CollectableItem(
        id: i,
        x: 0.1 + random.nextDouble() * 0.8,
        y: 0.1 + random.nextDouble() * 0.7,
        collected: false,
      ));
    }
    collectedCount = 0;
    showSuccess = false;
  }

  void _onItemTap(int id) {
    if (showSuccess) return;
    final itemIndex = items.indexWhere((item) => item.id == id);
    if (itemIndex == -1 || items[itemIndex].collected) return;

    setState(() {
      items[itemIndex] = items[itemIndex].copyWith(collected: true);
      collectedCount++;
    });
    _counterController.forward(from: 0);

    if (collectedCount == targetCount) {
      setState(() => showSuccess = true);
      _successController.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          if (round < maxRounds - 1) {
            setState(() {
              round++;
              _generateRound();
            });
          } else {
            _showCompletionDialog();
          }
        }
      });
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _CompletionDialog(
        onPlayAgain: () {
          Navigator.pop(context);
          setState(() {
            round = 0;
            _generateRound();
          });
        },
        onExit: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Zbieraj i licz'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: _ProgressIndicator(current: round + 1, total: maxRounds),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Zbierz $targetCount ',
                    style: TextStyle(fontSize: 22, color: AppTheme.textLightColor),
                  ),
                  Text(currentEmoji, style: const TextStyle(fontSize: 32)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: _counterScale,
              builder: (context, child) {
                return Transform.scale(
                  scale: _counterScale.value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: showSuccess ? AppTheme.greenColor : AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$collectedCount',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          ' / $targetCount',
                          style: const TextStyle(fontSize: 32, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: items.map((item) {
                      return Positioned(
                        key: ValueKey('r${round}_i${item.id}'),
                        left: item.x * constraints.maxWidth - 30,
                        top: item.y * constraints.maxHeight - 30,
                        child: _CollectableButton(
                          emoji: currentEmoji,
                          collected: item.collected,
                          onTap: () => _onItemTap(item.id),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            if (showSuccess)
              AnimatedBuilder(
                animation: _successScale,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _successScale.value,
                    child: const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        '🎉 Swietnie policzone! 🎉',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _CollectableItem {
  final int id;
  final double x;
  final double y;
  final bool collected;

  _CollectableItem({
    required this.id,
    required this.x,
    required this.y,
    required this.collected,
  });

  _CollectableItem copyWith({bool? collected}) {
    return _CollectableItem(id: id, x: x, y: y, collected: collected ?? this.collected);
  }
}

class _CollectableButton extends StatefulWidget {
  final String emoji;
  final bool collected;
  final VoidCallback onTap;

  const _CollectableButton({
    required this.emoji,
    required this.collected,
    required this.onTap,
  });

  @override
  State<_CollectableButton> createState() => _CollectableButtonState();
}

class _CollectableButtonState extends State<_CollectableButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
  }

  @override
  void didUpdateWidget(_CollectableButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.collected && !oldWidget.collected) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (context, child) {
        return Transform.scale(
          scale: _scale.value,
          child: GestureDetector(
            onTap: widget.collected ? null : widget.onTap,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(widget.emoji, style: const TextStyle(fontSize: 36)),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProgressIndicator extends StatelessWidget {
  final int current;
  final int total;

  const _ProgressIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (index) {
        bool isCompleted = index < current - 1;
        bool isCurrent = index == current - 1;
        return Expanded(
          child: Container(
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppTheme.greenColor
                  : isCurrent
                      ? AppTheme.primaryColor
                      : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}

class _CompletionDialog extends StatelessWidget {
  final VoidCallback onPlayAgain;
  final VoidCallback onExit;

  const _CompletionDialog({required this.onPlayAgain, required this.onExit});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🧮', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              'Super liczenie!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _DialogButton(
                  emoji: '🔄',
                  label: 'Jeszcze raz',
                  color: AppTheme.primaryColor,
                  onTap: onPlayAgain,
                ),
                _DialogButton(
                  emoji: '🏠',
                  label: 'Koniec',
                  color: AppTheme.accentColor,
                  onTap: onExit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _DialogButton({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
