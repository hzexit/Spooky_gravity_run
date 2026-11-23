import 'dart:ui';

enum SkinShape { classic, ghost, pumpkin, bat, zombie }

class SkinDef {
  final String id;
  final String name;
  final int price;
  final SkinShape shape;

  const SkinDef(this.id, this.name, this.price, this.shape);
}

const List<SkinDef> skins = [
  SkinDef('classic', 'Classic', 0, SkinShape.classic),
  SkinDef('ghost', 'Ghost', 30, SkinShape.ghost),
  SkinDef('pumpkin', 'Pumpkin', 50, SkinShape.pumpkin),
  SkinDef('bat', 'Bat', 80, SkinShape.bat),
  SkinDef('zombie', 'Zombie', 120, SkinShape.zombie),
];

SkinDef skinById(String id) =>
    skins.firstWhere((s) => s.id == id, orElse: () => skins.first);

Paint _fill(int argb) => Paint()..color = Color(argb);

/// วาดสกินลงในกรอบ w x h (ตำแหน่ง 0,0 มุมบนซ้าย)
void paintSkin(Canvas c, double w, double h, SkinDef skin) {
  switch (skin.shape) {
    case SkinShape.classic:
      c.drawRect(Rect.fromLTWH(0, 0, w, h), _fill(0xFFFF9800));
      break;

    case SkinShape.ghost:
      final body = Path()
        ..moveTo(0, h)
        ..lineTo(0, h * 0.5)
        ..quadraticBezierTo(0, 0, w / 2, 0)
        ..quadraticBezierTo(w, 0, w, h * 0.5)
        ..lineTo(w, h)
        ..quadraticBezierTo(w * 0.875, h * 0.76, w * 0.75, h)
        ..quadraticBezierTo(w * 0.625, h * 0.76, w * 0.5, h)
        ..quadraticBezierTo(w * 0.375, h * 0.76, w * 0.25, h)
        ..quadraticBezierTo(w * 0.125, h * 0.76, 0, h)
        ..close();
      c.drawPath(body, _fill(0xFFF5F5F5));
      c.drawCircle(Offset(w * 0.32, h * 0.4), w * 0.08, _fill(0xFF212121));
      c.drawCircle(Offset(w * 0.68, h * 0.4), w * 0.08, _fill(0xFF212121));
      c.drawOval(
        Rect.fromCenter(
            center: Offset(w * 0.5, h * 0.62), width: w * 0.16, height: h * 0.18),
        _fill(0xFF212121),
      );
      break;

    case SkinShape.pumpkin:
      c.drawOval(Rect.fromLTWH(0, h * 0.1, w, h * 0.9), _fill(0xFFFF6F00));
      c.drawRect(
          Rect.fromLTWH(w * 0.43, 0, w * 0.14, h * 0.2), _fill(0xFF2E7D32));
      final dark = _fill(0xFF3E2723);
      c.drawPath(
        Path()
          ..moveTo(w * 0.2, h * 0.5)
          ..lineTo(w * 0.42, h * 0.5)
          ..lineTo(w * 0.31, h * 0.32)
          ..close(),
        dark,
      );
      c.drawPath(
        Path()
          ..moveTo(w * 0.58, h * 0.5)
          ..lineTo(w * 0.8, h * 0.5)
          ..lineTo(w * 0.69, h * 0.32)
          ..close(),
        dark,
      );
      c.drawRect(Rect.fromLTWH(w * 0.28, h * 0.68, w * 0.44, h * 0.1), dark);
      break;

    case SkinShape.bat:
      final wing = _fill(0xFF4A148C);
      c.drawPath(
        Path()
          ..moveTo(w * 0.3, h * 0.35)
          ..lineTo(0, h * 0.15)
          ..lineTo(w * 0.08, h * 0.55)
          ..lineTo(0, h * 0.85)
          ..lineTo(w * 0.32, h * 0.7)
          ..close(),
        wing,
      );
      c.drawPath(
        Path()
          ..moveTo(w * 0.7, h * 0.35)
          ..lineTo(w, h * 0.15)
          ..lineTo(w * 0.92, h * 0.55)
          ..lineTo(w, h * 0.85)
          ..lineTo(w * 0.68, h * 0.7)
          ..close(),
        wing,
      );
      c.drawCircle(Offset(w / 2, h * 0.55), w * 0.3, _fill(0xFF7B1FA2));
      // หู
      c.drawPath(
        Path()
          ..moveTo(w * 0.28, h * 0.4)
          ..lineTo(w * 0.34, h * 0.08)
          ..lineTo(w * 0.46, h * 0.32)
          ..close(),
        _fill(0xFF7B1FA2),
      );
      c.drawPath(
        Path()
          ..moveTo(w * 0.72, h * 0.4)
          ..lineTo(w * 0.66, h * 0.08)
          ..lineTo(w * 0.54, h * 0.32)
          ..close(),
        _fill(0xFF7B1FA2),
      );
      c.drawCircle(Offset(w * 0.4, h * 0.52), w * 0.06, _fill(0xFFFFEB3B));
      c.drawCircle(Offset(w * 0.6, h * 0.52), w * 0.06, _fill(0xFFFFEB3B));
      break;

    case SkinShape.zombie:
      c.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(0, 0, w, h), Radius.circular(w * 0.12)),
        _fill(0xFF7CB342),
      );
      c.drawRect(Rect.fromLTWH(0, 0, w, h * 0.18), _fill(0xFF33691E)); // ผม
      c.drawCircle(Offset(w * 0.3, h * 0.45), w * 0.11, _fill(0xFFFFFFFF));
      c.drawCircle(Offset(w * 0.3, h * 0.45), w * 0.05, _fill(0xFF212121));
      c.drawCircle(Offset(w * 0.7, h * 0.45), w * 0.07, _fill(0xFFFFFFFF));
      c.drawCircle(Offset(w * 0.7, h * 0.45), w * 0.035, _fill(0xFF212121));
      c.drawRect(Rect.fromLTWH(w * 0.25, h * 0.7, w * 0.5, h * 0.07),
          _fill(0xFF1B5E20));
      // รอยเย็บ
      for (var i = 0; i < 4; i++) {
        c.drawRect(
          Rect.fromLTWH(w * (0.3 + i * 0.12), h * 0.66, w * 0.03, h * 0.15),
          _fill(0xFF1B5E20),
        );
      }
      break;
  }
}