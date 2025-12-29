import 'dart:math';
import 'package:flutter/material.dart';

class CardGameScreen extends StatefulWidget {
  const CardGameScreen({super.key});

  @override
  State<CardGameScreen> createState() => _CardGameScreenState();
}

class _CardGameScreenState extends State<CardGameScreen> {
  // ✅ 카드 뒤집기(짝맞추기)는 짝수 장수 필요 (4x4 = 16장)
  final int rows = 4;
  final int cols = 4;

  final Random _rng = Random();

  // (선택) 기존 블록 에셋 재활용. 부족하면 숫자로 표시됨.
  final List<String> tileAssets = [
    'block1.png',
    'block2.png',
    'block3.png',
    'block4.png',
    'block5.png',
  ];

  late List<List<_CardCell>> tileGrid;

  // 첫 번째 카드 선택 좌표
  Point<int>? selected; // (x=c, y=r)
  bool busy = false;

  int score = 0;
  int moves = 0;
  int lives = 5;
  int matchedPairs = 0;

  int get totalPairs => (rows * cols) ~/ 2;

  static const _bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF061A14), // very dark green (top)
      Color(0xFF0B2D22), // deep green (bottom)
    ],
  );


  @override
  void initState() {
    super.initState();
    _restartGame();
  }

  void _restartGame() {
    score = 0;
    moves = 0;
    lives = 5;
    matchedPairs = 0;
    selected = null;
    busy = false;
    _initGridPairs();
    setState(() {});
  }

  void _initGridPairs() {
    // 0..totalPairs-1 값을 두 장씩 만든 뒤 셔플 → 그리드에 채움
    final values = <int>[];
    for (int i = 0; i < totalPairs; i++) {
      values.add(i);
      values.add(i);
    }
    values.shuffle(_rng);

    int idx = 0;
    tileGrid = List.generate(rows, (r) {
      return List.generate(cols, (c) {
        final v = values[idx++];
        return _CardCell(value: v);
      });
    });
  }

  Future<void> _onTapCell(int r, int c) async {
    if (busy) return;

    final pos = Point<int>(c, r);
    final cell = tileGrid[r][c];

    if (cell.isMatched || cell.isFaceUp) return;

    // 1) 첫 카드
    if (selected == null) {
      setState(() {
        cell.isFaceUp = true;
        selected = pos;
      });
      return;
    }

    // 같은 칸 재탭 무시
    if (selected!.x == pos.x && selected!.y == pos.y) return;

    // 2) 두 번째 카드
    busy = true;

    setState(() {
      cell.isFaceUp = true;
    });

    moves++;

    final first = tileGrid[selected!.y][selected!.x];
    final second = cell;

    await Future.delayed(const Duration(milliseconds: 550));
    if (!mounted) return;

    if (first.value == second.value) {
      setState(() {
        first.isMatched = true;
        second.isMatched = true;
        matchedPairs++;
        score += 100;
      });

      if (matchedPairs == totalPairs) {
        busy = false;
        selected = null;
        await _clearDialog();
        return;
      }
    } else {
      setState(() {
        first.isFaceUp = false;
        second.isFaceUp = false;
        lives -= 1;
        score = max(0, score - 20);
      });

      if (lives <= 0) {
        busy = false;
        selected = null;
        await _gameOverDialog();
        return;
      }
    }

    selected = null;
    busy = false;
    if (mounted) setState(() {});
  }

  Future<void> _clearDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('클리어'),
        content: Text('점수: $score\n이동: $moves'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );

    _restartGame();
  }

  Future<void> _gameOverDialog() async {
    busy = true;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('게임 오버'),
        content: Text('점수: $score\n이동: $moves'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );

    busy = false;
    _restartGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: _bgGradient),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Image.asset(
          'assets/images/cardgame-title.png',
          height: 50,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Text(
            'CARD FLIP',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: _bgGradient),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              _buildTopBar(),
              _buildGameTitle(),
              Expanded(child: _buildPlayArea()),
              _buildBottomControls(),
            ],
          ),
        ),
      ),
    );
  }

  // 상단 바 (점수 + 하트(목숨) + 코인(이동))
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        children: [
          _textBadge('SCORE', '$score'),
          const Spacer(),
          _statusBadge('assets/images/heart_icon.png', '$lives', Colors.pinkAccent),
          const SizedBox(width: 10),
          _statusBadge('assets/images/coin_icon.png', '$moves', Colors.orangeAccent),
        ],
      ),
    );
  }

  Widget _buildGameTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.25),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white24, width: 1.5),
        ),
        child: Row(
          children: [
            const Icon(Icons.style, color: Colors.white70),
            const SizedBox(width: 10),
            const Text(
              'CARD FLIP',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                fontSize: 18,
              ),
            ),
            const Spacer(),
            _resetChip(),
          ],
        ),
      ),
    );
  }

  Widget _resetChip() {
    return InkWell(
      onTap: busy ? null : _restartGame,
      borderRadius: BorderRadius.circular(999),
      child: Opacity(
        opacity: busy ? 0.5 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.20),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white24, width: 1.2),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.refresh, size: 16, color: Colors.white70),
              SizedBox(width: 6),
              Text(
                'RESET',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textBadge(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white70, width: 2),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String assetPath, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white70, width: 2),
      ),
      child: Row(
        children: [
          Image.asset(
            assetPath,
            width: 20,
            height: 20,
            errorBuilder: (c, e, s) => Icon(Icons.circle, color: color, size: 20),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // 게임판(카드 뒤집기)
  Widget _buildPlayArea() {
    return Container(
      padding: const EdgeInsets.all(15),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: rows * cols,
        itemBuilder: (context, index) {
          final r = index ~/ cols;
          final c = index % cols;
          final cell = tileGrid[r][c];

          final isSelected = selected != null && selected!.x == c && selected!.y == r;
          final showBack = cell.isFaceUp || cell.isMatched;

          return GestureDetector(
            onTap: () => _onTapCell(r, c),
            child: _FlipCard(
              showBack: showBack,
              highlight: isSelected,
              front: _CardFront(disabled: busy),
              back: _CardBack(
                value: cell.value,
                isMatched: cell.isMatched,
                tileAssets: tileAssets,
              ),
            ),
          );
        },
      ),
    );
  }

  // 하단 버튼(동작은 아직 없음)
  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _circleIconButton(Icons.volume_up, Colors.orange),
          _circleIconButton(Icons.settings, Colors.blue),
          _circleIconButton(Icons.shopping_cart, Colors.redAccent),
        ],
      ),
    );
  }

  Widget _circleIconButton(IconData icon, Color bgColor) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 5)],
      ),
      child: CircleAvatar(
        radius: 25,
        backgroundColor: bgColor,
        child: Icon(icon, color: Colors.white, size: 30),
      ),
    );
  }
}

// ===================== 내부 모델/위젯 =====================

class _CardCell {
  final int value; // pair id
  bool isFaceUp;
  bool isMatched;

  _CardCell({
    required this.value,
    this.isFaceUp = false,
    this.isMatched = false,
  });
}

// 뒤집기 애니메이션(AnimatedSwitcher + Y축 회전)
class _FlipCard extends StatelessWidget {
  final bool showBack;
  final bool highlight;
  final Widget front;
  final Widget back;

  const _FlipCard({
    required this.showBack,
    required this.highlight,
    required this.front,
    required this.back,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: highlight ? Border.all(color: Colors.yellow, width: 3) : null,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) {
          final rotate = Tween(begin: pi, end: 0.0).animate(animation);
          return AnimatedBuilder(
            animation: rotate,
            child: child,
            builder: (context, child) {
              final isUnder = (child!.key != ValueKey(showBack));
              var angle = rotate.value;
              if (isUnder) angle = min(angle, pi / 2);

              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(angle),
                child: child,
              );
            },
          );
        },
        child: showBack
            ? KeyedSubtree(key: const ValueKey(true), child: back)
            : KeyedSubtree(key: const ValueKey(false), child: front),
      ),
    );
  }
}

class _CardFront extends StatelessWidget {
  final bool disabled;
  const _CardFront({required this.disabled});

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Center(
        child: Icon(
          Icons.help_outline,
          size: 38,
          color: disabled ? Colors.white24 : Colors.white70,
        ),
      ),
    );
  }
}

class _CardBack extends StatelessWidget {
  final int value;
  final bool isMatched;
  final List<String> tileAssets;

  const _CardBack({
    required this.value,
    required this.isMatched,
    required this.tileAssets,
  });

  @override
  Widget build(BuildContext context) {
    final canUseAsset = value >= 0 && value < tileAssets.length;

    return _CardShell(
      dim: isMatched,
      child: Center(
        child: canUseAsset
            ? Image.asset(
          'assets/images/${tileAssets[value]}',
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _fallbackText(),
        )
            : _fallbackText(),
      ),
    );
  }

  Widget _fallbackText() {
    return Text(
      '${value + 1}',
      style: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w900,
        color: isMatched ? Colors.white24 : Colors.white,
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  final Widget child;
  final bool dim;

  const _CardShell({required this.child, this.dim = false});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: dim ? 0.45 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.25),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24, width: 1.4),
          boxShadow: const [
            BoxShadow(color: Colors.black45, blurRadius: 6, offset: Offset(0, 3)),
          ],
        ),
        child: child,
      ),
    );
  }
}
