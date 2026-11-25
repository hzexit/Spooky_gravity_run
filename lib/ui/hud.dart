import 'package:flutter/material.dart';
import '../game/audio_manager.dart';
import '../game/gravity_game.dart';

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
          onTap: () {
            AudioManager.instance.play(AudioManager.click);
            game.pauseGame();
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.black38,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white70, width: 2),
            ),
            child: const Icon(Icons.pause, color: Colors.white, size: 26),
          ),
        ),
      ),
    );
  }
}