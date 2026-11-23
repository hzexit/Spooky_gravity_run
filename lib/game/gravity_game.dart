import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'background.dart';
import 'player.dart';
import 'obstacles.dart';
import 'items.dart';

class GravityGame extends FlameGame
    with TapCallbacks, HasCollisionDetection {
  late Player player;
  late TextComponent scoreText;
  late TextComponent candyText;

  static const double baseSpeed = 220;
  static const double maxSpeed = 480;
  static const String _bestKey = 'best_distance';

  double scrollSpeed = baseSpeed;
  double distance = 0; // หน่วยเมตร
  int candies = 0;
  double spawnTimer = 0;
  double candyTimer = 2;
  bool isPlaying = false; // false = อยู่หน้าเมนู
  bool isGameOver = false;
  bool isNewBest = false;
  final best = ValueNotifier<int>(0); // สถิติสูงสุด (เมนูฟังค่านี้อยู่)
  final _rng = Random();

  @override
  Future<void> onLoad() async {
    final prefs = await SharedPreferences.getInstance();
    best.value = prefs.getInt(_bestKey) ?? 0;

    add(ScrollingLines());
    player = Player();
    add(player);

    scoreText = TextComponent(
      text: '0 m',
      position: Vector2(16, 8),
      priority: 10,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(scoreText);

    candyText = TextComponent(
      text: 'Candy: 0',
      anchor: Anchor.topRight,
      position: Vector2(size.x - 16, 8),
      priority: 10,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFEB3B),
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(candyText);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded) {
      candyText.position = Vector2(size.x - 16, 8);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isPlaying || isGameOver) return;

    // ระยะทางและความเร็ว
    distance += scrollSpeed * dt / 10;
    scrollSpeed = (baseSpeed + distance * 0.2).clamp(baseSpeed, maxSpeed);
    scoreText.text = '${distance.floor()} m';

    // spawn หนาม (ยิ่งเร็ว ยิ่งถี่)
    spawnTimer -= dt;
    if (spawnTimer <= 0) {
      final factor = baseSpeed / scrollSpeed;
      spawnTimer = (1.3 + _rng.nextDouble()) * factor;
      final onFloor = _rng.nextBool();
      final y = onFloor
          ? size.y - Player.margin - 20
          : Player.margin + 20;
      add(Spike(Vector2(size.x + 40, y)));
    }

    // spawn ขนม ที่ความสูงสุ่ม
    candyTimer -= dt;
    if (candyTimer <= 0) {
      candyTimer = 1.5 + _rng.nextDouble() * 2;
      final minY = Player.margin + 30;
      final maxY = size.y - Player.margin - 30;
      final y = minY + _rng.nextDouble() * (maxY - minY);
      add(Candy(Vector2(size.x + 40, y)));
    }
  }

  void collectCandy() {
    candies++;
    candyText.text = 'Candy: $candies';
  }

  Future<void> _saveBest(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_bestKey, value);
  }

  void gameOver() {
    isGameOver = true;
    final d = distance.floor();
    isNewBest = d > best.value;
    if (isNewBest) {
      best.value = d;
      _saveBest(d);
    }
    pauseEngine();
    overlays.add('gameOver');
  }

  // เริ่มเล่น (จากเมนู หรือกด PLAY AGAIN)
  void startGame() {
    overlays.remove('menu');
    overlays.remove('gameOver');
    restart();
    isPlaying = true;
  }

  // กลับหน้าเมนู
  void backToMenu() {
    overlays.remove('gameOver');
    restart();
    isPlaying = false;
    overlays.add('menu');
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!isPlaying || isGameOver) return;
    player.flip();
  }

  void restart() {
    children.whereType<Spike>().toList().forEach((s) => s.removeFromParent());
    children.whereType<Candy>().toList().forEach((c) => c.removeFromParent());
    player.reset();
    isGameOver = false;
    isNewBest = false;
    distance = 0;
    candies = 0;
    scoreText.text = '0 m';
    candyText.text = 'Candy: 0';
    scrollSpeed = baseSpeed;
    spawnTimer = 1;
    candyTimer = 2;
    resumeEngine();
  }
}