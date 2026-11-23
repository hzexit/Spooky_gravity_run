import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'gravity_game.dart';

class Candy extends PositionComponent with HasGameReference<GravityGame> {
  Candy(Vector2 pos)
      : super(position: pos, size: Vector2.all(24), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    position.x -= game.scrollSpeed * dt;
    if (position.x < -size.x) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 2,
      Paint()..color = const Color(0xFFFFEB3B),
    );
  }
}