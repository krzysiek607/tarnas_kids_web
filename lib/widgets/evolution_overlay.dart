import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/pet_provider.dart';
import '../theme/app_theme.dart';
import '../services/sound_effects_controller.dart';

/// Pełnoekranowy overlay wyświetlany podczas ewolucji jajka
class EvolutionOverlay extends StatefulWidget {
  final EvolutionStage fromStage;
  final EvolutionStage toStage;
  final VoidCallback onComplete;

  const EvolutionOverlay({
    super.key,
    required this.fromStage,
    required this.toStage,
    required this.onComplete,
  });

  @override
  State<EvolutionOverlay> createState() => _EvolutionOverlayState();
}

class _EvolutionOverlayState extends State<EvolutionOverlay>
    with TickerProviderStateMixin {
  // Fazy animacji
  bool _isShaking = true;
  bool _showFlash = false;
  bool _showNewEgg = false;
  bool _showConfetti = false;
  bool _showText = false;
  bool _showButton = false;

  // Kontrolery animacji
  late AnimationController _shakeController;
  late AnimationController _flashController;
  late AnimationController _scaleController;
  late AnimationController _confettiController;

  // Animacje
  late Animation<double> _shakeAnimation;
  late Animation<double> _flashAnimation;
  late Animation<double> _scaleAnimation;

  // Cząsteczki konfetti
  final List<_ConfettiParticle> _confettiParticles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startEvolutionSequence();
  }

  void _initAnimations() {
    // Shake animation (2 sekundy)
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _shakeAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
    );
    _shakeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _shakeController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        if (_isShaking) {
          _shakeController.forward();
        }
      }
    });

    // Flash animation
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _flashAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flashController, curve: Curves.easeOut),
    );

    // Scale animation (dla nowego jajka)
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Confetti animation
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _confettiController.addListener(() {
      _updateConfetti();
    });
  }

  Future<void> _startEvolutionSequence() async {
    // Odtwórz dźwięk ewolucji (z audio ducking)
    SoundEffectsController().playEvolution();

    // FAZA 1: Trzęsienie (2 sekundy)
    _shakeController.forward();
    await Future.delayed(const Duration(seconds: 2));

    // FAZA 2: Flash + zmiana grafiki
    setState(() {
      _isShaking = false;
      _showFlash = true;
    });
    _shakeController.stop();
    _flashController.forward();

    await Future.delayed(const Duration(milliseconds: 150));

    setState(() {
      _showNewEgg = true;
    });
    _scaleController.forward();

    await Future.delayed(const Duration(milliseconds: 300));

    // FAZA 3: Konfetti
    setState(() {
      _showFlash = false;
      _showConfetti = true;
    });
    _generateConfetti();
    _confettiController.forward();

    await Future.delayed(const Duration(milliseconds: 500));

    // FAZA 4: Tekst gratulacji
    setState(() {
      _showText = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    // FAZA 5: Przycisk
    setState(() {
      _showButton = true;
    });
  }

  void _generateConfetti() {
    _confettiParticles.clear();
    final colors = [
      AppTheme.primaryColor,
      AppTheme.accentColor,
      AppTheme.yellowColor,
      AppTheme.purpleColor,
      AppTheme.greenColor,
      Colors.pink,
      Colors.orange,
    ];

    for (int i = 0; i < 100; i++) {
      _confettiParticles.add(_ConfettiParticle(
        x: _random.nextDouble(),
        y: -0.1 - _random.nextDouble() * 0.3,
        velocityX: (_random.nextDouble() - 0.5) * 0.3,
        velocityY: 0.5 + _random.nextDouble() * 0.5,
        rotation: _random.nextDouble() * math.pi * 2,
        rotationSpeed: (_random.nextDouble() - 0.5) * 10,
        color: colors[_random.nextInt(colors.length)],
        size: 8 + _random.nextDouble() * 8,
      ));
    }
  }

  void _updateConfetti() {
    if (!mounted) return;
    setState(() {
      for (var particle in _confettiParticles) {
        particle.y += particle.velocityY * 0.02;
        particle.x += particle.velocityX * 0.02;
        particle.rotation += particle.rotationSpeed * 0.02;
        particle.velocityY += 0.01; // Grawitacja
      }
    });
  }

  String _getOldEggAsset() {
    switch (widget.fromStage) {
      case EvolutionStage.egg:
        return 'assets/images/Creature/Egg.webp';
      case EvolutionStage.firstCrack:
        return 'assets/images/Creature/first_crack_idle.webp';
      case EvolutionStage.secondCrack:
        return 'assets/images/Creature/first_crack_idle.webp'; // placeholder
      case EvolutionStage.hatched:
        return 'assets/images/Creature/first_crack_idle.webp'; // placeholder
    }
  }

  String _getNewEggAsset() {
    switch (widget.toStage) {
      case EvolutionStage.egg:
        return 'assets/images/Creature/Egg.webp';
      case EvolutionStage.firstCrack:
        return 'assets/images/Creature/first_crack.webp';
      case EvolutionStage.secondCrack:
        return 'assets/images/Creature/first_crack_idle.webp'; // placeholder
      case EvolutionStage.hatched:
        return 'assets/images/Creature/first_crack_idle.webp'; // placeholder
    }
  }

  String _getCongratulationText() {
    switch (widget.toStage) {
      case EvolutionStage.firstCrack:
        return 'Jajko peklo!';
      case EvolutionStage.secondCrack:
        return 'Drugie pekniecie!';
      case EvolutionStage.hatched:
        return 'Wyklulo sie!';
      default:
        return 'Ewolucja!';
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _flashController.dispose();
    _scaleController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Przyciemnione tło
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              color: Colors.black.withValues(alpha: 0.8),
            ),
          ),

          // Konfetti (za jajkiem)
          if (_showConfetti)
            Positioned.fill(
              child: CustomPaint(
                painter: _ConfettiPainter(_confettiParticles),
              ),
            ),

          // Jajko na środku
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Jajko z animacją
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _shakeAnimation,
                    _scaleAnimation,
                  ]),
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_isShaking ? _shakeAnimation.value : 0, 0),
                      child: Transform.scale(
                        scale: _showNewEgg ? _scaleAnimation.value : 1.0,
                        child: SizedBox(
                          width: 200,
                          height: 200,
                          child: Image.asset(
                            _showNewEgg ? _getNewEggAsset() : _getOldEggAsset(),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // Tekst gratulacji
                AnimatedOpacity(
                  opacity: _showText ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: Column(
                    children: [
                      Text(
                        'GRATULACJE!',
                        style: GoogleFonts.fredoka(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.yellowColor,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              offset: const Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getCongratulationText(),
                        style: GoogleFonts.fredoka(
                          fontSize: 28,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              offset: const Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Przycisk "Super!"
                AnimatedOpacity(
                  opacity: _showButton ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: AnimatedScale(
                    scale: _showButton ? 1.0 : 0.5,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.elasticOut,
                    child: ElevatedButton(
                      onPressed: _showButton ? widget.onComplete : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.greenColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 8,
                      ),
                      child: Text(
                        'Super!',
                        style: GoogleFonts.fredoka(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Flash overlay
          if (_showFlash)
            AnimatedBuilder(
              animation: _flashAnimation,
              builder: (context, child) {
                return Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      color: Colors.white.withValues(
                        alpha: (1.0 - _flashAnimation.value) * 0.9,
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

/// Cząsteczka konfetti
class _ConfettiParticle {
  double x;
  double y;
  double velocityX;
  double velocityY;
  double rotation;
  double rotationSpeed;
  Color color;
  double size;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.velocityX,
    required this.velocityY,
    required this.rotation,
    required this.rotationSpeed,
    required this.color,
    required this.size,
  });
}

/// Malarz konfetti
class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;

  _ConfettiPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      if (particle.y > 1.2) continue; // Poza ekranem

      final paint = Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(
        particle.x * size.width,
        particle.y * size.height,
      );
      canvas.rotate(particle.rotation);

      // Rysuj prostokąt konfetti
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: particle.size,
          height: particle.size * 0.6,
        ),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
