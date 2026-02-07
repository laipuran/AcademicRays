import 'dart:typed_data';
import 'package:meta/meta.dart';

/// 任务状态
enum JobStatus {
  idle,
  processing,
  completed,
  error,
}

/// 图片处理任务抽象基类
/// [R] 任务返回的结果类型
abstract class ImageProcessingJob<R> {
  JobStatus _status = JobStatus.idle;
  R? _lastResult;

  /// 当前任务状态
  JobStatus get status => _status;

  /// 获取最近一次处理的结果
  R? get lastResult => _lastResult;

  /// 执行任务的统一入口
  /// [imageData] 输入图片的二进制数据
  Future<R> execute(Uint8List imageData) async {
    if (_status == JobStatus.processing) {
      throw Exception("Job is already running");
    }

    _status = JobStatus.processing;
    try {
      final result = await process(imageData);
      _lastResult = result;
      _status = JobStatus.completed;
      return result;
    } catch (e) {
      _status = JobStatus.error;
      rethrow;
    }
  }

  /// 子类应实现此方法来执行具体逻辑
  @protected
  Future<R> process(Uint8List imageData);
}
