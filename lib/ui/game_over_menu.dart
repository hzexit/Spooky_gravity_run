import 'package:flutter/material.dart';
import '../game/gravity_game.dart';
import 'menu_button.dart';

class GameOverMenu extends StatelessWidget {
  final GravityGame game;
  const GameOverMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'GAME OVER',
                  style: TextStyle(
                    color: Color(0xFFE53935),
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    decoration: TextDecoration.none,
                    shadows: [Shadow(color: Color(0xFFE53935), blurRadius: 16)],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${game.distance.floor()} m',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 4),
                // สถิติสูงสุด หรือป้าย NEW BEST
                Text(
                  game.isNewBest
                      ? 'NEW BEST!'
                      : 'BEST: ${game.best.value} m',
                  style: TextStyle(
                    color: game.isNewBest
                        ? const Color(0xFFFF9800)
                        : Colors.white70,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Candy: ${game.candies}',
                  style: const TextStyle(
                    color: Color(0xFFFFEB3B),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 24),
                MenuButton(
                  label: 'PLAY AGAIN',
                  selected: true,
                  onTap: game.startGame,
                ),
                const SizedBox(height: 14),
                MenuButton(
                  label: 'MENU',
                  onTap: game.backToMenu,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}