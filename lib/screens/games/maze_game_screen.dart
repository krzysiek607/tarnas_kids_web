import 'package:flutter/material.dart';
import 'dart:math';
import '../../theme/app_theme.dart';
import '../../widgets/kid_friendly_button.dart';
import '../../services/sound_effects_controller.dart';

/// Gra Labirynt - dziecko prowadzi postac od startu do mety (cukierka)
class MazeGameScreen extends StatefulWidget {
  const MazeGameScreen({super.key});

  @override
  State<MazeGameScreen> createState() => _MazeGameScreenState();
}

class _MazeGameScreenState extends State<MazeGameScreen>
    with SingleTickerProviderStateMixin {
  static const int maxLevel = 10;
  late int gridSize;
  late List<List<int>> maze;
  late Offset playerPosition;
  late Offset goalPosition;
  bool gameWon = false;
  bool gameStarted = false;
  int currentLevel = 1;
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    _loadLevel(currentLevel);
  }

  int _getGridSizeForLevel(int level) {
    if (level <= 2) return 5;
    if (level <= 5) return 7;
    if (level <= 8) return 9;
    return 11;
  }

  void _loadLevel(int level) {
    setState(() {
      currentLevel = level;
      gridSize = _getGridSizeForLevel(level);
      maze = _generateMaze(gridSize, level);
      playerPosition = const Offset(0, 0);
      goalPosition = Offset(gridSize - 1, gridSize - 1);
      gameWon = false;
      gameStarted = true;
    });
  }

  List<List<int>> _generateMaze(int size, int level) {
    List<List<int>> grid = List.generate(size, (_) => List.filled(size, 1));

    List<Point<int>> stack = [];
    Point<int> start = const Point(0, 0);
    grid[0][0] = 0;
    stack.add(start);

    while (stack.isNotEmpty) {
      Point<int> current = stack.last;
      List<Point<int>> neighbors = _getUnvisitedNeighbors(current, grid, size);

      if (neighbors.isEmpty) {
        stack.removeLast();
      } else {
        Point<int> next = neighbors[random.nextInt(neighbors.length)];

        int wallX = current.x + (next.x - current.x) ~/ 2;
        int wallY = current.y + (next.y - current.y) ~/ 2;
        grid[wallY][wallX] = 0;
        grid[next.y][next.x] = 0;

        stack.add(next);
      }
    }

    grid[size - 1][size - 1] = 0;
    _removeWalls(grid, size, level);
    _ensurePath(grid, size);

    return grid;
  }

  List<Point<int>> _getUnvisitedNeighbors(Point<int> cell, List<List<int>> grid, int size) {
    List<Point<int>> neighbors = [];
    List<Point<int>> directions = [
      const Point(0, -2),
      const Point(0, 2),
      const Point(-2, 0),
      const Point(2, 0),
    ];

    for (var dir in directions) {
      int newX = cell.x + dir.x;
      int newY = cell.y + dir.y;

      if (newX >= 0 && newX < size && newY >= 0 && newY < size) {
        if (grid[newY][newX] == 1) {
          neighbors.add(Point(newX, newY));
        }
      }
    }

    return neighbors;
  }

  void _removeWalls(List<List<int>> grid, int size, int level) {
    int wallsToRemove = (10 - level) * (size ~/ 2);

    for (int i = 0; i < wallsToRemove; i++) {
      int x = random.nextInt(size);
      int y = random.nextInt(size);

      if (x > 0 && x < size - 1 && y > 0 && y < size - 1) {
        grid[y][x] = 0;
      }
    }
  }

  void _ensurePath(List<List<int>> grid, int size) {
    List<List<bool>> visited = List.generate(size, (_) => List.filled(size, false));
    List<Point<int>> queue = [const Point(0, 0)];
    visited[0][0] = true;

    while (queue.isNotEmpty) {
      Point<int> current = queue.removeAt(0);

      if (current.x == size - 1 && current.y == size - 1) {
        return;
      }

      List<Point<int>> dirs = [
        const Point(0, -1),
        const Point(0, 1),
        const Point(-1, 0),
        const Point(1, 0),
      ];

      for (var dir in dirs) {
        int newX = current.x + dir.x;
        int newY = current.y + dir.y;

        if (newX >= 0 && newX < size && newY >= 0 && newY < size &&
            !visited[newY][newX] && grid[newY][newX] == 0) {
          visited[newY][newX] = true;
          queue.add(Point(newX, newY));
        }
      }
    }

    for (int i = 0; i < size; i++) {
      grid[0][i] = 0;
    }
    for (int i = 0; i < size; i++) {
      grid[i][size - 1] = 0;
    }
  }

  void _movePlayer(int dx, int dy) {
    if (gameWon) return;

    int newX = (playerPosition.dx + dx).toInt();
    int newY = (playerPosition.dy + dy).toInt();

    if (newX >= 0 && newX < gridSize && newY >= 0 && newY < gridSize) {
      if (maze[newY][newX] == 0) {
        setState(() {
          playerPosition = Offset(newX.toDouble(), newY.toDouble());
        });

        if (playerPosition == goalPosition) {
          setState(() {
            gameWon = true;
          });
          SoundEffectsController().playSuccess();
          _showWinDialog();
        }
      }
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameResultDialog(
        title: 'Brawo!',
        emoji: '🍬',
        message: 'Zdobyłeś cukierka!',
        buttons: [
          if (currentLevel < maxLevel)
            KidFriendlyButton.nextLevel(
              label: 'Dalej',
              onPressed: () {
                Navigator.pop(context);
                _loadLevel(currentLevel + 1);
              },
            ),
          KidFriendlyButton.playAgain(
            label: 'Od początku',
            onPressed: () {
              Navigator.pop(context);
              _loadLevel(1);
            },
          ),
          KidFriendlyButton.exit(
            label: 'Koniec',
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Labirynt - Poziom $currentLevel'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => _loadLevel(currentLevel),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Poprowadz postac do cukierka!',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final cellSize = constraints.maxWidth / gridSize;
                          final emojiSize = cellSize * 0.85; // 85% rozmiaru komórki

                          return Stack(
                            children: [
                              // Tło labiryntu (ściany)
                              GridView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: gridSize,
                                ),
                                itemCount: gridSize * gridSize,
                                itemBuilder: (context, index) {
                                  int x = index % gridSize;
                                  int y = index ~/ gridSize;
                                  bool isWall = maze[y][x] == 1;

                                  return Container(
                                    decoration: BoxDecoration(
                                      color: isWall
                                          ? AppTheme.purpleColor
                                          : Colors.white,
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                        width: 0.5,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              // Cukierek (cel) - statyczny
                              Positioned(
                                left: goalPosition.dx * cellSize,
                                top: goalPosition.dy * cellSize,
                                width: cellSize,
                                height: cellSize,
                                child: Center(
                                  child: Text(
                                    '🍬',
                                    style: TextStyle(fontSize: emojiSize),
                                  ),
                                ),
                              ),
                              // Postać gracza - animowana
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 150),
                                curve: Curves.easeOut,
                                left: playerPosition.dx * cellSize,
                                top: playerPosition.dy * cellSize,
                                width: cellSize,
                                height: cellSize,
                                child: Center(
                                  child: Text(
                                    '🧒',
                                    style: TextStyle(fontSize: emojiSize),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _ControlButton(
                    icon: Icons.arrow_upward_rounded,
                    onPressed: () => _movePlayer(0, -1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ControlButton(
                        icon: Icons.arrow_back_rounded,
                        onPressed: () => _movePlayer(-1, 0),
                      ),
                      const SizedBox(width: 60),
                      _ControlButton(
                        icon: Icons.arrow_forward_rounded,
                        onPressed: () => _movePlayer(1, 0),
                      ),
                    ],
                  ),
                  _ControlButton(
                    icon: Icons.arrow_downward_rounded,
                    onPressed: () => _movePlayer(0, 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ControlButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 70,
        height: 70,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }
}
