import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../game/gravity_game.dart';
import 'pixel_ui.dart';

class MainMenu extends StatelessWidget {
  final GravityGame game;
  const MainMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return PixelScreen(
      dim: 0, // ให้เห็นฉากพิกเซลของเกมด้านหลังเต็มๆ
      child: Stack(
        children: [
          Positioned.fill(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: PixelPanel(
                    width: 320,
                    padding: const EdgeInsets.fromLTRB(24, 22, 24, 14),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'SPOOKY',
                          style: pxStyle(size: 14, color: pxOrange, spacing: 8),
                        ),
                        const SizedBox(height: 8),
                        const PixelBanner('GRAVITY RUN'),
                        const SizedBox(height: 12),
                        ValueListenableBuilder<int>(
                          valueListenable: game.best,
                          builder: (_, b, __) => Text(
                            'BEST: $b m',
                            style: pxStyle(size: 15, color: pxYellow, spacing: 1),
                          ),
                        ),
                        const SizedBox(height: 14),
                        PixelButton(
                          label: 'PLAY',
                          tone: PxTone.red,
                          big: true,
                          arrows: true,
                          onTap: game.startGame,
                        ),
                        const SizedBox(height: 10),
                        PixelButton(label: 'SHOP', onTap: game.showShop),
                        const SizedBox(height: 10),
                        PixelButton(label: 'STATS', onTap: game.showStats),
                        const SizedBox(height: 10),
                        PixelButton(label: 'SETTINGS', onTap: game.showSettings),
                        const SizedBox(height: 10),
                        PixelButton(label: 'QUIT', onTap: () => SystemNavigator.pop()),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'v1.0.0',
                            style: pxStyle(size: 11, color: pxMuted, spacing: 0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}