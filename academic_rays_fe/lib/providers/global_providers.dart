import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import '../database/note_repository.dart';
import '../services/settings_service.dart';
import '../services/interfaces.dart';
import '../services/gemini_service.dart';
import '../services/ocr_service.dart';
import '../pipeline/pipeline_manager.dart';

// --- Database & Repository Providers ---

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepository(ref.watch(databaseProvider));
});

// --- Service Providers ---

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

// We provide an IOcrService but it could be toggled between Local/Cloud
final ocrServiceProvider = Provider<IOcrService>((ref) {
  // Ideally, read from settings to decide which service to return
  // For now, defaulting to Local placeholder
  return LocalOcrService();
});

// LLM service requires an API key
final llmServiceProvider = FutureProvider<ILlmService>((ref) async {
  final settings = ref.watch(settingsServiceProvider);
  final apiKey = await settings.getGeminiApiKey();
  if (apiKey == null || apiKey.isEmpty) {
    throw Exception("Gemini API Key is not set in Settings.");
  }
  return GeminiLlmService(apiKey);
});

// --- Pipeline Manager Provider ---

final pipelineManagerProvider = FutureProvider<NotePipelineManager>((ref) async {
  final repository = ref.watch(noteRepositoryProvider);
  final ocr = ref.watch(ocrServiceProvider);
  final llm = await ref.watch(llmServiceProvider.future);

  return NotePipelineManager(
    repository: repository,
    ocrService: ocr,
    llmService: llm,
  );
});

// --- Data Streams Providers ---

final notesStreamProvider = StreamProvider<List<Note>>((ref) {
  return ref.watch(noteRepositoryProvider).watchAllNotes();
});

final subjectsStreamProvider = StreamProvider<List<Subject>>((ref) {
  return ref.watch(noteRepositoryProvider).watchAllSubjects();
});
