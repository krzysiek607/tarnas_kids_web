import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/kid_friendly_button.dart';
import '../../providers/background_music_provider.dart';
import '../../services/sound_effects_controller.dart';
import '../../services/sound_effects_service.dart';

/// Gra Dopasowywanie - dziecko laczy pary elementow
class MatchingGameScreen extends ConsumerStatefulWidget {
  const MatchingGameScreen({super.key});

  @override
  ConsumerState<MatchingGameScreen> createState() => _MatchingGameScreenState();
}

class _MatchingGameScreenState extends ConsumerState<MatchingGameScreen> {
  int currentLevel = 1;
  int? selectedLeftIndex;
  Map<int, int> matchedPairs = {};
  late List<MatchItem> leftItems;
  late List<MatchItem> rightItems;
  late List<int> shuffledRightIndices;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlayingSound = false;

  final Map<int, LevelData> levelData = {
    1: LevelData(
      title: 'Zwierzę i dźwięk',
      description: 'Połącz zwierzę z dźwiękiem',
      pairs: [
        MatchPair(left: MatchItem('🐶', 'Pies'), right: MatchItem('💬', 'Hau Hau!', soundFile: 'dog.mp3')),
        MatchPair(left: MatchItem('🐱', 'Kot'), right: MatchItem('💬', 'Miau!', soundFile: 'cat.mp3')),
        MatchPair(left: MatchItem('🐄', 'Krowa'), right: MatchItem('💬', 'Muuuu!', soundFile: 'cow.mp3')),
        MatchPair(left: MatchItem('🐷', 'Świnka'), right: MatchItem('💬', 'Chrum!', soundFile: 'pig.mp3')),
        MatchPair(left: MatchItem('🐸', 'Żaba'), right: MatchItem('💬', 'Kum kum!', soundFile: 'frog.mp3')),
        MatchPair(left: MatchItem('🦁', 'Lew'), right: MatchItem('💬', 'Roarrr!', soundFile: 'lion.mp3')),
        MatchPair(left: MatchItem('🐔', 'Kura'), right: MatchItem('💬', 'Ko ko ko!', soundFile: 'chicken.mp3')),
        MatchPair(left: MatchItem('🐑', 'Owca'), right: MatchItem('💬', 'Bee bee!', soundFile: 'sheep.mp3')),
        MatchPair(left: MatchItem('🦆', 'Kaczka'), right: MatchItem('💬', 'Kwa kwa!', soundFile: 'duck.mp3')),
        MatchPair(left: MatchItem('🐴', 'Koń'), right: MatchItem('💬', 'Ihaha!', soundFile: 'horse.mp3')),
      ],
    ),
    2: LevelData(
      title: 'Zwierzę i dom',
      description: 'Gdzie mieszka zwierzę?',
      pairs: [
        MatchPair(left: MatchItem('🐟', 'Ryba'), right: MatchItem('🌊', 'Woda')),
        MatchPair(left: MatchItem('🐦', 'Ptak'), right: MatchItem('☁️', 'Niebo')),
        MatchPair(left: MatchItem('🐪', 'Wielbłąd'), right: MatchItem('🏜️', 'Pustynia')),
        MatchPair(left: MatchItem('🐧', 'Pingwin'), right: MatchItem('🧊', 'Lód')),
        MatchPair(left: MatchItem('🐒', 'Małpa'), right: MatchItem('🌴', 'Dżungla')),
        MatchPair(left: MatchItem('🐻', 'Niedźwiedź'), right: MatchItem('🌲', 'Las')),
        MatchPair(left: MatchItem('🦔', 'Jeż'), right: MatchItem('🍂', 'Liście')),
        MatchPair(left: MatchItem('🐝', 'Pszczoła'), right: MatchItem('🍯', 'Ul')),
        MatchPair(left: MatchItem('🐜', 'Mrówka'), right: MatchItem('🏔️', 'Mrowisko')),
        MatchPair(left: MatchItem('🦈', 'Rekin'), right: MatchItem('🌊', 'Ocean')),
      ],
    ),
    3: LevelData(
      title: 'Zawód i narzędzie',
      description: 'Czego używa w pracy?',
      pairs: [
        MatchPair(left: MatchItem('👨‍🍳', 'Kucharz'), right: MatchItem('🍳', 'Patelnia')),
        MatchPair(left: MatchItem('👨‍🚒', 'Strażak'), right: MatchItem('🚒', 'Wóz strażacki')),
        MatchPair(left: MatchItem('👮', 'Policjant'), right: MatchItem('🚔', 'Radiowóz')),
        MatchPair(left: MatchItem('👨‍⚕️', 'Lekarz'), right: MatchItem('💉', 'Strzykawka')),
        MatchPair(left: MatchItem('👨‍🏫', 'Nauczyciel'), right: MatchItem('📚', 'Książki')),
        MatchPair(left: MatchItem('👨‍🌾', 'Rolnik'), right: MatchItem('🚜', 'Traktor')),
        MatchPair(left: MatchItem('💇', 'Fryzjer'), right: MatchItem('✂️', 'Nożyczki')),
        MatchPair(left: MatchItem('🎨', 'Malarz'), right: MatchItem('🖌️', 'Pędzel')),
        MatchPair(left: MatchItem('👨‍🍞', 'Piekarz'), right: MatchItem('🍞', 'Chleb')),
        MatchPair(left: MatchItem('🚌', 'Kierowca'), right: MatchItem('🛞', 'Kierownica')),
      ],
    ),
  };

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
    _loadLevel(currentLevel);
  }

  Future<void> _initAudioPlayer() async {
    // Konfiguracja AudioPlayer dla efektow dzwiekowych
    // Ustawienie mixWithOthers pozwala na mieszanie z muzyka w tle
    await _audioPlayer.setAudioContext(AudioContext(
      android: AudioContextAndroid(
        isSpeakerphoneOn: false,
        stayAwake: false,
        contentType: AndroidContentType.sonification,
        usageType: AndroidUsageType.game,
        audioFocus: AndroidAudioFocus.none, // Nie zabieraj fokusu
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.ambient,
        options: {
          AVAudioSessionOptions.mixWithOthers,
        },
      ),
    ));

    // Listener na zakonczenie dzwieku
    _audioPlayer.onPlayerComplete.listen((_) {
      _onSoundComplete();
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    // Przywroc glosnosc muzyki przy wyjsciu
    if (_isPlayingSound) {
      ref.read(backgroundMusicProvider.notifier).setVolume(0.5);
    }
    super.dispose();
  }

  Future<void> _playSound(String? soundFile) async {
    if (soundFile != null) {
      // Przycisz muzyke w tle
      _isPlayingSound = true;
      await ref.read(backgroundMusicProvider.notifier).setVolume(0.15);

      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/$soundFile'));
    }
  }

  void _onSoundComplete() {
    // Przywroc glosnosc muzyki po zakonczeniu dzwieku
    if (_isPlayingSound) {
      _isPlayingSound = false;
      ref.read(backgroundMusicProvider.notifier).setVolume(0.5);
    }
  }

  void _loadLevel(int level) {
    final data = levelData[level]!;
    final random = Random();
    final allPairs = List<MatchPair>.from(data.pairs);
    allPairs.shuffle(random);
    final selectedPairs = allPairs.take(3).toList();

    setState(() {
      currentLevel = level;
      leftItems = selectedPairs.map((p) => p.left).toList();
      rightItems = selectedPairs.map((p) => p.right).toList();
      shuffledRightIndices = List.generate(3, (i) => i)..shuffle(random);
      selectedLeftIndex = null;
      matchedPairs = {};
    });
  }

  void _onLeftTap(int index) {
    if (matchedPairs.containsKey(index)) return;
    setState(() {
      selectedLeftIndex = index;
    });
  }

  void _onRightTap(int shuffledIndex) {
    int actualRightIndex = shuffledRightIndices[shuffledIndex];
    if (matchedPairs.containsValue(actualRightIndex)) return;

    // Odtworz dzwiek odglosu przy kliknieciu
    _playSound(rightItems[actualRightIndex].soundFile);

    if (selectedLeftIndex == null) return;
    if (selectedLeftIndex == actualRightIndex) {
      setState(() {
        matchedPairs[selectedLeftIndex!] = actualRightIndex;
        selectedLeftIndex = null;
      });
      SoundEffectsController().playSuccess();
      if (matchedPairs.length == 3) {
        Future.delayed(const Duration(milliseconds: 500), _showWinDialog);
      }
    } else {
      // Dźwięk błędu przy złym dopasowaniu
      SoundEffectsService.instance.playError();
      setState(() {
        selectedLeftIndex = null;
      });
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameResultDialog(
        title: 'Świetnie!',
        emoji: '⭐',
        message: 'Wszystko dopasowane!',
        buttons: [
          if (currentLevel < 3)
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
    final level = levelData[currentLevel]!;
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Dopasuj - Poziom $currentLevel'),
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(level.title, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(level.description, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 24),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(3, (index) {
                          bool isMatched = matchedPairs.containsKey(index);
                          bool isSelected = selectedLeftIndex == index;
                          return _MatchCard(
                            item: leftItems[index],
                            isSelected: isSelected,
                            isMatched: isMatched,
                            onTap: () => _onLeftTap(index),
                            color: AppTheme.primaryColor,
                          );
                        }),
                      ),
                    ),
                    SizedBox(
                      width: 40,
                      child: CustomPaint(
                        painter: _ConnectionPainter(matchedPairs, shuffledRightIndices),
                        size: const Size(40, double.infinity),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(3, (shuffledIndex) {
                          int actualIndex = shuffledRightIndices[shuffledIndex];
                          bool isMatched = matchedPairs.containsValue(actualIndex);
                          return _MatchCard(
                            item: rightItems[actualIndex],
                            isSelected: false,
                            isMatched: isMatched,
                            onTap: () => _onRightTap(shuffledIndex),
                            color: AppTheme.accentColor,
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  final MatchItem item;
  final bool isSelected;
  final bool isMatched;
  final VoidCallback onTap;
  final Color color;

  const _MatchCard({
    required this.item,
    required this.isSelected,
    required this.isMatched,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isMatched ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 100,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isMatched ? AppTheme.greenColor : isSelected ? color.withValues(alpha: 0.3) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : Colors.grey.shade300, width: isSelected ? 3 : 1),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(item.emoji, style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 4),
            Text(item.label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isMatched ? Colors.white : AppTheme.textColor), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _ConnectionPainter extends CustomPainter {
  final Map<int, int> matchedPairs;
  final List<int> shuffledRightIndices;
  _ConnectionPainter(this.matchedPairs, this.shuffledRightIndices);
  @override
  void paint(Canvas canvas, Size size) {}
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class MatchItem {
  final String emoji;
  final String label;
  final String? soundFile;
  MatchItem(this.emoji, this.label, {this.soundFile});
}

class MatchPair {
  final MatchItem left;
  final MatchItem right;
  MatchPair({required this.left, required this.right});
}

class LevelData {
  final String title;
  final String description;
  final List<MatchPair> pairs;
  LevelData({required this.title, required this.description, required this.pairs});
}
