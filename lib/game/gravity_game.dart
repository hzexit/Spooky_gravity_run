import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart';
import 'background.dart';
import 'player.dart';
import 'obstacles.dart';

class GravityGame extends FlameGame
    with TapCallbacks, HasCollisionDetection {
  late Player player;
  late TextComponent scoreText;

  static const double baseSpeed = 300;
  static const double maxSpeed = 800;

  double scrollSpeed = baseSpeed;
  double distance = 0; // หน่วยเมตร
  double spawnTimer = 0;
  bool isGameOver = false;
  final _rng = Random();

  @override
  Future<void> onLoad() async {
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
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) return;

    // ระยะทางและความเร็ว
    distance += scrollSpeed * dt / 10;
    scrollSpeed = (baseSpeed + distance * 0.2).clamp(baseSpeed, maxSpeed);
    scoreText.text = '${distance.floor()} m';

    // spawn หนาม (ยิ่งเร็ว ยิ่งถี่)
    spawnTimer -= dt;
    if (spawnTimer <= 0) {
      final factor = baseSpeed / scrollSpeed;
      spawnTimer = (0.9 + _rng.nextDouble()) * factor;
      final onFloor = _rng.nextBool();
      final y = onFloor
          ? size.y - Player.margin - 20
          : Player.margin + 20;
      add(Spike(Vector2(size.x + 40, y)));
    }
  }

  void gameOver() {
    isGameOver = true;
    pauseEngine();
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (isGameOver) {
      restart();
    } else {
      player.flip();
    }
  }

  void restart() {
    children.whereType<Spike>().toList().forEach((s) => s.removeFromParent());
    player.reset();
    isGameOver = false;
    distance = 0;
    scrollSpeed = baseSpeed;
    spawnTimer = 1;
    resumeEngine();
  }
}