import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/tracing_canvas.dart';
import '../../widgets/reward_dialog.dart';
import '../../services/database_service.dart';

/// Uniwersalny ekran gry rysowania po sladzie
class TracingGameScreen extends StatefulWidget {
  final String title;
  final String emoji;
  final List<TracingPattern> patterns;
  final Color drawColor;
  final String? successMessage;
  final bool useHandwritingFont; // Czy uzywac czcionki recznej
  final String rewardType; // Typ nagrody dla bazy danych (np. 'letters', 'patterns')
  final bool enableRewards; // Czy wlaczone nagrody

  const TracingGameScreen({
    super.key,
    required this.title,
    required this.emoji,
    required this.patterns,
    this.drawColor = const Color(0xFF42A5F5),
    this.successMessage,
    this.useHandwritingFont = false,
    this.rewardType = 'tracing',
    this.enableRewards = true,
  });

  @override
  State<TracingGameScreen> createState() => _TracingGameScreenState();
}

class _TracingGameScreenState extends State<TracingGameScreen> {
  int _currentIndex = 0;
  final GlobalKey<TracingCanvasState> _canvasKey = GlobalKey();

  TracingPattern get _currentPattern => widget.patterns[_currentIndex];
  bool get _isFirst => _currentIndex == 0;
  bool get _isLast => _currentIndex == widget.patterns.length - 1;

  void _previousPattern() {
    if (!_isFirst) {
      setState(() {
        _currentIndex--;
      });
      _canvasKey.currentState?.clear();
    }
  }

  void _nextPattern() async {
    final canvasState = _canvasKey.currentState;

    // Sprawdz czy uzytkownik narysował cokolwiek
    if (canvasState == null || !canvasState.hasDrawing) {
      debugPrint('✏️ TRACING: Brak rysunku!');
      _showTryAgainMessage('Najpierw narysuj wzór!');
      return;
    }

    // Oblicz wynik rysunku
    final score = canvasState.calculateScore();

    // DEBUG: Pokaż szczegóły wyniku w konsoli
    debugPrint('✏️ TRACING: ═══════════════════════════════════');
    debugPrint('✏️ TRACING: Wzór: ${_currentPattern.name}');
    debugPrint('✏️ TRACING: $score');
    debugPrint('✏️ TRACING: Nagroda? ${score.isGoodEnough ? "TAK ✅" : "NIE ❌"}');
    debugPrint('✏️ TRACING: ═══════════════════════════════════');

    if (!_isLast) {
      // Sprawdz czy wynik jest wystarczajaco dobry
      if (widget.enableRewards && score.isGoodEnough) {
        debugPrint('✏️ TRACING: Przyznawanie nagrody...');
        await _grantReward();
      } else if (widget.enableRewards) {
        // Nie przyznaj nagrody, ale pozwól przejść dalej
        debugPrint('✏️ TRACING: Za słaby wynik - brak nagrody');
        _showTryAgainMessage(
          'Spróbuj dokładniej! 🎯\n'
          'Dokładność: ${score.accuracy.toInt()}%, Pokrycie: ${score.coverage.toInt()}%',
        );
      }

      setState(() {
        _currentIndex++;
      });
      canvasState.clear();
    } else {
      // Ostatni wzór
      if (widget.enableRewards && score.isGoodEnough) {
        debugPrint('✏️ TRACING: Ostatni wzór - przyznawanie nagrody...');
        await _grantReward(isLast: true);
      } else {
        if (widget.enableRewards) {
          debugPrint('✏️ TRACING: Ostatni wzór - za słaby wynik');
          _showTryAgainMessage(
            'Spróbuj dokładniej! 🎯\n'
            'Dokładność: ${score.accuracy.toInt()}%, Pokrycie: ${score.coverage.toInt()}%',
          );
        }
        // Po ostatnim wzorze - wróć do menu
        if (mounted) {
          Navigator.pop(context);
        }
      }
    }
  }

  /// Pokazuje komunikat zachęcający do ponownej próby
  void _showTryAgainMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Text('💪', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Przyznaje nagrodę i pokazuje popup
  Future<void> _grantReward({bool isLast = false}) async {
    try {
      Reward reward;

      // Jeśli baza jest dostępna, zapisz nagrodę
      if (DatabaseService.isInitialized) {
        reward = await DatabaseService.instance.addReward(widget.rewardType);
      } else {
        // Jeśli brak bazy - tylko wylosuj lokalnie
        final random = DateTime.now().millisecondsSinceEpoch % 4;
        reward = availableRewards[random];
      }

      // Pokaż popup nagrody
      if (mounted) {
        await RewardDialog.show(
          context,
          reward,
          onClose: () {
            if (isLast && mounted) {
              // Po ostatnim wzorze - wróć do menu
              Navigator.pop(context);
            }
          },
        );
      }
    } catch (e) {
      print('Błąd przyznawania nagrody: $e');
      // W razie błędu - kontynuuj bez nagrody
      if (isLast && mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _clearCanvas() {
    _canvasKey.currentState?.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Licznik
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_currentIndex + 1}/${widget.patterns.length}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Naglowek z emoji i nazwa wzoru
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.emoji,
                    style: const TextStyle(fontSize: 36),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _currentPattern.name,
                        style: widget.useHandwritingFont
                            ? GoogleFonts.caveat(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textColor,
                              )
                            : Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textColor,
                                ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Podpowiedz jesli istnieje
            if (_currentPattern.hint != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _currentPattern.hint!,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textLightColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            const SizedBox(height: 12),

            // Canvas do rysowania
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: TracingCanvas(
                    key: _canvasKey,
                    pattern: _currentPattern,
                    drawColor: widget.drawColor,
                    drawWidth: 14.0,
                    traceWidth: 10.0,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Przyciski nawigacji
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Poprzedni
                  _NavButton(
                    icon: Icons.arrow_back_rounded,
                    label: 'Wstecz',
                    onTap: _isFirst ? null : _previousPattern,
                    color: AppTheme.primaryColor,
                  ),

                  // Wyczysc
                  _NavButton(
                    icon: Icons.delete_outline_rounded,
                    label: 'Wyczysc',
                    onTap: _clearCanvas,
                    color: Colors.orange,
                  ),

                  // Nastepny
                  _NavButton(
                    icon: Icons.arrow_forward_rounded,
                    label: 'Dalej',
                    onTap: _isLast ? null : _nextPattern,
                    color: AppTheme.accentColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

/// Przycisk nawigacji
class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color color;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isDisabled ? 0.4 : 1.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isDisabled ? Colors.grey.shade300 : color,
                shape: BoxShape.circle,
                boxShadow: isDisabled
                    ? null
                    : [
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDisabled ? Colors.grey : AppTheme.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
