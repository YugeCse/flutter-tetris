import 'dart:async';

import 'package:flame/components.dart' show Anchor;
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tetris/block/block.dart';
import 'package:tetris/board.dart';

/// 主游戏类
class TetrisGame extends FlameGame with KeyboardEvents, TapDetector {
  /// 游戏面板
  Board? _board;

  /// 当前方块
  Block? _curBlock;

  /// 下一个方块
  Block? _nextBlock;

  /// 计时更新方块自动下落
  int timeMillis = 0;

  /// 是否允许运行
  bool allowRun = true;

  /// 方块下落速度
  double fallDownSpeed = 1.0;

  /// 是否播放背景音乐
  bool isBgMusicPlaying = false;

  @override
  FutureOr<void> onLoad() async {
    add(_board = Board()..anchor = Anchor.topLeft);
    _board?.position.x = (size.x - _board!.size.x) / 2;
    _board?.position.y = (size.y - _board!.size.y) / 2;
    _board?.add(_curBlock = Block.generate());
    _nextBlock = Block.generate(); //生成下一个方块
    _board?.expectNextBlockShape = _nextBlock!.shape;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _board?.position.x = (size.x - _board!.size.x) / 2;
    _board?.position.y = (size.y - _board!.size.y) / 2;
  }

  /// 暂停Game
  void pause() {
    allowRun = false; //暂停Game
  }

  /// 重新开始
  void restart() {
    _board?.clear();
    if (_curBlock != null) {
      _curBlock?.removeFromParent();
    }
    fallDownSpeed = 1.0; //重置下落速度
    allowRun = true; //允许Game继续运行
  }

  @override
  void update(double dt) {
    super.update(dt);
    var curMillis = DateTime.now().millisecondsSinceEpoch;
    var diffMillis = curMillis - timeMillis;
    if (!allowRun || diffMillis < fallDownSpeed * 1000) return;
    timeMillis = curMillis;
    if (_curBlock?.moveDown(_board!) == false) {
      _board?.mergeBlock(_curBlock!);
      _curBlock?.removeFromParent();
      _board?.add(_curBlock = _nextBlock!);
      _nextBlock = Block.generate();
      _board?.expectNextBlockShape = _nextBlock!.shape;
    }
  }

  @override
  void onTapDown(TapDownInfo info) {
    super.onTapDown(info);
    if (!isBgMusicPlaying) {
      isBgMusicPlaying = true;
      FlameAudio.loopLongAudio('bg-music.mp3');
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
