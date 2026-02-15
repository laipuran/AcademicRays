import 'dart:io';
import 'note_steps.dart';
import '../database/note_repository.dart';
import '../services/interfaces.dart';

class NotePipelineManager {
  final NoteRepository repository;
  final IOcrService ocrService;
  final ILlmService llmService;

  NotePipelineManager({
    required this.repository,
    required this.ocrService,
    required this.llmService,
  });

  /// Orchestrates the full process from an image file to a saved note.
  Future<void> processCapture(int captureId, File image, {int? subjectId}) async {
    try {
      // 1. Update status to processing
      await repository.updateCaptureStatus(captureId, 'processing');

      // 2. OCR Step
      final ocrStep = OcrStep(ocrService);
      final rawText = await ocrStep.execute(image);

      // 3. LLM Step
      final structureStep = StructureStep(llmService);
      final structuredNote = await structureStep.execute(rawText);

      // 4. Storage Step
      final storageStep = StorageStep(repository, subjectId: subjectId, rawText: rawText);
      await storageStep.execute(structuredNote);

      // 5. Mark Capture as completed
      await repository.updateCaptureStatus(captureId, 'completed');
    } catch (e) {
      await repository.updateCaptureStatus(captureId, 'error');
      rethrow;
    }
  }
}
