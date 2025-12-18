import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/saved_document.dart';

/// Service for managing saved documents in local storage using Hive.
class DocumentDatabase {
  static const String _boxName = 'documents';
  static Box<SavedDocument>? _box;
  static const _uuid = Uuid();

  /// Initialize the database
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(SavedDocumentAdapter());
    _box = await Hive.openBox<SavedDocument>(_boxName);
  }

  /// Get all saved documents, sorted by last updated
  static List<SavedDocument> getAllDocuments() {
    if (_box == null) return [];
    final docs = _box!.values.toList();
    docs.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return docs;
  }

  /// Get a document by ID
  static SavedDocument? getDocument(String id) {
    if (_box == null) return null;
    return _box!.get(id);
  }

  /// Create a new document
  static Future<SavedDocument> createDocument({
    required String title,
    required String htmlContent,
    int wordCount = 0,
    int charCount = 0,
  }) async {
    final now = DateTime.now();
    final doc = SavedDocument(
      id: _uuid.v4(),
      title: title,
      htmlContent: htmlContent,
      createdAt: now,
      updatedAt: now,
      wordCount: wordCount,
      charCount: charCount,
    );
    await _box?.put(doc.id, doc);
    return doc;
  }

  /// Update an existing document
  static Future<SavedDocument?> updateDocument({
    required String id,
    String? title,
    String? htmlContent,
    int? wordCount,
    int? charCount,
  }) async {
    final doc = _box?.get(id);
    if (doc == null) return null;

    final updatedDoc = doc.copyWith(
      title: title,
      htmlContent: htmlContent,
      updatedAt: DateTime.now(),
      wordCount: wordCount,
      charCount: charCount,
    );
    await _box?.put(id, updatedDoc);
    return updatedDoc;
  }

  /// Delete a document
  static Future<void> deleteDocument(String id) async {
    await _box?.delete(id);
  }

  /// Delete all documents
  static Future<void> deleteAllDocuments() async {
    await _box?.clear();
  }

  /// Check if a document exists
  static bool documentExists(String id) {
    return _box?.containsKey(id) ?? false;
  }

  /// Get total document count
  static int get documentCount => _box?.length ?? 0;

  /// Listen to changes in the documents box
  static Stream<BoxEvent>? watchDocuments() {
    return _box?.watch();
  }
}

