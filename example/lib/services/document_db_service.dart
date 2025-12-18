import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/document_model.dart';

/// Service for managing saved documents in local Hive database
class DocumentDbService {
  static const String _boxName = 'saved_documents';
  static Box<SavedDocument>? _box;
  static const _uuid = Uuid();

  /// Initialize Hive and open the documents box
  static Future<void> initialize() async {
    await Hive.initFlutter();
    
    // Register the adapter if not already registered
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(SavedDocumentAdapter());
    }
    
    _box = await Hive.openBox<SavedDocument>(_boxName);
  }

  /// Get all saved documents, sorted by updatedAt descending
  static List<SavedDocument> getAllDocuments() {
    if (_box == null) return [];
    final documents = _box!.values.toList();
    documents.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return documents;
  }

  /// Get a document by ID
  static SavedDocument? getDocument(String id) {
    if (_box == null) return null;
    return _box!.get(id);
  }

  /// Create a new document
  static Future<SavedDocument> createDocument({
    String title = 'Untitled Document',
    String html = '',
    int wordCount = 0,
    int charCount = 0,
  }) async {
    final id = _uuid.v4();
    final document = SavedDocument.create(
      id: id,
      title: title,
      html: html,
      wordCount: wordCount,
      charCount: charCount,
    );
    await _box?.put(id, document);
    return document;
  }

  /// Update an existing document
  static Future<void> updateDocument(SavedDocument document) async {
    document.updatedAt = DateTime.now();
    await _box?.put(document.id, document);
  }

  /// Save or update a document
  static Future<SavedDocument> saveDocument({
    String? id,
    required String title,
    required String html,
    int wordCount = 0,
    int charCount = 0,
  }) async {
    if (id != null && _box?.containsKey(id) == true) {
      final document = _box!.get(id)!;
      document.updateContent(
        title: title,
        html: html,
        wordCount: wordCount,
        charCount: charCount,
      );
      await updateDocument(document);
      return document;
    } else {
      return await createDocument(
        title: title,
        html: html,
        wordCount: wordCount,
        charCount: charCount,
      );
    }
  }

  /// Delete a document by ID
  static Future<void> deleteDocument(String id) async {
    await _box?.delete(id);
  }

  /// Delete all documents
  static Future<void> deleteAllDocuments() async {
    await _box?.clear();
  }

  /// Get the count of saved documents
  static int get documentCount => _box?.length ?? 0;

  /// Check if the service is initialized
  static bool get isInitialized => _box != null && _box!.isOpen;
}

