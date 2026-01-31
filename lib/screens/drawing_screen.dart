import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';
import '../theme/app_theme.dart';
import '../providers/drawing_provider.dart';
import '../widgets/drawing_painter.dart';
import '../widgets/kid_friendly_button.dart';

/// Ekran rysowania dla dzieci
class DrawingScreen extends ConsumerStatefulWidget {
  const DrawingScreen({super.key});

  @override
  ConsumerState<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends ConsumerState<DrawingScreen> {
  final GlobalKey _canvasKey = GlobalKey();
  bool _isSaving = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Poczekaj na pierwszą klatkę, potem załaduj zasoby
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAsync();
    });
  }

  /// Asynchroniczna inicjalizacja - nie blokuje UI
  Future<void> _initializeAsync() async {
    // Precache wszystkich obrazków narzędzi
    final futures = availableTools.map((tool) {
      return precacheImage(AssetImage(tool.iconPath), context);
    }).toList();

    // Czekaj na załadowanie wszystkich obrazków
    await Future.wait(futures);

    // Oznacz jako zainicjalizowane
    if (mounted) {
      setState(() => _isInitialized = true);
    }
  }

  /// Skeleton UI wyświetlany podczas ładowania zasobów
  Widget _buildLoadingSkeleton() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        toolbarHeight: 64,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
        ),
      ),
      body: Column(
        children: [
          // Skeleton dla canvas
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade200, width: 2),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryColor,
                  strokeWidth: 3,
                ),
              ),
            ),
          ),
          // Skeleton dla panelu narzędzi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Skeleton dla narzędzi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )),
                  ),
                  const SizedBox(height: 10),
                  // Skeleton dla kolorów
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(8, (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                    )),
                  ),
                  const SizedBox(height: 10),
                  // Skeleton dla slidera
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Pokaż loading skeleton podczas inicjalizacji
    if (!_isInitialized) {
      return _buildLoadingSkeleton();
    }
    final drawingState = ref.watch(drawingProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        toolbarHeight: 64,
        leading: _buildAppBarButton(
          icon: Icons.arrow_back_rounded,
          color: AppTheme.textColor,
          onTap: () => Navigator.pop(context),
        ),
        actions: [
          // 1. Udostępnij
          _buildAppBarButton(
            icon: Icons.share_rounded,
            color: drawingState.lines.isEmpty
                ? Colors.grey.shade300
                : AppTheme.accentColor,
            isLoading: _isSaving,
            onTap: drawingState.lines.isEmpty || _isSaving
                ? null
                : () => _shareDrawing(),
          ),
          // 2. Zapisz
          _buildAppBarButton(
            icon: Icons.save_alt_rounded,
            color: drawingState.lines.isEmpty
                ? Colors.grey.shade300
                : AppTheme.greenColor,
            isLoading: _isSaving,
            onTap: drawingState.lines.isEmpty || _isSaving
                ? null
                : () => _saveToGallery(),
          ),
          // 3. Cofnij
          _buildAppBarButton(
            icon: Icons.undo_rounded,
            color: drawingState.lines.isEmpty
                ? Colors.grey.shade300
                : AppTheme.textColor,
            onTap: drawingState.lines.isEmpty
                ? null
                : () => ref.read(drawingProvider.notifier).undo(),
          ),
          // 4. Dalej
          _buildAppBarButton(
            icon: Icons.redo_rounded,
            color: drawingState.undoHistory.isEmpty
                ? Colors.grey.shade300
                : AppTheme.textColor,
            onTap: drawingState.undoHistory.isEmpty
                ? null
                : () => ref.read(drawingProvider.notifier).redo(),
          ),
          // 5. Wyczyść
          _buildAppBarButton(
            icon: Icons.delete_outline_rounded,
            color: drawingState.lines.isEmpty
                ? Colors.grey.shade300
                : AppTheme.primaryColor,
            onTap: drawingState.lines.isEmpty
                ? null
                : () => _showClearDialog(context, ref),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: RepaintBoundary(
                  key: _canvasKey,
                  child: _OptimizedDrawingCanvas(
                    drawingState: drawingState,
                    onPanStart: (details) {
                      ref.read(drawingProvider.notifier)
                          .startLine(details.localPosition);
                    },
                    onPanUpdate: (details) {
                      ref.read(drawingProvider.notifier)
                          .addPoint(details.localPosition);
                    },
                    onPanEnd: () {
                      ref.read(drawingProvider.notifier).endLine();
                    },
                    onClear: () {
                      // Callback gdy canvas jest czyszczony
                    },
                  ),
                ),
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildToolSelector(context, ref, drawingState),
                  const SizedBox(height: 10),
                  _buildColorPalette(context, ref, drawingState),
                  const SizedBox(height: 10),
                  _buildStrokeWidthSlider(context, ref, drawingState),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Przechwytuje rysunek jako obraz
  Future<Uint8List?> _captureDrawing() async {
    try {
      final boundary = _canvasKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }

  /// Udostepnia rysunek
  Future<void> _shareDrawing() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      final bytes = await _captureDrawing();
      if (bytes == null) {
        _showErrorSnackBar('Nie udalo sie przechwycic rysunku');
        return;
      }

      // BULLETPROOF: Sprawdź mounted po await
      if (!mounted) return;

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/moj_rysunek_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);

      // BULLETPROOF: Sprawdź mounted po await
      if (!mounted) return;

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Moj rysunek z Tarnas Kids!',
      );
    } catch (e) {
      _showErrorSnackBar('Blad podczas udostepniania');
    } finally {
      // BULLETPROOF: Sprawdź mounted w finally
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// Zapisuje rysunek do galerii
  Future<void> _saveToGallery() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      // Sprawdz uprawnienia
      final hasAccess = await Gal.hasAccess(toAlbum: true);
      if (!hasAccess) {
        final granted = await Gal.requestAccess(toAlbum: true);
        if (!granted) {
          _showErrorSnackBar('Brak uprawnien do zapisania');
          // BULLETPROOF: Sprawdź mounted po await
          if (mounted) setState(() => _isSaving = false);
          return;
        }
      }

      // BULLETPROOF: Sprawdź mounted po await
      if (!mounted) return;

      final bytes = await _captureDrawing();
      if (bytes == null) {
        _showErrorSnackBar('Nie udalo sie przechwycic rysunku');
        // BULLETPROOF: Sprawdź mounted po await
        if (mounted) setState(() => _isSaving = false);
        return;
      }

      // BULLETPROOF: Sprawdź mounted po await
      if (!mounted) return;

      // Zapisz do pliku tymczasowego
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/tarnas_kids_rysunek_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      // BULLETPROOF: Sprawdź mounted po await
      if (!mounted) return;

      // Zapisz do galerii
      await Gal.putImage(filePath, album: 'Tarnas Kids');

      _showSuccessSnackBar('Rysunek zapisany w galerii!');
    } catch (e) {
      _showErrorSnackBar('Blad podczas zapisywania');
    } finally {
      // BULLETPROOF: Sprawdź mounted w finally
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: AppTheme.greenColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildToolSelector(
    BuildContext context,
    WidgetRef ref,
    DrawingState state,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: availableTools.map((toolInfo) {
        final isSelected = state.selectedTool == toolInfo.tool;
        return GestureDetector(
          onTap: () => ref.read(drawingProvider.notifier).setTool(toolInfo.tool),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isSelected ? 68 : 60,
                  height: isSelected ? 68 : 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : Colors.grey.shade300,
                      width: isSelected ? 4 : 2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.4),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      toolInfo.iconPath,
                      width: 68,
                      height: 68,
                      fit: BoxFit.cover,
                      cacheWidth: 136, // 2x dla retina
                      cacheHeight: 136,
                      filterQuality: FilterQuality.medium,
                      gaplessPlayback: true, // Zapobiega migotaniu
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.brush,
                            color: Colors.grey,
                            size: 28,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  toolInfo.name,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? AppTheme.primaryColor : AppTheme.textColor,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildColorPalette(
    BuildContext context,
    WidgetRef ref,
    DrawingState state,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: availableColors.map((color) {
          final isSelected = state.selectedColor == color;
          return GestureDetector(
            onTap: () => ref.read(drawingProvider.notifier).setColor(color),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isSelected ? 40 : 32,
              height: isSelected ? 40 : 32,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : (color == Colors.white ? Colors.grey.shade300 : Colors.transparent),
                  width: isSelected ? 3 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: color == Colors.white && isSelected
                  ? const Icon(Icons.check, color: Colors.grey, size: 18)
                  : null,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStrokeWidthSlider(
    BuildContext context,
    WidgetRef ref,
    DrawingState state,
  ) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: state.selectedColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: state.selectedColor == Colors.white
                    ? Colors.grey
                    : state.selectedColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: state.selectedColor == Colors.white
                      ? Colors.grey.shade400
                      : Colors.white,
                  width: 1,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Slider(
            value: state.strokeWidth,
            min: 2,
            max: 30,
            divisions: 14,
            activeColor: AppTheme.primaryColor,
            inactiveColor: Colors.grey.shade300,
            onChanged: (value) {
              ref.read(drawingProvider.notifier).setStrokeWidth(value);
            },
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Center(
            child: Container(
              width: state.strokeWidth.clamp(6, 30),
              height: state.strokeWidth.clamp(6, 30),
              decoration: BoxDecoration(
                color: state.selectedColor,
                shape: BoxShape.circle,
                border: state.selectedColor == Colors.white
                    ? Border.all(color: Colors.grey.shade400)
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Buduje przycisk w AppBar z ikoną 48x48
  Widget _buildAppBarButton({
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color,
                  ),
                )
              : Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
        ),
      ),
    );
  }

  void _showClearDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => KidFriendlyConfirmDialog(
        title: 'Wyczyść rysunek?',
        emoji: '🗑️',
        message: 'Czy na pewno chcesz wymazać cały rysunek?',
        confirmLabel: 'Tak',
        cancelLabel: 'Nie',
        onConfirm: () {
          ref.read(drawingProvider.notifier).clear();
          Navigator.pop(context);
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }
}

/// OPTYMALIZACJA: Canvas z backing image dla wydajności
/// Wypala linie do bitmapy przy onPanEnd lub przekroczeniu limitu punktów
class _OptimizedDrawingCanvas extends StatefulWidget {
  final DrawingState drawingState;
  final void Function(DragStartDetails) onPanStart;
  final void Function(DragUpdateDetails) onPanUpdate;
  final VoidCallback onPanEnd;
  final VoidCallback onClear;

  const _OptimizedDrawingCanvas({
    required this.drawingState,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
    required this.onClear,
  });

  @override
  State<_OptimizedDrawingCanvas> createState() => _OptimizedDrawingCanvasState();
}

class _OptimizedDrawingCanvasState extends State<_OptimizedDrawingCanvas> {
  ui.Image? _backingImage;
  int _bakedLinesCount = 0;
  Size _canvasSize = Size.zero;
  Timer? _sprayBakeTimer;

  // Limit punktów w aktualnej linii przed wymuszeniem bake'a
  static const int _maxPointsBeforeBake = 500;

  @override
  void didUpdateWidget(_OptimizedDrawingCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Wykryj wyczyszczenie canvas
    if (widget.drawingState.lines.isEmpty && _bakedLinesCount > 0) {
      _clearBackingImage();
    }

    // Wykryj undo - jeśli linii jest mniej niż wypalone, przebuduj
    if (widget.drawingState.lines.length < _bakedLinesCount) {
      _rebuildBackingImage();
    }

    // OPTYMALIZACJA SPRAY: Sprawdź czy aktualna linia ma za dużo punktów
    final currentLine = widget.drawingState.currentLine;
    if (currentLine != null && currentLine.points.length > _maxPointsBeforeBake) {
      // Wymuś bake aktualnej linii (dla sprayu)
      _scheduleSprayBake();
    }
  }

  /// Planuje bake dla sprayu (debounced)
  void _scheduleSprayBake() {
    _sprayBakeTimer?.cancel();
    _sprayBakeTimer = Timer(const Duration(milliseconds: 100), () {
      if (mounted && widget.drawingState.currentLine != null) {
        // Wymuś zakończenie linii i bake
        widget.onPanEnd();
      }
    });
  }

  @override
  void dispose() {
    _sprayBakeTimer?.cancel();
    _backingImage?.dispose();
    super.dispose();
  }

  /// Czyści backing image
  void _clearBackingImage() {
    _backingImage?.dispose();
    setState(() {
      _backingImage = null;
      _bakedLinesCount = 0;
    });
  }

  /// Przebudowuje backing image po undo
  Future<void> _rebuildBackingImage() async {
    _backingImage?.dispose();
    _backingImage = null;
    _bakedLinesCount = 0;

    // Wypiekaj wszystkie istniejące linie
    if (widget.drawingState.lines.isNotEmpty) {
      await _bakeLinesToImage(widget.drawingState.lines.length);
    } else {
      setState(() {});
    }
  }

  /// Wypala linie do backing image
  Future<void> _bakeLinesToImage(int upToIndex) async {
    if (_canvasSize == Size.zero) return;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Narysuj poprzedni backing image
    if (_backingImage != null) {
      canvas.drawImage(_backingImage!, Offset.zero, Paint());
    }

    // Narysuj nowe linie (od _bakedLinesCount do upToIndex)
    final painter = DrawingPainter(
      lines: widget.drawingState.lines.sublist(_bakedLinesCount, upToIndex),
      currentLine: null,
      backingImage: null,
      bakedLinesCount: 0,
    );
    painter.paint(canvas, _canvasSize);

    // Stwórz nowy obraz
    final picture = recorder.endRecording();
    final newImage = await picture.toImage(
      _canvasSize.width.toInt(),
      _canvasSize.height.toInt(),
    );

    // Zwolnij stary obraz
    _backingImage?.dispose();

    if (mounted) {
      setState(() {
        _backingImage = newImage;
        _bakedLinesCount = upToIndex;
      });
    }
  }

  /// Obsługuje zakończenie rysowania - wypala nowe linie
  void _handlePanEnd() {
    widget.onPanEnd();

    // Po zakończeniu linii - wypiekaj wszystkie niewypieczone linie
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.drawingState.lines.length > _bakedLinesCount) {
        _bakeLinesToImage(widget.drawingState.lines.length);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _canvasSize = Size(constraints.maxWidth, constraints.maxHeight);

        return Container(
          color: Colors.white,
          child: GestureDetector(
            onPanStart: widget.onPanStart,
            onPanUpdate: widget.onPanUpdate,
            onPanEnd: (_) => _handlePanEnd(),
            child: CustomPaint(
              painter: DrawingPainter(
                lines: widget.drawingState.lines,
                currentLine: widget.drawingState.currentLine,
                backingImage: _backingImage,
                bakedLinesCount: _bakedLinesCount,
              ),
              size: Size.infinite,
            ),
          ),
        );
      },
    );
  }
}
