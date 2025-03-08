import 'dart:ui' show Color;

import 'package:tetris/block/block.dart';

/// 碰撞检测类
class Collision {
  Collision._();

  /// 检测碰撞，与边缘碰撞或者已经填充的方块碰撞
  static bool isCollision(
    Block block,
    List<List<Color?>> cells,
    int boardRows,
    int boardCols,
  ) {
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
            // debugPrint('碰撞检测：x=$bx, y=$by');
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
  static bool isCollision2(
    List<List<Color?>> boardCells,
    List<int> shapeCells,
    double xPosition,
    double yPosition,
    int boardRows,
    int boardCols,
  ) {
    for (var y = 0; y < Block.maxGridRows; y++) {
      for (var x = 0; x < Block.maxGridCols; x++) {
        var index = y * Block.maxGridCols + x;
        var value = shapeCells[index]; //获取单元格的取值
        if (value == 1) {
          var bx = (xPosition / Block.gridSize).round() + x;
          var by = (yPosition / Block.gridSize).round() + y;
          // 检查是否超出边界或与墙碰撞
          if (bx < 0 ||
              bx >= boardCols ||
              by >= boardRows ||
              (by >= 0 && boardCells[by][bx] != null)) {
            // debugPrint('碰撞检测：x=$bx, y=$by');
            return true;
          }
        }
      }
    }
    return false;
  }
}
