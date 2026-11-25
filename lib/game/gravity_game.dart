import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import '../data/db_helper.dart';
import 'audio_manager.dart';
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
  late TextComponent powerText;

  static const double baseSpeed = 220;
  static const double maxSpeed = 540;
  static const double speedGain = 0.26; // ความเร็วที่เพิ่มต่อ 1 เมตร
  static const double magnetRadius = 260; // รัศมีดูดขนม (px)
  static const double magnetDuration = 8; // วินาที

  double scrollSpeed = baseSpeed;
  double distance = 0; // หน่วยเมตร
  int candies = 0;
  bool isPlaying = false; // false = อยู่หน้าเมนู
  bool isGameOver = false;
  bool isNewBest = false;
  final best = ValueNotifier<int>(0);
  SkinDef currentSkin = skins.first;

  // power-up
  bool shieldActive = false;
  double magnetTime = 0;
  double invincibleTime = 0; // กันชนซ้ำหลังโล่แตก

  @override
  Future<void> onLoad() async {
    try {
      await AudioManager.instance.init();
      best.value = await DbHelper.instance.getBestDistance();
      currentSkin = skinById(await DbHelper.instance.getSelectedSkin());
    } catch (e) {
      debugPrint('Load error: $e');
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

    powerText = TextComponent(
      text: '',
      anchor: Anchor.topCenter,
      position: Vector2(size.x / 2, 8),
      priority: 10,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF80DEEA),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(powerText);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded) {
      candyText.position = Vector2(size.x - 16, 8);
      powerText.position = Vector2(size.x / 2, 8);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isPlaying || isGameOver) return;

    distance += scrollSpeed * dt / 10;
    scrollSpeed =
        (baseSpeed + distance * speedGain).clamp(baseSpeed, maxSpeed);
    scoreText.text = '${distance.floor()} m';

    if (magnetTime > 0) magnetTime -= dt;
    if (magnetTime < 0) magnetTime = 0;
    if (invincibleTime > 0) invincibleTime -= dt;
    _updatePowerText();

    level.update(dt, scrollSpeed, distance);
  }

  void _updatePowerText() {
    final parts = <String>[];
    if (shieldActive) parts.add('SHIELD');
    if (magnetTime > 0) parts.add('MAGNET ${magnetTime.ceil()}s');
    final t = parts.join('   ');
    if (powerText.text != t) powerText.text = t;
  }

  void collectCandy() {
    candies++;
    candyText.text = 'Candy: $candies';
    AudioManager.instance.play(AudioManager.candy);
  }

  void collectPowerUp(PowerType type) {
    switch (type) {
      case PowerType.shield:
        shieldActive = true;
        break;
      case PowerType.magnet:
        magnetTime = magnetDuration;
        break;
    }
    _updatePowerText();
    AudioManager.instance.play(AudioManager.item);
  }

  /// ชนหนาม: ถ้ามีโล่ โล่แตกแทนและหนามหาย ถ้าไม่มีก็จบเกม
  void hitSpike(Spike spike) {
    if (invincibleTime > 0) return;
    if (shieldActive) {
      shieldActive = false;
      invincibleTime = 0.4;
      spike.removeFromParent();
      _updatePowerText();
      AudioManager.instance.play(AudioManager.shieldBroken);
    } else {
      gameOver();
    }
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

    AudioManager.instance.stopBgm();
    AudioManager.instance.play(AudioManager.gameOver);

    pauseEngine();
    overlays.remove('hud');
    overlays.add('gameOver');
  }

  // เริ่มเล่น (จากเมนู หรือกด PLAY AGAIN)
  void startGame() {
    overlays.remove('menu');
    overlays.remove('gameOver');
    overlays.remove('pause');
    restart();
    isPlaying = true;
    overlays.add('hud');
    AudioManager.instance.startBgm();
  }

  // กลับหน้าเมนู
  void backToMenu() {
    overlays.remove('gameOver');
    overlays.remove('pause');
    overlays.remove('hud');
    restart();
    isPlaying = false;
    overlays.add('menu');
    AudioManager.instance.stopBgm();
  }

  // หยุดเกมชั่วคราว
  void pauseGame() {
    if (!isPlaying || isGameOver) return;
    pauseEngine();
    AudioManager.instance.pauseBgm();
    overlays.remove('hud');
    overlays.add('pause');
  }

  void resumeGame() {
    overlays.remove('pause');
    overlays.add('hud');
    AudioManager.instance.resumeBgm();
    resumeEngine();
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

  void showSettings() {
    overlays.remove('menu');
    overlays.add('settings');
  }

  void closeSettings() {
    overlays.remove('settings');
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
    children.whereType<PowerUp>().toList().forEach((p) => p.removeFromParent());
    player.reset();
    isGameOver = false;
    isNewBest = false;
    distance = 0;
    candies = 0;
    shieldActive = false;
    magnetTime = 0;
    invincibleTime = 0;
    scoreText.text = '0 m';
    candyText.text = 'Candy: 0';
    powerText.text = '';
    scrollSpeed = baseSpeed;
    level.reset();
    resumeEngine();
  }
}