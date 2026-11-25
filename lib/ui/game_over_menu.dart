import 'package:flutter/material.dart';
import '../game/gravity_game.dart';
import 'pixel_ui.dart';

class GameOverMenu extends StatelessWidget {
  final GravityGame game;
  const GameOverMenu({super.key, required this.game});

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
                const PixelBanner('GAME OVER'),
                const SizedBox(height: 16),
                Text(
                  '${game.distance.floor()} m',
                  style: pxStyle(size: 30, spacing: 1, shadow: const Color(0xFF000000)),
                ),
                const SizedBox(height: 8),
                // สถิติสูงสุด หรือป้าย NEW BEST
                Text(
                  game.isNewBest ? 'NEW BEST!' : 'BEST: ${game.best.value} m',
                  style: pxStyle(
                    size: 18,
                    color: game.isNewBest ? pxOrange : pxMuted,
                    spacing: 2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'CANDY: ${game.candies}',
                  style: pxStyle(size: 18, color: pxYellow, spacing: 2),
                ),
                const SizedBox(height: 20),
                PixelButton(
                  label: 'PLAY AGAIN',
                  tone: PxTone.red,
                  big: true,
                  arrows: true,
                  onTap: game.startGame,
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