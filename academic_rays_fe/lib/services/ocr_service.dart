import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'interfaces.dart';

/// Simple placeholder for Local OCR (e.g. Google ML Kit)
class LocalOcrService implements IOcrService {
  @override
  Future<String> extractText(File image) async {
    // Simulating delay
    await Future.delayed(const Duration(seconds: 1));
    return "This is a simulated OCR result from a local model for ${image.path}";
  }
}

/// Implementation of OCR using Zhipu GLM-4.6V API
class GlmOcrService implements IOcrService {
  final String apiKey;
  final Dio _dio = Dio();
  final String model;
  final String prompt;

  static const String defaultPrompt = r'''
Role: 你是一个极致追求“视觉还原”的 OCR 专家。你精通将手写或印刷图像精准转化为数字文本，重点在于对字符形状的忠实记录。
Task: 将上传图像中的所有文本、符号、公式完整还原为 Markdown 格式，对数学/科学符号使用 LaTeX。
Strict Rules (识别准则):
1. 视觉优先 (Visual-Centric): 必须按照视觉看到的字符形状进行转写。即便符号在逻辑上不通顺、存在笔误或不符合常规定义，也必须还原其“本貌”，严禁根据所谓的“学科常识”进行猜测、修正或补全。
2. 去知识化 (Subject-Agnostic): 处理符号时不带有任何学科预设。不论是数学、物理还是化学符号，均视为单纯的几何图形与字符组合。严禁将模糊的 A 修正为 Delta，除非它在视觉上确实更接近 Delta。
3. 符号映射原则: 维持视觉形状的连续性。手写的波浪线转为 \sim，手写的撇号、下标、分式需准确捕捉其相对位置。
4. 布局保持 (Non-Invasive): 严格保持原始板书的行间距、缩进和序号习惯（如 ①, (a), [1] 等）。对于矩阵或类矩阵结构，使用 \begin{bmatrix} ... \end{bmatrix} 还原其空间排布。
5. 禁止解释与润色: 严禁输出任何评论、解题步骤、补全或“优化”后的表达。输出应是图像内容的纯净映射。
6. 格式化规范: 变量和公式必须使用 $ $ 包裹。确保 LaTeX 语法闭合，严禁出现括号不匹配。
Output Format: 直接输出转写结果，不含任何引言、解释或标注。''';

  GlmOcrService({
    required this.apiKey,
    this.model = 'glm-4.6v-flash',
    this.prompt = defaultPrompt,
  });

  @override
  Future<String> extractText(File image) async {
    try {
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await _dio.post(
        'https://open.bigmodel.cn/api/paas/v4/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': model,
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text': prompt,
                },
                {
                  'type': 'image_url',
                  'image_url': {
                    'url': 'data:image/jpeg;base64,$base64Image',
                  }
                }
              ]
            }
          ],
          'thinking': {
            'type': 'enabled',
          },
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return data['choices'][0]['message']['content'] as String;
      } else {
        throw Exception('GLM API returned status ${response.statusCode}: ${response.data}');
      }
    } on DioException catch (e) {
      final errorData = e.response?.data;
      throw Exception('GLM OCR request failed: ${e.message}. Status: ${e.response?.statusCode}. Data: $errorData');
    } catch (e) {
      throw Exception('GLM OCR failed: $e');
    }
  }
}
