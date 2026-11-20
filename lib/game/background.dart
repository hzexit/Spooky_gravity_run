import 'dart:ui';
import 'package:flame/components.dart';
import 'gravity_game.dart';

class ScrollingLines extends PositionComponent
    with HasGameReference<GravityGame> {
  double offset = 0;
  static const double gap = 80;

  @override
  void update(double dt) {
    offset = (offset + game.scrollSpeed * dt) % gap;
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = const Color(0xFF424242);
    final w = game.size.x;
    final h = game.size.y;
    const m = Player0.margin;

    // เส้นพื้นและเพดาน
    canvas.drawRect(Rect.fromLTWH(0, h - m, w, 4), paint);
    canvas.drawRect(Rect.fromLTWH(0, m - 4, w, 4), paint);

    // ขีดเล็กๆ ที่เลื่อนไปทางซ้าย ให้รู้สึกว่าวิ่ง
    for (double x = -offset; x < w; x += gap) {
      canvas.drawRect(Rect.fromLTWH(x, h - m + 12, 30, 3), paint);
      canvas.drawRect(Rect.fromLTWH(x, m - 15, 30, 3), paint);
    }
  }
}

class Player0 {
  static const double margin = 40;
}