import 'package:google_generative_ai/google_generative_ai.dart';
import 'interfaces.dart';

class GeminiLlmService implements ILlmService {
  final String apiKey;
  late final GenerativeModel _model;

  GeminiLlmService(this.apiKey) {
    _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  }

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

Output the result in a JSON-like format with "title", "markdown", and "keywords".
''';

    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);
    
    // In a real implementation, we would parse the JSON from response.text
    // For now, let's do a basic extraction or return the whole text as markdown
    final text = response.text ?? '';
    
    return StructuredNote(
      title: "Extracted Note", // TODO: Better parsing
      markdownContent: text,
      keywords: [],
    );
  }
}
