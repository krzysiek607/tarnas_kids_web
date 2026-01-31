import 'package:flutter/material.dart';
import 'dart:math';
import '../../theme/app_theme.dart';
import '../../services/sound_effects_controller.dart';

class LetterItem {
  final String emoji;
  final String name;
  final String letter;
  const LetterItem(this.emoji, this.name, this.letter);
}

class FindLetterScreen extends StatefulWidget {
  const FindLetterScreen({super.key});
  @override
  State<FindLetterScreen> createState() => _FindLetterScreenState();
}

class _FindLetterScreenState extends State<FindLetterScreen> with TickerProviderStateMixin {
  final Random random = Random();
  late String targetLetter;
  late LetterItem correctItem;
  late List<LetterItem> displayedItems;
  int score = 0;
  int round = 0;
  static const int maxRounds = 10;
  late AnimationController _successController;
  late Animation<double> _successScale;
  late AnimationController _bounceController;
  bool showSuccess = false;
  int? tappedIndex;

  final Map<String, List<LetterItem>> itemsByLetter = {
    'A': [LetterItem('🚗', 'Auto', 'A'), LetterItem('🍉', 'Arbuz', 'A')],
    'B': [LetterItem('🍌', 'Banan', 'B'), LetterItem('🎈', 'Balon', 'B'), LetterItem('🥦', 'Brokul', 'B'), LetterItem('🐞', 'Biedronka', 'B')],
    'C': [LetterItem('🍬', 'Cukierek', 'C'), LetterItem('🧅', 'Cebula', 'C'), LetterItem('🍪', 'Ciastko', 'C'), LetterItem('☁️', 'Chmura', 'C')],
    'D': [LetterItem('🏠', 'Dom', 'D'), LetterItem('🌳', 'Drzewo', 'D'), LetterItem('🚪', 'Drzwi', 'D'), LetterItem('🦖', 'Dinozaur', 'D')],
    'F': [LetterItem('🏳️', 'Flaga', 'F'), LetterItem('🎆', 'Fajerwerki', 'F'), LetterItem('🦩', 'Flaming', 'F')],
    'G': [LetterItem('⭐', 'Gwiazda', 'G'), LetterItem('🎸', 'Gitara', 'G'), LetterItem('🍄', 'Grzyb', 'G'), LetterItem('🍐', 'Gruszka', 'G')],
    'H': [LetterItem('🚁', 'Helikopter', 'H'), LetterItem('🍵', 'Herbata', 'H')],
    'J': [LetterItem('🥚', 'Jajko', 'J'), LetterItem('🍎', 'Jabłko', 'J'), LetterItem('🦎', 'Jaszczurka', 'J')],
    'K': [LetterItem('🐱', 'Kot', 'K'), LetterItem('🔑', 'Klucz', 'K'), LetterItem('📖', 'Książka', 'K'), LetterItem('🦀', 'Krab', 'K'), LetterItem('🌸', 'Kwiat', 'K')],
    'L': [LetterItem('🦁', 'Lew', 'L'), LetterItem('🍃', 'Liść', 'L'), LetterItem('🍭', 'Lizak', 'L'), LetterItem('🦊', 'Lis', 'L')],
    'M': [LetterItem('🐭', 'Mysz', 'M'), LetterItem('🦋', 'Motyl', 'M'), LetterItem('🥕', 'Marchewka', 'M')],
    'N': [LetterItem('🔪', 'Nóż', 'N'), LetterItem('🦏', 'Nosorozec', 'N'), LetterItem('✂️', 'Nożyczki', 'N')],
    'O': [LetterItem('👀', 'Oczy', 'O'), LetterItem('🔥', 'Ogień', 'O'), LetterItem('✏️', 'Ołówek', 'O'), LetterItem('🐙', 'Ośmiornica', 'O')],
    'P': [LetterItem('🐕', 'Pies', 'P'), LetterItem('🐦', 'Ptak', 'P'), LetterItem('🍕', 'Pizza', 'P'), LetterItem('🎁', 'Prezent', 'P')],
    'R': [LetterItem('🐟', 'Ryba', 'R'), LetterItem('🌹', 'Róża', 'R'), LetterItem('🚀', 'Rakieta', 'R'), LetterItem('🤖', 'Robot', 'R')],
    'S': [LetterItem('☀️', 'Słońce', 'S'), LetterItem('🐘', 'Słoń', 'S'), LetterItem('🦉', 'Sowa', 'S'), LetterItem('🧦', 'Skarpeta', 'S')],
    'T': [LetterItem('🐅', 'Tygrys', 'T'), LetterItem('📺', 'Telewizor', 'T'), LetterItem('🚜', 'Traktor', 'T'), LetterItem('🌷', 'Tulipan', 'T')],
    'U': [LetterItem('👂', 'Ucho', 'U'), LetterItem('😊', 'Uśmiech', 'U')],
    'W': [LetterItem('💧', 'Woda', 'W'), LetterItem('🍇', 'Winogrona', 'W'), LetterItem('🐋', 'Wieloryb', 'W'), LetterItem('🐿️', 'Wiewiórka', 'W')],
    'Z': [LetterItem('🦓', 'Zebra', 'Z'), LetterItem('⏰', 'Zegar', 'Z'), LetterItem('🐸', 'Żaba', 'Z'), LetterItem('🦷', 'Ząb', 'Z')],
  };

  late List<String> availableLetters;
  late List<LetterItem> allItems;

  @override
  void initState() {
    super.initState();
    availableLetters = itemsByLetter.entries.where((e) => e.value.isNotEmpty).map((e) => e.key).toList();
    allItems = itemsByLetter.values.expand((list) => list).toList();
    _successController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _successScale = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _successController, curve: Curves.elasticOut));
    _bounceController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _generateRound();
  }

  @override
  void dispose() {
    _successController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _generateRound() {
    targetLetter = availableLetters[random.nextInt(availableLetters.length)];
    final itemsForLetter = itemsByLetter[targetLetter]!;
    correctItem = itemsForLetter[random.nextInt(itemsForLetter.length)];
    int wrongCount = 3 + random.nextInt(2);
    Set<LetterItem> wrongItems = {};
    while (wrongItems.length < wrongCount) {
      final randomItem = allItems[random.nextInt(allItems.length)];
      if (randomItem.letter != targetLetter && !wrongItems.contains(randomItem)) wrongItems.add(randomItem);
    }
    displayedItems = [correctItem, ...wrongItems]..shuffle(random);
    tappedIndex = null;
    showSuccess = false;
  }

  void _onItemTap(int index) {
    if (showSuccess) return;
    setState(() { tappedIndex = index; });
    if (displayedItems[index] == correctItem) {
      setState(() { score++; showSuccess = true; });
      _successController.forward(from: 0);
      SoundEffectsController().playSuccess();
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          if (round < maxRounds - 1) setState(() { round++; _generateRound(); });
          else _showCompletionDialog();
        }
      });
    } else {
      _bounceController.forward(from: 0).then((_) { if (mounted) setState(() { tappedIndex = null; }); });
    }
  }

  void _showCompletionDialog() {
    showDialog(context: context, barrierDismissible: false, builder: (ctx) => _CompletionDialog(score: score, maxScore: maxRounds,
      onPlayAgain: () { Navigator.pop(ctx); setState(() { score = 0; round = 0; _generateRound(); }); },
      onExit: () { Navigator.pop(ctx); Navigator.pop(context); }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: const Text('Znajdź literkę'), leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context))),
      body: SafeArea(child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
        _ProgressIndicator(current: round + 1, total: maxRounds),
        const SizedBox(height: 20),
        Container(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: AppTheme.cardShadow),
          child: Column(children: [Text('Co zaczyna się na', style: TextStyle(fontSize: 18, color: AppTheme.textLightColor)), const SizedBox(height: 8), Text(targetLetter, style: TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: AppTheme.primaryColor))])),
        const SizedBox(height: 32),
        Expanded(child: Center(child: Wrap(spacing: 16, runSpacing: 16, alignment: WrapAlignment.center, children: List.generate(displayedItems.length, (i) => _ItemButton(item: displayedItems[i], isCorrect: displayedItems[i] == correctItem, isTapped: tappedIndex == i, showSuccess: showSuccess && displayedItems[i] == correctItem, onTap: () => _onItemTap(i), successAnimation: _successScale))))),
        if (showSuccess) AnimatedBuilder(animation: _successScale, builder: (ctx, _) => Transform.scale(scale: _successScale.value, child: Column(children: [const Text('⭐ Świetnie! ⭐', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.amber)), const SizedBox(height: 4), Text('${correctItem.name} zaczyna się na $targetLetter', style: TextStyle(fontSize: 16, color: AppTheme.textLightColor))]))),
        const SizedBox(height: 20),
      ]))));
  }
}

class _ProgressIndicator extends StatelessWidget {
  final int current, total;
  const _ProgressIndicator({required this.current, required this.total});
  @override
  Widget build(BuildContext context) => Row(children: List.generate(total, (i) => Expanded(child: Container(height: 8, margin: const EdgeInsets.symmetric(horizontal: 2), decoration: BoxDecoration(color: i < current - 1 ? AppTheme.greenColor : i == current - 1 ? AppTheme.primaryColor : Colors.grey.shade300, borderRadius: BorderRadius.circular(4))))));
}

class _ItemButton extends StatelessWidget {
  final LetterItem item;
  final bool isCorrect, isTapped, showSuccess;
  final VoidCallback onTap;
  final Animation<double> successAnimation;
  const _ItemButton({required this.item, required this.isCorrect, required this.isTapped, required this.showSuccess, required this.onTap, required this.successAnimation});

  @override
  Widget build(BuildContext context) {
    Color bg = Colors.white, border = Colors.grey.shade300;
    double scale = 1.0;
    if (showSuccess && isCorrect) { bg = AppTheme.greenColor; border = AppTheme.greenColor; scale = 1.1; }
    else if (isTapped && !isCorrect) scale = 0.95;
    return GestureDetector(onTap: showSuccess ? null : onTap, child: AnimatedContainer(duration: const Duration(milliseconds: 200), transform: Matrix4.identity()..scale(scale), transformAlignment: Alignment.center, width: 100, height: 100,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20), border: Border.all(color: border, width: 3), boxShadow: [BoxShadow(color: (showSuccess && isCorrect) ? AppTheme.greenColor.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 4))]),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(item.emoji, style: const TextStyle(fontSize: 40)), const SizedBox(height: 2), Text(item.name, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: (showSuccess && isCorrect) ? Colors.white : AppTheme.textColor), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis)])));
  }
}

class _CompletionDialog extends StatelessWidget {
  final int score, maxScore;
  final VoidCallback onPlayAgain, onExit;
  const _CompletionDialog({required this.score, required this.maxScore, required this.onPlayAgain, required this.onExit});

  @override
  Widget build(BuildContext context) => Dialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)), child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Text('🌟', style: TextStyle(fontSize: 64)), const SizedBox(height: 16),
    Text('Wspaniale!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textColor)), const SizedBox(height: 8),
    Text('Znalazłeś $score z $maxScore przedmiotów!', style: TextStyle(fontSize: 18, color: AppTheme.textLightColor)), const SizedBox(height: 24),
    Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_DialogButton(emoji: '🔄', label: 'Jeszcze raz', color: AppTheme.primaryColor, onTap: onPlayAgain), _DialogButton(emoji: '🏠', label: 'Koniec', color: AppTheme.accentColor, onTap: onExit)])])));
}

class _DialogButton extends StatelessWidget {
  final String emoji, label;
  final Color color;
  final VoidCallback onTap;
  const _DialogButton({required this.emoji, required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)), child: Column(children: [Text(emoji, style: const TextStyle(fontSize: 28)), const SizedBox(height: 4), Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white))])));
}
