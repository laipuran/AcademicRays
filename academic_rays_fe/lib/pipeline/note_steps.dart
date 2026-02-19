import 'dart:io';
import '../services/interfaces.dart';
import '../database/note_repository.dart';
import 'pipeline_base.dart';

/// Step 1: Extract text using OCR
class OcrStep extends PipelineStep<File, String> {
  final IOcrService ocrService;

  OcrStep(this.ocrService) : super('OCR Extraction');

  @override
  Future<String> execute(File input) async {
    return await ocrService.extractText(input);
  }
}

/// Step 2: Structure raw text into Markdown using LLM
class StructureStep extends PipelineStep<String, StructuredNote> {
  final ILlmService llmService;
  final String? context;

  StructureStep(this.llmService, {this.context}) : super('LLM Synthesis');

  @override
  Future<StructuredNote> execute(String input) async {
    return await llmService.processNote(input, context: context);
  }
}

/// Step 3: Save the final result to the local database
class StorageStep extends PipelineStep<StructuredNote, int> {
  final NoteRepository repository;
  final int? subjectId;
  final String rawText;

  StorageStep(this.repository, {this.subjectId, required this.rawText})
      : super('Database Storage');

  @override
  Future<int> execute(StructuredNote input) async {
    int? finalSubjectId = subjectId;
    
    // Auto-classification: if no subjectId provided, use the one from structured result
    if (finalSubjectId == null && input.subject != null) {
      finalSubjectId = await repository.getOrCreateSubject(input.subject!);
    }

    return await repository.createNote(
      subjectId: finalSubjectId,
      markdown: input.markdownContent,
      rawText: rawText,
    );
  }
}
