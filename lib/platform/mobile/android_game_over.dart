import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'package:tetris/platform/mobile/android_tetris_game.dart';

class AndroidGameOver extends PositionComponent
    with HasGameRef<AndroidTetrisGame> {
  int userHighScore = 0;
  int userLevelNumber = 1;

  @override
  FutureOr<void> onLoad() async {
    priority = 1;
    add(
      TextComponent(
        anchor: Anchor.center,
        text: "游戏结束",
        textRenderer: TextPaint(
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
        position: Vector2(size.x / 2, size.y / 3),
      ),
    );
    add(
      TextComponent(
        anchor: Anchor.center,
        text: "等级: $userLevelNumber",
        textRenderer: TextPaint(
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        position: Vector2(size.x / 2, size.y / 2),
      ),
    );
    add(
      TextComponent(
        anchor: Anchor.center,
        text: "得分: $userHighScore",
        textRenderer: TextPaint(
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        position: Vector2(size.x / 2, size.y / 2 + 30),
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, width, height),
        Radius.circular(12),
      ),
      Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.black87.withAlpha(180),
    );
  }
}
