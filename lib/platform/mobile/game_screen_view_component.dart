import 'dart:async';

import 'package:flame/components.dart' hide Block;
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame_svg/flame_svg.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:tetris/data/offset_int.dart';
import 'package:tetris/block/block.dart';
import 'package:tetris/platform/game_collision_detector.dart';
import 'package:tetris/utils/collision_utils.dart' show CollisionUtils;
import 'package:tetris/utils/datetime_utils.dart';
import 'package:tetris/utils/sound_utils.dart';
import 'package:tetris/utils/shape_utils.dart';

/// 游戏显示组件
class GameScreenViewComponent extends PositionComponent
    with GameCollisionDetector {
  /// 游戏视图Padding宽度
  static final double viewPadding = 8;

  /// 游戏表格行数
  int cellRowCount = 0;

  /// 游戏表格列数
  int cellColumnCount = 0;

  /// 游戏状态栏高度
  double gameStatusBarHeight = 0;

  /// 游戏视图宽度
  double gameViewportWidth = 0;

  /// 游戏视图高度
  double gameViewportHeight = 0;

  /// 游戏侧边栏视图宽度
  double sideViewportWidth = 0;

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

  /// 俄罗斯城堡图像
  Image? _tetrisCityImage;

  /// 背景音乐开启Svg资源
  Svg? _bgMusicOnSvg;

  /// 背景音乐关闭Svg资源
  Svg? _bgMusicOffSvg;

  /// 音效开启Svg资源
  Svg? _soundOnSvg;

  /// 音效关闭Svg资源
  Svg? _soundOffSvg;

  /// 预测下一个方块的标题组件
  TextComponent? _expectedNextBlockTitle;

  /// 当前得分数字组件
  TextComponent? _scoreNumberComponent;

  /// 当前等级数字组件
  TextComponent? _levelNumberComponent;

  /// 当前时间组件
  TextComponent? _dateTimeTextComponent;

  /// 背景音乐开关图标展示组件
  SvgComponent? _bgMusicSvgComponent;

  /// 音效开关图标展示组件
  SvgComponent? _soundSvgComponent;

  GameScreenViewComponent({super.size, super.position}) {
    gameStatusBarHeight = Block.gridSize * 1.2; //游戏状态栏高度，设定为2个格子高度
    gameViewportWidth = size.x - viewPadding * 2;
    gameViewportHeight = size.y - viewPadding * 2 - gameStatusBarHeight;
    cellRowCount = (gameViewportHeight / Block.gridSize).round(); //获取所有能绘制的表格数
    cellColumnCount =
        (gameViewportWidth / Block.gridSize).round(); //获取所有能绘制的表格数
    sideViewportWidth = Block.gridSize * 5; //给定边栏5个格子的数量
    cellColumnCount -= 5; //减去边栏的5个格子数量
    gameViewportWidth = cellColumnCount * Block.gridSize;
    tetrisCells = List.generate(
      cellRowCount,
      (_) => List.filled(cellColumnCount, null),
    ); //通过行数和列数构造游戏屏幕中的所有格子数据
  }

  @override
  FutureOr<void> onLoad() async {
    _tetrisCityImage = await Flame.images.load('tetris_city_mobile.png');
    _bgMusicOnSvg = await Svg.load('assets/bg_music_on.svg');
    _bgMusicOffSvg = await Svg.load('assets/bg_music_off.svg');
    _soundOnSvg = await Svg.load('assets/sound_open_black.svg');
    _soundOffSvg = await Svg.load('assets/sound_silent_black.svg');
    var titleTextRenderer = TextPaint(
      style: TextStyle(
        fontSize: 11,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
    );
    var valueTextRenderer = TextPaint(
      style: TextStyle(
        fontSize: 20,
        color: Colors.black,
        fontWeight: FontWeight.w500,
      ),
    );
    add(
      _expectedNextBlockTitle = TextComponent(
        anchor: Anchor.center,
        text: "下一个方块",
        textRenderer: titleTextRenderer,
        position:
            Vector2(cellColumnCount + 1.5, 0) * Block.gridSize +
            Vector2(0, gameStatusBarHeight + viewPadding * 2),
      ),
    );
    add(
      TextComponent(
        text: '得分：',
        textRenderer: titleTextRenderer,
        position:
            Vector2(cellColumnCount + 1.5, 6) * Block.gridSize +
            Vector2(0, gameStatusBarHeight + viewPadding * 2),
      ),
    );
    add(
      _scoreNumberComponent = TextComponent(
        text: '$scoreNumber',
        textRenderer: valueTextRenderer,
        position:
            Vector2(cellColumnCount + 1.5, 7.3) * Block.gridSize +
            Vector2(0, gameStatusBarHeight + viewPadding * 2),
      ),
    );
    add(
      TextComponent(
        text: '等级：',
        textRenderer: titleTextRenderer,
        position:
            Vector2(cellColumnCount + 1.5, 10) * Block.gridSize +
            Vector2(0, gameStatusBarHeight + viewPadding * 2),
      ),
    );
    add(
      _levelNumberComponent = TextComponent(
        text: '$levelNumber',
        textRenderer: valueTextRenderer,
        position:
            Vector2(cellColumnCount + 1.5, 11.3) * Block.gridSize +
            Vector2(0, gameStatusBarHeight + viewPadding * 2),
      ),
    );
    add(
      _dateTimeTextComponent = TextComponent(
        text: DatetimeUtils.todayTimeText,
        textRenderer: titleTextRenderer,
        position: Vector2(Block.gridSize * 0.5, viewPadding / 3.0),
      ),
    );
    add(
      _bgMusicSvgComponent = SvgComponent(
        svg: SoundUtils.isBgMusicEnabled ? _bgMusicOnSvg : _bgMusicOffSvg,
        paint:
            Paint()
              ..color = Colors.black
              ..blendMode = BlendMode.srcATop,
        size: Vector2.all(Block.gridSize * 1.0),
        position: Vector2(size.x - Block.gridSize * 1.5, viewPadding / 2),
      ),
    );
    add(
      _soundSvgComponent = SvgComponent(
        svg: SoundUtils.isSoundEffectEnabled ? _soundOnSvg : _soundOffSvg,
        position: Vector2(
          size.x - Block.gridSize * 2 - Block.gridSize,
          viewPadding / 3.0,
        ),
        size: Vector2.all(Block.gridSize * 1.2),
        paint:
            Paint()
              ..colorFilter = ColorFilter.mode(Colors.black, BlendMode.srcIn),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _expectedNextBlockTitle?.position.x =
        ((cellColumnCount + 3.5) * Block.gridSize); //更新标题的位置
    _levelNumberComponent?.text = "$levelNumber"; //更新分数
    _scoreNumberComponent?.text = "$scoreNumber"; //更新分数
    _dateTimeTextComponent?.text = DatetimeUtils.todayTimeText; //更新日期
    _bgMusicSvgComponent?.svg =
        SoundUtils.isBgMusicEnabled ? _bgMusicOnSvg : _bgMusicOffSvg; //更新背景音乐图标
    var soundSvgPaint =
        Paint()..colorFilter = ColorFilter.mode(Colors.black, BlendMode.srcIn);
    _soundSvgComponent
      ?..svg = SoundUtils.isSoundEffectEnabled ? _soundOnSvg : _soundOffSvg
      ..paint = soundSvgPaint; //更新音效图标
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    drawGameScreenBackground(canvas); //绘制游戏背景色
    drawGameAllCellBlocks(canvas); //绘制游戏屏幕中的所有格子
    drawExpectedBlock(canvas); //绘制预测的下一个方块
    // var paragraph = ParagraphBuilder(
    //   ParagraphStyle(fontStyle: FontStyle.normal, fontSize: 16),
    // );
    // // paragraph.pushStyle(TextSTyle(color: Colors.white));
    // paragraph.addText("Hello world");
    // canvas.drawParagraph(paragraph.build(), Offset(100, 100));
  }

  /// 绘制游戏屏幕背景
  void drawGameScreenBackground(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        Radius.circular(10),
      ),
      Paint()..color = const Color(0xFF6E5D51),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          viewPadding - 2,
          viewPadding - 2 + gameStatusBarHeight,
          cellColumnCount * Block.gridSize + 4,
          cellRowCount * Block.gridSize + 4,
        ),
        Radius.circular(3),
      ),
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke,
    );
    if (_tetrisCityImage != null) {
      canvas.drawImageRect(
        _tetrisCityImage!,
        Rect.fromLTWH(
          0,
          0,
          _tetrisCityImage!.width.toDouble(),
          _tetrisCityImage!.height.toDouble(),
        ),
        Rect.fromLTWH(
          (cellColumnCount + 1.2) * Block.gridSize,
          size.y - Block.gridSize * 5 - 0.5 * Block.gridSize,
          Block.gridSize * 5,
          Block.gridSize * 5,
        ),
        Paint()
          ..color = Colors.white
          ..blendMode = BlendMode.colorBurn,
      );
    }
  }

  /// 绘制游戏屏幕中的所有格子
  void drawGameAllCellBlocks(Canvas canvas) {
    for (var y = 0; y < tetrisCells.length; y++) {
      for (var x = 0; x < tetrisCells[y].length; x++) {
        Block.drawCell(
          canvas,
          OffsetInt(dx: x, dy: y),
          strokeWidth: 1.2,
          innerPadding: 0.2,
          borderRadius: 1,
          offset: Offset(
            viewPadding / Block.gridSize,
            (gameStatusBarHeight + viewPadding) / Block.gridSize,
          ),
          renderColor: tetrisCells[y][x] ?? Block.defaultRenderColor,
        );
      }
    }
  }

  /// 绘制被预测的方块
  void drawExpectedBlock(Canvas canvas) {
    if (expectNextBlockShape.isEmpty ||
        expectNextBlockShape.length != Block.maxGridCols * Block.maxGridRows) {
      return;
    }
    for (var i = 0; i < expectNextBlockShape.length; i++) {
      var x = i % Block.maxGridCols;
      var y = i ~/ Block.maxGridCols;
      var isSolid = expectNextBlockShape[y * Block.maxGridCols + x] == 1;
      var (cols, rows) = ShapeUtils.computeShpaeFillMaxNum(
        expectNextBlockShape,
      );
      var offsetCols =
          (1 +
              cellColumnCount +
              viewPadding / Block.gridSize +
              (Block.maxGridCols - cols) / 2.0);
      var offsetRows = ((gameStatusBarHeight + viewPadding) / Block.gridSize);
      Block.drawCell(
        canvas,
        OffsetInt(dx: x, dy: y),
        strokeWidth: 1.2,
        innerPadding: 0.2,
        borderRadius: 1,
        offset: Offset(offsetCols, offsetRows + 2.0),
        renderColor: isSolid ? expectNextBlockColor : Colors.transparent,
      );
    }
  }

  /// 碰撞检测2
  /// - xPosition, yPosition: 方块左上角坐标
  /// - shape: 方块形状
  @override
  bool isCollision2(double xPosition, double yPosition, List<int> shape) {
    return CollisionUtils.isCollision2(
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
  bool isCollision(Block block) => CollisionUtils.isCollision(
    block,
    tetrisCells,
    cellRowCount,
    cellColumnCount,
  );

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
        clearLineCount++; //计算清理掉的行数
        tetrisCells.removeAt(y);
        tetrisCells.insert(0, List.filled(cellColumnCount, null));
      }
    }
    if (clearLineCount > 0) {
      if (clearLineCount <= 2) {
        scoreNumber += clearLineCount;
      } else if (clearLineCount == 3) {
        scoreNumber += 5; //掉3行，得5分
      } else {
        scoreNumber += 7; //掉4行，得7分
      }
      SoundUtils.playClearLinesSound(); //播放消除音效
    } else {
      SoundUtils.playFallDownSound(); //播放下落音效
    }
  }

  /// 清空所有数据行
  void resetData() {
    tetrisCells.clear();
    for (var i = 0; i < cellRowCount; i++) {
      tetrisCells.add(List.filled(cellColumnCount, null));
    }
    scoreNumber = 0; //重置分数
    levelNumber = 1; //重置等级
    _scoreNumberComponent?.text = "0"; //重置分数
    _levelNumberComponent?.text = "1"; //重置等级
  }
}
