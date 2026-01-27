import 'package:flutter/material.dart';
import 'dart:math';
import '../../theme/app_theme.dart';

class ConnectSyllablesScreen extends StatefulWidget {
  const ConnectSyllablesScreen({super.key});

  @override
  State<ConnectSyllablesScreen> createState() => _ConnectSyllablesScreenState();
}

class _ConnectSyllablesScreenState extends State<ConnectSyllablesScreen>
    with TickerProviderStateMixin {
  final Random random = Random();
  int round = 0;
  int score = 0;
  static const int maxRounds = 10;

  late _WordData currentWord;
  List<String?> placedSyllables = [];
  List<String> availableSyllables = [];
  bool showSuccess = false;
  List<_WordData> usedWords = [];

  late AnimationController _successController;
  late Animation<double> _successScale;

  // 20 slow z poprawna polska sylabifikacja
  final List<_WordData> wordData = [
    _WordData('MAMA', ['MA', 'MA'], '👩'),
    _WordData('TATA', ['TA', 'TA'], '👨'),
    _WordData('KURA', ['KU', 'RA'], '🐔'),
    _WordData('LODY', ['LO', 'DY'], '🍦'),
    _WordData('KOTY', ['KO', 'TY'], '🐱'),
    _WordData('RYBA', ['RY', 'BA'], '🐟'),
    _WordData('BUTY', ['BU', 'TY'], '👟'),
    _WordData('DOMY', ['DO', 'MY'], '🏠'),
    _WordData('KAWA', ['KA', 'WA'], '☕'),
    _WordData('WODA', ['WO', 'DA'], '💧'),
    _WordData('LATO', ['LA', 'TO'], '☀️'),
    _WordData('ZIMA', ['ZI', 'MA'], '❄️'),
    _WordData('MAPA', ['MA', 'PA'], '🗺️'),
    _WordData('KINO', ['KI', 'NO'], '🎬'),
    _WordData('AUTO', ['AU', 'TO'], '🚗'),
    _WordData('KOLO', ['KO', 'LO'], '⭕'),
    _WordData('TORBA', ['TOR', 'BA'], '👜'),
    _WordData('LAMPA', ['LAM', 'PA'], '💡'),
    _WordData('MLEKO', ['MLE', 'KO'], '🥛'),
    _WordData('MOTYL', ['MO', 'TYL'], '🦋'),
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
    // Wybierz slowo ktore jeszcze nie bylo uzyte w tej sesji
    List<_WordData> availableWords = wordData.where((w) => !usedWords.contains(w)).toList();
    if (availableWords.isEmpty) {
      usedWords.clear();
      availableWords = List.from(wordData);
    }
    
    currentWord = availableWords[random.nextInt(availableWords.length)];
    usedWords.add(currentWord);
    
    placedSyllables = List.filled(currentWord.syllables.length, null);
    availableSyllables = List.from(currentWord.syllables)..shuffle(random);
    showSuccess = false;
  }

  void _onSyllablePlaced(String syllable, int slotIndex) {
    if (showSuccess) return;
    if (placedSyllables[slotIndex] != null) return;

    setState(() {
      placedSyllables[slotIndex] = syllable;
      availableSyllables.remove(syllable);
    });

    if (!placedSyllables.contains(null)) {
      _checkAnswer();
    }
  }

  void _onSyllableRemoved(int slotIndex) {
    if (showSuccess) return;
    if (placedSyllables[slotIndex] == null) return;

    setState(() {
      availableSyllables.add(placedSyllables[slotIndex]!);
      placedSyllables[slotIndex] = null;
    });
  }

  void _checkAnswer() {
    bool isCorrect = true;
    for (int i = 0; i < currentWord.syllables.length; i++) {
      if (placedSyllables[i] != currentWord.syllables[i]) {
        isCorrect = false;
        break;
      }
    }

    if (isCorrect) {
      setState(() {
        score++;
        showSuccess = true;
      });
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
    } else {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            availableSyllables = List.from(currentWord.syllables)..shuffle(random);
            placedSyllables = List.filled(currentWord.syllables.length, null);
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
        score: score,
        maxScore: maxRounds,
        onPlayAgain: () {
          Navigator.pop(context);
          setState(() {
            score = 0;
            round = 0;
            usedWords.clear();
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
        title: const Text('Połącz sylaby'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _ProgressIndicator(current: round + 1, total: maxRounds),
              const SizedBox(height: 24),

              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Center(
                  child: Text(
                    currentWord.emoji,
                    style: const TextStyle(fontSize: 60),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(currentWord.syllables.length, (index) {
                  return DragTarget<String>(
                    onAcceptWithDetails: (details) {
                      _onSyllablePlaced(details.data, index);
                    },
                    builder: (context, candidateData, rejectedData) {
                      bool isHighlighted = candidateData.isNotEmpty;
                      return GestureDetector(
                        onTap: () => _onSyllableRemoved(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 80,
                          height: 70,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: placedSyllables[index] != null
                                ? (showSuccess ? AppTheme.greenColor : AppTheme.primaryColor)
                                : (isHighlighted
                                    ? AppTheme.primaryColor.withValues(alpha: 0.3)
                                    : Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isHighlighted
                                  ? AppTheme.primaryColor
                                  : Colors.grey.shade400,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              placedSyllables[index] ?? '',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: placedSyllables[index] != null
                                    ? Colors.white
                                    : Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),

              const Spacer(),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: availableSyllables.map((syllable) {
                  return Draggable<String>(
                    data: syllable,
                    feedback: Material(
                      color: Colors.transparent,
                      child: _SyllableChip(syllable: syllable, isDragging: true),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.3,
                      child: _SyllableChip(syllable: syllable),
                    ),
                    child: _SyllableChip(syllable: syllable),
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
                      child: Column(
                        children: [
                          Text(
                            currentWord.word,
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.greenColor,
                            ),
                          ),
                          const Text(
                            '⭐ Brawo! ⭐',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _WordData {
  final String word;
  final List<String> syllables;
  final String emoji;

  _WordData(this.word, this.syllables, this.emoji);
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

class _SyllableChip extends StatelessWidget {
  final String syllable;
  final bool isDragging;

  const _SyllableChip({required this.syllable, this.isDragging = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: isDragging ? AppTheme.accentColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDragging ? 0.2 : 0.1),
            blurRadius: isDragging ? 12 : 6,
            offset: Offset(0, isDragging ? 8 : 3),
          ),
        ],
      ),
      child: Text(
        syllable,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: isDragging ? Colors.white : AppTheme.textColor,
        ),
      ),
    );
  }
}

class _CompletionDialog extends StatelessWidget {
  final int score;
  final int maxScore;
  final VoidCallback onPlayAgain;
  final VoidCallback onExit;

  const _CompletionDialog({
    required this.score,
    required this.maxScore,
    required this.onPlayAgain,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌟', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              'Wspaniale!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ułożyłeś $score z $maxScore słów!',
              style: TextStyle(fontSize: 18, color: AppTheme.textLightColor),
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
