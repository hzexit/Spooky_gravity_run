import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'player.dart';

class GravityGame extends FlameGame with TapCallbacks {
  late Player player;

  @override
  Future<void> onLoad() async {
    player = Player();
    add(player);
  }

  @override
  void onTapDown(TapDownEvent event) {
    player.flip();
  }
}