import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../game/gravity_game.dart';
import 'menu_button.dart';

class MainMenu extends StatelessWidget {
  final GravityGame game;
  const MainMenu({super.key, required this.game});

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coming soon!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Widget _logo() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'SPOOKY',
          style: TextStyle(
            color: Color(0xFFFF9800),
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: 14,
            decoration: TextDecoration.none,
          ),
        ),
        Text(
          'GRAVITY RUN',
          style: TextStyle(
            color: Colors.white,
            fontSize: 52,
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
            decoration: TextDecoration.none,
            shadows: [Shadow(color: Color(0xFFFF9800), blurRadius: 18)],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(painter: _SpookyBackgroundPainter()),
        ),
        Positioned.fill(
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _logo(),
                    const SizedBox(height: 14),
                    ValueListenableBuilder<int>(
                      valueListenable: game.best,
                      builder: (context, value, _) => Text(
                        'BEST: $value m',
                        style: const TextStyle(
                          color: Color(0xFFFFEB3B),
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    MenuButton(
                      label: 'PLAY',
                      selected: true,
                      onTap: game.startGame,
                    ),
                    const SizedBox(height: 14),
                    MenuButton(
                      label: 'SHOP',
                      onTap: game.showShop,
                    ),
                    const SizedBox(height: 14),
                    MenuButton(
                      label: 'STATS',
                      onTap: game.showStats,
                    ),
                    const SizedBox(height: 14),
                    MenuButton(
                      label: 'SETTINGS',
                      onTap: game.showSettings,
                    ),
                    const SizedBox(height: 14),
                    MenuButton(
                      label: 'QUIT',
                      onTap: () => SystemNavigator.pop(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const Positioned(
          right: 16,
          bottom: 10,
          child: Text(
            'v1.0.0',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _SpookyBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final sky = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0B1B26), Color(0xFF1B3A4B), Color(0xFF3D1A3A)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), sky);

    final moonCenter = Offset(w * 0.82, h * 0.22);
    final moonR = (w < h ? w : h) * 0.09;
    canvas.drawCircle(
      moonCenter,
      moonR * 1.8,
      Paint()
        ..color = const Color(0x44FFF3C4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40),
    );
    canvas.drawCircle(
        moonCenter, moonR, Paint()..color = const Color(0xFFFFF3C4));

    final hills = Path()
      ..moveTo(0, h)
      ..lineTo(0, h * 0.86)
      ..quadraticBezierTo(w * 0.25, h * 0.76, w * 0.5, h * 0.86)
      ..quadraticBezierTo(w * 0.75, h * 0.96, w, h * 0.84)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(hills, Paint()..color = const Color(0xFF140A1F));

    final spike = Paint()..color = const Color(0xFF0A0510);
    const step = 44.0;
    for (double x = 0; x < w; x += step) {
      final p = Path()
        ..moveTo(x, h)
        ..lineTo(x + step / 2, h - 34)
        ..lineTo(x + step, h)
        ..close();
      canvas.drawPath(p, spike);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}