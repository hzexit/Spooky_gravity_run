import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import '../data/db_helper.dart';
import 'background.dart';
import 'player.dart';
import 'obstacles.dart';
import 'items.dart';
import 'level_generator.dart';
import 'skins.dart';

class GravityGame extends FlameGame
    with TapCallbacks, HasCollisionDetection {
  late Player player;
  late LevelGenerator level;
  late TextComponent scoreText;
  late TextComponent candyText;

  static const double baseSpeed = 220;
  static const double maxSpeed = 480;

  double scrollSpeed = baseSpeed;
  double distance = 0; // หน่วยเมตร
  int candies = 0;
  bool isPlaying = false; // false = อยู่หน้าเมนู
  bool isGameOver = false;
  bool isNewBest = false;
  final best = ValueNotifier<int>(0);
  SkinDef currentSkin = skins.first;

  @override
  Future<void> onLoad() async {
    // อ่านข้อมูลจากฐานข้อมูล (ถ้ามีปัญหา เกมยังเล่นได้)
    try {
      best.value = await DbHelper.instance.getBestDistance();
      currentSkin = skinById(await DbHelper.instance.getSelectedSkin());
    } catch (e) {
      debugPrint('DB load error: $e');
    }

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

    distance += scrollSpeed * dt / 10;
    scrollSpeed = (baseSpeed + distance * 0.2).clamp(baseSpeed, maxSpeed);
    scoreText.text = '${distance.floor()} m';

    level.update(dt, scrollSpeed, distance);
  }

  void collectCandy() {
    candies++;
    candyText.text = 'Candy: $candies';
  }

  Future<void> _saveRun(int d, int c) async {
    try {
      await DbHelper.instance.insertRun(distance: d, candies: c);
    } catch (e) {
      debugPrint('DB save error: $e');
    }
  }

  void gameOver() {
    if (isGameOver) return;
    isGameOver = true;
    final d = distance.floor();
    isNewBest = d > best.value;
    if (isNewBest) best.value = d;
    _saveRun(d, candies);
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

  void showStats() {
    overlays.remove('menu');
    overlays.add('stats');
  }

  void closeStats() {
    overlays.remove('stats');
    overlays.add('menu');
  }

  void showShop() {
    overlays.remove('menu');
    overlays.add('shop');
  }

  void closeShop() {
    overlays.remove('shop');
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