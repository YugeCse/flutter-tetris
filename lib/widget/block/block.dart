import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:tetris/widget/block/J_block.dart';
import 'package:tetris/widget/block/j2_block.dart';
import 'package:tetris/widget/block/l_block.dart';
import 'package:tetris/widget/block/o_block.dart';
import 'package:tetris/widget/block/t_block.dart';
import 'package:tetris/widget/block/z2_block.dart';
import 'package:tetris/widget/block/z_block.dart';
import 'package:tetris/widget/board_component.dart';
import 'package:tetris/utils/utils.dart';

/// 所有Block的基类
abstract class Block extends PositionComponent {
  /// 单个Block最大的列数
  static int maxGridCols = 4;

  /// 单个Block最大的行数
  static int maxGridRows = 4;

  /// 单个Block的单元尺寸
  static double gridSize = 50;

  /// 所有变幻形状
  abstract List<List<int>> shapes;

  /// 当前旋转索引，从0开始
  int _curRotateIndex = 0;

  /// 当前Block的颜色
  Color tetrisColor = Colors.blue;

  // 当前形状
  List<int> get shape => shapes[_curRotateIndex];

  Block() {
    _curRotateIndex = Random().nextInt(shapes.length);
    tetrisColor =
        [
          Colors.red,
          Colors.blue,
          Colors.green,
          Colors.yellow,
          Colors.purple,
        ][Random().nextInt(5)];
    size = Vector2(gridSize * maxGridCols, gridSize * maxGridRows);
  }

  void moveLeft(BoardComponent board) {
    position.x -= gridSize;
    if (board.isCollision(this)) {
      position.x += gridSize;
    }
  }

  void moveRight(BoardComponent board) {
    position.x += gridSize;
    if (board.isCollision(this)) {
      position.x -= gridSize;
    }
  }

  bool moveDown(BoardComponent board) {
    position.y += gridSize;
    if (board.isCollision(this)) {
      position.y -= gridSize;
      return false;
    }
    return true;
  }

  void rotate(BoardComponent board) {
    var targetRotateIndex = _curRotateIndex;
    if (++targetRotateIndex < shapes.length) {
    } else {
      targetRotateIndex = 0;
    }
    if (board.isCollision2(position.x, position.y, shapes[targetRotateIndex])) {
      debugPrint('发生了碰撞，不能变形 $runtimeType');
      return;
    }
    _curRotateIndex = targetRotateIndex; //取新的形状值
    // debugPrint('rotate $_curRotateIndex, shapes = ${shapes[_curRotateIndex]}');
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    for (var y = 0; y < maxGridRows; y++) {
      for (var x = 0; x < maxGridCols; x++) {
        var index = y * maxGridCols + x;
        if (shape[index] == 1) {
          canvas.drawRRect(
            RRect.fromLTRBR(
              x * gridSize + 1,
              y * gridSize + 1,
              (x + 1) * gridSize - 1,
              (y + 1) * gridSize - 1,
              Radius.circular(5),
            ),
            Paint()..color = tetrisColor,
          );
        }
      }
    }
  }

  /// 生成不同的方块内容
  static Block generate() {
    var seed = DateTime.now().millisecondsSinceEpoch;
    final blockFactories = [
      () => LBlock(),
      () => OBlock(),
      () => JBlock(),
      () => J2Block(),
      () => ZBlock(),
      () => Z2Block(),
      () => TBlock(),
    ];
    var rand = Random(seed).nextInt(blockFactories.length);
    var currentBlock = blockFactories[rand]();
    var currentBlockShape = currentBlock.shape;
    var (mxCols, _) = Utils.computeShpaeFillMaxNum(currentBlockShape);
    int xCoordinate = ((BoardComponent.boardCols - mxCols) / 2).floor();
    return currentBlock..position = Vector2(xCoordinate * Block.gridSize, 0);
  }
}
