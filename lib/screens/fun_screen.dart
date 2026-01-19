import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../providers/drawing_provider.dart';

/// Ekran zabawy dla dzieci - menu wyboru gier
/// Uklad lukowy z tlem
class FunScreen extends StatefulWidget {
  const FunScreen({super.key});

  @override
  State<FunScreen> createState() => _FunScreenState();
}

class _FunScreenState extends State<FunScreen> {
  @override
  void initState() {
    super.initState();
    // Precache obrazków narzędzi rysowania w tle
    // Dzięki temu DrawingScreen załaduje się szybciej
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _precacheDrawingAssets();
    });
  }

  /// Ładuje obrazki narzędzi rysowania do cache w tle
  Future<void> _precacheDrawingAssets() async {
    for (final tool in availableTools) {
      if (mounted) {
        precacheImage(AssetImage(tool.iconPath), context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Tlo
          SizedBox.expand(
            child: Image.asset(
              'assets/images/fun_background.png',
              fit: BoxFit.cover,
            ),
          ),

          // Przycisk powrotu
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: _BackButton(onTap: () => Navigator.pop(context)),
          ),

          // Menu w ksztalcie luku - 4 przyciski
          Positioned(
            left: 0,
            right: 0,
            top: MediaQuery.of(context).padding.top + 190,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Przycisk 1 (skrajny lewy) - nizej
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: _ArchMenuButton(
                    iconPath: 'assets/images/icons/zabawa_rysowanie.png',
                    tooltip: 'Rysowanie',
                    color: AppTheme.primaryColor,
                    onTap: () => context.push('/drawing'),
                  ),
                ),
                // Przycisk 2 (srodkowy lewy) - wyzej
                _ArchMenuButton(
                  iconPath: 'assets/images/icons/zabawa_labirynt.png',
                  tooltip: 'Labirynt',
                  color: AppTheme.accentColor,
                  onTap: () => context.push('/fun/maze'),
                ),
                // Przycisk 3 (srodkowy prawy) - wyzej
                _ArchMenuButton(
                  iconPath: 'assets/images/icons/zabawa_dopasuj.png',
                  tooltip: 'Dopasuj',
                  color: AppTheme.yellowColor,
                  onTap: () => context.push('/fun/matching'),
                ),
                // Przycisk 4 (skrajny prawy) - nizej
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: _ArchMenuButton(
                    iconPath: 'assets/images/icons/zabawa_kropki.png',
                    tooltip: 'Połącz kropki',
                    color: AppTheme.purpleColor,
                    onTap: () => context.push('/fun/dots'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Przycisk powrotu
class _BackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.arrow_back_rounded,
          color: AppTheme.textColor,
          size: 24,
        ),
      ),
    );
  }
}

/// Przycisk menu w ksztalcie luku - ikona z obrazka z Tooltip na tap
class _ArchMenuButton extends StatefulWidget {
  final String iconPath;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;

  const _ArchMenuButton({
    required this.iconPath,
    required this.tooltip,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ArchMenuButton> createState() => _ArchMenuButtonState();
}

class _ArchMenuButtonState extends State<_ArchMenuButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  final GlobalKey _tooltipKey = GlobalKey();
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (_isNavigating) return;
    _isNavigating = true;

    // Pokaz tooltip
    final dynamic tooltip = _tooltipKey.currentState;
    tooltip?.ensureTooltipVisible();

    // Po 500ms wykonaj nawigację
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _isNavigating = false;
        widget.onTap();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      key: _tooltipKey,
      message: widget.tooltip,
      preferBelow: true,
      triggerMode: TooltipTriggerMode.manual,
      showDuration: const Duration(milliseconds: 500),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          _handleTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: Opacity(
            opacity: 0.9,
            child: Container(
              width: 95,
              height: 95,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.5),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(
                  color: Colors.white,
                  width: 4,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  widget.iconPath,
                  width: 95,
                  height: 95,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback jesli obrazek nie istnieje
                    return Center(
                      child: Text(
                        '?',
                        style: TextStyle(
                          fontSize: 40,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
