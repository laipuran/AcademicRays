import 'dart:typed_data';
import 'dart:ui';
import 'pipeline_interface.dart';

/// 纸张边缘检测任务
/// 返回纸张四个顶点的坐标列表
class EdgeDetectionJob implements ImageProcessingJob<List<Offset>> {
  JobStatus _status = JobStatus.idle;
  List<Offset>? _lastResult;

  @override
  JobStatus get status => _status;

  @override
  List<Offset>? get lastResult => _lastResult;

  @override
  Future<List<Offset>> execute(Uint8List imageData) async {
    _status = JobStatus.processing;
    try {
      // TODO: 集成 OpenCV 或端侧边缘检测模型
      await Future.delayed(const Duration(milliseconds: 500)); // 模拟耗时
      
      _lastResult = [
        const Offset(0, 0),
        const Offset(100, 0),
        const Offset(100, 200),
        const Offset(0, 200),
      ];
      
      _status = JobStatus.completed;
      return _lastResult!;
    } catch (e) {
      _status = JobStatus.error;
      rethrow;
    }
  }
}
