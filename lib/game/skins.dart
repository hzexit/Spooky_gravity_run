import 'dart:math';
import 'dart:ui';

enum SkinShape {
  classic,
  ghost,
  pumpkin,
  bat,
  zombie,
  witch,
  mummy,
  dracula,
  skeleton,
  werewolf,
  frankenstein,
  blackCat,
  jackOLantern,
  jester,
}

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
  SkinDef('blackcat', 'Black Cat', 130, SkinShape.blackCat),
  SkinDef('witch', 'Witch', 150, SkinShape.witch),
  SkinDef('mummy', 'Mummy', 180, SkinShape.mummy),
  SkinDef('jacko', 'Jack-o-Lantern', 200, SkinShape.jackOLantern),
  SkinDef('dracula', 'Dracula', 220, SkinShape.dracula),
  SkinDef('skeleton', 'Skeleton', 260, SkinShape.skeleton),
  SkinDef('werewolf', 'Werewolf', 300, SkinShape.werewolf),
  SkinDef('frankenstein', 'Frankenstein', 350, SkinShape.frankenstein),
  SkinDef('jester', 'Jester', 400, SkinShape.jester),
];

SkinDef skinById(String id) =>
    skins.firstWhere((s) => s.id == id, orElse: () => skins.first);

Paint _fill(int argb) => Paint()..color = Color(argb);

Paint _stroke(int argb, double width) => Paint()
  ..color = Color(argb)
  ..style = PaintingStyle.stroke
  ..strokeWidth = width
  ..strokeCap = StrokeCap.round;

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

    // ---------------- แม่มด ----------------
    case SkinShape.witch:
      c.drawRect(Rect.fromLTWH(w * 0.1, h * 0.36, w * 0.8, h * 0.64),
          _fill(0xFF8BC34A));
      c.drawRect(Rect.fromLTWH(w * 0.04, h * 0.42, w * 0.12, h * 0.4),
          _fill(0xFFE65100));
      c.drawRect(Rect.fromLTWH(w * 0.84, h * 0.42, w * 0.12, h * 0.4),
          _fill(0xFFE65100));
      c.drawPath(
        Path()
          ..moveTo(w * 0.26, h * 0.34)
          ..lineTo(w * 0.52, 0)
          ..lineTo(w * 0.74, h * 0.34)
          ..close(),
        _fill(0xFF4A148C),
      );
      c.drawRect(Rect.fromLTWH(w * 0.02, h * 0.3, w * 0.96, h * 0.1),
          _fill(0xFF311B92));
      c.drawRect(Rect.fromLTWH(w * 0.28, h * 0.24, w * 0.44, h * 0.07),
          _fill(0xFFFF9800));
      c.drawCircle(Offset(w * 0.34, h * 0.55), w * 0.09, _fill(0xFFFFFFFF));
      c.drawCircle(Offset(w * 0.66, h * 0.55), w * 0.09, _fill(0xFFFFFFFF));
      c.drawCircle(Offset(w * 0.36, h * 0.56), w * 0.045, _fill(0xFF212121));
      c.drawCircle(Offset(w * 0.68, h * 0.56), w * 0.045, _fill(0xFF212121));
      c.drawPath(
        Path()
          ..moveTo(w * 0.47, h * 0.58)
          ..lineTo(w * 0.53, h * 0.58)
          ..lineTo(w * 0.5, h * 0.76)
          ..close(),
        _fill(0xFF558B2F),
      );
      c.drawRect(Rect.fromLTWH(w * 0.34, h * 0.84, w * 0.32, h * 0.05),
          _fill(0xFF33691E));
      break;

    // ---------------- มัมมี่ ----------------
    case SkinShape.mummy:
      c.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(0, 0, w, h), Radius.circular(w * 0.1)),
        _fill(0xFFE8DDBF),
      );
      final band = _fill(0xFFB9AB82);
      for (var i = 0; i < 6; i++) {
        c.drawRect(Rect.fromLTWH(0, h * (0.08 + i * 0.16), w, h * 0.05), band);
      }
      c.drawRect(Rect.fromLTWH(w * 0.12, h * 0.06, w * 0.04, h * 0.88),
          _fill(0xFFD2C6A0));
      c.drawRect(Rect.fromLTWH(w * 0.1, h * 0.32, w * 0.8, h * 0.24),
          _fill(0xFF1E1E1E));
      c.drawCircle(Offset(w * 0.32, h * 0.44), w * 0.08, _fill(0xFFFFFFFF));
      c.drawCircle(Offset(w * 0.68, h * 0.44), w * 0.08, _fill(0xFFFFFFFF));
      c.drawCircle(Offset(w * 0.34, h * 0.44), w * 0.04, _fill(0xFFE53935));
      c.drawCircle(Offset(w * 0.70, h * 0.44), w * 0.04, _fill(0xFFE53935));
      break;

    // ---------------- แดร็กคูล่า ----------------
    case SkinShape.dracula:
      c.drawPath(
        Path()
          ..moveTo(0, h * 0.4)
          ..lineTo(w * 0.22, h * 0.4)
          ..lineTo(w * 0.22, h)
          ..lineTo(0, h)
          ..close(),
        _fill(0xFFB71C1C),
      );
      c.drawPath(
        Path()
          ..moveTo(w, h * 0.4)
          ..lineTo(w * 0.78, h * 0.4)
          ..lineTo(w * 0.78, h)
          ..lineTo(w, h)
          ..close(),
        _fill(0xFFB71C1C),
      );
      c.drawRect(Rect.fromLTWH(w * 0.16, h * 0.12, w * 0.68, h * 0.88),
          _fill(0xFFE9DCCB));
      c.drawPath(
        Path()
          ..moveTo(w * 0.12, h * 0.34)
          ..lineTo(w * 0.12, h * 0.1)
          ..lineTo(w * 0.88, h * 0.1)
          ..lineTo(w * 0.88, h * 0.34)
          ..lineTo(w * 0.62, h * 0.2)
          ..lineTo(w * 0.5, h * 0.36)
          ..lineTo(w * 0.38, h * 0.2)
          ..close(),
        _fill(0xFF1A1A1A),
      );
      c.drawCircle(Offset(w * 0.36, h * 0.5), w * 0.07, _fill(0xFFFFFFFF));
      c.drawCircle(Offset(w * 0.64, h * 0.5), w * 0.07, _fill(0xFFFFFFFF));
      c.drawCircle(Offset(w * 0.36, h * 0.5), w * 0.04, _fill(0xFFD50000));
      c.drawCircle(Offset(w * 0.64, h * 0.5), w * 0.04, _fill(0xFFD50000));
      c.drawRect(Rect.fromLTWH(w * 0.32, h * 0.7, w * 0.36, h * 0.07),
          _fill(0xFF4E0D0D));
      c.drawPath(
        Path()
          ..moveTo(w * 0.35, h * 0.77)
          ..lineTo(w * 0.43, h * 0.77)
          ..lineTo(w * 0.39, h * 0.9)
          ..close(),
        _fill(0xFFFFFFFF),
      );
      c.drawPath(
        Path()
          ..moveTo(w * 0.57, h * 0.77)
          ..lineTo(w * 0.65, h * 0.77)
          ..lineTo(w * 0.61, h * 0.9)
          ..close(),
        _fill(0xFFFFFFFF),
      );
      break;

    // ---------------- โครงกระดูก ----------------
    case SkinShape.skeleton:
      c.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.04, 0, w * 0.92, h * 0.74),
            Radius.circular(w * 0.35)),
        _fill(0xFFF3F1E8),
      );
      c.drawRect(Rect.fromLTWH(w * 0.2, h * 0.68, w * 0.6, h * 0.32),
          _fill(0xFFE4E1D4));
      c.drawOval(Rect.fromLTWH(w * 0.14, h * 0.28, w * 0.28, h * 0.26),
          _fill(0xFF1A1A1A));
      c.drawOval(Rect.fromLTWH(w * 0.58, h * 0.28, w * 0.28, h * 0.26),
          _fill(0xFF1A1A1A));
      c.drawCircle(Offset(w * 0.28, h * 0.42), w * 0.035, _fill(0xFFFF5252));
      c.drawCircle(Offset(w * 0.72, h * 0.42), w * 0.035, _fill(0xFFFF5252));
      c.drawPath(
        Path()
          ..moveTo(w * 0.5, h * 0.55)
          ..lineTo(w * 0.43, h * 0.7)
          ..lineTo(w * 0.57, h * 0.7)
          ..close(),
        _fill(0xFF1A1A1A),
      );
      final tooth = _fill(0xFF2B2B2B);
      for (var i = 0; i < 5; i++) {
        c.drawRect(
          Rect.fromLTWH(w * (0.28 + i * 0.1), h * 0.82, w * 0.025, h * 0.16),
          tooth,
        );
      }
      c.drawRect(Rect.fromLTWH(w * 0.26, h * 0.82, w * 0.48, h * 0.025), tooth);
      break;

    // ---------------- หมาป่า ----------------
    case SkinShape.werewolf:
      c.drawPath(
        Path()
          ..moveTo(w * 0.08, h * 0.38)
          ..lineTo(w * 0.14, 0)
          ..lineTo(w * 0.4, h * 0.2)
          ..close(),
        _fill(0xFF5D5D5D),
      );
      c.drawPath(
        Path()
          ..moveTo(w * 0.92, h * 0.38)
          ..lineTo(w * 0.86, 0)
          ..lineTo(w * 0.6, h * 0.2)
          ..close(),
        _fill(0xFF5D5D5D),
      );
      c.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(0, h * 0.14, w, h * 0.86), Radius.circular(w * 0.22)),
        _fill(0xFF7E7E7E),
      );
      c.drawOval(Rect.fromLTWH(w * 0.22, h * 0.52, w * 0.56, h * 0.42),
          _fill(0xFFB0AEAE));
      c.drawOval(Rect.fromLTWH(w * 0.4, h * 0.54, w * 0.2, h * 0.12),
          _fill(0xFF1A1A1A));
      c.drawCircle(Offset(w * 0.3, h * 0.42), w * 0.08, _fill(0xFFFFEB3B));
      c.drawCircle(Offset(w * 0.7, h * 0.42), w * 0.08, _fill(0xFFFFEB3B));
      c.drawRect(Rect.fromLTWH(w * 0.28, h * 0.4, w * 0.04, h * 0.1),
          _fill(0xFF1A1A1A));
      c.drawRect(Rect.fromLTWH(w * 0.68, h * 0.4, w * 0.04, h * 0.1),
          _fill(0xFF1A1A1A));
      c.drawPath(
        Path()
          ..moveTo(w * 0.33, h * 0.8)
          ..lineTo(w * 0.41, h * 0.8)
          ..lineTo(w * 0.37, h * 0.92)
          ..close(),
        _fill(0xFFFFFFFF),
      );
      c.drawPath(
        Path()
          ..moveTo(w * 0.59, h * 0.8)
          ..lineTo(w * 0.67, h * 0.8)
          ..lineTo(w * 0.63, h * 0.92)
          ..close(),
        _fill(0xFFFFFFFF),
      );
      break;

    // ---------------- แฟรงเกนสไตน์ ----------------
    case SkinShape.frankenstein:
      c.drawRect(Rect.fromLTWH(w * 0.1, 0, w * 0.8, h), _fill(0xFF9CCC65));
      c.drawRect(
          Rect.fromLTWH(w * 0.1, 0, w * 0.8, h * 0.22), _fill(0xFF1F1F1F));
      c.drawRect(Rect.fromLTWH(w * 0.3, h * 0.26, w * 0.4, h * 0.03),
          _fill(0xFF33691E));
      for (var i = 0; i < 4; i++) {
        c.drawRect(
          Rect.fromLTWH(w * (0.34 + i * 0.1), h * 0.23, w * 0.025, h * 0.09),
          _fill(0xFF33691E),
        );
      }
      c.drawRect(
          Rect.fromLTWH(0, h * 0.58, w * 0.12, h * 0.1), _fill(0xFF90A4AE));
      c.drawRect(
          Rect.fromLTWH(0, h * 0.54, w * 0.05, h * 0.18), _fill(0xFF607D8B));
      c.drawRect(
          Rect.fromLTWH(w * 0.88, h * 0.58, w * 0.12, h * 0.1),
          _fill(0xFF90A4AE));
      c.drawRect(
          Rect.fromLTWH(w * 0.95, h * 0.54, w * 0.05, h * 0.18),
          _fill(0xFF607D8B));
      c.drawCircle(Offset(w * 0.34, h * 0.46), w * 0.08, _fill(0xFFFFFFFF));
      c.drawCircle(Offset(w * 0.66, h * 0.46), w * 0.08, _fill(0xFFFFFFFF));
      c.drawCircle(Offset(w * 0.34, h * 0.48), w * 0.04, _fill(0xFF212121));
      c.drawCircle(Offset(w * 0.66, h * 0.48), w * 0.04, _fill(0xFF212121));
      c.drawRect(Rect.fromLTWH(w * 0.24, h * 0.34, w * 0.2, h * 0.08),
          _fill(0xFF7CB342));
      c.drawRect(Rect.fromLTWH(w * 0.56, h * 0.34, w * 0.2, h * 0.08),
          _fill(0xFF7CB342));
      c.drawRect(Rect.fromLTWH(w * 0.3, h * 0.76, w * 0.4, h * 0.04),
          _fill(0xFF33691E));
      for (var i = 0; i < 4; i++) {
        c.drawRect(
          Rect.fromLTWH(w * (0.33 + i * 0.1), h * 0.72, w * 0.025, h * 0.12),
          _fill(0xFF33691E),
        );
      }
      break;

    // ---------------- แมวดำ ----------------
    case SkinShape.blackCat:
      // หูสองข้าง + ด้านในสีชมพู
      c.drawPath(
        Path()
          ..moveTo(w * 0.06, h * 0.42)
          ..lineTo(w * 0.13, 0)
          ..lineTo(w * 0.42, h * 0.2)
          ..close(),
        _fill(0xFF22222B),
      );
      c.drawPath(
        Path()
          ..moveTo(w * 0.14, h * 0.32)
          ..lineTo(w * 0.17, h * 0.1)
          ..lineTo(w * 0.32, h * 0.22)
          ..close(),
        _fill(0xFF8D4A5E),
      );
      c.drawPath(
        Path()
          ..moveTo(w * 0.94, h * 0.42)
          ..lineTo(w * 0.87, 0)
          ..lineTo(w * 0.58, h * 0.2)
          ..close(),
        _fill(0xFF22222B),
      );
      c.drawPath(
        Path()
          ..moveTo(w * 0.86, h * 0.32)
          ..lineTo(w * 0.83, h * 0.1)
          ..lineTo(w * 0.68, h * 0.22)
          ..close(),
        _fill(0xFF8D4A5E),
      );
      // หัว
      c.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(0, h * 0.14, w, h * 0.86), Radius.circular(w * 0.3)),
        _fill(0xFF22222B),
      );
      // ตาเขียวเหลือง รูม่านตาเป็นเส้นตั้ง
      c.drawOval(Rect.fromLTWH(w * 0.17, h * 0.4, w * 0.24, h * 0.24),
          _fill(0xFFC6FF00));
      c.drawOval(Rect.fromLTWH(w * 0.59, h * 0.4, w * 0.24, h * 0.24),
          _fill(0xFFC6FF00));
      c.drawRect(Rect.fromLTWH(w * 0.285, h * 0.42, w * 0.035, h * 0.2),
          _fill(0xFF111111));
      c.drawRect(Rect.fromLTWH(w * 0.705, h * 0.42, w * 0.035, h * 0.2),
          _fill(0xFF111111));
      // จมูก
      c.drawPath(
        Path()
          ..moveTo(w * 0.44, h * 0.68)
          ..lineTo(w * 0.56, h * 0.68)
          ..lineTo(w * 0.5, h * 0.76)
          ..close(),
        _fill(0xFFFF8A80),
      );
      // ปากรูปตัว w เล็กๆ
      final mouth = _stroke(0xFF8D8D99, 1.4);
      c.drawLine(Offset(w * 0.5, h * 0.76), Offset(w * 0.5, h * 0.82), mouth);
      c.drawLine(Offset(w * 0.5, h * 0.82), Offset(w * 0.42, h * 0.86), mouth);
      c.drawLine(Offset(w * 0.5, h * 0.82), Offset(w * 0.58, h * 0.86), mouth);
      // หนวด
      final whisker = _stroke(0xFFB0B0BC, 1.2);
      c.drawLine(Offset(0, h * 0.7), Offset(w * 0.3, h * 0.74), whisker);
      c.drawLine(Offset(0, h * 0.82), Offset(w * 0.3, h * 0.79), whisker);
      c.drawLine(Offset(w, h * 0.7), Offset(w * 0.7, h * 0.74), whisker);
      c.drawLine(Offset(w, h * 0.82), Offset(w * 0.7, h * 0.79), whisker);
      break;

    // ---------------- แจ็กโอแลนเทิร์น ----------------
    case SkinShape.jackOLantern:
      // ก้านสีเขียว
      c.drawRect(Rect.fromLTWH(w * 0.42, 0, w * 0.16, h * 0.18),
          _fill(0xFF33691E));
      c.drawRect(Rect.fromLTWH(w * 0.5, 0, w * 0.2, h * 0.08),
          _fill(0xFF558B2F));
      // ลำตัวสีส้มเข้ม + รอยเส้นฟักทอง
      c.drawOval(Rect.fromLTWH(0, h * 0.1, w, h * 0.9), _fill(0xFFE65100));
      final rib = _stroke(0xFFBF360C, 2);
      c.drawOval(Rect.fromLTWH(w * 0.2, h * 0.1, w * 0.6, h * 0.9), rib);
      c.drawOval(Rect.fromLTWH(w * 0.38, h * 0.1, w * 0.24, h * 0.9), rib);
      // แสงเทียนในฟักทอง
      c.drawCircle(Offset(w * 0.5, h * 0.6), w * 0.34, _fill(0x33FFEB3B));
      // ตาสามเหลี่ยมเรืองแสง
      final glow = _fill(0xFFFFEE58);
      c.drawPath(
        Path()
          ..moveTo(w * 0.2, h * 0.52)
          ..lineTo(w * 0.42, h * 0.52)
          ..lineTo(w * 0.31, h * 0.3)
          ..close(),
        glow,
      );
      c.drawPath(
        Path()
          ..moveTo(w * 0.58, h * 0.52)
          ..lineTo(w * 0.8, h * 0.52)
          ..lineTo(w * 0.69, h * 0.3)
          ..close(),
        glow,
      );
      // ปากยิ้มฟันเฟือง
      c.drawPath(
        Path()
          ..moveTo(w * 0.2, h * 0.6)
          ..lineTo(w * 0.35, h * 0.7)
          ..lineTo(w * 0.43, h * 0.6)
          ..lineTo(w * 0.5, h * 0.72)
          ..lineTo(w * 0.57, h * 0.6)
          ..lineTo(w * 0.65, h * 0.7)
          ..lineTo(w * 0.8, h * 0.6)
          ..lineTo(w * 0.72, h * 0.84)
          ..lineTo(w * 0.28, h * 0.84)
          ..close(),
        glow,
      );
      break;

    // ---------------- Jester (ตัวตลกต้นฉบับ) ----------------
    case SkinShape.jester:
      // หน้า
      c.drawRect(Rect.fromLTWH(w * 0.12, h * 0.34, w * 0.76, h * 0.66),
          _fill(0xFFF6E7D0));
      // หมวกสองแฉก เขียวอมฟ้า กับ ทอง
      c.drawPath(
        Path()
          ..moveTo(w * 0.1, h * 0.4)
          ..lineTo(w * 0.02, h * 0.07)
          ..lineTo(w * 0.5, h * 0.3)
          ..lineTo(w * 0.5, h * 0.4)
          ..close(),
        _fill(0xFF00897B),
      );
      c.drawPath(
        Path()
          ..moveTo(w * 0.9, h * 0.4)
          ..lineTo(w * 0.98, h * 0.07)
          ..lineTo(w * 0.5, h * 0.3)
          ..lineTo(w * 0.5, h * 0.4)
          ..close(),
        _fill(0xFFFFB300),
      );
      // แถบหมวก
      c.drawRect(Rect.fromLTWH(w * 0.08, h * 0.36, w * 0.84, h * 0.08),
          _fill(0xFF263238));
      // กระดิ่ง
      c.drawCircle(Offset(w * 0.04, h * 0.08), w * 0.06, _fill(0xFFFFE082));
      c.drawCircle(Offset(w * 0.96, h * 0.08), w * 0.06, _fill(0xFFFFE082));
      // ตา
      c.drawCircle(Offset(w * 0.36, h * 0.58), w * 0.06, _fill(0xFF263238));
      c.drawCircle(Offset(w * 0.64, h * 0.58), w * 0.06, _fill(0xFF263238));
      // ลายข้าวหลามตัดใต้ตา
      c.drawPath(
        Path()
          ..moveTo(w * 0.28, h * 0.68)
          ..lineTo(w * 0.32, h * 0.75)
          ..lineTo(w * 0.28, h * 0.82)
          ..lineTo(w * 0.24, h * 0.75)
          ..close(),
        _fill(0xFF00897B),
      );
      c.drawPath(
        Path()
          ..moveTo(w * 0.72, h * 0.68)
          ..lineTo(w * 0.76, h * 0.75)
          ..lineTo(w * 0.72, h * 0.82)
          ..lineTo(w * 0.68, h * 0.75)
          ..close(),
        _fill(0xFFFFB300),
      );
      // ยิ้ม
      c.drawArc(
        Rect.fromCenter(
            center: Offset(w * 0.5, h * 0.72), width: w * 0.36, height: h * 0.22),
        0.3,
        pi - 0.6,
        false,
        _stroke(0xFF8E2430, 2.2),
      );
      break;
  }
}