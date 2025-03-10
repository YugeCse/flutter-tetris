import 'dart:async';

import 'package:flame/components.dart' hide Block;
import 'package:flame/flame.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'package:tetris/data/offset_int.dart';
import 'package:tetris/platform/game_collision_detector.dart';
import 'package:tetris/utils/collision_utils.dart';
import 'package:tetris/utils/sound_utils.dart';
import 'package:tetris/block/block.dart';
import 'package:tetris/utils/shape_utils.dart';
import 'package:tetris/platform/web/web_sound_component.dart';

/// 游戏面板类
class WebBoardComponent extends PositionComponent with GameCollisionDetector {
  /// 面板的列数: 10
  static final int boardCols = 10;

  /// 面板的行数: 15
  static final int boardRows = 15;

  /// 边栏区: 5
  static final int boardSideCols = 5;

  /// 面板所有的格子数
  final List<List<Color?>> cells = [];

  /// 预测的下一个方块
  List<int> expectNextBlockShape = [];

  /// 预测的下一个方块的颜色
  Color expectNextBlockColor = Colors.blue;

  /// 当前得分数字
  int scoreNumber = 0;

  /// 当前得分组件
  TextComponent? scoreTextComponent;

  /// 当前等级数字
  int levelNumber = 1;

  /// 当前等级组件
  TextComponent? levelTextComponent;

  /// 构造函数，完成面板格子数填充和定义面板大小
  WebBoardComponent() {
    size = Vector2(
      (boardCols + boardSideCols) * Block.gridSize,
      boardRows * Block.gridSize,
    );
    for (var y = 0; y < boardRows; y++) {
      cells.add(List.filled(boardCols, null));
    }
  }

  @override
  FutureOr<void> onLoad() async {
    add(
      TextComponent(
        text: 'THE NEXT BLOCK',
        position: Vector2(
          (boardCols + 0.5) * Block.gridSize,
          0.2 * Block.gridSize,
        ),
      ),
    );
    add(
      TextComponent(
        text: 'My Score:',
        position: Vector2(
          (boardCols + 0.5) * Block.gridSize,
          5.8 * Block.gridSize,
        ),
      ),
    );
    add(
      scoreTextComponent = TextComponent(
        text: '0',
        position: Vector2(
          (boardCols + 0.5) * Block.gridSize,
          6.8 * Block.gridSize,
        ),
        size: Vector2(Block.maxGridCols * Block.gridSize, 60),
        textRenderer: TextPaint(
          style: TextStyle(fontSize: 60, color: Color(0xFFFFFFFF)),
        ),
      ),
    );
    add(
      levelTextComponent = TextComponent(
        text: 'My Level:   $levelNumber',
        position: Vector2(
          (boardCols + 0.5) * Block.gridSize,
          9 * Block.gridSize,
        ),
      ),
    );
    add(
      WebSoundComponent()
        ..position = Vector2(
          (boardCols + 0.5) * Block.gridSize,
          11 * Block.gridSize,
        ),
    );
    add(
      SpriteComponent.fromImage(
        await Flame.images.load('tetris_city_web.jpg'),
        srcSize: Vector2(1200, 834),
        scale: Vector2(
          (Block.maxGridCols * Block.gridSize) / 1200,
          (Block.maxGridCols * Block.gridSize) / 1200,
        ),
        position: Vector2(
          Block.gridSize * (boardCols + 0.5),
          size.y -
              (834 * (Block.maxGridCols * Block.gridSize) / 1200 +
                  Block.gridSize / 3),
        ),
      ),
    );
  }

  /// 检测碰撞，与边缘碰撞或者已经填充的方块碰撞
  @override
  bool isCollision(Block block) =>
      CollisionUtils.isCollision(block, cells, boardRows, boardCols);

  /// 碰撞检测2
  /// - xPosition, yPosition: 方块左上角坐标
  /// - shape: 方块形状
  @override
  bool isCollision2(double xPosition, double yPosition, List<int> shape) {
    return CollisionUtils.isCollision2(
      cells,
      shape,
      xPosition,
      yPosition,
      boardRows,
      boardCols,
    );
  }

  /// 合并方块
  void mergeBlock(Block block) {
    for (var y = 0; y < Block.maxGridCols; y++) {
      for (var x = 0; x < Block.maxGridRows; x++) {
        var index = y * Block.maxGridCols + x;
        var value = block.shape[index];
        if (value == 1) {
          var bx = (block.position.x / Block.gridSize).round();
          var by = (block.position.y / Block.gridSize).round();
          cells[by + y][bx + x] = block.tetrisColor; //填充表格
        }
      }
    }
    clearLines(); //清除满行
    // debugPrint("walls = $cells");
  }

  /// 清除满行
  void clearLines() {
    var clearLineCount = 0;
    for (var y = 0; y < boardRows; y++) {
      if (cells[y].every((element) => element != null)) {
        clearLineCount++;
        cells.removeAt(y);
        cells.insert(0, List.filled(boardCols, null));
        scoreTextComponent?.text = "${++scoreNumber}";
      }
    }
    if (clearLineCount > 0) {
      SoundUtils.playClearLinesSound(); //播放消除音效
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    levelTextComponent?.text = 'My Level:   $levelNumber';
  }

  @override
  void render(Canvas canvas) {
    drawBackground(canvas); //绘制背景
    drawNextBlockShape(canvas); //绘制下一个方块
  }

  /// 绘制背景
  void drawBackground(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          0,
          0,
          WebBoardComponent.boardCols * Block.gridSize,
          WebBoardComponent.boardRows * Block.gridSize,
        ),
        Radius.circular(5),
      ),
      Paint()..color = Colors.black,
    );
    for (var y = 0; y < boardRows; y++) {
      for (var x = 0; x < boardCols; x++) {
        Block.drawCell(
          canvas,
          OffsetInt(dx: x, dy: y),
          renderColor: cells[y][x] ?? Block.defaultRenderColor,
        ); //绘制被填充的单元格
      }
    }
  }

  /// 绘制下一个方块
  void drawNextBlockShape(Canvas canvas) {
    double startY = 1;
    double startX = WebBoardComponent.boardCols + 0.5;
    var (maxX, maxY) = ShapeUtils.computeShpaeFillMaxNum(expectNextBlockShape);
    startX += (Block.maxGridCols - maxX) / 2;
    startY += (Block.maxGridRows - maxY) / 2;
    for (var y = 0; y < Block.maxGridRows; y++) {
      for (var x = 0; x < Block.maxGridCols; x++) {
        var index = y * Block.maxGridCols + x;
        var value =
            index >= 0 && index < expectNextBlockShape.length
                ? expectNextBlockShape[index]
                : 0;
        Block.drawCell(
          canvas,
          OffsetInt(dx: x, dy: y),
          offset: Offset(startX, startY),
          renderColor: value == 1 ? expectNextBlockColor : Colors.transparent,
        ); //绘制被填充的单元格
      }
    }
  }

  /// 清空所有数据行
  void clear() {
    cells.clear();
    for (var i = 0; i < boardRows; i++) {
      cells.add(List.filled(boardCols, null));
    }
    scoreNumber = 0;
    levelNumber = 1;
    scoreTextComponent?.text = "0";
    levelTextComponent?.text = "My Level:  1";
  }
}
