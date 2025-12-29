import 'dart:math';
import 'package:flutter/material.dart';

class Match3GameScreen extends StatefulWidget {
  const Match3GameScreen({super.key});

  @override
  State<Match3GameScreen> createState() => _Match3GameScreenState();
}

class _Match3GameScreenState extends State<Match3GameScreen> {
  // 7행 5열
  final int rows = 7;
  final int cols = 5;

  final Random _rng = Random();

  // 삭제(null) 처리를 위해 int? 사용
  late List<List<int?>> tileGrid;

  // 타일 종류(에셋 파일명)
  final List<String> tileAssets = [
    'block1.png',
    'block2.png',
    'block3.png',
    'block4.png',
    'block5.png',
    'block6.png', // 있으면 사용. 없으면 제거하고 5종으로 맞춰라.
  ];

  // 선택 상태
  Point<int>? selected; // (x=c, y=r)
  bool busy = false;

  int score = 0;

  @override
  void initState() {
    super.initState();
    _restartGame();
  }

  void _restartGame() {
    score = 0;
    selected = null;
    _initGridNoMatches();
    setState(() {});
  }

  int _randomType() => _rng.nextInt(tileAssets.length);

  void _initGridNoMatches() {
    // 시작 시 매치 없는 보드
    while (true) {
      tileGrid = List.generate(
        rows,
            (_) => List<int?>.generate(cols, (_) => _randomType()),
      );
      if (_findMatches().isEmpty) break;
    }
  }

  List<Point<int>> _findMatches() {
    final marked = <String>{};

    // 가로
    for (int r = 0; r < rows; r++) {
      int run = 1;
      for (int c = 1; c <= cols; c++) {
        final curr = (c < cols) ? tileGrid[r][c] : null;
        final prev = tileGrid[r][c - 1];
        if (c < cols && curr != null && prev != null && curr == prev) {
          run++;
        } else {
          if (run >= 3) {
            for (int k = c - run; k < c; k++) {
              marked.add('$r,$k');
            }
          }
          run = 1;
        }
      }
    }

    // 세로
    for (int c = 0; c < cols; c++) {
      int run = 1;
      for (int r = 1; r <= rows; r++) {
        final curr = (r < rows) ? tileGrid[r][c] : null;
        final prev = tileGrid[r - 1][c];
        if (r < rows && curr != null && prev != null && curr == prev) {
          run++;
        } else {
          if (run >= 3) {
            for (int k = r - run; k < r; k++) {
              marked.add('$k,$c');
            }
          }
          run = 1;
        }
      }
    }

    return marked.map((s) {
      final parts = s.split(',');
      final r = int.parse(parts[0]);
      final c = int.parse(parts[1]);
      return Point<int>(c, r);
    }).toList();
  }

  void _swap(Point<int> a, Point<int> b) {
    final t = tileGrid[a.y][a.x];
    tileGrid[a.y][a.x] = tileGrid[b.y][b.x];
    tileGrid[b.y][b.x] = t;
  }

  int _removeMatchesOnce() {
    final matches = _findMatches();
    if (matches.isEmpty) return 0;

    // 제거
    for (final p in matches) {
      tileGrid[p.y][p.x] = null;
    }

    // 낙하 + 리필
    for (int c = 0; c < cols; c++) {
      int write = rows - 1;

      for (int r = rows - 1; r >= 0; r--) {
        final v = tileGrid[r][c];
        if (v != null) {
          tileGrid[write][c] = v;
          write--;
        }
      }

      for (int r = write; r >= 0; r--) {
        tileGrid[r][c] = _randomType();
      }
    }

    score += matches.length * 10;
    return matches.length;
  }

  Future<void> _resolveChains() async {
    while (true) {
      final removed = _removeMatchesOnce();
      if (removed == 0) break;
      if (!mounted) return;
      setState(() {});
      await Future.delayed(const Duration(milliseconds: 150));
    }
  }

  Future<void> _gameOver() async {
    busy = true;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('게임 오버'),
        content: Text('점수: $score'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          )
        ],
      ),
    );

    busy = false;
    _restartGame();
  }

  Future<void> _onTapCell(int r, int c) async {
    if (busy) return;

    final cell = Point<int>(c, r);

    if (selected == null) {
      setState(() => selected = cell);
      return;
    }

    // 같은 칸 -> 선택 해제
    if (selected!.x == cell.x && selected!.y == cell.y) {
      setState(() => selected = null);
      return;
    }

    // 인접 아니면 선택 이동
    final dist = (selected!.x - cell.x).abs() + (selected!.y - cell.y).abs();
    if (dist != 1) {
      setState(() => selected = cell);
      return;
    }

    // 인접이면 스왑
    busy = true;
    _swap(selected!, cell);
    setState(() {});

    // 스왑 후 매치 없으면 -> 되돌리고 즉시 게임오버
    if (_findMatches().isEmpty) {
      await Future.delayed(const Duration(milliseconds: 120));
      _swap(selected!, cell);
      selected = null;
      if (mounted) setState(() {});
      busy = false;
      await _gameOver();
      return;
    }

    // 매치 있으면 연쇄 처리
    await _resolveChains();
    selected = null;
    busy = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2E004E), Color(0xFF8E24AA)],
          ),
        ),
        child: SafeArea(
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

  // 상단 바 (하트/코인 + 점수)
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          _textBadge('SCORE', '$score'),
          const Spacer(),
          _statusBadge('assets/images/heart_icon.png', '5', Colors.pinkAccent),
          const SizedBox(width: 10),
          _statusBadge('assets/images/coin_icon.png', '100', Colors.orangeAccent),
        ],
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
          Text(label, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w800)),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
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
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // 타이틀
  Widget _buildGameTitle() {
    return const Column(
      children: [
        Text(
          "BNK",
          style: TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2),
        ),
        Text(
          "MATCH",
          style: TextStyle(fontSize: 48, color: Colors.yellowAccent, fontWeight: FontWeight.w900, height: 0.8),
        ),
      ],
    );
  }

  // 게임판
  Widget _buildPlayArea() {
    return Container(
      padding: const EdgeInsets.all(15),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
        ),
        itemCount: rows * cols,
        itemBuilder: (context, index) {
          final r = index ~/ cols;
          final c = index % cols;
          final t = tileGrid[r][c];

          final isSelected = selected != null && selected!.x == c && selected!.y == r;

          return GestureDetector(
            onTap: () => _onTapCell(r, c),
            child: Container(
              decoration: BoxDecoration(
                color: (r + c) % 2 == 0
                    ? Colors.green.withOpacity(0.8)
                    : Colors.purple.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
                border: isSelected ? Border.all(color: Colors.yellow, width: 3) : null,
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: (t == null)
                    ? const SizedBox.shrink()
                    : Image.asset(
                  'assets/images/${tileAssets[t]}',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Text("$t", style: const TextStyle(color: Colors.white30)),
                  ),
                ),
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
