import 'dart:io';

/// Interface for OCR services
abstract class IOcrService {
  /// Extracts text from an image file
  Future<String> extractText(File image);
}

/// A structured representation of a note after LLM processing
class StructuredNote {
  final String title;
  final String markdownContent;
  final List<String> keywords;

  StructuredNote({
    required this.title,
    required this.markdownContent,
    this.keywords = const [],
  });
}

/// Interface for LLM services
abstract class ILlmService {
  /// Processes raw text (from OCR) into a structured markdown note
  Future<StructuredNote> processNote(String rawText, {String? context});
}
