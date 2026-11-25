import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioManager {
  AudioManager._();
  static final AudioManager instance = AudioManager._();

  static const String click = 'click_button_sound.mp3';
  static const String flip = 'change_gravity_sound.mp3';
  static const String gameOver = 'gameover_sound.mp3';
  static const String bgm = 'background_sound.mp3';
  static const String candy = 'collect_candy_sound.mp3'; // เก็บขนม
  static const String item = 'received_item_sound.mp3'; // เก็บโล่/แม่เหล็ก
  static const String shieldBroken = 'shield_broken_sound.mp3'; // โล่แตก
  static const String _key = 'sound_on';

  final soundOn = ValueNotifier<bool>(true);
  bool _bgmWanted = false;
  bool _inited = false;

  // พูลเสียงขนม: เล่นซ้อนกันได้หลายอันพร้อมกัน
  AudioPool? _candyPool;

  Future<void> init() async {
    if (_inited) return;
    _inited = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      soundOn.value = prefs.getBool(_key) ?? true;
      FlameAudio.bgm.initialize();
      await FlameAudio.audioCache
          .loadAll([click, flip, gameOver, candy, item, shieldBroken]);
      _candyPool = await FlameAudio.createPool(
        candy,
        minPlayers: 3,
        maxPlayers: 8,
      );
    } catch (e) {
      debugPrint('Audio init error: $e');
    }
  }

  Future<void> setSound(bool on) async {
    soundOn.value = on;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, on);
    } catch (e) {
      debugPrint('Audio save error: $e');
    }
    if (!on) {
      await _stop();
    } else if (_bgmWanted) {
      await _bgmPlay();
    }
  }

  // ---------- เสียงเอฟเฟกต์ ----------
  void play(String file) {
    if (!soundOn.value) return;
    if (file == candy && _candyPool != null) {
      _playCandy();
      return;
    }
    _play(file);
  }

  Future<void> _playCandy() async {
    try {
      await _candyPool!.start(volume: 0.8);
    } catch (e) {
      debugPrint('Audio candy error: $e');
    }
  }

  Future<void> _play(String file) async {
    try {
      await FlameAudio.play(file, volume: 0.8);
    } catch (e) {
      debugPrint('Audio play error: $e');
    }
  }

  // ---------- เพลงพื้นหลัง ----------
  void startBgm() {
    _bgmWanted = true;
    if (soundOn.value) _bgmPlay();
  }

  void stopBgm() {
    _bgmWanted = false;
    _stop();
  }

  void pauseBgm() {
    try {
      FlameAudio.bgm.pause();
    } catch (e) {
      debugPrint('Audio pause error: $e');
    }
  }

  void resumeBgm() {
    if (!_bgmWanted || !soundOn.value) return;
    try {
      FlameAudio.bgm.resume();
    } catch (e) {
      debugPrint('Audio resume error: $e');
    }
  }

  Future<void> _bgmPlay() async {
    try {
      await FlameAudio.bgm.play(bgm, volume: 0.4);
    } catch (e) {
      debugPrint('Audio bgm error: $e');
    }
  }

  Future<void> _stop() async {
    try {
      await FlameAudio.bgm.stop();
    } catch (e) {
      debugPrint('Audio stop error: $e');
    }
  }
}