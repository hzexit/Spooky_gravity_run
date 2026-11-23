import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'gravity_game.dart';
import 'obstacles.dart';
import 'items.dart';
import 'skins.dart';

class Player extends PositionComponent
    with HasGameReference<GravityGame>, CollisionCallbacks {
  static const double gravity = 3000;
  static const double flipKick = 600; // ความเร็วทันทีที่กดสลับ
  static const double margin = 40; // ระยะห่างจากขอบบน/ล่าง
  double vy = 0;
  int dir = 1; // 1 = ตกลงพื้น, -1 = ตกขึ้นเพดาน

  Player() : super(size: Vector2.all(48), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    position = Vector2(120, game.size.y - margin - size.y / 2);
    add(RectangleHitbox(size: Vector2.all(38), position: Vector2.all(5)));
  }

  void flip() {
    dir = -dir;
    vy = dir * flipKick;
  }

  void reset() {
    dir = 1;
    vy = 0;
    position = Vector2(120, game.size.y - margin - size.y / 2);
  }

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
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    super.onCollisionStart(points, other);
    if (other is Spike) {
      game.hitSpike(other);
    } else if (other is Candy) {
      game.collectCandy();
      other.removeFromParent();
    } else if (other is PowerUp) {
      game.collectPowerUp(other.type);
      other.removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);

    // วงแม่เหล็กจางๆ
    if (game.magnetTime > 0) {
      canvas.drawCircle(
        center,
        GravityGame.magnetRadius,
        Paint()..color = const Color(0x18EF5350),
      );
    }

    canvas.save();
    // อยู่บนเพดาน = พลิกหัวกลับ
    if (dir == -1) {
      canvas.translate(0, size.y);
      canvas.scale(1, -1);
    }
    paintSkin(canvas, size.x, size.y, game.currentSkin);
    canvas.restore();

    // วงโล่
    if (game.shieldActive) {
      canvas.drawCircle(
        center,
        size.x * 0.75,
        Paint()
          ..color = const Color(0x3329B6F6)
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        center,
        size.x * 0.75,
        Paint()
          ..color = const Color(0xFF29B6F6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }
  }
}