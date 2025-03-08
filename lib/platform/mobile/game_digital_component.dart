import 'package:flame/components.dart' hide Block;
import 'package:flutter/material.dart';
import 'package:tetris/data/offset_int.dart';
import 'package:tetris/block/block.dart';
import 'package:tetris/platform/game_collision_detector.dart';
import 'package:tetris/utils/collision.dart' show Collision;
import 'package:tetris/utils/sound.dart';

/// 游戏显示组件
class GameDigitalComponent extends PositionComponent
    with GameCollisionDetector {
  /// 游戏视图Padding宽度
  static final double viewPadding = 8;

  /// 游戏表格行数
  int cellRowCount = 0;

  /// 游戏表格列数
  int cellColumnCount = 0;

  double gameViewWidth = 0;

  double gameViewHeight = 0;

  double sideViewWidth = 0;

  /// 俄罗斯方块的格子
  List<List<Color?>> tetrisCells = [];

  /// 预测的下一个方块
  List<int> expectNextBlockShape = [];

  /// 预测的下一个方块的颜色
  Color expectNextBlockColor = Colors.blue;

  /// 当前得分数字
  int scoreNumber = 0;

  /// 当前等级数字
  int levelNumber = 1;

  GameDigitalComponent({super.size, super.position}) {
    gameViewWidth = size.x - viewPadding * 2;
    gameViewHeight = size.y - viewPadding * 2;
    sideViewWidth = gameViewWidth * 0.3;
    gameViewWidth = gameViewWidth - sideViewWidth;
    cellRowCount = (gameViewHeight / Block.gridSize).round();
    cellColumnCount = (gameViewWidth / Block.gridSize).round();
    gameViewWidth = (cellColumnCount * Block.gridSize).toDouble();
    sideViewWidth = size.x - viewPadding * 2 - gameViewWidth;
    tetrisCells = List.generate(
      cellRowCount,
      (_) => List.filled(cellColumnCount, null),
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    debugPrint('$size');
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        Radius.circular(10),
      ),
      Paint()..color = const Color(0xFF6E5D51),
    );
    for (var y = 0; y < tetrisCells.length; y++) {
      for (var x = 0; x < tetrisCells[y].length; x++) {
        Block.drawCell(
          canvas,
          OffsetInt(dx: x, dy: y),
          strokeWidth: 1,
          innerPadding: 0.2,
          borderRadius: 1,
          offset: Offset(
            viewPadding / Block.gridSize,
            viewPadding / Block.gridSize,
          ),
          renderColor: tetrisCells[y][x] ?? Block.defaultRenderColor,
        );
      }
    }
  }

  /// 碰撞检测2
  /// - xPosition, yPosition: 方块左上角坐标
  /// - shape: 方块形状
  @override
  bool isCollision2(double xPosition, double yPosition, List<int> shape) {
    return Collision.isCollision2(
      tetrisCells,
      shape,
      xPosition,
      yPosition,
      cellRowCount,
      cellColumnCount,
    );
  }

  /// 检测碰撞，与边缘碰撞或者已经填充的方块碰撞
  @override
  bool isCollision(Block block) =>
      Collision.isCollision(block, tetrisCells, cellRowCount, cellColumnCount);

  /// 合并方块
  void mergeBlock(Block block) {
    for (var y = 0; y < Block.maxGridCols; y++) {
      for (var x = 0; x < Block.maxGridRows; x++) {
        var index = y * Block.maxGridCols + x;
        var value = block.shape[index];
        if (value == 1) {
          var bx = (block.position.x / Block.gridSize).round();
          var by = (block.position.y / Block.gridSize).round();
          tetrisCells[by + y][bx + x] = Colors.black; //填充表格
        }
      }
    }
    clearLines(); //清除满行 //debugPrint("walls = $cells");
  }

  /// 清除满行
  void clearLines() {
    var clearLineCount = 0;
    for (var y = 0; y < cellRowCount; y++) {
      if (tetrisCells[y].every((element) => element != null)) {
        clearLineCount++;
        tetrisCells.removeAt(y);
        tetrisCells.insert(0, List.filled(cellColumnCount, null));
      }
    }
    if (clearLineCount > 0) {
      Sound.playClearLinesSound(); //播放消除音效
    }
  }

  /// 清空所有数据行
  void clear() {
    scoreNumber = 0;
    levelNumber = 1;
    tetrisCells.clear();
    for (var i = 0; i < cellRowCount; i++) {
      tetrisCells.add(List.filled(cellColumnCount, null));
    }
  }
}
