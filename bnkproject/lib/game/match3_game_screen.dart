import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Match3GameScreen extends StatefulWidget {
  const Match3GameScreen({super.key});

  @override
  State<Match3GameScreen> createState() => _Match3GameScreenState();
}

class _Match3GameScreenState extends State<Match3GameScreen> {
  static const int rows = 8;
  static const int cols = 8;
  static const int types = 5;

  final Random _rng = Random();

  // late 터짐 방지: 기본 그리드로 초기화해둠 (initState에서 바로 랜덤 보드로 교체)
  List<List<int?>> grid =
  List.generate(rows, (_) => List<int?>.filled(cols, 0));

  List<ui.Image?> images = List<ui.Image?>.filled(types, null);
  bool imagesReady = false;
  String statusText = '로딩중…';

  Point<int>? selected; // (c, r)
  bool busy = false;
  int score = 0;

  @override
  void initState() {
    super.initState();

    // 1) 보드는 먼저 만들어서 첫 build에서 크래시 방지
    _restartGame();

    // 2) 이미지는 비동기로 로드 (로드 완료되면 setState)
    _loadImages().then((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _loadImages() async {
    bool anyFail = false;

    for (int i = 0; i < types; i++) {
      final path = 'assets/image/block${i + 1}.png';
      try {
        final ByteData data = await rootBundle.load(path);
        final Uint8List bytes = data.buffer.asUint8List();
        final ui.Codec codec = await ui.instantiateImageCodec(bytes);
        final ui.FrameInfo frame = await codec.getNextFrame();
        images[i] = frame.image;
      } catch (_) {
        anyFail = true;
        images[i] = null;
      }
    }

    imagesReady = true;
    statusText = anyFail ? '일부 이미지 실패(색 블럭 대체)' : '준비완료';
  }

  void _restartGame() {
    score = 0;
    selected = null;
    _initGridNoMatches();
  }

  int _randomBlock() => _rng.nextInt(types);

  bool _inBounds(int r, int c) => r >= 0 && r < rows && c >= 0 && c < cols;

  void _initGridNoMatches() {
    // 매치 없는 상태로 스타트
    while (true) {
      grid = List.generate(
        rows,
            (_) => List<int?>.generate(cols, (_) => _randomBlock()),
      );
      if (_findMatches().isEmpty) break;
    }
  }

  List<Point<int>> _findMatches() {
    final Set<String> marked = <String>{};

    // 가로
    for (int r = 0; r < rows; r++) {
      int run = 1;
      for (int c = 1; c <= cols; c++) {
        final curr = (c < cols) ? grid[r][c] : null;
        final prev = grid[r][c - 1];
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
        final curr = (r < rows) ? grid[r][c] : null;
        final prev = grid[r - 1][c];
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
      return Point<int>(c, r); // (c,r)
    }).toList();
  }

  void _swap(Point<int> a, Point<int> b) {
    final t = grid[a.y][a.x];
    grid[a.y][a.x] = grid[b.y][b.x];
    grid[b.y][b.x] = t;
  }

  int _removeMatchesOnce() {
    final matches = _findMatches();
    if (matches.isEmpty) return 0;

    // 제거(null)
    for (final p in matches) {
      grid[p.y][p.x] = null;
    }

    // 낙하 + 리필
    for (int c = 0; c < cols; c++) {
      int write = rows - 1;

      for (int r = rows - 1; r >= 0; r--) {
        final v = grid[r][c];
        if (v != null) {
          grid[write][c] = v;
          write--;
        }
      }

      for (int r = write; r >= 0; r--) {
        grid[r][c] = _randomBlock();
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

  Future<void> _gameOverDialog() async {
    if (!mounted) return;

    await Future.delayed(const Duration(milliseconds: 50));
    if (!mounted) return;

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
          ),
        ],
      ),
    );

    _restartGame();
    busy = false;
    if (mounted) setState(() {});
  }

  Future<void> _onTapBoard(Offset localPos, double boardSize) async {
    if (busy) return;

    final double cellSize = boardSize / cols;
    final int c = (localPos.dx / cellSize).floor();
    final int r = (localPos.dy / cellSize).floor();
    if (!_inBounds(r, c)) return;

    final cell = Point<int>(c, r);

    // 1) 선택 없음 -> 선택
    if (selected == null) {
      setState(() => selected = cell);
      return;
    }

    // 2) 같은 칸 다시 누르면 선택 해제
    if (selected!.x == cell.x && selected!.y == cell.y) {
      setState(() => selected = null);
      return;
    }

    // 3) 인접 아니면 선택 이동
    final dist = (selected!.x - cell.x).abs() + (selected!.y - cell.y).abs();
    if (dist != 1) {
      setState(() => selected = cell);
      return;
    }

    // 4) 인접이면 스왑 시도
    busy = true;
    _swap(selected!, cell);
    setState(() {}); // 즉시 반영

    if (_findMatches().isEmpty) {
      // 실패 스왑: 되돌리고 1실패=게임오버
      await Future.delayed(const Duration(milliseconds: 120));
      _swap(selected!, cell);
      selected = null;
      if (mounted) setState(() {});
      await _gameOverDialog();
      return;
    }

    // 성공 스왑: 연쇄 처리
    await _resolveChains();
    selected = null;
    busy = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFF222222);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double boardSize =
            min(constraints.maxWidth, constraints.maxHeight);

            return Stack(
              children: [
                // HUD
                Positioned(
                  top: 12,
                  left: 12,
                  child: DefaultTextStyle(
                    style: const TextStyle(fontSize: 14, height: 1.4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('상태: '),
                        Text(
                          statusText,
                          style: const TextStyle(color: Colors.white),
                        ),
                        const Text('  |  점수: '),
                        Text(
                          '$score',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Board
                Center(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (d) => _onTapBoard(d.localPosition, boardSize),
                    child: SizedBox(
                      width: boardSize,
                      height: boardSize,
                      child: CustomPaint(
                        painter: _GameBoardPainter(
                          grid: grid,
                          images: images,
                          imagesReady: imagesReady,
                          selected: selected,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GameBoardPainter extends CustomPainter {
  final List<List<int?>> grid;
  final List<ui.Image?> images;
  final bool imagesReady;
  final Point<int>? selected;

  _GameBoardPainter({
    required this.grid,
    required this.images,
    required this.imagesReady,
    required this.selected,
  });

  static const List<Color> fallbackColors = [
    Color(0xFF6666CC),
    Color(0xFFCC6666),
    Color(0xFF66CC66),
    Color(0xFFCCCC66),
    Color(0xFF66CCCC),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final int rCount = grid.length;
    final int cCount = grid[0].length;
    final double cell = size.width / cCount;

    // 배경
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF111111),
    );

    // 블럭
    for (int r = 0; r < rCount; r++) {
      for (int c = 0; c < cCount; c++) {
        final t = grid[r][c];
        if (t == null) continue;

        final Rect dst = Rect.fromLTWH(c * cell, r * cell, cell, cell);

        final img =
        (imagesReady && t >= 0 && t < images.length) ? images[t] : null;

        if (img != null) {
          final Rect src =
          Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble());
          canvas.drawImageRect(
            img,
            src,
            dst,
            Paint()..filterQuality = FilterQuality.none,
          );
        } else {
          canvas.drawRect(dst, Paint()..color = fallbackColors[t % 5]);
          canvas.drawRect(dst, Paint()..color = const Color(0x26000000));
        }
      }
    }

    // 선택 테두리
    if (selected != null) {
      final Rect sel =
      Rect.fromLTWH(selected!.x * cell, selected!.y * cell, cell, cell);
      canvas.drawRect(
        sel,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..color = Colors.yellow,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GameBoardPainter oldDelegate) => true;
}
