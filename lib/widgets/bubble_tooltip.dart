import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Tooltip w stylu White Card - spójny z motywem Tarnas Kids
/// Białe tło, kolorowa obwódka, gwiazdki, bounce animation
class BubbleTooltip extends StatefulWidget {
  final Widget child;
  final String message;
  final Color color;
  final VoidCallback? onDismiss;

  const BubbleTooltip({
    super.key,
    required this.child,
    required this.message,
    required this.color,
    this.onDismiss,
  });

  @override
  State<BubbleTooltip> createState() => BubbleTooltipState();
}

class BubbleTooltipState extends State<BubbleTooltip>
    with SingleTickerProviderStateMixin {
  static const double _tooltipWidth = 170;
  static const Offset _tooltipOffset = Offset(-37, 100);
  static const Duration _autoDismissDuration = Duration(milliseconds: 900);
  static const Duration _animationDuration = Duration(milliseconds: 500);

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  OverlayEntry? _overlayEntry;
  Timer? _autoDismissTimer;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _overlayEntry?.remove();
    _overlayEntry = null;
    _animationController.dispose();
    super.dispose();
  }

  /// Pokazuje tooltip - wywoływane z zewnątrz
  void showTooltip() {
    if (_overlayEntry != null || !mounted) return;

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    _animationController.forward();

    _autoDismissTimer?.cancel();
    _autoDismissTimer = Timer(_autoDismissDuration, () {
      if (mounted) {
        _hideTooltip();
        widget.onDismiss?.call();
      }
    });
  }

  void _hideTooltip() {
    _autoDismissTimer?.cancel();
    _autoDismissTimer = null;

    final entry = _overlayEntry;
    if (entry == null) return;
    _overlayEntry = null;

    _animationController.reverse().then((_) {
      if (mounted) {
        entry.remove();
      }
    });
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Positioned(
        width: _tooltipWidth,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: _tooltipOffset,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                alignment: Alignment.topCenter,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: child,
                ),
              );
            },
            child: Semantics(
              label: widget.message,
              child: _WhiteCardContent(
                message: widget.message,
                color: widget.color,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: widget.child,
    );
  }
}

/// Zawartość White Card tooltip
class _WhiteCardContent extends StatelessWidget {
  final String message;
  final Color color;

  const _WhiteCardContent({
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Ogonek (trójkąt) wskazujący do góry - biały z kolorową obwódką
        CustomPaint(
          size: const Size(28, 14),
          painter: _WhiteTrianglePainter(borderColor: color),
        ),
        // Biała kartka
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 16,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: color,
              width: 2.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.star_rounded,
                color: AppTheme.yellowColor,
                size: 20,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.star_rounded,
                color: AppTheme.yellowColor,
                size: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Biały trójkąt z kolorową obwódką (ogonek karty)
class _WhiteTrianglePainter extends CustomPainter {
  final Color borderColor;

  _WhiteTrianglePainter({required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    // Biały wypełniony trójkąt
    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, fillPaint);

    // Kolorowa obwódka na bokach trójkąta (nie na dole - łączy się z kartą)
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round;

    final borderPath = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height);

    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _WhiteTrianglePainter oldDelegate) =>
      oldDelegate.borderColor != borderColor;
}
