import 'package:flutter/material.dart';
import '../game/gravity_game.dart';
import 'menu_button.dart';

class PauseMenu extends StatelessWidget {
  final GravityGame game;
  const PauseMenu({super.key, required this.game});

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
                  'PAUSED',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 6,
                    decoration: TextDecoration.none,
                    shadows: [Shadow(color: Color(0xFFFF9800), blurRadius: 16)],
                  ),
                ),
                const SizedBox(height: 24),
                MenuButton(
                  label: 'RESUME',
                  selected: true,
                  onTap: game.resumeGame,
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