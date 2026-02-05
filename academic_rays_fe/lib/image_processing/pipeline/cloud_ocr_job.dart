import 'dart:typed_data';
import 'pipeline_interface.dart';

/// 云端 AI OCR 任务
/// 将图片发送至 Gemini/Mathpix API 并返回 Markdown 文本
class CloudOcrJob extends ImageProcessingJob<String> {
  @override
  Future<String> process(Uint8List imageData) async {
    // TODO: 调用 Gemini API 或 Mathpix API
    // 1. 准备 Multi-part body
    // 2. 发起 POST 请求
    // 3. 解析返回的 JSON
    
    await Future.delayed(const Duration(seconds: 2)); // 模拟网络延迟
    
    return "# 识别结果\n这里是 AI 返回的 Markdown 内容。";
  }
}
