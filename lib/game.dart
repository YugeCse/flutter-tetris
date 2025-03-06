import 'dart:async';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tetris/block/block.dart';
import 'package:tetris/board.dart';

/// 主游戏类
class TetrisGame extends FlameGame with KeyboardEvents {
  /// 游戏面板
  Board? _board;

  /// 当前方块
  Block? _curBlock;

  /// 计时更新方块自动下落
  int timeMillis = 0;

  @override
  FutureOr<void> onLoad() async {
    add(_board = Board());
    _board?.add(_curBlock = Block.generate());
  }

  @override
  void update(double dt) {
    super.update(dt);
    var curMillis = DateTime.now().millisecondsSinceEpoch;
    var diffMillis = curMillis - timeMillis;
    if (diffMillis < 1000) return;
    timeMillis = curMillis;
    if (_curBlock?.moveDown(_board!) == false) {
      _board?.mergeBlock(_curBlock!);
      _curBlock?.removeFromParent();
      _curBlock = Block.generate();
      _board?.add(_curBlock!);
    }
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
          event.logicalKey == LogicalKeyboardKey.keyW) {
        _curBlock?.rotate(_board!);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
          event.logicalKey == LogicalKeyboardKey.keyS) {
        _curBlock?.moveDown(_board!);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
          event.logicalKey == LogicalKeyboardKey.keyA) {
        _curBlock?.moveLeft(_board!);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
          event.logicalKey == LogicalKeyboardKey.keyD) {
        _curBlock?.moveRight(_board!);
      }
    }
    return super.onKeyEvent(event, keysPressed);
  }
}
