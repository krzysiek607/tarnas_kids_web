import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';

/// Animowany dialog nagrody wyświetlany po ukończeniu zadania
class RewardDialog extends StatefulWidget {
  final Reward reward;
  final VoidCallback? onClose;

  const RewardDialog({
    super.key,
    required this.reward,
    this.onClose,
  });

  /// Pokazuje dialog nagrody z animacją
  static Future<void> show(BuildContext context, Reward reward, {VoidCallback? onClose}) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return RewardDialog(reward: reward, onClose: onClose);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        // Animacja skalowania + fade
        final scaleAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.elasticOut,
        ));

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
        ));

        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<RewardDialog> createState() => _RewardDialogState();
}

class _RewardDialogState extends State<RewardDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    // Animacja podskakiwania ikony
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _bounceController,
        curve: Curves.elasticOut,
      ),
    );

    // Opóźnij start animacji bounce
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _bounceController.forward();
      }
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _handleClose() {
    Navigator.of(context).pop();
    widget.onClose?.call();
  }

  @override
  Widget build(BuildContext context) {
    // SafeArea + ConstrainedBox zapobiegają błędom przy zmianie rozmiaru okna (Windows)
    return SafeArea(
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: Container(
              margin: const EdgeInsets.all(32),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Konfetti/gwiazdki w tle
              _buildStars(),

              // Napis "BRAWO!"
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.accentColor,
                    AppTheme.yellowColor,
                  ],
                ).createShader(bounds),
                child: const Text(
                  'BRAWO!',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 4,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Zdobywasz nagrodę!',
                style: TextStyle(
                  fontSize: 18,
                  color: AppTheme.textLightColor,
                ),
              ),

              const SizedBox(height: 24),

              // Ikona nagrody z animacją
              AnimatedBuilder(
                animation: _bounceAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 0.8 + (_bounceAnimation.value * 0.2),
                    child: child,
                  );
                },
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppTheme.yellowColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.yellowColor,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.yellowColor.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Image.asset(
                      widget.reward.iconPath,
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback emoji jeśli brak obrazka
                        return Text(
                          _getRewardEmoji(widget.reward.id),
                          style: const TextStyle(fontSize: 64),
                        );
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Nazwa nagrody
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor.withOpacity(0.1),
                      AppTheme.accentColor.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.reward.name,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Przycisk OK
              GestureDetector(
                onTap: _handleClose,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.accentColor,
                        AppTheme.primaryColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Super!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
          ),
        ),
      ),
    );
  }

  /// Gwiazdki/dekoracje
  Widget _buildStars() {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStar(Colors.yellow, 24),
          const SizedBox(width: 8),
          _buildStar(AppTheme.primaryColor, 16),
          const SizedBox(width: 8),
          _buildStar(AppTheme.accentColor, 20),
          const SizedBox(width: 8),
          _buildStar(Colors.yellow, 28),
          const SizedBox(width: 8),
          _buildStar(AppTheme.accentColor, 20),
          const SizedBox(width: 8),
          _buildStar(AppTheme.primaryColor, 16),
          const SizedBox(width: 8),
          _buildStar(Colors.yellow, 24),
        ],
      ),
    );
  }

  Widget _buildStar(Color color, double size) {
    return Icon(
      Icons.star_rounded,
      color: color,
      size: size,
    );
  }

  String _getRewardEmoji(String rewardId) {
    switch (rewardId) {
      case 'cookie':
        return '🍪';
      case 'candy':
        return '🍬';
      case 'icecream':
        return '🍦';
      case 'chocolate':
        return '🍫';
      default:
        return '🎁';
    }
  }
}
