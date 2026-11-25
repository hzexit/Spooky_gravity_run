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
    final w = size.x, h = size.y;
    final c = Offset(w / 2, h / 2);
    final r = w * 0.27; // รัศมีเม็ดลูกอมตรงกลาง

    const pink = Color(0xFFFF4F9A);
    const wrap = Color(0xFFFFB3D1);
    const outline = Color(0xFF8A1F55);
    const white = Color(0xFFFFFFFF);

    final fill = Paint()..style = PaintingStyle.fill;
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeJoin = StrokeJoin.round
      ..color = outline;

    // ปลายห่อกระดาษซ้าย-ขวา
    for (final dir in [-1.0, 1.0]) {
      final baseX = c.dx + dir * r * 0.8;
      final tipX = c.dx + dir * w * 0.47;
      final wing = Path()
        ..moveTo(baseX, c.dy)
        ..lineTo(tipX, c.dy - h * 0.26)
        ..lineTo(tipX, c.dy + h * 0.26)
        ..close();
      canvas.drawPath(wing, fill..color = wrap);
      canvas.drawPath(wing, line);
      // รอยพับ
      line.strokeWidth = 1.2;
      canvas.drawLine(
        Offset(c.dx + dir * (r + w * 0.07), c.dy - h * 0.07),
        Offset(c.dx + dir * (r + w * 0.07), c.dy + h * 0.07),
        line,
      );
      line.strokeWidth = 1.8;
    }

    // เม็ดลูกอมลายทางเฉียง
    canvas.drawCircle(c, r, fill..color = pink);
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: r)));
    final stripe = Paint()
      ..color = white
      ..strokeWidth = 3.5;
    for (var i = -3; i <= 3; i++) {
      final o = i * 7.0;
      canvas.drawLine(
        Offset(c.dx + o - r, c.dy + r),
        Offset(c.dx + o + r, c.dy - r),
        stripe,
      );
    }
    canvas.restore();
    canvas.drawCircle(c, r, line);

    // จุดเงาสะท้อน
    canvas.drawCircle(
      Offset(c.dx - r * 0.35, c.dy - r * 0.4),
      r * 0.16,
      Paint()..color = white,
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