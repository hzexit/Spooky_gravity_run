import 'package:flutter/material.dart';
import '../game/audio_manager.dart';
import '../game/gravity_game.dart';
import 'menu_button.dart';

class SettingsMenu extends StatelessWidget {
  final GravityGame game;
  const SettingsMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final audio = AudioManager.instance;
    return Material(
      color: const Color(0xF20B1B26),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'SETTINGS',
                  style: TextStyle(
                    color: Color(0xFFFF9800),
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 5,
                  ),
                ),
                const SizedBox(height: 28),
                ValueListenableBuilder<bool>(
                  valueListenable: audio.soundOn,
                  builder: (context, on, _) => MenuButton(
                    label: on ? 'SOUND: ON' : 'SOUND: OFF',
                    selected: true,
                    onTap: () => audio.setSound(!on),
                  ),
                ),
                const SizedBox(height: 14),
                MenuButton(
                  label: 'BACK',
                  onTap: game.closeSettings,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}