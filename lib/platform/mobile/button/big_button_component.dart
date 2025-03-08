import 'package:flame/events.dart';
import 'package:flame/geometry.dart';

class BigButtonComponent extends CircleComponent with TapCallbacks {
  void Function()? onTapClick;

  @override
  void onTapDown(TapDownEvent event) {
    onTapClick?.call();
    super.onTapDown(event);
  }
}
