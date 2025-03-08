import 'dart:async';

import 'package:flame_audio/flame_audio.dart';

/// 音效工具类
class Sound {
  Sound._();

  /// 背景音乐的Audio对象
  static AudioPlayer? _bgMusicPlayer;

  /// 播放方块掉落音效
  static Future<void> playFallDownSound() =>
      Sound.playSound('sound_fall_down.mp3');

  /// 播放方块消行音效
  static Future<void> playClearLinesSound() =>
      Sound.playSound('sound_clear_lines.mp3');

  /// 播放游戏结束音效
  static Future<void> playGameOverSound() =>
      Sound.playSound('sound_game_over.mp3');

  ///播放背景音乐
  static Future<AudioPlayer> playBgMusic({double volume = 0.5}) async {
    if (_bgMusicPlayer == null) {
      _bgMusicPlayer = await FlameAudio.playLongAudio(
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
