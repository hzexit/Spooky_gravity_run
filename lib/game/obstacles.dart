import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'gravity_game.dart';

class Spike extends PositionComponent with HasGameReference<GravityGame> {
  Spike(Vector2 pos)
      : super(position: pos, size: Vector2(40, 40), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    position.x -= game.scrollSpeed * dt;
    if (position.x < -size.x) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), Paint()..color = const Color(0xFFE53935));
  }
}