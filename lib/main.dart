import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:tetris/game.dart';

/// 入口函数
void main() {
  runApp(GameWidget.controlled(gameFactory: () => TetrisGame()));
}
