import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/tracing_canvas.dart';

/// Uniwersalny ekran gry rysowania po sladzie
class TracingGameScreen extends StatefulWidget {
  final String title;
  final String emoji;
  final List<TracingPattern> patterns;
  final Color drawColor;
  final String? successMessage;
  final bool useHandwritingFont; // Czy uzywac czcionki recznej

  const TracingGameScreen({
    super.key,
    required this.title,
    required this.emoji,
    required this.patterns,
    this.drawColor = const Color(0xFF42A5F5),
    this.successMessage,
    this.useHandwritingFont = false,
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

  void _nextPattern() {
    if (!_isLast) {
      setState(() {
        _currentIndex++;
      });
      _canvasKey.currentState?.clear();
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
