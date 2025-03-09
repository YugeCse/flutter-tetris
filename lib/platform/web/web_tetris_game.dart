import 'dart:async';

import 'package:flame/components.dart' show Anchor;
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tetris/data/level_info.dart';
import 'package:tetris/platform/web/web_game_over.dart';
import 'package:tetris/utils/sound_utils.dart';
import 'package:tetris/block/block.dart';
import 'package:tetris/platform/web/web_board_component.dart';

/// 主游戏类
class WebTetrisGame extends FlameGame with KeyboardEvents {
  /// 游戏等级信息
  /// + 1-20 1.0
  /// + 21-50 0.9
  /// + 51-90 0.7
  /// + 91-130 0.5
  /// + 131-180 0.45
  /// + 181-250 0.4
  /// + 251-300 0.35
  /// + 301-350 0.3
  /// + 351-450 0.2
  /// + 451-1000000 0.2
  final List<LevelInfo> gameLevels = [
    LevelInfo(1, 0, 20, 1.0),
    LevelInfo(2, 21, 50, 0.9),
    LevelInfo(3, 51, 90, 0.7),
    LevelInfo(4, 91, 130, 0.5),
    LevelInfo(5, 131, 180, 0.45),
    LevelInfo(6, 181, 250, 0.4),
    LevelInfo(7, 251, 300, 0.35),
    LevelInfo(8, 301, 350, 0.3),
    LevelInfo(9, 351, 450, 0.2),
    LevelInfo(10, 451, 1000000, 0.2),
  ];

  /// 游戏等级
  int gameLevel = 1;

  /// 方块下落速度
  double fallDownSpeed = 1.0;

  /// 计时更新方块自动下落
  int timeMillis = 0;

  /// 是否允许运行
  bool allowRun = true;

  /// 游戏面板
  WebBoardComponent? _board;

  /// 当前方块
  Block? _curBlock;

  /// 下一个方块
  Block? _nextBlock;

  /// 游戏结束场景
  WebGameOverScene? _gameOverScene;

  @override
  FutureOr<void> onLoad() async {
    add(_board = WebBoardComponent()..anchor = Anchor.topLeft);
    _board?.position.x = (size.x - _board!.size.x) / 2;
    _board?.position.y = (size.y - _board!.size.y) / 2;
    _board?.add(
      _curBlock = Block.generate(gridCols: WebBoardComponent.boardCols),
    );
    _nextBlock = Block.generate(
      gridCols: WebBoardComponent.boardCols,
    ); //生成下一个方块
    _board?.expectNextBlockShape = _nextBlock!.shape;
    _board?.expectNextBlockColor = _nextBlock!.tetrisColor;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // canvas.drawColor(Colors.grey, BlendMode.softLight);
    var size = _board!.size;
    var position = _board!.position;
    canvas.drawRRect(
      RRect.fromLTRBR(
        position.x - 2,
        position.y - 2,
        position.x + size.x + 5,
        position.y + size.y + 2,
        Radius.circular(5),
      ),
      Paint()
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke
        ..color = const Color.fromARGB(51, 2, 2, 2),
    );
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
    _gameOverScene?.removeFromParent();
    _board?.clear();
    if (_curBlock != null) {
      _curBlock?.removeFromParent();
    }
    gameLevel = 1; //重置游戏等级
    fallDownSpeed = 1.0; //重置下落速度
    allowRun = true; //允许Game继续运行
    _board?.add(
      _curBlock = Block.generate(gridCols: WebBoardComponent.boardCols),
    );
    _nextBlock = Block.generate(
      gridCols: WebBoardComponent.boardCols,
    ); //生成下一个方块
    _board?.expectNextBlockShape = _nextBlock!.shape;
    _board?.expectNextBlockColor = _nextBlock!.tetrisColor;
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
      updateLevelByScore(); //根据分数更新等级
      _curBlock?.removeFromParent();
      _board?.add(_curBlock = _nextBlock!);
      if (_board?.isCollision(_curBlock!) == true) {
        allowRun = false;
        debugPrint('Game Over');
        SoundUtils.playGameOverSound(); //播放游戏结束音效
        add(_gameOverScene = WebGameOverScene()..onRestartGame = restart);
        return;
      }
      _nextBlock = Block.generate(gridCols: WebBoardComponent.boardCols);
      _board?.expectNextBlockShape = _nextBlock!.shape;
      _board?.expectNextBlockColor = _nextBlock!.tetrisColor;
    }
  }

  /// 根据分数更新等级
  void updateLevelByScore() {
    var levelIndex = gameLevel - 1;
    if (levelIndex >= gameLevels.length) return;
    for (var i = levelIndex; i < gameLevels.length; i++) {
      var levelInfo = gameLevels[i];
      if (levelInfo.level == gameLevel) continue;
      if (levelInfo.level != gameLevel &&
          _board!.scoreNumber >= levelInfo.minScore &&
          _board!.scoreNumber <= levelInfo.maxScore) {
        gameLevel = levelInfo.level;
        fallDownSpeed = levelInfo.speed;
        _board?.levelNumber = gameLevel;
      }
    }
    debugPrint('Level Up: $gameLevel, Game Speed: $fallDownSpeed');
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
        SoundUtils.playFallDownSound(); //播放下落音效
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
