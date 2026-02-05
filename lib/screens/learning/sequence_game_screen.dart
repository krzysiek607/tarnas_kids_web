import 'package:flutter/material.dart';
import 'dart:math';
import '../../theme/app_theme.dart';
import '../../services/sound_effects_controller.dart';
import '../../services/sound_effects_service.dart';

class SequenceGameScreen extends StatefulWidget {
  const SequenceGameScreen({super.key});

  @override
  State<SequenceGameScreen> createState() => _SequenceGameScreenState();
}

class _SequenceGameScreenState extends State<SequenceGameScreen>
    with TickerProviderStateMixin {
  final Random random = Random();
  int round = 0;
  static const int maxRounds = 5;

  late _SequenceData currentSequence;
  late List<_SequenceStep> shuffledSteps;
  List<_SequenceStep?> placedSteps = [];
  bool showSuccess = false;

  late AnimationController _successController;
  late Animation<double> _successScale;

  // 10 sekwencji z poprawna logika
  final List<_SequenceData> sequences = [
    _SequenceData(
      title: 'Poranek',
      icon: '🌅',
      steps: [
        _SequenceStep(0, '😴', 'Budzenie'),
        _SequenceStep(1, '🚿', 'Mycie'),
        _SequenceStep(2, '👕', 'Ubieranie'),
        _SequenceStep(3, '🥣', 'Śniadanie'),
      ],
    ),
    _SequenceData(
      title: 'Roślina',
      icon: '🌱',
      steps: [
        _SequenceStep(0, '🌰', 'Nasiono'),
        _SequenceStep(1, '💧', 'Podlewanie'),
        _SequenceStep(2, '🌱', 'Kiełek'),
        _SequenceStep(3, '🌸', 'Kwiat'),
      ],
    ),
    _SequenceData(
      title: 'Motyl',
      icon: '🦋',
      steps: [
        _SequenceStep(0, '🥚', 'Jajko'),
        _SequenceStep(1, '🐛', 'Gąsienica'),
        _SequenceStep(2, '🧶', 'Kokon'),
        _SequenceStep(3, '🦋', 'Motyl'),
      ],
    ),
    _SequenceData(
      title: 'Dzień',
      icon: '☀️',
      steps: [
        _SequenceStep(0, '🌅', 'Wschód'),
        _SequenceStep(1, '☀️', 'Południe'),
        _SequenceStep(2, '🌇', 'Zachód'),
        _SequenceStep(3, '🌙', 'Noc'),
      ],
    ),
    _SequenceData(
      title: 'Pizza',
      icon: '🍕',
      steps: [
        _SequenceStep(0, '🫓', 'Ciasto'),
        _SequenceStep(1, '🍅', 'Sos'),
        _SequenceStep(2, '🧀', 'Ser'),
        _SequenceStep(3, '🍕', 'Gotowe'),
      ],
    ),
    _SequenceData(
      title: 'Kurczak',
      icon: '🐔',
      steps: [
        _SequenceStep(0, '🥚', 'Jajko'),
        _SequenceStep(1, '🐣', 'Wykluwanie'),
        _SequenceStep(2, '🐥', 'Pisklak'),
        _SequenceStep(3, '🐔', 'Kura'),
      ],
    ),
    // Nowe sekwencje
    _SequenceData(
      title: 'Pory roku',
      icon: '🍂',
      steps: [
        _SequenceStep(0, '🌸', 'Wiosna'),
        _SequenceStep(1, '☀️', 'Lato'),
        _SequenceStep(2, '🍂', 'Jesień'),
        _SequenceStep(3, '❄️', 'Zima'),
      ],
    ),
    _SequenceData(
      title: 'Bałwan',
      icon: '⛄',
      steps: [
        _SequenceStep(0, '❄️', 'Śnieg'),
        _SequenceStep(1, '⚪', 'Kula'),
        _SequenceStep(2, '⛄', 'Bałwan'),
        _SequenceStep(3, '🥕', 'Nos'),
      ],
    ),
    _SequenceData(
      title: 'Książka',
      icon: '📖',
      steps: [
        _SequenceStep(0, '✏️', 'Pisanie'),
        _SequenceStep(1, '📄', 'Strony'),
        _SequenceStep(2, '📚', 'Okładka'),
        _SequenceStep(3, '📖', 'Czytanie'),
      ],
    ),
    _SequenceData(
      title: 'Żaba',
      icon: '🐸',
      steps: [
        _SequenceStep(0, '💧', 'Woda'),
        _SequenceStep(1, '🥚', 'Skrzek'),
        _SequenceStep(2, '🐟', 'Kijanka'),
        _SequenceStep(3, '🐸', 'Żaba'),
      ],
    ),
  ];

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
    _generateRound();
  }

  @override
  void dispose() {
    _successController.dispose();
    super.dispose();
  }

  void _generateRound() {
    currentSequence = sequences[random.nextInt(sequences.length)];
    shuffledSteps = List.from(currentSequence.steps)..shuffle(random);
    placedSteps = List.filled(currentSequence.steps.length, null);
    showSuccess = false;
  }

  void _onStepPlaced(_SequenceStep step, int slotIndex) {
    if (showSuccess) return;
    if (placedSteps[slotIndex] != null) return;

    setState(() {
      placedSteps[slotIndex] = step;
      shuffledSteps.remove(step);
    });

    if (!placedSteps.contains(null)) {
      _checkAnswer();
    }
  }

  void _onStepRemoved(int slotIndex) {
    if (showSuccess) return;
    if (placedSteps[slotIndex] == null) return;

    setState(() {
      shuffledSteps.add(placedSteps[slotIndex]!);
      placedSteps[slotIndex] = null;
    });
  }

  void _checkAnswer() {
    bool isCorrect = true;
    for (int i = 0; i < currentSequence.steps.length; i++) {
      if (placedSteps[i]?.order != i) {
        isCorrect = false;
        break;
      }
    }

    if (isCorrect) {
      setState(() => showSuccess = true);
      _successController.forward(from: 0);
      SoundEffectsController().playSuccess();
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
    } else {
      SoundEffectsService.instance.playError();
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            shuffledSteps = List.from(currentSequence.steps)..shuffle(random);
            placedSteps = List.filled(currentSequence.steps.length, null);
          });
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
        title: const Text('Ułóż kolejność'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _ProgressIndicator(current: round + 1, total: maxRounds),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(currentSequence.icon, style: const TextStyle(fontSize: 40)),
                    const SizedBox(width: 12),
                    Text(
                      currentSequence.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Sloty na kroki z numerami
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(currentSequence.steps.length, (index) {
                  return Column(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      DragTarget<_SequenceStep>(
                        onAcceptWithDetails: (details) {
                          _onStepPlaced(details.data, index);
                        },
                        builder: (context, candidateData, rejectedData) {
                          bool isHighlighted = candidateData.isNotEmpty;
                          return GestureDetector(
                            onTap: () => _onStepRemoved(index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: placedSteps[index] != null
                                    ? (showSuccess ? AppTheme.greenColor : AppTheme.primaryColor)
                                    : (isHighlighted
                                        ? AppTheme.primaryColor.withValues(alpha: 0.3)
                                        : Colors.grey.shade200),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isHighlighted ? AppTheme.primaryColor : Colors.grey.shade400,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: placedSteps[index] != null
                                    ? _AnimatedSlotContent(
                                        key: ValueKey('slot_${index}_${placedSteps[index]!.order}'),
                                        emoji: placedSteps[index]!.emoji,
                                      )
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                }),
              ),

              const SizedBox(height: 8),

              // Strzalki miedzy slotami
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(currentSequence.steps.length - 1, (index) {
                    return Icon(
                      Icons.arrow_forward_rounded,
                      color: AppTheme.textLightColor,
                      size: 20,
                    );
                  }),
                ),
              ),

              const Spacer(),

              // Dostepne kroki
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: shuffledSteps.map((step) {
                  return Draggable<_SequenceStep>(
                    data: step,
                    feedback: Material(
                      color: Colors.transparent,
                      child: _StepChip(step: step, isDragging: true),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.3,
                      child: _StepChip(step: step),
                    ),
                    child: _StepChip(step: step),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              if (showSuccess)
                AnimatedBuilder(
                  animation: _successScale,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _successScale.value,
                      child: const Text(
                        '⭐ Świetna kolejność! ⭐',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// === Klasy pomocnicze ===

/// Widget z animacją wlotu do slotu (bounce + scale)
class _AnimatedSlotContent extends StatefulWidget {
  final String emoji;

  const _AnimatedSlotContent({super.key, required this.emoji});

  @override
  State<_AnimatedSlotContent> createState() => _AnimatedSlotContentState();
}

class _AnimatedSlotContentState extends State<_AnimatedSlotContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Animacja scale z bounce
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.3), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 0.9), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 20),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Animacja przesunięcia z góry
    _offsetAnimation = Tween<double>(begin: -30, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
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
        return Transform.translate(
          offset: Offset(0, _offsetAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Text(
              widget.emoji,
              style: const TextStyle(fontSize: 32),
            ),
          ),
        );
      },
    );
  }
}

class _SequenceData {
  final String title;
  final String icon;
  final List<_SequenceStep> steps;

  const _SequenceData({
    required this.title,
    required this.icon,
    required this.steps,
  });
}

class _SequenceStep {
  final int order;
  final String emoji;
  final String label;

  const _SequenceStep(this.order, this.emoji, this.label);
}

class _StepChip extends StatelessWidget {
  final _SequenceStep step;
  final bool isDragging;

  const _StepChip({
    required this.step,
    this.isDragging = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDragging ? AppTheme.primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDragging ? AppTheme.primaryColor : Colors.grey.shade300,
          width: 2,
        ),
        boxShadow: isDragging
            ? [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : AppTheme.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            step.emoji,
            style: const TextStyle(fontSize: 36),
          ),
          const SizedBox(height: 4),
          Text(
            step.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDragging ? Colors.white : AppTheme.textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressIndicator extends StatelessWidget {
  final int current;
  final int total;

  const _ProgressIndicator({
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (index) {
        final isCompleted = index < current;
        final isCurrent = index == current - 1;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isCurrent ? 32 : 12,
          height: 12,
          decoration: BoxDecoration(
            color: isCompleted ? AppTheme.greenColor : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(6),
          ),
        );
      }),
    );
  }
}

class _CompletionDialog extends StatelessWidget {
  final VoidCallback onPlayAgain;
  final VoidCallback onExit;

  const _CompletionDialog({
    required this.onPlayAgain,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🎉',
              style: TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            Text(
              'Świetnie!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ukończyłeś wszystkie sekwencje!',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textLightColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _DialogButton(
                    label: 'Wyjdź',
                    icon: Icons.home_rounded,
                    color: Colors.grey.shade400,
                    onTap: onExit,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DialogButton(
                    label: 'Jeszcze raz',
                    icon: Icons.refresh_rounded,
                    color: AppTheme.primaryColor,
                    onTap: onPlayAgain,
                  ),
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
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DialogButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
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
