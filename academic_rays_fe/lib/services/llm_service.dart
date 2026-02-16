import 'dart:convert';
import 'package:dio/dio.dart';
import 'interfaces.dart';

class ZhipuLlmService implements ILlmService {
  final String apiKey;
  final Dio _dio = Dio();
  final String model;

  ZhipuLlmService(this.apiKey, {this.model = 'glm-4.6v-flash'});

  @override
  Future<StructuredNote> processNote(String rawText, {String? context}) async {
    final prompt = '''
You are an expert academic assistant. Convert the following raw OCR text from a lecture into a well-structured Markdown note.
Include:
1. A concise title.
2. Clear headings.
3. Correct LaTeX formatting for all mathematical formulas.
4. A list of key terms/keywords.

Context metadata: ${context ?? 'None'}

Raw OCR text:
$rawText

Output the result in a JSON format with "title", "markdown", and "keywords" fields. 
Return ONLY the JSON string.
''';

    try {
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
                }
              ]
            }
          ],
          'response_format': {'type': 'json_object'},
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final contentStr = data['choices'][0]['message']['content'] as String;
        final contentJson = jsonDecode(contentStr);

        return StructuredNote(
          title: contentJson['title'] ?? "Extracted Note",
          markdownContent: contentJson['markdown'] ?? "",
          keywords: List<String>.from(contentJson['keywords'] ?? []),
        );
      } else {
        throw Exception('Zhipu API returned status ${response.statusCode}: ${response.data}');
      }
    } on DioException catch (e) {
      throw Exception('Zhipu LLM request failed: ${e.message}');
    } catch (e) {
      throw Exception('Zhipu LLM failed: $e');
    }
  }
}
