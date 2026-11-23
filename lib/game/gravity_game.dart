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
import 'level_generator.dart';

class GravityGame extends FlameGame
    with TapCallbacks, HasCollisionDetection {
  late Player player;
  late LevelGenerator level;
  late TextComponent scoreText;
  late TextComponent candyText;

  static const double baseSpeed = 220;
  static const double maxSpeed = 480;
  static const String _bestKey = 'best_distance';

  double scrollSpeed = baseSpeed;
  double distance = 0; // หน่วยเมตร
  int candies = 0;
  bool isPlaying = false; // false = อยู่หน้าเมนู
  bool isGameOver = false;
  bool isNewBest = false;
  final best = ValueNotifier<int>(0);

  @override
  Future<void> onLoad() async {
    final prefs = await SharedPreferences.getInstance();
    best.value = prefs.getInt(_bestKey) ?? 0;

    level = LevelGenerator(this);
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

    // สร้างด่านต่อเนื่องด้วย chunk
    level.update(dt, scrollSpeed, distance);
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
    level.reset();
    resumeEngine();
  }
}