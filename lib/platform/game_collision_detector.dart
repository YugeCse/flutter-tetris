import 'package:tetris/block/block.dart' show Block;

/// 游戏碰撞检测器
mixin GameCollisionDetector {
  /// 检测碰撞，与边缘碰撞或者已经填充的方块碰撞
  bool isCollision(Block block);

  /// 碰撞检测2
  /// - xPosition, yPosition: 方块左上角坐标
  /// - shape: 方块形状
  bool isCollision2(double xPosition, double yPosition, List<int> shape);
}
