import 'dart:math';
import 'package:flutter/foundation.dart';
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
  late int _currentIndex;
  final GlobalKey<TracingCanvasState> _canvasKey = GlobalKey();
  final Random _random = Random();
  int _completedCount = 0; // Licznik ukończonych wzorów
  bool _rewardGrantedForCurrentPattern = false; // Flaga czy nagroda już przyznana

  @override
  void initState() {
    super.initState();
    // LOSOWANIE POZIOMÓW: Zacznij od losowego wzoru
    _currentIndex = _random.nextInt(widget.patterns.length);
    if (kDebugMode) {
      debugPrint('[TRACING] Losowy start od wzoru $_currentIndex/${widget.patterns.length}');
    }
  }

  TracingPattern get _currentPattern => widget.patterns[_currentIndex];

  /// Losuje nowy indeks różny od obecnego
  int _getNextRandomIndex() {
    if (widget.patterns.length <= 1) return 0;

    int newIndex = _currentIndex;
    // Upewnij się, że nowy indeks jest różny od poprzedniego
    while (newIndex == _currentIndex) {
      newIndex = _random.nextInt(widget.patterns.length);
    }
    return newIndex;
  }

  /// Pomiń wzór - czyści canvas i losuje nowy wzór
  void _previousPattern() {
    // WAŻNE: Wyczyść canvas PRZED zmianą wzoru
    _canvasKey.currentState?.clear();

    setState(() {
      _currentIndex = _getNextRandomIndex();
      _rewardGrantedForCurrentPattern = false; // Reset flagi przy zmianie wzoru
    });
    if (kDebugMode) {
      debugPrint('[TRACING] Pominięto - nowy wzór: $_currentIndex');
    }
  }

  /// Wywoływane przez TracingCanvas gdy wszystkie waypointy zaliczone
  /// Przyznaje nagrodę NATYCHMIAST (razem z dźwiękiem sukcesu)
  void _onPatternCompleted() {
    if (!widget.enableRewards) return;
    if (_rewardGrantedForCurrentPattern) return; // Już przyznano

    if (kDebugMode) {
      debugPrint('[TRACING] onComplete - przyznawanie nagrody natychmiast!');
    }
    _rewardGrantedForCurrentPattern = true;
    _grantReward();
  }

  /// INFINITE RANDOM LOOP: Zawsze losuje nowy wzór
  void _nextPattern() async {
    final canvasState = _canvasKey.currentState;

    // Sprawdz czy uzytkownik narysował cokolwiek
    if (canvasState == null || !canvasState.hasDrawing) {
      if (kDebugMode) {
        debugPrint('[TRACING] Brak rysunku!');
      }
      _showTryAgainMessage('Najpierw narysuj wzór!');
      return;
    }

    // Oblicz wynik rysunku
    final score = canvasState.calculateScore();

    // DEBUG: Pokaż szczegóły wyniku w konsoli
    if (kDebugMode) {
      debugPrint('[TRACING] Wzór: ${_currentPattern.name} | $score | Nagroda: ${_rewardGrantedForCurrentPattern ? "TAK" : "NIE"}');
    }

    // Nagroda jest przyznawana przez onComplete (gdy success.mp3 się odtwarza)
    // Tutaj tylko sprawdzamy czy wynik był wystarczający
    if (!_rewardGrantedForCurrentPattern && widget.enableRewards && !score.isGoodEnough) {
      // Za słaby wynik - pokaż komunikat
      if (kDebugMode) {
        debugPrint('[TRACING] Za słaby wynik - brak nagrody');
      }
      _showTryAgainMessage(
        'Spróbuj dokładniej! 🎯\n'
        'Dokładność: ${score.accuracy.toInt()}%, Pokrycie: ${score.coverage.toInt()}%',
      );
    }

    // BULLETPROOF: Sprawdź mounted po await
    if (!mounted) return;

    // INFINITE RANDOM LOOP: Losuj nowy wzór (różny od obecnego)
    setState(() {
      _currentIndex = _getNextRandomIndex();
      _completedCount++;
      _rewardGrantedForCurrentPattern = false; // Reset flagi dla nowego wzoru
    });
    canvasState.clear();

    if (kDebugMode) {
      debugPrint('[TRACING] Następny losowy wzór: $_currentIndex (ukończono: $_completedCount)');
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
  Future<void> _grantReward() async {
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
        await RewardDialog.show(context, reward);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[TRACING] Błąd przyznawania nagrody: $e');
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
          // Licznik ukończonych wzorów
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(
                    '$_completedCount',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
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
                            ? GoogleFonts.nunito(
                                fontSize: 56,
                                fontWeight: FontWeight.w800,
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
                    onComplete: _onPatternCompleted, // Nagroda natychmiast!
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Przyciski nawigacji - INFINITE LOOP (zawsze aktywne)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Pomiń (losuje inny wzór bez sprawdzania rysunku)
                  _NavButton(
                    icon: Icons.skip_next_rounded,
                    label: 'Pomiń',
                    onTap: _previousPattern,
                    color: AppTheme.primaryColor,
                  ),

                  // Wyczysc
                  _NavButton(
                    icon: Icons.delete_outline_rounded,
                    label: 'Wyczyść',
                    onTap: _clearCanvas,
                    color: Colors.orange,
                  ),

                  // Dalej (sprawdza rysunek i przyznaje nagrodę)
                  _NavButton(
                    icon: Icons.arrow_forward_rounded,
                    label: 'Dalej',
                    onTap: _nextPattern,
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
