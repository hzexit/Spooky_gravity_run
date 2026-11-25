import 'package:flutter/material.dart';
import '../game/audio_manager.dart';
import '../game/gravity_game.dart';
import 'pixel_ui.dart';

class SettingsMenu extends StatelessWidget {
  final GravityGame game;
  const SettingsMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final audio = AudioManager.instance;
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
                const PixelBanner('SETTINGS'),
                const SizedBox(height: 22),
                ValueListenableBuilder<bool>(
                  valueListenable: audio.soundOn,
                  builder: (context, on, _) => PixelButton(
                    label: on ? 'SOUND: ON' : 'SOUND: OFF',
                    tone: on ? PxTone.green : PxTone.grey,
                    onTap: () => audio.setSound(!on),
                  ),
                ),
                const SizedBox(height: 12),
                PixelButton(label: 'BACK', onTap: game.closeSettings),
              ],
            ),
          ),
        ),
      ),
    );
  }
}