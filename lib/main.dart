import 'dart:io';

import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tetris/block/block.dart';
import 'package:tetris/platform/mobile/android_tetris_game.dart';
import 'package:tetris/platform/web/web_tetris_game.dart';

/// 入口函数
void main() {
  FlameGame gameObject;
  if (kIsWeb) {
    gameObject = WebTetrisGame();
  } else {
    Block.gridSize = 13; // 俄罗斯方块的格子占用像素点
    gameObject = AndroidTetrisGame();
  }
  runApp(GameWidget.controlled(gameFactory: () => gameObject));
  if (Platform.isAndroid) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
    );
  }
}
