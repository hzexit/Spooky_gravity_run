import 'package:flutter/material.dart';
import '../game/audio_manager.dart';
import '../game/gravity_game.dart';
import 'pixel_ui.dart';

class Hud extends StatelessWidget {
  final GravityGame game;
  const Hud({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 44, right: 12),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            AudioManager.instance.play(AudioManager.click);
            game.pauseGame();
          },
          child: CustomPaint(
            painter: const PixelPainter(
              fill: Color(0xCC16080E),
              border: pxGoldDark,
              light: Color(0xFF2A1219),
              dark: Color(0xFF0C0407),
              step: 4,
            ),
            child: SizedBox(
              width: 44,
              height: 44,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 6, height: 18, color: Colors.white),
                  const SizedBox(width: 6),
                  Container(width: 6, height: 18, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}