import 'database.dart';
import 'package:drift/drift.dart';

class NoteRepository {
  final AppDatabase db;

  NoteRepository(this.db);

  // --- Subjects ---

  Future<List<Subject>> getAllSubjects() => db.select(db.subjects).get();

  Stream<List<Subject>> watchAllSubjects() => db.select(db.subjects).watch();

  Future<int> addSubject(String name, {int? color}) {
    return db.into(db.subjects).insert(
          SubjectsCompanion.insert(
            name: name,
            color: Value(color),
          ),
        );
  }

  // --- Captures ---

  Future<int> addCapture(String path, {double? lat, double? lng}) {
    return db.into(db.captures).insert(
          CapturesCompanion.insert(
            localPath: path,
            latitude: Value(lat),
            longitude: Value(lng),
          ),
        );
  }

  Future<void> updateCaptureStatus(int id, String status) {
    return (db.update(db.captures)..where((t) => t.id.equals(id))).write(
      CapturesCompanion(status: Value(status)),
    );
  }

  // --- Notes ---

  Future<int> createNote({
    int? subjectId,
    String? markdown,
    String? rawText,
  }) {
    return db.into(db.notes).insert(
          NotesCompanion.insert(
            subjectId: Value(subjectId),
            markdownContent: Value(markdown),
            rawText: Value(rawText),
          ),
        );
  }

  Stream<List<Note>> watchNotesForSubject(int subjectId) {
    return (db.select(db.notes)..where((t) => t.subjectId.equals(subjectId)))
        .watch();
  }

  Stream<List<Note>> watchAllNotes() => db.select(db.notes).watch();

  Future<Note?> getNoteById(int id) {
    return (db.select(db.notes)..where((t) => t.id.equals(id))).getSingleOrNull();
  }
}
