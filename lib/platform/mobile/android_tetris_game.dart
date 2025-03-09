import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/rendering.dart';
import 'package:tetris/block/block.dart';
import 'package:tetris/data/level_info.dart';
import 'package:tetris/platform/mobile/android_board_component.dart';
import 'package:tetris/platform/mobile/button/game_button_type.dart';
import 'package:tetris/utils/sound_utils.dart';

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
  bool _isAllowGameRun = false;

  /// 游戏面板对象
  AndroidBoardComponent? _board;

  /// 当前方块
  Block? _curBlock;

  /// 下一个方块
  Block? _nextBlock;

  /// 游戏是否结束
  bool _isGameOver = false;

  /// 游戏结束控制器
  StreamController<int>? gameOverStreamController;

  @override
  FutureOr<void> onLoad() async {
    gameOverStreamController = StreamController.broadcast(); //初始化游戏结束控制器
    add(_board = AndroidBoardComponent()..onGameButtonClick = gameButtonClick);
    // _board?.onGameScreenLoaded = () {
    //   var gridCols = _board!.gameScreenViewComponent.cellColumnCount;
    //   _board?.addToGameScreen(
    //     _curBlock = Block.generate(
    //       gridCols: gridCols,
    //       startOffset: Vector2(
    //         0,
    //         _board!.gameScreenViewComponent.gameStatusBarHeight,
    //       ),
    //     ),
    //   );
    //   _nextBlock = Block.generate(
    //     gridCols: gridCols,
    //     startOffset: Vector2(
    //       0,
    //       _board!.gameScreenViewComponent.gameStatusBarHeight,
    //     ),
    //   ); //生成下一个方块
    //   _board?.expectNextBlockShape = _nextBlock!.shape;
    //   _board?.expectNextBlockColor = _nextBlock!.tetrisColor;
    // };
  }

  /// 重新开始
  void restartGame() {
    // _gameOverScene?.removeFromParent();
    if (_curBlock != null) {
      _curBlock?.removeFromParent();
    }
    _board?.resetData(); //清空游戏面板
    gameLevel = 1; //重置游戏等级
    fallDownSpeed = 1.0; //重置下落速度
    _isGameOver = false;
    _isAllowGameRun = true; //允许Game继续运行
    var blockStartOffset = Vector2(
      0,
      _board!.gameScreenViewComponent.gameStatusBarHeight,
    );
    var gridCols = _board!.gameScreenViewComponent.cellColumnCount;
    _board?.addToGameScreen(
      _curBlock = Block.generate(
        gridCols: gridCols,
        startOffset: blockStartOffset,
      ),
    );
    _nextBlock = Block.generate(
      gridCols: gridCols,
      startOffset: blockStartOffset,
    ); //生成下一个方块
    _board?.expectNextBlockShape = _nextBlock!.shape;
    _board?.expectNextBlockColor = _nextBlock!.tetrisColor;
  }

  /// 游戏按钮点击事件
  void gameButtonClick(GameButtonType type) {
    if (type == GameButtonType.up || type == GameButtonType.send) {
      _curBlock?.rotate(_board!.gameScreenViewComponent);
    } else if (type == GameButtonType.left) {
      _curBlock?.moveLeft(_board!.gameScreenViewComponent);
    } else if (type == GameButtonType.right) {
      _curBlock?.moveRight(_board!.gameScreenViewComponent);
    } else if (type == GameButtonType.down) {
      _curBlock?.moveDown(_board!.gameScreenViewComponent);
    } else if (type == GameButtonType.playOrPause) {
      if (_isGameOver) {
        restartGame(); //重新开始游戏
      } else {
        if (_curBlock == null) {
          restartGame(); //重新开始游戏
          return;
        }
        _isAllowGameRun = !_isAllowGameRun; //游戏开始和暂停
      }
    } else if (type == GameButtonType.soundEffect) {
      SoundUtils.isSoundEffectEnabled = !SoundUtils.isSoundEffectEnabled;
    } else if (type == GameButtonType.bgMusic) {
      SoundUtils.isBgMusicEnabled = !SoundUtils.isBgMusicEnabled;
    } else if (type == GameButtonType.shutdown) {}
  }

  @override
  void update(double dt) {
    super.update(dt);
    var curMillis = DateTime.now().millisecondsSinceEpoch;
    var diffMillis = curMillis - timeMillis;
    if (!_board!.isGameScreenViewLoaded ||
        !_isAllowGameRun ||
        _isGameOver ||
        diffMillis < fallDownSpeed * 1000) {
      return;
    }
    timeMillis = curMillis; //更新时间数据
    if (_curBlock?.moveDown(_board!.gameScreenViewComponent) == true) {
      debugPrint('方块正在下落...');
      return; //如果方块可以继续下落
    }
    _board?.mergeBlock(_curBlock!);
    updateLevelByScore(); //根据分数更新等级
    _curBlock?.removeFromParent(); //移除当前方块
    _board?.addToGameScreen(_curBlock = _nextBlock!); //将下一个方块添加到游戏屏幕
    if (_board?.isCollision(_curBlock!) == true) {
      SoundUtils.playGameOverSound(); //播放游戏结束音效
      _board?.mergeBlock(_curBlock!); //游戏结束了还是要merge这个方块
      _isGameOver = true; //标记游戏结束
      _isAllowGameRun = false; //不允许Game继续运行
      gameOverStreamController?.sink.add(1); //发送游戏结束事件
      // add(_gameOverScene = WebGameOverScene()..onRestartGame = restart);
    }
    var gridCols = _board!.gameScreenViewComponent.cellColumnCount;
    _nextBlock = Block.generate(
      gridCols: gridCols,
      startOffset: Vector2(
        0,
        _board!.gameScreenViewComponent.gameStatusBarHeight,
      ),
    );
    _board
      ?..expectNextBlockShape = _nextBlock!.shape
      ..expectNextBlockColor = _nextBlock!.tetrisColor;
  }

  /// 根据分数更新等级
  void updateLevelByScore() {
    var levelIndex = gameLevel - 1;
    if (levelIndex >= gameLevels.length) return;
    for (var i = levelIndex; i < gameLevels.length; i++) {
      var levelInfo = gameLevels[i];
      if (levelInfo.level == gameLevel) continue;
      if (levelInfo.level != gameLevel &&
          _board!.gameScreenViewComponent.scoreNumber >= levelInfo.minScore &&
          _board!.gameScreenViewComponent.scoreNumber <= levelInfo.maxScore) {
        gameLevel = levelInfo.level;
        fallDownSpeed = levelInfo.speed;
        _board?.gameScreenViewComponent
          ?..levelNumber = gameLevel
          ..speedNumber = fallDownSpeed;
      }
    }
    debugPrint('Level Up: $gameLevel, Game Speed: $fallDownSpeed');
  }
}
