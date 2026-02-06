import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Duży, kolorowy przycisk zaprojektowany specjalnie dla dzieci 4-8 lat
///
/// Cechy:
/// - Duży rozmiar (łatwy do kliknięcia małymi paluszkami)
/// - Animacja wciskania (scale 0.92)
/// - Gradient kolorowy
/// - Ikona z emoji lub IconData
/// - Opcjonalny dźwięk kliknięcia (przygotowane do implementacji)
///
/// Użycie:
/// ```dart
/// BigButton(
///   label: 'Rysowanie',
///   icon: '🎨',
///   gradient: AppTheme.primaryGradient,
///   onTap: () => Navigator.push(...),
/// )
/// ```
class BigButton extends StatefulWidget {
  /// Tekst wyświetlany na przycisku
  final String label;

  /// Ikona - może być emoji (String) lub ikona Flutter (IconData)
  final dynamic icon;

  /// Gradient koloru przycisku
  final LinearGradient gradient;

  /// Callback wywoływany po kliknięciu
  final VoidCallback onTap;

  /// Czy przycisk jest nieaktywny (opcjonalne)
  final bool isDisabled;

  const BigButton({
    super.key,
    required this.label,
    required this.icon,
    required this.gradient,
    required this.onTap,
    this.isDisabled = false,
  });

  @override
  State<BigButton> createState() => _BigButtonState();
}

class _BigButtonState extends State<BigButton>
    with SingleTickerProviderStateMixin {
  /// Controller do animacji scale
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  /// Czy przycisk jest aktualnie wciśnięty
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    // Konfiguracja animacji wciskania
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 100), // Szybka, responsywna animacja
    );

    // Tween animacji - normalny rozmiar (1.0) do lekko zmniejszonego (0.92)
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.92,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Obsługa rozpoczęcia wciskania przycisku
  void _handleTapDown(TapDownDetails details) {
    if (!widget.isDisabled) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }

  /// Obsługa zakończenia wciskania przycisku
  void _handleTapUp(TapUpDetails details) {
    if (!widget.isDisabled) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  /// Obsługa anulowania wciskania (np. palec zjechał z przycisku)
  void _handleTapCancel() {
    if (!widget.isDisabled) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  /// Obsługa kliknięcia
  void _handleTap() {
    if (!widget.isDisabled) {
      widget.onTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: double.infinity, // Pełna szerokość dostępna
          constraints: BoxConstraints(
            minHeight: 100, // Minimum 100px wysokości (duży dla dzieci)
            maxWidth: 400, // Maksymalna szerokość dla większych ekranów
          ),
          decoration: BoxDecoration(
            // Gradient koloru
            gradient: widget.isDisabled
                ? LinearGradient(
                    colors: [Colors.grey.shade300, Colors.grey.shade400],
                  )
                : widget.gradient,

            // Zaokrąglone rogi
            borderRadius: BorderRadius.circular(AppTheme.buttonBorderRadius),

            // Cień - większy gdy wciśnięty
            boxShadow: _isPressed
                ? AppTheme.buttonShadowPressed
                : AppTheme.cardShadow,
          ),
          padding: EdgeInsets.symmetric(vertical: 24, horizontal: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ikona - emoji lub IconData
              _buildIcon(),

              SizedBox(width: AppTheme.spacingMedium),

              // Label
              Flexible(
                child: Text(
                  widget.label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontSize: 26,
                        color: widget.isDisabled
                            ? Colors.grey.shade600
                            : Colors.white,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Buduje widget ikony w zależności od typu (emoji lub IconData)
  Widget _buildIcon() {
    if (widget.icon is String) {
      // Emoji jako String
      return Text(
        widget.icon,
        style: TextStyle(fontSize: 48),
      );
    } else if (widget.icon is IconData) {
      // Flutter IconData
      return Icon(
        widget.icon,
        size: AppTheme.iconSizeLarge,
        color: widget.isDisabled ? Colors.grey.shade600 : Colors.white,
      );
    } else {
      // Fallback - pusta ikona
      return SizedBox(width: AppTheme.iconSizeLarge);
    }
  }
}
