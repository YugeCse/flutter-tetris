import 'package:flame/events.dart';
import 'package:flame/geometry.dart';

class DirectionButtonComponent extends CircleComponent with TapCallbacks {
  void Function()? onTapClick;

  @override
  void onTapDown(TapDownEvent event) {
    onTapClick?.call();
    super.onTapDown(event);
  }
}
