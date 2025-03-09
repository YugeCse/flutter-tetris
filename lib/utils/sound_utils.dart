import 'dart:async';

import 'package:flame_audio/flame_audio.dart';

/// 音效工具类
class SoundUtils {
  SoundUtils._();

  /// 背景音乐的Audio对象
  static AudioPlayer? _bgMusicPlayer;

  static bool _isBgMusicEnabled = false;

  /// 设置是否开启背景音乐
  static set isBgMusicEnabled(bool value) {
    if (value) {
      playBgMusic();
    } else {
      stopBgMusic();
    }
    _isBgMusicEnabled = value;
  }

  /// 获取是否开启音效
  static bool isSoundEffectEnabled = true;

  /// 获取是否开启背景音乐
  static bool get isBgMusicEnabled => _isBgMusicEnabled;

  /// 播放方块掉落音效
  static void playFallDownSound() {
    if (!isSoundEffectEnabled) return;
    SoundUtils.playSound('sound_fall_down.mp3');
  }

  /// 播放方块消行音效
  static void playClearLinesSound() {
    if (!isSoundEffectEnabled) return;
    SoundUtils.playSound('sound_clear_lines.mp3');
  }

  /// 播放游戏结束音效
  static void playGameOverSound() {
    if (!isSoundEffectEnabled) return;
    SoundUtils.playSound('sound_game_over.mp3');
  }

  ///播放背景音乐
  static Future<AudioPlayer> playBgMusic({double volume = 0.3}) async {
    if (_bgMusicPlayer == null) {
      _bgMusicPlayer = await FlameAudio.loopLongAudio(
        'bg_music.mp3',
        volume: volume,
      );
    } else {
      _bgMusicPlayer?.resume();
    }
    return _bgMusicPlayer!;
  }

  /// 暂停背景音乐
  static FutureOr<void> stopBgMusic() => _bgMusicPlayer?.stop();

  /// 播放音效
  static Future<void> playSound(String soundName) => FlameAudio.play(soundName);
}
