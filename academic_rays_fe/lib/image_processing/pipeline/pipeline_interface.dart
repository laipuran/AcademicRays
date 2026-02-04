import 'dart:typed_data';
import 'dart:ui';

/// 任务状态
enum JobStatus {
  idle,
  processing,
  completed,
  error,
}

/// 图片处理任务抽象接口
/// [R] 任务返回的结果类型
abstract class ImageProcessingJob<R> {
  /// 当前任务状态
  JobStatus get status;

  /// 执行任务
  /// [imageData] 输入图片的二进制数据
  Future<R> execute(Uint8List imageData);

  /// 获取最近一次处理的结果
  R? get lastResult;
}
