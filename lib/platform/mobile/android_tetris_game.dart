import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/rendering.dart';
import 'package:tetris/block/block.dart';
import 'package:tetris/data/level_info.dart';
import 'package:tetris/platform/mobile/android_board_component.dart';
import 'package:tetris/platform/mobile/button/game_button_type.dart';
import 'package:tetris/utils/sound.dart';

/// 安卓俄罗斯方块游戏类
class AndroidTetrisGame extends FlameGame {
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

  /// 游戏面板对象
  AndroidBoardComponent? _board;

  /// 当前方块
  Block? _curBlock;

  /// 下一个方块
  Block? _nextBlock;

  @override
  FutureOr<void> onLoad() async {
    add(_board = AndroidBoardComponent()..onGameButtonClick = gameButtonClick);
    _board?.onGameDiagitalComponentInitilized = () {
      var gridCols = _board!.gameDigitalComponent.cellColumnCount;
      _board?.addToGameDigitalComponent(
        _curBlock = Block.generate(gridCols: gridCols),
      );
      _nextBlock = Block.generate(gridCols: gridCols); //生成下一个方块
      _board?.expectNextBlockShape = _nextBlock!.shape;
      _board?.expectNextBlockColor = _nextBlock!.tetrisColor;
    };
  }

  /// 暂停Game
  void pause() {
    allowRun = false; //暂停Game
  }

  /// 重新开始
  void restart() {
    // _gameOverScene?.removeFromParent();
    _board?.clear();
    if (_curBlock != null) {
      _curBlock?.removeFromParent();
    }
    gameLevel = 1; //重置游戏等级
    fallDownSpeed = 1.0; //重置下落速度
    allowRun = true; //允许Game继续运行
    var gridCols = _board!.gameDigitalComponent.cellColumnCount;
    _board?.add(_curBlock = Block.generate(gridCols: gridCols));
    _nextBlock = Block.generate(gridCols: gridCols); //生成下一个方块
    _board?.expectNextBlockShape = _nextBlock!.shape;
    _board?.expectNextBlockColor = _nextBlock!.tetrisColor;
  }

  /// 游戏按钮点击事件
  void gameButtonClick(GameButtonType type) {
    if (type == GameButtonType.up || type == GameButtonType.send) {
      _curBlock?.rotate(_board!.gameDigitalComponent);
    } else if (type == GameButtonType.left) {
      _curBlock?.moveLeft(_board!.gameDigitalComponent);
    } else if (type == GameButtonType.right) {
      _curBlock?.moveRight(_board!.gameDigitalComponent);
    } else if (type == GameButtonType.down) {
      _curBlock?.moveDown(_board!.gameDigitalComponent);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    var curMillis = DateTime.now().millisecondsSinceEpoch;
    var diffMillis = curMillis - timeMillis;
    if (!allowRun ||
        diffMillis < fallDownSpeed * 1000 ||
        !_board!.isGameDiaitalComponentInitilized) {
      return;
    }
    timeMillis = curMillis;
    if (_curBlock?.moveDown(_board!.gameDigitalComponent) == false) {
      _board?.gameDigitalComponent.mergeBlock(_curBlock!);
      updateLevelByScore(); //根据分数更新等级
      _curBlock?.removeFromParent();
      _board?.addToGameDigitalComponent(_curBlock = _nextBlock!);
      if (_board?.gameDigitalComponent.isCollision(_curBlock!) == true) {
        allowRun = false;
        debugPrint('Game Over');
        Sound.playGameOverSound(); //播放游戏结束音效
        // add(_gameOverScene = WebGameOverScene()..onRestartGame = restart);
        return;
      }
      var gridCols = _board!.gameDigitalComponent.cellColumnCount;
      _nextBlock = Block.generate(gridCols: gridCols);
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
          _board!.gameDigitalComponent.scoreNumber >= levelInfo.minScore &&
          _board!.gameDigitalComponent.scoreNumber <= levelInfo.maxScore) {
        gameLevel = levelInfo.level;
        fallDownSpeed = levelInfo.speed;
        _board?.gameDigitalComponent.levelNumber = gameLevel;
      }
    }
    debugPrint('Level Up: $gameLevel, Game Speed: $fallDownSpeed');
  }
}
