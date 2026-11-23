import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'game/gravity_game.dart';
import 'ui/main_menu.dart';
import 'ui/game_over_menu.dart';
import 'ui/stats_menu.dart'; // จุดที่ 1: import นี้ต้องมี

void main() {
  final game = GravityGame();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: GameWidget<GravityGame>(
          game: game,
          initialActiveOverlays: const ['menu'],
          overlayBuilderMap: {
            'menu': (context, g) => MainMenu(game: g),
            'gameOver': (context, g) => GameOverMenu(game: g),
            'stats': (context, g) => StatsMenu(game: g), // จุดที่ 2: บรรทัดนี้ต้องมี
          },
        ),
      ),
    ),
  );
}