import 'package:flutter/material.dart';
import '../game/audio_manager.dart';

const String kMono = 'monospace';
const Color pxGold = Color(0xFFC9A24B);
const Color pxGoldDark = Color(0xFF7A5A2A);
const Color pxOrange = Color(0xFFF39C2E);
const Color pxYellow = Color(0xFFFFEB3B);
const Color pxRed = Color(0xFFFF4040);
const Color pxMuted = Color(0xFFB89A9A);

TextStyle pxStyle({
  double size = 15,
  Color color = Colors.white,
  double spacing = 2,
  Color? shadow,
}) {
  final o = size >= 24 ? 3.0 : 2.0;
  return TextStyle(
    fontFamily: kMono,
    fontWeight: FontWeight.w900,
    fontSize: size,
    letterSpacing: spacing,
    color: color,
    decoration: TextDecoration.none,
    shadows: shadow == null ? null : [Shadow(offset: Offset(o, o), color: shadow)],
  );
}

/// พื้นหลังมืดโปร่งทับเกม + ให้ Text มี Material ครอบ
class PixelScreen extends StatelessWidget {
  const PixelScreen({super.key, required this.child, this.dim = 0.55});
  final Widget child;
  final double dim;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        color: Color.fromRGBO(0, 0, 0, dim),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

/// กรอบใหญ่ มุมบาก มีเม็ดทองที่มุม
class PixelPanel extends StatelessWidget {
  const PixelPanel({
    super.key,
    required this.child,
    this.width,
    this.padding = const EdgeInsets.fromLTRB(24, 22, 24, 20),
  });
  final Widget child;
  final double? width; // null = ขยายเต็มพื้นที่ที่ให้
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      child: CustomPaint(
        painter: const PixelPainter(
          fill: Color(0xEE16080E),
          border: pxGoldDark,
          light: Color(0xFF2A1219),
          dark: Color(0xFF0C0407),
          stud: pxGold,
          step: 8,
        ),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// ป้ายหัวข้อสีแดง
class PixelBanner extends StatelessWidget {
  const PixelBanner(
    this.text, {
    super.key,
    this.size = 28,
    this.color = pxRed,
  });
  final String text;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const PixelPainter(
        fill: Color(0xFF3A0610),
        border: Color(0xFFB8323A),
        light: Color(0xFF5A0C18),
        dark: Color(0xFF220308),
        step: 4,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        child: Text(
          text,
          style: pxStyle(size: size, color: color, spacing: 2, shadow: const Color(0xFF2A0000)),
        ),
      ),
    );
  }
}

/// การ์ดเล็ก (ช่องสถิติ / การ์ดสกิน)
class PixelCard extends StatelessWidget {
  const PixelCard({
    super.key,
    required this.child,
    this.width,
    this.highlight = false,
  });
  final Widget child;
  final double? width;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: CustomPaint(
        painter: PixelPainter(
          fill: const Color(0xFF22101A),
          border: highlight ? pxGold : const Color(0xFF4A2A33),
          light: const Color(0xFF30171F),
          dark: const Color(0xFF140910),
          step: 4,
        ),
        child: Padding(padding: const EdgeInsets.all(12), child: child),
      ),
    );
  }
}

enum PxTone { grey, red, green, orange }

class PixelButton extends StatefulWidget {
  const PixelButton({
    super.key,
    required this.label,
    required this.onTap, // null = ปุ่มกดไม่ได้
    this.tone = PxTone.grey,
    this.big = false,
    this.compact = false,
    this.arrows = false,
    this.highlight = false,
  });
  final String label;
  final VoidCallback? onTap;
  final PxTone tone;
  final bool big;
  final bool compact;
  final bool arrows;
  final bool highlight;

  @override
  State<PixelButton> createState() => _PixelButtonState();
}

class _PixelButtonState extends State<PixelButton> {
  bool _down = false;

  // [fill, light, dark, border]
  List<Color> _colors() {
    if (widget.onTap == null) {
      return const [Color(0xFF22222A), Color(0xFF30303A), Color(0xFF14141A), Color(0xFF0C0C10)];
    }
    switch (widget.tone) {
      case PxTone.red:
        return const [Color(0xFFC42020), Color(0xFFFF6B5E), Color(0xFF7A0A0A), Color(0xFF3A0000)];
      case PxTone.green:
        return const [Color(0xFF2E8B3A), Color(0xFF6BD67A), Color(0xFF16521E), Color(0xFF082A0E)];
      case PxTone.orange:
        return const [Color(0xFFD9822B), Color(0xFFFFC46B), Color(0xFF8A4A10), Color(0xFF3E1E04)];
      case PxTone.grey:
        return const [Color(0xFF3A3A44), Color(0xFF5C5C68), Color(0xFF22222A), Color(0xFF14141A)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final c = _colors();
    final fill = (_down && enabled) ? Color.lerp(c[0], Colors.black, 0.25)! : c[0];
    final size = widget.big ? 22.0 : (widget.compact ? 12.0 : 15.0);
    final spacing = widget.compact ? 1.0 : 3.0;
    final height = widget.big ? 54.0 : (widget.compact ? 36.0 : 44.0);
    final textColor = enabled ? Colors.white : const Color(0xFF77777F);
    final style = pxStyle(
      size: size,
      color: textColor,
      spacing: spacing,
      shadow: enabled ? const Color(0xAA000000) : null,
    );

    Widget label = Text(widget.label, style: style);
    if (widget.arrows) {
      final a = style.copyWith(color: pxYellow);
      label = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('>', style: a),
          const SizedBox(width: 12),
          Text(widget.label, style: style),
          const SizedBox(width: 12),
          Text('<', style: a),
        ],
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => setState(() => _down = true) : null,
      onTapCancel: enabled ? () => setState(() => _down = false) : null,
      onTapUp: enabled
          ? (_) {
              setState(() => _down = false);
              AudioManager.instance.play(AudioManager.click);
              widget.onTap!();
            }
          : null,
      child: Transform.translate(
        offset: Offset(0, (_down && enabled) ? 3 : 0),
        child: CustomPaint(
          painter: PixelPainter(
            fill: fill,
            border: widget.highlight ? pxGold : c[3],
            light: c[1],
            dark: c[2],
            step: 4,
          ),
          child: Container(
            height: height,
            width: double.infinity,
            alignment: Alignment.center,
            child: label,
          ),
        ),
      ),
    );
  }
}

/// สี่เหลี่ยมมุมบากแบบพิกเซล: ขอบ + พื้น + ขอบสว่างบน/เงาล่าง (+ เม็ดทองที่มุม)
class PixelPainter extends CustomPainter {
  const PixelPainter({
    required this.fill,
    required this.border,
    required this.light,
    required this.dark,
    required this.step,
    this.stud,
  });
  final Color fill, border, light, dark;
  final Color? stud;
  final double step;

  @override
  void paint(Canvas c, Size s) {
    final p = Paint()..isAntiAlias = false;

    void notch(Rect r, Color col) {
      p.color = col;
      c.drawRect(Rect.fromLTRB(r.left + step, r.top, r.right - step, r.bottom), p);
      c.drawRect(Rect.fromLTRB(r.left, r.top + step, r.right, r.bottom - step), p);
    }

    final outer = Offset.zero & s;
    notch(outer, border);
    final inner = outer.deflate(step);
    notch(inner, fill);

    p.color = light;
    c.drawRect(
        Rect.fromLTWH(inner.left + step, inner.top, inner.width - 2 * step, step / 2), p);
    p.color = dark;
    c.drawRect(
        Rect.fromLTWH(inner.left + step, inner.bottom - step / 2, inner.width - 2 * step, step / 2),
        p);

    if (stud != null) {
      p.color = stud!;
      for (final o in [
        Offset.zero,
        Offset(s.width - step, 0),
        Offset(0, s.height - step),
        Offset(s.width - step, s.height - step),
      ]) {
        c.drawRect(Rect.fromLTWH(o.dx, o.dy, step, step), p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant PixelPainter old) =>
      old.fill != fill || old.border != border || old.light != light || old.dark != dark;
}