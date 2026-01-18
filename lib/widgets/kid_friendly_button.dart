import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Przycisk przyjazny dzieciom - z duzym obrazkiem/ikona i tekstem
/// Dzieci ktore nie umieja czytac moga rozpoznac akcje po obrazku
class KidFriendlyButton extends StatelessWidget {
  final String label;
  final String emoji;
  final IconData? icon;
  final Color color;
  final VoidCallback onPressed;
  final bool isLarge;

  const KidFriendlyButton({
    super.key,
    required this.label,
    this.emoji = '',
    this.icon,
    required this.color,
    required this.onPressed,
    this.isLarge = false,
  });

  /// Przycisk "Zagraj ponownie" / "Od poczatku"
  factory KidFriendlyButton.playAgain({
    required VoidCallback onPressed,
    String label = 'Jeszcze raz',
  }) {
    return KidFriendlyButton(
      label: label,
      emoji: '🔄',
      color: AppTheme.greenColor,
      onPressed: onPressed,
    );
  }

  /// Przycisk "Nastepny poziom"
  factory KidFriendlyButton.nextLevel({
    required VoidCallback onPressed,
    String label = 'Dalej',
  }) {
    return KidFriendlyButton(
      label: label,
      emoji: '➡️',
      color: AppTheme.accentColor,
      onPressed: onPressed,
    );
  }

  /// Przycisk "Koniec" / "Wyjdz"
  factory KidFriendlyButton.exit({
    required VoidCallback onPressed,
    String label = 'Koniec',
  }) {
    return KidFriendlyButton(
      label: label,
      emoji: '🏠',
      color: AppTheme.primaryColor,
      onPressed: onPressed,
    );
  }

  /// Przycisk "Tak" / potwierdzenie
  factory KidFriendlyButton.confirm({
    required VoidCallback onPressed,
    String label = 'Tak',
    Color? color,
  }) {
    return KidFriendlyButton(
      label: label,
      emoji: '✅',
      color: color ?? AppTheme.greenColor,
      onPressed: onPressed,
    );
  }

  /// Przycisk "Nie" / anuluj
  factory KidFriendlyButton.cancel({
    required VoidCallback onPressed,
    String label = 'Nie',
  }) {
    return KidFriendlyButton(
      label: label,
      emoji: '❌',
      color: Colors.grey,
      onPressed: onPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isLarge ? 24 : 16,
          vertical: isLarge ? 16 : 12,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (emoji.isNotEmpty)
              Text(
                emoji,
                style: TextStyle(fontSize: isLarge ? 32 : 24),
              )
            else if (icon != null)
              Icon(
                icon,
                color: Colors.white,
                size: isLarge ? 32 : 24,
              ),
            SizedBox(width: isLarge ? 12 : 8),
            Text(
              label,
              style: TextStyle(
                fontSize: isLarge ? 22 : 18,
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

/// Dialog wyniku gry - przyjazny dzieciom z duzymi przyciskami obrazkowymi
class GameResultDialog extends StatelessWidget {
  final String title;
  final String emoji;
  final String message;
  final List<Widget> buttons;

  const GameResultDialog({
    super.key,
    required this.title,
    required this.emoji,
    required this.message,
    required this.buttons,
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
            // Duze emoji
            Text(
              emoji,
              style: const TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 16),
            // Tytul
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Wiadomosc
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                color: AppTheme.textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Przyciski w kolumnie - latwe do klikniecia
            ...buttons.map((button) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SizedBox(
                width: double.infinity,
                child: button,
              ),
            )),
          ],
        ),
      ),
    );
  }
}

/// Dialog potwierdzenia - przyjazny dzieciom
class KidFriendlyConfirmDialog extends StatelessWidget {
  final String title;
  final String emoji;
  final String message;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final String confirmLabel;
  final String cancelLabel;

  const KidFriendlyConfirmDialog({
    super.key,
    required this.title,
    this.emoji = '🤔',
    required this.message,
    required this.onConfirm,
    required this.onCancel,
    this.confirmLabel = 'Tak',
    this.cancelLabel = 'Nie',
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
            Text(
              emoji,
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: KidFriendlyButton.cancel(
                    label: cancelLabel,
                    onPressed: onCancel,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: KidFriendlyButton.confirm(
                    label: confirmLabel,
                    onPressed: onConfirm,
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
