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
  final String? subject;

  StructuredNote({
    required this.title,
    required this.markdownContent,
    this.keywords = const [],
    this.subject,
  });
}

/// Interface for LLM services
abstract class ILlmService {
  /// Processes raw text (from OCR) into a structured markdown note
  Future<StructuredNote> processNote(String rawText, {String? context});
}
