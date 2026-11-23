import 'dart:math';
import 'package:flame/components.dart';
import 'chunks.dart';
import 'gravity_game.dart';
import 'items.dart';
import 'obstacles.dart';
import 'player.dart';

class LevelGenerator {
  final GravityGame game;
  final _rng = Random();
  double nextChunkX = 0; // ตำแหน่ง x บนจอที่ chunk ถัดไปจะเริ่ม
  Chunk? _last;
  int _sincePowerUp = 0; // จำนวน chunk นับจากไอเทมล่าสุด

  LevelGenerator(this.game);

  void reset() {
    nextChunkX = game.size.x + 200;
    _last = null;
    _sincePowerUp = 0;
  }

  void update(double dt, double scrollSpeed, double distance) {
    nextChunkX -= scrollSpeed * dt;
    while (nextChunkX < game.size.x + LevelRules.col) {
      final chunk = _pick(distance);
      _spawn(chunk, nextChunkX);
      _maybeSpawnPowerUp(nextChunkX, distance);
      nextChunkX += chunk.width * LevelRules.col;
    }
  }

  // เลือก chunk ตามระยะทาง: ยิ่งไกล ยิ่งสุ่มจากกลุ่มที่ยากขึ้น
  Chunk _pick(double distance) {
    final r = _rng.nextDouble();
    final List<Chunk> pool;
    if (distance < 400) {
      pool = easyChunks;
    } else if (distance < 1000) {
      pool = r < 0.3 ? easyChunks : mediumChunks;
    } else {
      pool = r < 0.2 ? easyChunks : (r < 0.5 ? mediumChunks : hardChunks);
    }
    Chunk c;
    do {
      c = pool[_rng.nextInt(pool.length)];
    } while (c == _last && pool.length > 1);
    _last = c;
    return c;
  }

  // วางไอเทมตรงช่องว่าง (padding) ต้นแต่ละ chunk ซึ่งว่างเสมอ จึงไม่ทับหนาม
  void _maybeSpawnPowerUp(double startX, double distance) {
    _sincePowerUp++;
    if (distance < 60) return; // ช่วงเริ่มเกมยังไม่ให้
    if (_sincePowerUp < 3) return; // ห่างกันอย่างน้อย 3 chunk
    if (_rng.nextDouble() > 0.4) return;

    _sincePowerUp = 0;
    final type = _rng.nextBool() ? PowerType.shield : PowerType.magnet;
    final x = startX + 1.5 * LevelRules.col;
    game.add(PowerUp(type, Vector2(x, game.size.y / 2)));
  }

  void _spawn(Chunk chunk, double startX) {
    final h = game.size.y;
    final yTopSpike = Player.margin + 20;
    final yBotSpike = h - Player.margin - 20;
    final yTopCandy = Player.margin + 24;
    final yBotCandy = h - Player.margin - 24;
    final yMid = h / 2;

    final top = chunk.rows[0];
    final mid = chunk.rows[1];
    final bot = chunk.rows[2];

    for (var i = 0; i < chunk.width; i++) {
      final x = startX + i * LevelRules.col + LevelRules.col / 2;

      if (top[i] == 'v') game.add(Spike(Vector2(x, yTopSpike)));
      if (top[i] == 'c') game.add(Candy(Vector2(x, yTopCandy)));
      if (mid[i] == 'c') game.add(Candy(Vector2(x, yMid)));
      if (bot[i] == '^') game.add(Spike(Vector2(x, yBotSpike)));
      if (bot[i] == 'c') game.add(Candy(Vector2(x, yBotCandy)));
    }
  }
}