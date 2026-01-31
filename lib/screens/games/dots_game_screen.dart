import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../../theme/app_theme.dart';
import '../../widgets/kid_friendly_button.dart';
import '../../services/sound_effects_service.dart';

/// Gra Kropki - dziecko klika na pojawiajace sie kropki
class DotsGameScreen extends StatefulWidget {
  const DotsGameScreen({super.key});

  @override
  State<DotsGameScreen> createState() => _DotsGameScreenState();
}

class _DotsGameScreenState extends State<DotsGameScreen>
    with TickerProviderStateMixin {
  static const int dotCount = 6;
  static const int gameDuration = 25; // sekund
  static const double dotSize = 80;

  int? activeDotIndex;
  int score = 0;
  int timeLeft = gameDuration;
  bool gameStarted = false;
  bool gameEnded = false;
  Timer? gameTimer;
  Timer? dotTimer;
  final Random random = Random();
  List<Offset> dotPositions = [];
  Size? gameAreaSize;

  late List<AnimationController> pulseControllers;
  late List<Animation<double>> pulseAnimations;

  @override
  void initState() {
    super.initState();
    pulseControllers = List.generate(
      dotCount,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );
    pulseAnimations = pulseControllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 1.3).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    dotTimer?.cancel();
    for (var controller in pulseControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  List<Offset> _generateRandomPositions(Size areaSize) {
    List<Offset> positions = [];
    double padding = dotSize / 2 + 10;
    double minDistance = dotSize + 20;

    for (int i = 0; i < dotCount; i++) {
      Offset newPos;
      bool validPosition;
      int attempts = 0;

      do {
        validPosition = true;
        double x = padding + random.nextDouble() * (areaSize.width - 2 * padding);
        double y = padding + random.nextDouble() * (areaSize.height - 2 * padding);
        newPos = Offset(x, y);

        // Sprawdz czy nie nachodzi na inne kropki
        for (var pos in positions) {
          double distance = (newPos - pos).distance;
          if (distance < minDistance) {
            validPosition = false;
            break;
          }
        }
        attempts++;
      } while (!validPosition && attempts < 100);

      positions.add(newPos);
    }

    return positions;
  }

  void _startGame() {
    if (gameAreaSize != null) {
      dotPositions = _generateRandomPositions(gameAreaSize!);
    }

    setState(() {
      gameStarted = true;
      gameEnded = false;
      score = 0;
      timeLeft = gameDuration;
      activeDotIndex = null;
    });

    // Timer odliczajacy czas gry
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        timeLeft--;
      });
      if (timeLeft <= 0) {
        _endGame();
      }
    });

    // Timer zmieniajacy aktywna kropke
    _activateRandomDot();
  }

  void _activateRandomDot() {
    if (gameEnded) return;

    // Wylacz poprzednia kropke
    if (activeDotIndex != null) {
      pulseControllers[activeDotIndex!].reset();
    }

    // Wybierz nowa losowa kropke
    int newIndex;
    do {
      newIndex = random.nextInt(dotCount);
    } while (newIndex == activeDotIndex);

    setState(() {
      activeDotIndex = newIndex;
    });

    pulseControllers[newIndex].repeat(reverse: true);

    // Ustaw czas do nastepnej zmiany (1.5-2.5 sekundy)
    int delay = 1500 + random.nextInt(1000);
    dotTimer = Timer(Duration(milliseconds: delay), () {
      if (!gameEnded) {
        _activateRandomDot();
      }
    });
  }

  void _onDotTap(int index) {
    if (!gameStarted || gameEnded) return;

    if (index == activeDotIndex) {
      setState(() {
        score++;
      });
      pulseControllers[index].reset();
      dotTimer?.cancel();

      // Dźwięk sukcesu przy trafieniu
      SoundEffectsService.instance.playSuccess();

      // Generuj nowe losowe pozycje po kazdym trafieniu
      if (gameAreaSize != null) {
        dotPositions = _generateRandomPositions(gameAreaSize!);
      }

      _activateRandomDot();
    }
  }

  void _endGame() {
    gameTimer?.cancel();
    dotTimer?.cancel();

    if (activeDotIndex != null) {
      pulseControllers[activeDotIndex!].reset();
    }

    setState(() {
      gameEnded = true;
      activeDotIndex = null;
    });

    _showResultDialog();
  }

  void _showResultDialog() {
    String message;
    String emoji;

    if (score >= 15) {
      message = 'Fantastycznie!';
      emoji = '🏆';
    } else if (score >= 10) {
      message = 'Bardzo dobrze!';
      emoji = '⭐';
    } else if (score >= 5) {
      message = 'Dobrze!';
      emoji = '👍';
    } else {
      message = 'Spróbuj jeszcze raz!';
      emoji = '💪';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameResultDialog(
        title: message,
        emoji: emoji,
        message: 'Zdobyłeś $score punktów!',
        buttons: [
          KidFriendlyButton.playAgain(
            label: 'Jeszcze raz',
            onPressed: () {
              Navigator.pop(context);
              _startGame();
            },
          ),
          KidFriendlyButton.exit(
            label: 'Koniec',
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Kropki'),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _InfoBox(
                    label: 'Punkty',
                    value: '$score',
                    color: AppTheme.greenColor,
                  ),
                  _InfoBox(
                    label: 'Czas',
                    value: '$timeLeft s',
                    color: timeLeft <= 5 ? Colors.red : AppTheme.accentColor,
                  ),
                ],
              ),
            ),
            Expanded(
              child: gameStarted && !gameEnded
                  ? _buildGameArea()
                  : _buildStartScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartScreen() {
    return LayoutBuilder(
      builder: (context, constraints) {
        gameAreaSize = Size(constraints.maxWidth, constraints.maxHeight);

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '👆',
                style: TextStyle(fontSize: 80),
              ),
              const SizedBox(height: 24),
              Text(
                'Klikaj kolorowe kropki!',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Masz $gameDuration sekund',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: _startGame,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: const Text(
                    'START',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGameArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        gameAreaSize = Size(constraints.maxWidth, constraints.maxHeight);

        if (dotPositions.isEmpty) {
          dotPositions = _generateRandomPositions(gameAreaSize!);
        }

        return Stack(
          children: List.generate(dotCount, (index) {
            bool isActive = index == activeDotIndex;
            return Positioned(
              left: dotPositions[index].dx - dotSize / 2,
              top: dotPositions[index].dy - dotSize / 2,
              child: GestureDetector(
                onTap: () => _onDotTap(index),
                child: AnimatedBuilder(
                  animation: pulseAnimations[index],
                  builder: (context, child) {
                    return Transform.scale(
                      scale: isActive ? pulseAnimations[index].value : 1.0,
                      child: Container(
                        width: dotSize,
                        height: dotSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive
                              ? _getColorForIndex(index)
                              : Colors.grey.shade400,
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: _getColorForIndex(index)
                                        .withValues(alpha: 0.5),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  )
                                ]
                              : null,
                        ),
                        child: isActive
                            ? const Center(
                                child: Text(
                                  '!',
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Color _getColorForIndex(int index) {
    final colors = [
      AppTheme.primaryColor,
      AppTheme.accentColor,
      AppTheme.yellowColor,
      AppTheme.purpleColor,
      AppTheme.greenColor,
      AppTheme.orangeColor,
    ];
    return colors[index % colors.length];
  }
}

class _InfoBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoBox({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textLightColor,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
