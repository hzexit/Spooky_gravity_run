import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'gravity_game.dart';
import 'obstacles.dart';
import 'items.dart';

class Player extends PositionComponent
    with HasGameReference<GravityGame>, CollisionCallbacks {
  static const double gravity = 3000;
  static const double flipKick = 600; // ความเร็วทันทีที่กดสลับ (ยิ่งมากยิ่งไว)
  static const double margin = 40; // ระยะห่างจากขอบบน/ล่าง
  double vy = 0;
  int dir = 1; // 1 = ตกลงพื้น, -1 = ตกขึ้นเพดาน

  Player() : super(size: Vector2.all(48), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    position = Vector2(120, game.size.y - margin - size.y / 2);
    // hitbox เล็กกว่าตัวจริงนิดหน่อย ให้ใจดีกับผู้เล่น
    add(RectangleHitbox(size: Vector2.all(38), position: Vector2.all(5)));
  }

  void flip() {
    dir = -dir;
    vy = dir * flipKick; // เปลี่ยนทิศทันที ไม่ต้องรอเบรก
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
      game.gameOver();
    } else if (other is Candy) {
      game.collectCandy();
      other.removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), Paint()..color = const Color(0xFFFF9800));
  }
}