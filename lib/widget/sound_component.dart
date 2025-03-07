import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_svg/flame_svg.dart';

/// This component is used to control the background music.
class SoundComponent extends PositionComponent with TapCallbacks {
  bool isSoundOpen = false;
  Svg? soundOpenSvg;
  Svg? soundSilentSvg;
  SvgComponent? soundSvgComponent;
  AudioPlayer? backgroundMusicPlayer;

  @override
  FutureOr<void> onLoad() async {
    soundOpenSvg = await Svg.load('assets/sound_open.svg');
    soundSilentSvg = await Svg.load('assets/sound_silent.svg');
    var titleComponent = TextComponent(text: 'BG Music: ');
    add(titleComponent);
    add(
      soundSvgComponent = SvgComponent(
        svg: soundSilentSvg,
        size: Vector2(30, 30),
        position: Vector2(titleComponent.size.x + 12, 0),
      ),
    );
    size = Vector2(titleComponent.size.x + soundSvgComponent!.size.x + 12, 30);
  }

  @override
  void onTapDown(TapDownEvent event) async {
    super.onTapDown(event);
    isSoundOpen = !isSoundOpen;
    if (isSoundOpen) {
      if (backgroundMusicPlayer == null) {
        backgroundMusicPlayer = await FlameAudio.loopLongAudio('bg-music.mp3');
      } else {
        backgroundMusicPlayer?.resume();
      }
    } else {
      backgroundMusicPlayer?.stop();
    }
    soundSvgComponent?.svg = isSoundOpen ? soundOpenSvg : soundSilentSvg;
  }
}
