import 'dart:math';
import 'package:flutter/material.dart';

/// Mobile UX/UI goals
/// - Grid stays square, centered, never overflows on small screens
/// - Top HUD compact + readable
/// - Bottom controls moved into a single dock (SafeArea aware)
/// - Uses 30 card images under: assets/images/game/card/card_01.png ~ card_30.png
/// - Each round: randomly pick totalPairs images, then duplicate/shuffle to fill grid
class CardGameScreen extends StatefulWidget {
  const CardGameScreen({super.key});

  @override
  State<CardGameScreen> createState() => _CardGameScreenState();
}

class _CardGameScreenState extends State<CardGameScreen> {
  // ✅ 4x4 default. (필요하면 난이도별로 바꿔도 됨)
  final int rows = 4;
  final int cols = 4;

  final Random _rng = Random();

  late List<List<_CardCell>> tileGrid;

  // ✅ 30장 전체 풀 (파일명 규칙 기반)
  late final List<String> allCardAssets;

  // ✅ 이번 판에 사용할 카드(페어) 목록: 길이 = totalPairs
  late List<String> pairAssets;

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
      Color(0xFF061A14),
      Color(0xFF0B2D22),
    ],
  );

  @override
  void initState() {
    super.initState();

    // assets/images/game/card/card_01.png ~ card_30.png
    allCardAssets = List.generate(30, (i) {
      final n = (i + 1).toString().padLeft(2, '0');
      return 'assets/images/game/card/card_$n.png';
    });

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
    if (allCardAssets.length < totalPairs) {
      throw Exception('Not enough card assets: ${allCardAssets.length} < $totalPairs');
    }

    // 1) 30장 중 이번 판에 사용할 totalPairs장 랜덤 선택
    final pool = List<String>.from(allCardAssets)..shuffle(_rng);
    pairAssets = pool.take(totalPairs).toList();

    // 2) pair id(0..totalPairs-1) 두 장씩 생성 후 셔플하여 그리드 채움
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
      moves++;
    });

    final first = tileGrid[selected!.y][selected!.x];
    final second = cell;

    await Future.delayed(const Duration(milliseconds: 520));
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'CARD FLIP',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: _bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 6),
              _buildHud(),
              const SizedBox(height: 10),

              // ✅ 모바일에서 오버플로우 안 나게: grid를 "정사각형"으로 강제 + 가운데 배치
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final maxW = constraints.maxWidth;
                    final maxH = constraints.maxHeight;

                    // 하단 도크(버튼) 공간 고려: 여기서는 Expanded 내부라 이미 제외되지만,
                    // 혹시 작은 화면이면 그리드 상하 패딩도 포함해서 안전하게 계산
                    final pad = 16.0;
                    final size = min(maxW, maxH) - pad * 2;
                    final gridSize = max(0.0, size);

                    return Center(
                      child: SizedBox(
                        width: gridSize,
                        height: gridSize,
                        child: _buildPlayArea(),
                      ),
                    );
                  },
                ),
              ),

              // ✅ 모바일 하단 도크: SafeArea bottom + 터치 타겟 크게
              _buildBottomDock(),
            ],
          ),
        ),
      ),
    );
  }

  /// 상단 HUD: 한 줄에 들어가게 압축, 글자/패딩 모바일 기준
  Widget _buildHud() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          _pillStat(label: 'SCORE', value: '$score'),
          const SizedBox(width: 10),
          _pillStat(label: 'MOVES', value: '$moves'),
          const Spacer(),
          _lifePill(lives: lives),
          const SizedBox(width: 10),
          _resetPill(),
        ],
      ),
    );
  }

  Widget _pillStat({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white24, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w800, fontSize: 12),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _lifePill({required int lives}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white24, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.favorite, color: Colors.pinkAccent, size: 16),
          const SizedBox(width: 6),
          Text(
            '$lives',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _resetPill() {
    return InkWell(
      onTap: busy ? null : _restartGame,
      borderRadius: BorderRadius.circular(999),
      child: Opacity(
        opacity: busy ? 0.5 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
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
                style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w900, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ 정사각 영역 안에서 그리드만 렌더링 (스크롤 제거)
  Widget _buildPlayArea() {
    final spacing = 8.0;

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
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
              pairAssets: pairAssets,
            ),
          ),
        );
      },
    );
  }

  /// ✅ 하단 도크: 버튼 3개, SafeArea 포함
  Widget _buildBottomDock() {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.25),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white24, width: 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _dockIconButton(
              icon: Icons.volume_up,
              onTap: () {},
            ),
            _dockIconButton(
              icon: Icons.settings,
              onTap: () {},
            ),
            _dockIconButton(
              icon: Icons.shopping_cart,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _dockIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 54,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.28),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white24, width: 1.1),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
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
          size: 34,
          color: disabled ? Colors.white24 : Colors.white70,
        ),
      ),
    );
  }
}

class _CardBack extends StatelessWidget {
  final int value;
  final bool isMatched;
  final List<String> pairAssets;

  const _CardBack({
    required this.value,
    required this.isMatched,
    required this.pairAssets,
  });

  @override
  Widget build(BuildContext context) {
    final path = pairAssets[value];

    return _CardShell(
      dim: isMatched,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Image.asset(
          path,
          fit: BoxFit.contain,
          // ✅ 숫자 fallback 제거. (에셋 문제면 그냥 비워두고 빨리 발견하게)
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
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
