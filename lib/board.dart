import 'dart:async';

import 'package:flame/components.dart' hide Block;
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:tetris/block/block.dart';

/// 游戏面板类
class Board extends PositionComponent {
  /// 面板的列数
  static final int boardCols = 10;

  /// 面板的行数
  static final int boardRows = 15;

  /// 边栏区
  static final int boardSideCols = 5;

  /// 面板所有的格子数
  final List<List<Color?>> cells = [];

  /// 预测的下一个方块
  List<int> expectNextBlockShape = [];

  /// 构造函数，完成面板格子数填充和定义面板大小
  Board() {
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
        text: 'The Next Block: ',
        position: Vector2((boardCols + 1) * Block.gridSize, 0),
      ),
    );
    add(
      TextComponent(
        text: 'Score: 0',
        position: Vector2((boardCols + 1) * Block.gridSize, 6 * Block.gridSize),
      ),
    );
    add(
      SpriteComponent.fromImage(
        await Flame.images.load('tetris-city.jpg'),
        srcSize: Vector2(1200, 834),
        scale: Vector2(
          (Block.maxGridCols * Block.gridSize) / 1200,
          (Block.maxGridCols * Block.gridSize) / 1200,
        ),
        position: Vector2(
          Block.gridSize * (boardCols + 1),
          size.y - (834 * (Block.maxGridCols * Block.gridSize) / 1200),
        ),
      ),
    );
  }

  /// 检测碰撞，与边缘碰撞或者已经填充的方块碰撞
  bool isCollision(Block block) {
    for (var y = 0; y < Block.maxGridRows; y++) {
      for (var x = 0; x < Block.maxGridCols; x++) {
        var index = y * Block.maxGridCols + x;
        var value = block.shape[index];
        if (value == 1) {
          var bx = (block.position.x / Block.gridSize).floor() + x;
          var by = (block.position.y / Block.gridSize).floor() + y;
          // 检查是否超出边界或与墙碰撞
          if (bx < 0 ||
              bx >= boardCols ||
              by >= boardRows ||
              (by >= 0 && cells[by][bx] != null)) {
            debugPrint('碰撞检测：x=$bx, y=$by');
            return true;
          }
        }
      }
    }
    return false;
  }

  /// 碰撞检测2
  /// - xPosition, yPosition: 方块左上角坐标
  /// - shape: 方块形状
  bool isCollision2(double xPosition, double yPosition, List<int> shape) {
    for (var y = 0; y < Block.maxGridRows; y++) {
      for (var x = 0; x < Block.maxGridCols; x++) {
        var index = y * Block.maxGridCols + x;
        var value = shape[index];
        if (value == 1) {
          var bx = (xPosition / Block.gridSize).floor() + x;
          var by = (yPosition / Block.gridSize).floor() + y;
          // 检查是否超出边界或与墙碰撞
          if (bx < 0 ||
              bx >= boardCols ||
              by >= boardRows ||
              (by >= 0 && cells[by][bx] != null)) {
            debugPrint('碰撞检测：x=$bx, y=$by');
            return true;
          }
        }
      }
    }
    return false;
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
    for (var y = 0; y < boardRows; y++) {
      if (cells[y].every((element) => element != null)) {
        cells.removeAt(y);
        cells.insert(0, List.filled(boardCols, null));
      }
    }
  }

  @override
  void render(Canvas canvas) {
    for (var y = 0; y < boardRows; y++) {
      for (var x = 0; x < boardCols; x++) {
        if (cells[y][x] != null) {
          canvas.drawRRect(
            RRect.fromLTRBR(
              x * Block.gridSize,
              y * Block.gridSize,
              (x + 1) * Block.gridSize,
              (y + 1) * Block.gridSize,
              Radius.circular(5),
            ),
            Paint()..color = cells[y][x]!,
          );
        }
        canvas.drawRRect(
          RRect.fromLTRBR(
            x * Block.gridSize,
            y * Block.gridSize,
            (x + 1) * Block.gridSize,
            (y + 1) * Block.gridSize,
            Radius.circular(5),
          ),
          Paint()
            ..style = PaintingStyle.stroke
            ..color = const Color.fromARGB(255, 64, 64, 64),
        );
      }
    }
    drawNextBlockShape(canvas); //绘制下一个方块
  }

  /// 绘制下一个方块
  void drawNextBlockShape(Canvas canvas) {
    var startY = 1;
    var startX = Board.boardCols + 1;
    for (var y = 0; y < Block.maxGridRows; y++) {
      for (var x = 0; x < Block.maxGridCols; x++) {
        var index = y * Block.maxGridCols + x;
        var value =
            index >= 0 && index < expectNextBlockShape.length
                ? expectNextBlockShape[index]
                : 0;
        canvas.drawRRect(
          RRect.fromLTRBR(
            (startX + x) * Block.gridSize,
            (startY + y) * Block.gridSize,
            (startX + x + 1) * Block.gridSize,
            (startY + y + 1) * Block.gridSize,
            Radius.circular(5),
          ),
          Paint()
            ..color = Colors.greenAccent
            ..style = value == 1 ? PaintingStyle.fill : PaintingStyle.stroke,
        );
      }
    }
  }

  /// 清空所有数据行
  void clear() {
    cells.clear();
    for (var i = 0; i < boardRows; i++) {
      cells.add(List.filled(boardCols, null));
    }
  }
}
