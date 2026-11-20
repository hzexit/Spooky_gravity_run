import 'dart:math';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'player.dart';
import 'obstacles.dart';

class GravityGame extends FlameGame
    with TapCallbacks, HasCollisionDetection {
  late Player player;
  double scrollSpeed = 300;
  double spawnTimer = 0;
  bool isGameOver = false;
  final _rng = Random();

  @override
  Future<void> onLoad() async {
    player = Player();
    add(player);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) return;

    spawnTimer -= dt;
    if (spawnTimer <= 0) {
      spawnTimer = 1.0 + _rng.nextDouble();
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
    spawnTimer = 1;
    resumeEngine();
  }
}