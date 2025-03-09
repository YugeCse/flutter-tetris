import 'dart:math';

import 'package:flame/components.dart' hide Block;
import 'package:flame/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tetris/data/offset_int.dart';
import 'package:tetris/block/J_block.dart';
import 'package:tetris/block/j2_block.dart';
import 'package:tetris/block/l_block.dart';
import 'package:tetris/block/o_block.dart';
import 'package:tetris/block/t_block.dart';
import 'package:tetris/block/z2_block.dart';
import 'package:tetris/block/z_block.dart';
import 'package:tetris/platform/game_collision_detector.dart';
import 'package:tetris/platform/mobile/game_screen_view_component.dart';
import 'package:tetris/utils/utils.dart';

/// 所有Block的基类
abstract class Block extends PositionComponent {
  /// 单个Block最大的列数: 4
  static int maxGridCols = 4;

  /// 单个Block最大的行数: 4
  static int maxGridRows = 4;

  /// 单个Block的单元尺寸: 默认50
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
          Colors.blueAccent,
        ][Random().nextInt(5)];
    size = Vector2(gridSize * maxGridCols, gridSize * maxGridRows);
  }

  void moveLeft(GameCollisionDetector board) {
    position.x -= gridSize;
    if (board.isCollision(this)) {
      position.x += gridSize;
    }
  }

  void moveRight(GameCollisionDetector board) {
    position.x += gridSize;
    if (board.isCollision(this)) {
      position.x -= gridSize;
    }
  }

  bool moveDown(GameCollisionDetector board) {
    position.y += gridSize;
    if (board.isCollision(this)) {
      position.y -= gridSize;
      return false;
    }
    return true;
  }

  void rotate(GameCollisionDetector board) {
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
          if (kIsWeb) {
            drawCell(canvas, OffsetInt(dx: x, dy: y), renderColor: tetrisColor);
          } else {
            drawCell(
              canvas,
              OffsetInt(dx: x, dy: y),
              renderColor: tetrisColor,
              strokeWidth: 1.2,
              innerPadding: 0.2,
              borderRadius: 1,
              offset: Offset(
                GameScreenViewComponent.viewPadding / Block.gridSize,
                GameScreenViewComponent.viewPadding / Block.gridSize,
              ),
            );
          }
        }
      }
    }
  }

  /// 绘制方块的默认颜色
  static Color get defaultRenderColor {
    if (kIsWeb) {
      return Color.fromARGB(255, 34, 34, 34);
    }
    return Color.fromARGB(255, 78, 78, 78).withAlpha(80);
  }

  /// 绘制单元格
  /// - canvas: 画布
  /// - x, y: 单元格坐标
  /// - renderColor: 单元格颜色
  /// - startX, startY: 绘制起始坐标
  static void drawCell(
    Canvas canvas,
    OffsetInt coordinate, {
    double strokeWidth = 3.0,
    double innerPadding = 2.0,
    double borderRadius = 3.0,
    Offset offset = Offset.zero,
    Color? renderColor,
  }) {
    var paint = Paint();
    var rect = RRect.fromLTRBR(
      (offset.dx + coordinate.dx) * Block.gridSize + innerPadding,
      (offset.dy + coordinate.dy) * Block.gridSize + innerPadding,
      (offset.dx + coordinate.dx + 1) * Block.gridSize - innerPadding,
      (offset.dy + coordinate.dy + 1) * Block.gridSize - innerPadding,
      Radius.circular(borderRadius),
    );
    canvas.drawRRect(
      rect.deflate(innerPadding),
      paint
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..color = renderColor ?? defaultRenderColor,
    );
    var centerRect = rect.deflate(Block.gridSize / 4.2).outerRect;
    if (kIsWeb) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(centerRect, Radius.circular(borderRadius)),
        paint
          ..style = PaintingStyle.fill
          ..color = renderColor ?? defaultRenderColor,
      );
    } else {
      _drawHeartIcon(
        canvas,
        centerRect.center.toVector2(),
        renderColor ?? defaultRenderColor,
      );
    }
  }

  /// 绘制桃心
  static void _drawHeartIcon(
    Canvas canvas,
    Vector2 position,
    Color renderColor,
  ) {
    final Paint paint =
        Paint()
          ..color = renderColor
          ..style = PaintingStyle.fill;
    final double scale = 0.245; // 缩放比例
    final double offsetX = position.x; // 水平居中
    final double offsetY = position.y; // 垂直居中
    final Path path = Path();
    for (double t = 0; t <= 2 * 3.141592653589793; t += 0.01) {
      final double x = 16.0 * pow(sin(t), 3);
      final double y =
          13 * cos(t) - 5 * cos(2 * t) - 2 * cos(3 * t) - cos(4 * t);
      final double scaledX = x * scale + offsetX;
      final double scaledY = -y * scale + offsetY; // 反转 y 轴以适配屏幕坐标系
      if (t == 0) {
        path.moveTo(scaledX, scaledY);
      } else {
        path.lineTo(scaledX, scaledY);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  /// 生成不同的方块内容
  static Block generate({required int gridCols}) {
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
    int xCoordinate = ((gridCols - mxCols) / 2).floor();
    return currentBlock..position = Vector2(xCoordinate * Block.gridSize, 0);
  }
}
