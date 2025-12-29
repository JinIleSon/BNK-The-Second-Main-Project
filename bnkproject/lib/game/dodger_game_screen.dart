// lib/game/dodger_game_screen.dart
import 'dart:math';

import 'package:flame/camera.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DodgerGameScreen extends StatefulWidget {
  const DodgerGameScreen({super.key});

  @override
  State<DodgerGameScreen> createState() => _DodgerGameScreenState();
}

class _DodgerGameScreenState extends State<DodgerGameScreen> {
  late final DodgerGame _game;

  bool _leftPressed = false;
  bool _rightPressed = false;

  @override
  void initState() {
    super.initState();
    _game = DodgerGame();
  }

  Future<void> _openTitleLink() async {
    final uri = Uri.parse(
      'http://ncsedu.co.kr/?utm_source=main_banner&utm_medium=HQ&utm_campaign=bcc_311%E3%85%8B&src=text&kw=00450A',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    const scaffoldBg = Color(0xFFF6F6FA); // 바깥 배경(전체 화면)
    const gameFrameBg = Colors.white; // 빨간 점선 안(게임 영역) 배경

    final controlsH = 12 + 56 + 12 + mq.padding.bottom;
    const titleH = 90.0;
    final availH = mq.size.height - mq.padding.top - controlsH - titleH - 16;

    double w = min(mq.size.width - 24, 400);
    double h = w * 1.5;
    if (h > availH) {
      h = max(520, availH);
      w = h * (2 / 3);
    }

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        // ✅ 여기서 "타이틀 글자색"을 강제로 검정으로 박아버림
        title: const Text(
          '부기 씨앗호떡 피하기',
          style: TextStyle(color: Colors.black),
        ),
        // ✅ 뒤로가기 아이콘도 검정
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 6),

                // ✅ 타이틀 이미지: title.png로 고정 (assets/images/title.png)
                SizedBox(
                  width: w,
                  height: titleH,
                  child: GestureDetector(
                    onTap: _openTitleLink,
                    child: Image.asset(
                      'assets/images/title.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                ),

                const SizedBox(height: 8),
                Transform.translate(
                  offset: const Offset(0, -40),
                  child: Center(
                    child: SizedBox(
                      width: w,
                      height: h,
                      child: _DashedBorder(
                        radius: 12,
                        strokeWidth: 2,
                        dash: 6,
                        gap: 5,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              // ✅ 빨간 점선 “안쪽” Flutter 레이어 배경
                              color: gameFrameBg,
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                  color: Colors.black.withOpacity(0.08),
                                )
                              ],
                            ),
                            child: GameWidget(
                              game: _game,
                              overlayBuilderMap: {
                                'Hud': (_, DodgerGame game) =>
                                    _HudOverlay(game: game),
                                'Menu': (_, DodgerGame game) =>
                                    _MenuOverlay(game: game),
                              },
                              initialActiveOverlays: const ['Hud', 'Menu'],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(height: controlsH),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _ControlsBar(
                leftPressed: _leftPressed,
                rightPressed: _rightPressed,
                onLeftDown: () {
                  setState(() => _leftPressed = true);
                  _rightPressed = false;
                  _game.setDirection(-1);
                  _game.setFacingRight(false);
                },
                onLeftUp: () {
                  setState(() => _leftPressed = false);
                  if (_game.direction == -1) _game.setDirection(0);
                },
                onRightDown: () {
                  setState(() => _rightPressed = true);
                  _leftPressed = false;
                  _game.setDirection(1);
                  _game.setFacingRight(true);
                },
                onRightUp: () {
                  setState(() => _rightPressed = false);
                  if (_game.direction == 1) _game.setDirection(0);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// =========================
/// Game (Flame)
/// =========================

enum GamePhase { ready, playing, gameOver }
enum DropKind { hotteok, coin, dongbak }

class DodgerHudState {
  final int score;
  final int level;
  final int hotteokAvoided;
  final int coins;
  final int dongbaks;

  const DodgerHudState({
    required this.score,
    required this.level,
    required this.hotteokAvoided,
    required this.coins,
    required this.dongbaks,
  });

  DodgerHudState copyWith({
    int? score,
    int? level,
    int? hotteokAvoided,
    int? coins,
    int? dongbaks,
  }) {
    return DodgerHudState(
      score: score ?? this.score,
      level: level ?? this.level,
      hotteokAvoided: hotteokAvoided ?? this.hotteokAvoided,
      coins: coins ?? this.coins,
      dongbaks: dongbaks ?? this.dongbaks,
    );
  }
}

class DodgerGame extends FlameGame with HasCollisionDetection {
  final _rng = Random();

  late PlayerComponent _player;
  final _Sprites _sprites = _Sprites();

  final ValueNotifier<GamePhase> phase = ValueNotifier(GamePhase.ready);
  final ValueNotifier<DodgerHudState> hud = ValueNotifier(
    const DodgerHudState(
      score: 0,
      level: 1,
      hotteokAvoided: 0,
      coins: 0,
      dongbaks: 0,
    ),
  );

  // input: -1(left), 0, 1(right)
  int direction = 0;
  void setDirection(int v) => direction = v;
  void setFacingRight(bool right) => _player.facingRight = right;

  int score = 0;
  int level = 1;
  int hotteokAvoided = 0;
  int coinsCollected = 0;
  int dongbakCollected = 0;

  double spawnInterval = 0.70;
  double hotteokSpeed = 3.0;
  double coinSpeed = 2.6;
  double dongbakSpeed = 2.4;

  static const double shieldDuration = 4.0;
  double shieldLeft = 0.0;
  bool get isShield => shieldLeft > 0;

  double _spawnAcc = 0.0;
  double _levelAcc = 0.0;

  static const int maxDrops = 6;

  static const double hotteokSize = 42;
  static const double coinSize = 30;
  static const double dongbakSize = 30;

  static const double playerSize = 80;
  static const double playerSpeedPxPerSec = 300;

  int get _dropCount => children.whereType<DropComponent>().length;

  // ✅ 게임 캔버스 배경(Flame 쪽)도 흰색 고정
  @override
  Color backgroundColor() => Colors.white;

  @override
  Future<void> onLoad() async {
    camera.viewport = FixedResolutionViewport(resolution: Vector2(400, 600));

    // ✅ prefix 지정 후 파일명만 로드
    images.prefix = 'assets/images/';

    await images.loadAll([
      'player.png',
      'porkSoup.png',
      'coin_icon.png',
      'dongbak.png',
    ]);

    _sprites.player = Sprite(images.fromCache('player.png'));
    _sprites.hotteok = Sprite(images.fromCache('porkSoup.png'));
    _sprites.coin = Sprite(images.fromCache('coin_icon.png'));
    _sprites.dongbak = Sprite(images.fromCache('dongbak.png'));

    _player = PlayerComponent(sprite: _sprites.player, facingRight: true);
    add(_player);

    _resetToReady();
  }

  void _resetToReady() {
    pauseEngine();
    phase.value = GamePhase.ready;

    children
        .whereType<DropComponent>()
        .toList()
        .forEach((c) => c.removeFromParent());

    _player.size = Vector2.all(playerSize);
    _player.position = Vector2((size.x - playerSize) / 2, 520);
    _player.facingRight = true;
    _player.shieldActive = false;

    score = 0;
    level = 1;
    hotteokAvoided = 0;
    coinsCollected = 0;
    dongbakCollected = 0;

    spawnInterval = 0.70;
    hotteokSpeed = 3.0;
    coinSpeed = 2.6;
    dongbakSpeed = 2.4;

    shieldLeft = 0;
    _spawnAcc = 0;
    _levelAcc = 0;

    _pushHud();
  }

  void startGame() {
    children
        .whereType<DropComponent>()
        .toList()
        .forEach((c) => c.removeFromParent());

    _player.position = Vector2((size.x - playerSize) / 2, 520);
    _player.facingRight = true;
    _player.shieldActive = false;

    score = 0;
    level = 1;
    hotteokAvoided = 0;
    coinsCollected = 0;
    dongbakCollected = 0;

    spawnInterval = 0.70;
    hotteokSpeed = 3.0;
    coinSpeed = 2.6;
    dongbakSpeed = 2.4;

    shieldLeft = 0;
    _spawnAcc = 0;
    _levelAcc = 0;

    phase.value = GamePhase.playing;
    _pushHud();

    overlays.remove('Menu');
    resumeEngine();
  }

  void _harder() {
    if (phase.value != GamePhase.playing) return;
    level++;
    hotteokSpeed += 0.35;
    coinSpeed += 0.25;
    dongbakSpeed += 0.2;
    spawnInterval = max(0.22, spawnInterval - 0.06);
    _pushHud();
  }

  void _spawnOne() {
    if (_dropCount >= maxDrops) return;

    final r = _rng.nextDouble();

    late DropKind kind;
    late double sizePx;
    late double spdFrame;
    late Sprite sprite;

    if (r < 0.60) {
      kind = DropKind.hotteok;
      sizePx = hotteokSize;
      spdFrame = hotteokSpeed + _rng.nextDouble() * 1.5;
      sprite = _sprites.hotteok;
    } else if (r < 0.88) {
      kind = DropKind.coin;
      sizePx = coinSize;
      spdFrame = coinSpeed + _rng.nextDouble() * 1.2;
      sprite = _sprites.coin;
    } else {
      kind = DropKind.dongbak;
      sizePx = dongbakSize;
      spdFrame = dongbakSpeed + _rng.nextDouble() * 1.0;
      sprite = _sprites.dongbak;
    }

    final x = _rng.nextDouble() * (size.x - sizePx);
    final spd = spdFrame * 60.0; // px/frame -> px/sec (60fps 근사)

    final drop = DropComponent(kind: kind, sprite: sprite, speed: spd)
      ..size = Vector2.all(sizePx)
      ..position = Vector2(x, -sizePx);

    add(drop);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (phase.value != GamePhase.playing) return;

    if (shieldLeft > 0) {
      shieldLeft = max(0, shieldLeft - dt);
      _player.shieldActive = true;
    } else {
      _player.shieldActive = false;
    }

    if (direction != 0) {
      _player.position.x += direction * playerSpeedPxPerSec * dt;
      _player.position.x = _player.position.x.clamp(0, size.x - playerSize);
    }

    _spawnAcc += dt;
    while (_spawnAcc >= spawnInterval) {
      _spawnAcc -= spawnInterval;
      _spawnOne();
    }

    _levelAcc += dt;
    if (_levelAcc >= 5.0) {
      _levelAcc -= 5.0;
      _harder();
    }
  }

  void onDropPassed(DropKind kind) {
    if (phase.value != GamePhase.playing) return;

    if (kind == DropKind.hotteok) {
      hotteokAvoided++;
      score += 1;
      _pushHud();
    }
  }

  void onDropHit(DropKind kind) {
    if (phase.value != GamePhase.playing) return;

    if (kind == DropKind.hotteok) {
      if (isShield) return;
      gameOver();
      return;
    }

    if (kind == DropKind.coin) {
      coinsCollected++;
      score += 10;
      _pushHud();
      return;
    }

    if (kind == DropKind.dongbak) {
      dongbakCollected++;
      score += 50;
      shieldLeft = shieldDuration;
      _pushHud();
      return;
    }
  }

  void gameOver() {
    pauseEngine();
    phase.value = GamePhase.gameOver;
    _pushHud();
    overlays.add('Menu');
  }

  void _pushHud() {
    hud.value = hud.value.copyWith(
      score: score,
      level: level,
      hotteokAvoided: hotteokAvoided,
      coins: coinsCollected,
      dongbaks: dongbakCollected,
    );
  }
}

class _Sprites {
  late Sprite player;
  late Sprite hotteok;
  late Sprite coin;
  late Sprite dongbak;
}

class PlayerComponent extends PositionComponent with CollisionCallbacks {
  PlayerComponent({
    required this.sprite,
    required this.facingRight,
  });

  final Sprite sprite;
  bool facingRight;
  bool shieldActive = false;

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  @override
  void render(Canvas canvas) {
    if (shieldActive) {
      final cx = size.x / 2;
      final cy = size.y / 2;
      final r = max(size.x, size.y) * 0.75;

      final fill = Paint()..color = const Color(0xFF00C8FF).withOpacity(0.25);
      final stroke = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = const Color(0xFF00A0FF).withOpacity(0.8);

      canvas.drawCircle(Offset(cx, cy), r, fill);
      canvas.drawCircle(Offset(cx, cy), r, stroke);
    }

    if (facingRight) {
      sprite.render(canvas, size: size);
    } else {
      canvas.save();
      canvas.translate(size.x, 0);
      canvas.scale(-1, 1);
      sprite.render(canvas, size: size);
      canvas.restore();
    }
  }
}

class DropComponent extends SpriteComponent
    with CollisionCallbacks, HasGameRef<DodgerGame> {
  DropComponent({
    required this.kind,
    required Sprite sprite,
    required this.speed,
  }) : super(sprite: sprite);

  final DropKind kind;
  final double speed;

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox.relative(
      Vector2(0.75, 0.75),
      parentSize: size,
      position: Vector2(size.x * 0.125, size.y * 0.125),
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.y += speed * dt;

    if (position.y > gameRef.size.y) {
      removeFromParent();
      gameRef.onDropPassed(kind);
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is PlayerComponent) {
      removeFromParent();
      gameRef.onDropHit(kind);
    }
  }
}

/// =========================
/// Overlays
/// =========================

class _HudOverlay extends StatelessWidget {
  const _HudOverlay({required this.game});
  final DodgerGame game;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      right: 8,
      child: IgnorePointer(
        child: ValueListenableBuilder<DodgerHudState>(
          valueListenable: game.hud,
          builder: (_, s, __) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.35),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DefaultTextStyle(
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  height: 1.4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Score: ${s.score}'),
                    Text('Level: ${s.level}'),
                    const SizedBox(height: 4),
                    _hudIconRow('assets/images/porkSoup.png', '${s.hotteokAvoided}'),
                    _hudIconRow('assets/images/coin_icon.png', '${s.coins}'),
                    _hudIconRow('assets/images/dongbak.png', '${s.dongbaks}'),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _hudIconRow(String asset, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(asset, width: 20, height: 20),
        const SizedBox(width: 6),
        Text(value),
      ],
    );
  }
}

class _MenuOverlay extends StatelessWidget {
  const _MenuOverlay({required this.game});
  final DodgerGame game;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ValueListenableBuilder<GamePhase>(
        valueListenable: game.phase,
        builder: (_, ph, __) {
          final isOver = ph == GamePhase.gameOver;

          return Container(
            color: Colors.black.withOpacity(0.35),
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: ValueListenableBuilder<DodgerHudState>(
                      valueListenable: game.hud,
                      builder: (_, s, __) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isOver ? '게임 오버' : '게임 시작',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              isOver ? '다시 도전!' : '왼쪽/오른쪽 버튼으로 이동하세요.',
                              style: const TextStyle(color: Color(0xFF333333)),
                              textAlign: TextAlign.center,
                            ),
                            if (isOver) ...[
                              const SizedBox(height: 12),
                              _statsLine(s),
                            ],
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  backgroundColor: const Color(0xFFE6FFF2),
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(
                                      color: Color(0xFFC9F9DF),
                                      width: 2,
                                    ),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: () => game.startGame(),
                                child: const Text(
                                  '게임 시작',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
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
          );
        },
      ),
    );
  }

  Widget _statsLine(DodgerHudState s) {
    return DefaultTextStyle(
      style: const TextStyle(
        fontSize: 15,
        color: Color(0xFF555555),
        height: 1.6,
      ),
      child: Column(
        children: [
          Text('Score: ${s.score}', style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/porkSoup.png', width: 20, height: 20),
              const SizedBox(width: 6),
              Text('${s.hotteokAvoided}'),
              const SizedBox(width: 12),
              const Text('|'),
              const SizedBox(width: 12),
              Image.asset('assets/images/coin_icon.png', width: 20, height: 20),
              const SizedBox(width: 6),
              Text('${s.coins}'),
              const SizedBox(width: 12),
              const Text('|'),
              const SizedBox(width: 12),
              Image.asset('assets/images/dongbak.png', width: 20, height: 20),
              const SizedBox(width: 6),
              Text('${s.dongbaks}'),
            ],
          ),
        ],
      ),
    );
  }
}

/// =========================
/// Bottom Controls
/// =========================

class _ControlsBar extends StatelessWidget {
  const _ControlsBar({
    required this.leftPressed,
    required this.rightPressed,
    required this.onLeftDown,
    required this.onLeftUp,
    required this.onRightDown,
    required this.onRightUp,
  });

  final bool leftPressed;
  final bool rightPressed;
  final VoidCallback onLeftDown;
  final VoidCallback onLeftUp;
  final VoidCallback onRightDown;
  final VoidCallback onRightUp;

  @override
  Widget build(BuildContext context) {
    final bg = Colors.white;

    return Container(
      padding: EdgeInsets.fromLTRB(12, 12, 12, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            bg.withOpacity(0.0),
            bg.withOpacity(0.85),
            bg,
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _HoldButton(
              label: '◀ 왼쪽',
              active: leftPressed,
              onDown: onLeftDown,
              onUp: onLeftUp,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _HoldButton(
              label: '오른쪽 ▶',
              active: rightPressed,
              onDown: onRightDown,
              onUp: onRightUp,
            ),
          ),
        ],
      ),
    );
  }
}

class _HoldButton extends StatelessWidget {
  const _HoldButton({
    required this.label,
    required this.active,
    required this.onDown,
    required this.onUp,
  });

  final String label;
  final bool active;
  final VoidCallback onDown;
  final VoidCallback onUp;

  @override
  Widget build(BuildContext context) {
    // 버튼 색상
    const baseBg = Color(0xFFEEF2FF);
    const activeBg = Color(0xFFE2E8FF);
    const border = Color(0xFFD6DEFF);

    return Listener(
      onPointerDown: (_) => onDown(),
      onPointerUp: (_) => onUp(),
      onPointerCancel: (_) => onUp(),
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 80),
        offset: active ? const Offset(0, 0.02) : Offset.zero,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: active ? activeBg : baseBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border, width: 2),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black, // ✅ 글자색 검정
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// =========================
/// Dashed Border
/// =========================

class _DashedBorder extends StatelessWidget {
  const _DashedBorder({
    required this.child,
    this.radius = 12,
    this.strokeWidth = 2,
    this.dash = 6,
    this.gap = 5,
  });

  final Widget child;
  final double radius;
  final double strokeWidth;
  final double dash;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRectPainter(
        radius: radius,
        strokeWidth: strokeWidth,
        dash: dash,
        gap: gap,
      ),
      child: child,
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  _DashedRectPainter({
    required this.radius,
    required this.strokeWidth,
    required this.dash,
    required this.gap,
  });

  final double radius;
  final double strokeWidth;
  final double dash;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = const Color(0xFFFF3B30);

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    for (final m in path.computeMetrics()) {
      double dist = 0;
      while (dist < m.length) {
        final len = min(dash, m.length - dist);
        final seg = m.extractPath(dist, dist + len);
        canvas.drawPath(seg, paint);
        dist += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRectPainter old) {
    return old.radius != radius ||
        old.strokeWidth != strokeWidth ||
        old.dash != dash ||
        old.gap != gap;
  }
}
