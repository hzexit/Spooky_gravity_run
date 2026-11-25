import 'package:flutter/material.dart';
import '../game/gravity_game.dart';
import 'pixel_ui.dart';

class PauseMenu extends StatelessWidget {
  final GravityGame game;
  const PauseMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return PixelScreen(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: PixelPanel(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const PixelBanner('PAUSED', color: Colors.white),
                const SizedBox(height: 22),
                PixelButton(
                  label: 'RESUME',
                  tone: PxTone.red,
                  big: true,
                  arrows: true,
                  onTap: game.resumeGame,
                ),
                const SizedBox(height: 12),
                PixelButton(label: 'MENU', onTap: game.backToMenu),
              ],
            ),
          ),
        ),
      ),
    );
  }
}