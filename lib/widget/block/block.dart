import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:tetris/data/offset_int.dart';
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
          var rect = RRect.fromLTRBR(
            x * gridSize + 2,
            y * gridSize + 2,
            (x + 1) * gridSize - 2,
            (y + 1) * gridSize - 2,
            Radius.circular(3),
          );
          canvas.drawRRect(
            rect.deflate(2.0),
            Paint()
              ..strokeWidth = 3.0
              ..color = tetrisColor
              ..style = PaintingStyle.stroke,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              rect.deflate(gridSize / 4.2).outerRect,
              Radius.circular(3),
            ),
            Paint()
              ..color = tetrisColor
              ..style = PaintingStyle.fill,
          );
        }
      }
    }
  }

  /// 绘制方块的默认颜色
  static const defaultRenderColor = Color.fromARGB(255, 34, 34, 34);

  /// 绘制单元格
  /// - canvas: 画布
  /// - x, y: 单元格坐标
  /// - renderColor: 单元格颜色
  /// - startX, startY: 绘制起始坐标
  static void drawCell(
    Canvas canvas,
    OffsetInt coordinate, {
    Offset offset = Offset.zero,
    Color renderColor = defaultRenderColor,
  }) {
    var paint = Paint();
    var rect = RRect.fromLTRBR(
      (offset.dx + coordinate.dx) * Block.gridSize + 2,
      (offset.dy + coordinate.dy) * Block.gridSize + 2,
      (offset.dx + coordinate.dx + 1) * Block.gridSize - 2,
      (offset.dy + coordinate.dy + 1) * Block.gridSize - 2,
      Radius.circular(5),
    );
    canvas.drawRRect(
      rect.deflate(2.0),
      paint
        ..strokeWidth = 3.0
        ..color = renderColor
        ..style = PaintingStyle.stroke,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.deflate(Block.gridSize / 4.2).outerRect,
        Radius.circular(3),
      ),
      paint
        ..color = renderColor
        ..style = PaintingStyle.fill,
    );
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
