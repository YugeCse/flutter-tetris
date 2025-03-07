import 'package:tetris/widget/block/block.dart';

/// 工具类
class Utils {
  Utils._();

  // 计算形状的填充最大值
  static (int, int) computeShpaeFillMaxNum(List<int> shape) {
    if (shape.length != 16) return (0, 0);
    int xMaxNum = 0;
    int yMaxNum = 0;
    List<int> xIndexes = [];
    for (int y = 0; y < Block.maxGridCols; y++) {
      bool yHas = false;
      for (int x = 0; x < Block.maxGridRows; x++) {
        var index = y * Block.maxGridRows + x;
        if (shape[index] == 1) {
          if (!xIndexes.contains(x)) {
            xIndexes.add(x);
            xMaxNum++;
          }
          yHas = true;
        }
      }
      if (yHas) yMaxNum++;
    }
    // debugPrint('xMaxNum: $xMaxNum, yMaxNum: $yMaxNum');
    return (xMaxNum, yMaxNum);
  }
}
