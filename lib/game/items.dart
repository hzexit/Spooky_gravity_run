import 'dart:math';
import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'gravity_game.dart';

class Candy extends PositionComponent with HasGameReference<GravityGame> {
  Candy(Vector2 pos)
      : super(position: pos, size: Vector2.all(32), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    position.x -= game.scrollSpeed * dt;

    // แม่เหล็ก: ดูดขนมที่อยู่ในรัศมีเข้าหาตัวละคร
    if (game.magnetTime > 0 && game.isPlaying && !game.isGameOver) {
      final to = game.player.position - position;
      final dist = to.length;
      if (dist < GravityGame.magnetRadius && dist > 1) {
        position.add(to / dist * 650 * dt);
      }
    }

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

enum PowerType { shield, magnet }

class PowerUp extends PositionComponent with HasGameReference<GravityGame> {
  final PowerType type;
  double _t = 0;

  PowerUp(this.type, Vector2 pos)
      : super(position: pos, size: Vector2.all(44), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    position.x -= game.scrollSpeed * dt;
    _t += dt;
    scale = Vector2.all(1 + 0.08 * sin(_t * 6)); // เต้นตุบๆ ให้สะดุดตา
    if (position.x < -size.x) removeFromParent();
  }

  @override
  void render(Canvas c) {
    final w = size.x, h = size.y;
    final center = Offset(w / 2, h / 2);
    final isShield = type == PowerType.shield;
    final main = isShield ? const Color(0xFF29B6F6) : const Color(0xFFEF5350);

    c.drawCircle(center, w / 2, Paint()..color = main.withAlpha(0x55));
    c.drawCircle(
      center,
      w / 2 - 1.5,
      Paint()
        ..color = main
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    if (isShield) {
      final shield = Path()
        ..moveTo(w * 0.3, h * 0.28)
        ..lineTo(w * 0.7, h * 0.28)
        ..lineTo(w * 0.7, h * 0.52)
        ..quadraticBezierTo(w * 0.7, h * 0.75, w * 0.5, h * 0.82)
        ..quadraticBezierTo(w * 0.3, h * 0.75, w * 0.3, h * 0.52)
        ..close();
      c.drawPath(shield, Paint()..color = const Color(0xFFE1F5FE));
    } else {
      final red = Paint()
        ..color = const Color(0xFFE53935)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7;
      c.drawArc(
        Rect.fromCenter(
            center: Offset(w / 2, h * 0.5), width: w * 0.4, height: w * 0.4),
        pi,
        pi,
        false,
        red,
      );
      c.drawLine(Offset(w * 0.3, h * 0.5), Offset(w * 0.3, h * 0.68), red);
      c.drawLine(Offset(w * 0.7, h * 0.5), Offset(w * 0.7, h * 0.68), red);
      final tip = Paint()
        ..color = const Color(0xFFFFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7;
      c.drawLine(Offset(w * 0.3, h * 0.68), Offset(w * 0.3, h * 0.77), tip);
      c.drawLine(Offset(w * 0.7, h * 0.68), Offset(w * 0.7, h * 0.77), tip);
    }
  }
}