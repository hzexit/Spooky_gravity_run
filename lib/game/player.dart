import 'dart:ui';
import 'package:flame/components.dart';
import 'gravity_game.dart';

class Player extends PositionComponent with HasGameReference<GravityGame> {
  static const double gravity = 2000;
  static const double margin = 40; // ระยะห่างจากขอบบน/ล่าง
  double vy = 0;
  int dir = 1; // 1 = ตกลงพื้น, -1 = ตกขึ้นเพดาน

  Player() : super(size: Vector2.all(48), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    position = Vector2(120, game.size.y - margin - size.y / 2);
  }

  void flip() => dir = -dir;

  @override
  void update(double dt) {
    vy += gravity * dir * dt;
    position.y += vy * dt;

    final floor = game.size.y - margin - size.y / 2;
    final ceiling = margin + size.y / 2;

    if (position.y >= floor) {
      position.y = floor;
      vy = 0;
    }
    if (position.y <= ceiling) {
      position.y = ceiling;
      vy = 0;
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), Paint()..color = const Color(0xFFFF9800));
  }
}