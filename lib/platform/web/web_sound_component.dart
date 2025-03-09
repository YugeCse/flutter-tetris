import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_svg/flame_svg.dart';
import 'package:tetris/utils/sound.dart';

/// This component is used to control the background music.
class WebSoundComponent extends PositionComponent with TapCallbacks {
  Svg? soundOpenSvg;
  Svg? soundSilentSvg;
  SvgComponent? soundSvgComponent;

  @override
  FutureOr<void> onLoad() async {
    soundOpenSvg = await Svg.load('assets/sound_open.svg');
    soundSilentSvg = await Svg.load('assets/sound_silent.svg');
    var titleComponent = TextComponent(text: 'BG Music: ');
    add(titleComponent);
    add(
      soundSvgComponent = SvgComponent(
        svg: Sound.isBgMusicEnabled ? soundOpenSvg : soundSilentSvg,
        size: Vector2(30, 30),
        position: Vector2(titleComponent.size.x + 12, 0),
      ),
    );
    size = Vector2(titleComponent.size.x + soundSvgComponent!.size.x + 12, 30);
  }

  @override
  void onTapDown(TapDownEvent event) async {
    super.onTapDown(event);
    Sound.isBgMusicEnabled = !Sound.isBgMusicEnabled;
    soundSvgComponent?.svg =
        Sound.isBgMusicEnabled ? soundOpenSvg : soundSilentSvg;
  }
}
