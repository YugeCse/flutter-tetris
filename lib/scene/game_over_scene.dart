import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

/// 游戏结束的场景
class GameOverScene extends PositionComponent with HasGameRef, TapCallbacks {
  TextComponent? _titleComponent;
  ButtonComponent? _buttonComponent;

  Function? onRestartGame;

  @override
  Future<void> onLoad() async {
    add(
      _titleComponent = TextComponent(
        text: 'Game Over',
        anchor: Anchor.center,
        textRenderer: TextPaint(
          style: TextStyle(fontSize: 60, color: Colors.white),
        ),
      ),
    );
    add(
      _buttonComponent = ButtonComponent(
        anchor: Anchor.center,
        button: TextComponent(
          text: 'RESTART',
          textRenderer: TextPaint(
            style: TextStyle(fontSize: 35, color: Colors.tealAccent),
          ),
        ),
        onReleased: () => onRestartGame?.call(),
        position: _titleComponent!.position + Vector2(0, 50),
      ),
    );
  }

  @override
  void onGameResize(Vector2 size) {
    this.size = size * 2;
    super.onGameResize(size);
    _titleComponent?.position = Vector2(size.x / 2, size.y / 2 - 50);
    _buttonComponent?.position = Vector2(size.x / 2, size.y / 2 + 50);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, height),
      Paint()..color = Colors.black87,
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    event.handled = true;
    super.onTapDown(event);
  }
}
