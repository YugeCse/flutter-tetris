import 'package:flame/components.dart';
import 'package:flame/events.dart';

/// 系统按钮组件，用于处理系统按钮的点击事件
class SystemButtonComponent extends CircleComponent with TapCallbacks {
  void Function()? onTapClick;

  @override
  void onTapDown(TapDownEvent event) {
    onTapClick?.call();
    super.onTapDown(event);
  }
}
