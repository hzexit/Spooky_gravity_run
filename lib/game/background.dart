import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'gravity_game.dart';

/// พื้นหลังพิกเซลอาร์ตธีมฮาโลวีน วาดด้วยโค้ดล้วน ไม่ใช้รูป
/// ใช้ชื่อคลาสเดิม ScrollingLines เพื่อไม่ต้องแก้ gravity_game.dart
class ScrollingLines extends Component {
  ScrollingLines() : super(priority: -100);

  double _w = 0, _h = 0, _ps = 4, _tileW = 1;
  Picture? _sky, _far, _mid, _fog;
  double _offFar = 0, _offMid = 0, _offFog = 0;
  late Random _rnd;

  @override
  void update(double dt) {
    final g = findGame();
    var speed = 40.0; // หน้าเมนู: เลื่อนช้าๆ
    if (g is GravityGame && g.isPlaying) speed = g.scrollSpeed;
    _offFar += speed * 0.08 * dt;
    _offMid += speed * 0.25 * dt;
    _offFog += speed * 0.5 * dt;
  }

  @override
  void render(Canvas canvas) {
    final g = findGame();
    if (g is! FlameGame) return;
    if (g.size.x != _w || g.size.y != _h) _build(g.size.x, g.size.y);
    if (_sky == null) return;
    canvas.drawPicture(_sky!);
    _tile(canvas, _far!, _offFar);
    _tile(canvas, _mid!, _offMid);
    _tile(canvas, _fog!, _offFog);
  }

  void _tile(Canvas c, Picture pic, double off) {
    final o = ((off % _tileW) / _ps).floor() * _ps; // snap ให้เลื่อนทีละพิกเซล
    c.save();
    c.translate(-o, 0);
    c.drawPicture(pic);
    c.translate(_tileW, 0);
    c.drawPicture(pic);
    c.restore();
  }

  Picture _record(void Function(_Pen) draw) {
    final rec = PictureRecorder();
    draw(_Pen(Canvas(rec), _ps));
    return rec.endRecording();
  }

  void _build(double w, double h) {
    _w = w;
    _h = h;
    _ps = (h / 90).floorToDouble().clamp(3.0, 8.0);
    final cols = (w / _ps).ceil() + 1;
    final rows = (h / _ps).ceil() + 1;
    _tileW = cols * _ps;
    final ground = (rows * 0.82).round();

    // ---------- ฟ้า + พระจันทร์เลือด + พื้น (ไม่เลื่อน) ----------
    _rnd = Random(7);
    _sky = _record((p) {
      const top = Color(0xFF0B0208);
      const hor = Color(0xFF5A0F22);
      const bands = 12;
      for (var i = 0; i < bands; i++) {
        final y0 = (ground * i / bands).floor();
        final y1 = (ground * (i + 1) / bands).floor();
        final t = pow(i / (bands - 1), 1.4).toDouble();
        p.rect(0, y0, cols, y1 - y0 + 1, Color.lerp(top, hor, t)!);
      }
      // ดาว
      for (var i = 0; i < 45; i++) {
        final x = _rnd.nextInt(cols);
        final y = _rnd.nextInt((ground * 0.55).round());
        p.cell(x, y,
            _rnd.nextBool() ? const Color(0xFFFFC9C9) : const Color(0xFFFF8A8A));
      }
      // พระจันทร์
      final cx = (cols * 0.72).round();
      final cy = (rows * 0.28).round();
      final r = (rows * 0.14).round().clamp(8, 16);
      p.disc(cx, cy, r + 6, const Color(0x1AFF1A1A));
      p.disc(cx, cy, r + 3, const Color(0x33FF1A1A));
      p.disc(cx, cy, r, const Color(0xFFC62828));
      p.disc(cx - 2, cy - 2, r - 3, const Color(0xFFE23B3B));
      p.disc(cx + r ~/ 3, cy + r ~/ 4, 3, const Color(0xFF9E1A1A));
      p.disc(cx - r ~/ 2, cy + r ~/ 3, 2, const Color(0xFF9E1A1A));
      p.disc(cx + r ~/ 5, cy - r ~/ 2, 2, const Color(0xFF9E1A1A));
      // เมฆบังพระจันทร์
      for (var i = 0; i < 5; i++) {
        final x = _rnd.nextInt(cols);
        final y = 4 + _rnd.nextInt((ground * 0.45).round());
        final cw = 30 + _rnd.nextInt(30);
        const c = Color(0x662A0510);
        p.rect(x, y, cw, 2, c);
        p.rect(x + 4, y - 1, cw - 10, 1, c);
        p.rect(x + 8, y + 2, cw - 16, 1, c);
      }
      // พื้น
      p.rect(0, ground, cols, rows - ground + 1, const Color(0xFF12040A));
      p.rect(0, ground, cols, 1, const Color(0xFF2A0A14));
      for (var x = 0; x < cols; x += 2) {
        if (_rnd.nextInt(3) == 0) {
          p.rect(x, ground - 1 - _rnd.nextInt(2), 1, 2, const Color(0xFF1C0710));
        }
      }
    });

    // ---------- ต้นไม้แห้ง (ไกล เลื่อนช้า) ----------
    _rnd = Random(21);
    _far = _record((p) {
      final n = cols ~/ 26;
      for (var s = 0; s < n; s++) {
        final x = s * 26 + 8 + _rnd.nextInt(10);
        final th = (rows * (0.22 + 0.2 * _rnd.nextDouble())).round();
        _tree(p, x, ground + 1, th, const Color(0xFF1B0610));
      }
    });

    // ---------- หลุมศพ + ฟักทอง (ใกล้ขึ้น) ----------
    _rnd = Random(33);
    _mid = _record((p) {
      final n = cols ~/ 16;
      for (var s = 0; s < n; s++) {
        final x = s * 16 + 3 + _rnd.nextInt(6);
        final base = ground + 4 + _rnd.nextInt(4);
        final k = _rnd.nextInt(5);
        if (k == 0) {
          _pumpkin(p, x, base);
        } else if (k == 1) {
          _grave(p, x, base, cross: true);
        } else if (k == 2) {
          _grave(p, x, base, h: 7);
        } else if (k == 3) {
          _grave(p, x, base, h: 9);
        }
      }
    });

    // ---------- หมอก ----------
    _rnd = Random(55);
    _fog = _record((p) {
      for (var i = 0; i < 10; i++) {
        final x = _rnd.nextInt(cols);
        final y = ground - 3 + _rnd.nextInt(5);
        final fw = 18 + _rnd.nextInt(26);
        p.rect(x, y, fw, 2, const Color(0x26FFB4B4));
        p.rect(x + 3, y - 1, fw - 6, 1, const Color(0x1AFFB4B4));
      }
    });
  }

  void _tree(_Pen p, int x, int base, int h, Color c) {
    p.rect(x, base - h, 2, h, c);
    p.rect(x - 1, base - 3, 4, 3, c); // โคนต้น
    for (var k = 0; k < 4; k++) {
      final y = base - (h * (0.35 + 0.15 * k)).round();
      final dir = k.isEven ? -1 : 1;
      final len = 5 + _rnd.nextInt(5) - k;
      final bx0 = dir > 0 ? x + 2 : x - 1;
      for (var i = 0; i < len; i++) {
        p.cell(bx0 + dir * i, y - i ~/ 2, c);
        p.cell(bx0 + dir * i, y - i ~/ 2 + 1, c);
      }
      final fx = bx0 + dir * (len ~/ 2);
      for (var j = 1; j <= 3; j++) {
        p.cell(fx, y - len ~/ 4 - j, c);
      }
    }
    p.rect(x, base - h - 3, 1, 3, c); // ยอด
  }

  void _grave(_Pen p, int x, int base, {bool cross = false, int h = 8}) {
    const c = Color(0xFF2A0C16);
    const hi = Color(0xFF3E1624);
    if (cross) {
      p.rect(x + 2, base - 11, 2, 11, c);
      p.rect(x, base - 8, 6, 2, c);
      p.rect(x + 2, base - 11, 1, 11, hi);
    } else {
      p.rect(x, base - h + 1, 7, h - 1, c);
      p.rect(x + 1, base - h, 5, 1, c);
      p.rect(x + 1, base - h + 1, 1, h - 2, hi);
      p.rect(x + 3, base - h + 3, 1, 2, const Color(0xFF14050B)); // รอยแตก
    }
  }

  void _pumpkin(_Pen p, int x, int base) {
    const body = Color(0xFF8A3508);
    const dark = Color(0xFF5E2306);
    const glow = Color(0xFFFFB300);
    p.rect(x, base - 4, 8, 4, body);
    p.rect(x + 1, base - 5, 6, 1, body);
    p.rect(x + 1, base, 6, 1, dark);
    p.rect(x + 3, base - 4, 1, 4, dark);
    p.rect(x + 3, base - 7, 2, 2, const Color(0xFF2E3A12)); // ก้าน
    p.cell(x + 1, base - 4, glow); // ตา
    p.cell(x + 6, base - 4, glow);
    p.rect(x + 2, base - 2, 4, 1, glow); // ปาก
  }
}

class _Pen {
  _Pen(this.c, this.ps);
  final Canvas c;
  final double ps;
  final Paint _p = Paint()..isAntiAlias = false;

  void rect(int x, int y, int w, int h, Color col) {
    _p.color = col;
    c.drawRect(Rect.fromLTWH(x * ps, y * ps, w * ps, h * ps), _p);
  }

  void cell(int x, int y, Color col) => rect(x, y, 1, 1, col);

  void disc(int cx, int cy, int r, Color col) {
    for (var dy = -r; dy <= r; dy++) {
      final dx = sqrt(r * r - dy * dy).floor();
      rect(cx - dx, cy + dy, 2 * dx + 1, 1, col);
    }
  }
}