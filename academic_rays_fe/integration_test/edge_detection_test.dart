import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:academic_rays_fe/image_processing/pipeline/edge_detection_job.dart';
import 'package:academic_rays_fe/image_processing/pipeline/pipeline_interface.dart';
import 'package:academic_rays_fe/image_processing/pipeline/edge_visualization_widget.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('EdgeDetectionJob Integration Test', () {
    testWidgets('should detect paper edges in test_image1.jpg', (WidgetTester tester) async {
      // 1. 加载测试图片资产
      final ByteData data = await rootBundle.load('test_assets/test_image1.jpg');
      final Uint8List bytes = data.buffer.asUint8List();

      // 2. 创建任务实例
      final job = EdgeDetectionJob();

      // 3. 执行任务
      final result = await job.execute(bytes);

      // 4. 断言结果
      expect(job.status, JobStatus.completed);
      expect(result, isNotEmpty, reason: '边缘检测应该在测试图片中找到轮廓');
      expect(result.length, 4, reason: '边缘检测应该为矩形纸张返回 4 个顶点');

      print('检测到的顶点坐标: $result');

      // 5. 显示可视化结果并等待 3 秒后自动继续
      await tester.pumpWidget(MaterialApp(
        home: EdgeVisualizationWidget(
          imageData: bytes,
          points: result,
        ),
      ));

      await tester.pumpAndSettle();

      print('=== 结果将显示 3 秒钟，请检查 ===');
      
      // 使用真实时间延迟，通过循环 pump 保持 UI 渲染
      final end = DateTime.now().add(const Duration(seconds: 3));
      while (DateTime.now().isBefore(end)) {
        await tester.pump();
        // 这里的 Future.delayed 必须是真实的 Dart Future 延迟
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      print('显示结束，测试通过');
    });

    testWidgets('should throw exception for empty image data', (WidgetTester tester) async {
      final job = EdgeDetectionJob();
      
      expect(
        () => job.execute(Uint8List(0)),
        throwsA(isA<Exception>()),
        reason: '空数据应该抛出异常',
      );
    });
  });
}
