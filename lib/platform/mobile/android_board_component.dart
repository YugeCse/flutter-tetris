import 'dart:ui' show Image;

import 'package:flame/components.dart' hide Block;
import 'package:flame/flame.dart';
import 'package:flutter/rendering.dart';
import 'package:tetris/block/block.dart';
import 'package:tetris/platform/mobile/button/big_button_component.dart';
import 'package:tetris/platform/mobile/button/direction_button_component.dart';
import 'package:tetris/platform/mobile/button/game_button_type.dart';
import 'package:tetris/platform/mobile/button/system_button_component.dart';
import 'package:tetris/platform/mobile/game_screen_view_component.dart';

/// Android游戏面板, 背景尺寸：872x1600
class AndroidBoardComponent extends PositionComponent with HasGameRef {
  /// 游戏面板尺寸
  static final _gameBoyOriginSize = Vector2(872, 1600);

  double _gameBoyImgScale = 1.0;

  late Image _gameBoyImage;

  final double _gameBoyHeaderOriginHeight = 300.0;

  double _gameBoyHeaderHeight = 0;

  double _gameBoyFooterHeight = 0;

  double _gameBoyFooterStartClipY = 0;

  double _gameBoyFooterOriginHeight = 0;

  /// 游戏按键点击事件
  void Function(GameButtonType)? onGameButtonClick;

  /// 游戏屏幕是否加载
  bool isGameScreenViewLoaded = false;

  /// 游戏屏幕组件
  late GameScreenViewComponent gameScreenViewComponent;

  /// 游戏屏幕加载完成事件
  void Function()? onGameScreenLoaded;

  @override
  Future<void> onLoad() async {
    _gameBoyImage = await Flame.images.load('game_boy.png');
    _gameBoyImgScale = gameRef.size.x / _gameBoyOriginSize.x;
    _gameBoyFooterStartClipY = _gameBoyOriginSize.y * 0.4;
    _gameBoyFooterOriginHeight = _gameBoyOriginSize.y * 0.6;
    _gameBoyHeaderHeight = _gameBoyImgScale * _gameBoyHeaderOriginHeight;
    _gameBoyFooterHeight = _gameBoyImgScale * _gameBoyFooterOriginHeight;
    // 添加游戏显示组件
    var topMargin = _gameBoyOriginSize.y * 0.1 * _gameBoyImgScale;
    var bottomMargin = _gameBoyOriginSize.y * 0.53 * _gameBoyImgScale;
    var horizontalMargin = (_gameBoyOriginSize.x * 0.185) * _gameBoyImgScale;
    add(
      gameScreenViewComponent = GameScreenViewComponent(
        size: Vector2(
          gameRef.size.x - horizontalMargin * 2,
          gameRef.size.y - topMargin - bottomMargin,
        ),
        position: Vector2(horizontalMargin, topMargin),
      ),
    );
    isGameScreenViewLoaded = true;
    onGameScreenLoaded?.call(); //通知初始化完成
    var directionButtonSize = Vector2(
      88 * _gameBoyImgScale,
      88 * _gameBoyImgScale,
    ); //方向控制按钮的大小
    add(
      DirectionButtonComponent()
        ..onTapClick = () {
          onGameButtonClick?.call(GameButtonType.up);
        }
        ..size = directionButtonSize
        ..position = Vector2(
          (_gameBoyOriginSize.x * 0.25) * _gameBoyImgScale,
          gameRef.size.y - _gameBoyOriginSize.y * 0.366 * _gameBoyImgScale,
        )
        ..debugMode = true,
    ); //添加上按钮
    add(
      DirectionButtonComponent()
        ..onTapClick = () {
          onGameButtonClick?.call(GameButtonType.down);
        }
        ..size = directionButtonSize
        ..position = Vector2(
          (_gameBoyOriginSize.x * 0.25) * _gameBoyImgScale,
          gameRef.size.y - _gameBoyOriginSize.y * 0.2552 * _gameBoyImgScale,
        )
        ..debugMode = true,
    ); //添加下按钮
    add(
      DirectionButtonComponent()
        ..onTapClick = () {
          onGameButtonClick?.call(GameButtonType.left);
        }
        ..size = directionButtonSize
        ..position = Vector2(
          (_gameBoyOriginSize.x * 0.1472) * _gameBoyImgScale,
          gameRef.size.y - _gameBoyOriginSize.y * 0.3095 * _gameBoyImgScale,
        )
        ..debugMode = true,
    ); //添加左按钮
    add(
      DirectionButtonComponent()
        ..onTapClick = () {
          onGameButtonClick?.call(GameButtonType.right);
        }
        ..size = directionButtonSize
        ..position = Vector2(
          (_gameBoyOriginSize.x * 0.354) * _gameBoyImgScale,
          gameRef.size.y - _gameBoyOriginSize.y * 0.3095 * _gameBoyImgScale,
        )
        ..debugMode = true,
    ); //添加右按钮
    add(
      BigButtonComponent()
        ..onTapClick = () {
          onGameButtonClick?.call(GameButtonType.send);
        }
        ..position = Vector2(
          (_gameBoyOriginSize.x * 0.6945) * _gameBoyImgScale,
          gameRef.size.y - _gameBoyOriginSize.y * 0.325 * _gameBoyImgScale,
        )
        ..size = Vector2(140 * _gameBoyImgScale, 140 * _gameBoyImgScale)
        ..debugMode = true,
    ); //添加大按钮
    // 添加系统按钮组: 开始/暂停/重置, 音效, 背景音乐, 关机
    var sysButtonSize = Vector2(60 * _gameBoyImgScale, 60 * _gameBoyImgScale);
    add(
      SystemButtonComponent()
        ..onTapClick = () {
          onGameButtonClick?.call(GameButtonType.playOrPause);
        }
        ..debugMode = true
        ..size = sysButtonSize
        ..position = Vector2(
          _gameBoyOriginSize.x * 0.232 * _gameBoyImgScale,
          gameRef.size.y - _gameBoyOriginSize.y * 0.460 * _gameBoyImgScale,
        ),
    ); // 添加开始/暂停/重置按钮
    add(
      SystemButtonComponent()
        ..onTapClick = () {
          onGameButtonClick?.call(GameButtonType.soundEffect);
        }
        ..debugMode = true
        ..size = sysButtonSize
        ..position = Vector2(
          _gameBoyOriginSize.x * 0.385 * _gameBoyImgScale,
          gameRef.size.y - _gameBoyOriginSize.y * 0.460 * _gameBoyImgScale,
        ),
    ); // 添加音效按钮
    add(
      SystemButtonComponent()
        ..onTapClick = () {
          onGameButtonClick?.call(GameButtonType.bgMusic);
        }
        ..debugMode = true
        ..size = sysButtonSize
        ..position = Vector2(
          _gameBoyOriginSize.x * 0.5412 * _gameBoyImgScale,
          gameRef.size.y - _gameBoyOriginSize.y * 0.460 * _gameBoyImgScale,
        ),
    ); // 添加背景音乐按钮
    add(
      SystemButtonComponent()
        ..onTapClick = () {
          onGameButtonClick?.call(GameButtonType.shutdown);
        }
        ..debugMode = true
        ..size = sysButtonSize
        ..position = Vector2(
          _gameBoyOriginSize.x * 0.6953 * _gameBoyImgScale,
          gameRef.size.y - _gameBoyOriginSize.y * 0.460 * _gameBoyImgScale,
        ),
    ); // 添加关机按钮
  }

  /// 添加组件到游戏屏幕
  void addToGameScreen(Component component) =>
      gameScreenViewComponent.add(component);

  /// 设置预测的下一个方块
  set expectNextBlockShape(List<int> value) {
    gameScreenViewComponent.expectNextBlockShape = value;
  }

  /// 获取预测的下一个方块
  List<int> get expectNextBlockShape =>
      gameScreenViewComponent.expectNextBlockShape;

  /// 设置预测的下一个方块的颜色
  set expectNextBlockColor(Color value) {
    gameScreenViewComponent.expectNextBlockColor = value;
  }

  /// 获取预测的下一个方块的颜色
  Color get expectNextBlockColor =>
      gameScreenViewComponent.expectNextBlockColor;

  /// 合并方块到游戏面板数据中
  void mergeBlock(Block block) => gameScreenViewComponent.mergeBlock(block);

  /// 清空所有数据行
  void clear() => gameScreenViewComponent.clear();

  /// 判断方块是否碰撞
  bool isCollision(Block block) => gameScreenViewComponent.isCollision(block);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    drawGameBoyBackground(canvas); //绘制游戏面板背景
  }

  /// 绘制游戏面板背景
  /// + canvas 绘制画布对象
  /// + 说明：
  /// + a.游戏面板尺寸：872x1600
  /// + b.游戏面板背景图片：game_boy.png
  void drawGameBoyBackground(Canvas canvas) {
    var shouldRenderHeight =
        gameRef.size.y - _gameBoyHeaderHeight - _gameBoyFooterHeight;
    canvas.drawImageRect(
      _gameBoyImage,
      Rect.fromLTWH(0, 0, _gameBoyOriginSize.x, _gameBoyHeaderOriginHeight),
      Rect.fromLTWH(0, 0, gameRef.size.x, _gameBoyHeaderHeight),
      Paint()..isAntiAlias = false,
    );
    if (shouldRenderHeight > 0) {
      var imgOriginRect = Rect.fromLTWH(
        0,
        _gameBoyHeaderOriginHeight,
        _gameBoyOriginSize.x,
        _gameBoyHeaderOriginHeight + 100,
      );
      var imgDrawSize = Vector2(gameRef.size.x, _gameBoyImgScale * 100);
      var count = shouldRenderHeight / imgDrawSize.y;
      for (var i = 0; i < count; i++) {
        canvas.drawImageRect(
          _gameBoyImage,
          imgOriginRect,
          Rect.fromLTWH(
            0,
            imgDrawSize.y * i + _gameBoyHeaderHeight,
            imgDrawSize.x,
            imgDrawSize.y,
          ),
          Paint()..isAntiAlias = false,
        );
      }
    }
    canvas.drawImageRect(
      _gameBoyImage,
      Rect.fromLTWH(
        0,
        _gameBoyFooterStartClipY,
        _gameBoyOriginSize.x,
        _gameBoyFooterOriginHeight,
      ),
      Rect.fromLTWH(
        0,
        gameRef.size.y - _gameBoyFooterHeight,
        gameRef.size.x,
        _gameBoyFooterHeight,
      ),
      Paint()..isAntiAlias = false,
    );
  }
}
