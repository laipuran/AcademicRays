import 'dart:typed_data';
import 'dart:ui';
import 'package:dartcv4/dartcv.dart' as cv;
import 'pipeline_interface.dart';

/// 纸张边缘检测任务
/// 返回纸张四个顶点的坐标列表
class EdgeDetectionJob extends ImageProcessingJob<List<Offset>> {
  @override
  Future<List<Offset>> process(Uint8List imageData) async {
    cv.Mat? mat;
    cv.Mat? gray;
    cv.Mat? blurred;
    cv.Mat? edged;
    cv.VecVecPoint? contours;

    try {
      // 1. 从 Uint8List 加载图片
      mat = cv.imdecode(imageData, cv.IMREAD_COLOR);
      if (mat.isEmpty) {
        throw Exception("Failed to decode image data");
      }

      // 2. 预处理：灰度化和高斯模糊减噪
      gray = cv.cvtColor(mat, cv.COLOR_BGR2GRAY);
      // 增加高斯模糊核大小，以平滑掉文字细节，避免检测到由于文字对比度产生的边缘
      blurred = cv.gaussianBlur(gray, (11, 11), 0);

      // 3. Canny 边缘检测
      edged = cv.canny(blurred, 75, 200);

      // 增加膨胀操作，连接断裂的边缘 (由于光照阴影可能导致边缘不连续)
      final kernel = cv.getStructuringElement(cv.MORPH_RECT, (9, 9));
      final dilated = cv.dilate(edged, kernel);
      kernel.dispose(); // 及时释放资源
      edged.dispose(); // 释放旧的 edged
      edged = dilated;

      // 4. 查找轮廓并按面积排序
      // 使用 RETR_EXTERNAL 只查找最外层轮廓，忽略书本内部的文字轮廓
      final contoursResult = cv.findContours(edged, cv.RETR_EXTERNAL, cv.CHAIN_APPROX_SIMPLE);
      contours = contoursResult.$1;
      
      final sortedContours = contours.toList()
        ..sort((a, b) => cv.contourArea(b).compareTo(cv.contourArea(a)));

      // 计算最小有效面积 (例如图像总面积的 5%)
      final imageArea = mat.rows * mat.cols;
      final minArea = imageArea * 0.05;

      for (var contour in sortedContours) {
        // 面积过滤
        if (cv.contourArea(contour) < minArea) continue;

        // 计算周长并进行多边形逼近
        final peri = cv.arcLength(contour, true);
        final approx = cv.approxPolyDP(contour, 0.02 * peri, true);

        // 如果逼近后正好是 4 个点，则认为找到了纸张边缘
        if (approx.length == 4) {
          final points = <Offset>[];
          for (var i = 0; i < 4; i++) {
            final p = approx[i];
            points.add(Offset(p.x.toDouble(), p.y.toDouble()));
          }
          approx.dispose();
          return _normalizePoints(points);
        }
        approx.dispose();
      }

      return [];
    } finally {
      // 确保资源被释放
      mat?.release();
      gray?.release();
      blurred?.release();
      edged?.release();
      contours?.dispose();
    }
  }

  /// 对顶点进行排序，确保顺序为：左上, 右上, 右下, 左下
  List<Offset> _normalizePoints(List<Offset> points) {
    if (points.length != 4) return points;

    // 按照 y 坐标排序
    points.sort((a, b) => a.dy.compareTo(b.dy));
    
    // 前两个是上部点，后两个是下部点
    var topPoints = points.sublist(0, 2);
    var bottomPoints = points.sublist(2, 4);

    // 比较 x 坐标确定左右
    topPoints.sort((a, b) => a.dx.compareTo(b.dx));
    bottomPoints.sort((a, b) => a.dx.compareTo(b.dx));

    return [
      topPoints[0],    // 左上
      topPoints[1],    // 右上
      bottomPoints[1], // 右下
      bottomPoints[0], // 左下
    ];
  }
}
