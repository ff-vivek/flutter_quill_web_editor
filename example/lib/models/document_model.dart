import 'package:hive/hive.dart';

part 'document_model.g.dart';

/// Model for saved HTML documents
@HiveType(typeId: 0)
class SavedDocument extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String html;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  DateTime updatedAt;

  @HiveField(5)
  int wordCount;

  @HiveField(6)
  int charCount;

  SavedDocument({
    required this.id,
    required this.title,
    required this.html,
    required this.createdAt,
    required this.updatedAt,
    this.wordCount = 0,
    this.charCount = 0,
  });

  /// Create a new document with default values
  factory SavedDocument.create({
    required String id,
    String title = 'Untitled Document',
    String html = '',
    int wordCount = 0,
    int charCount = 0,
  }) {
    final now = DateTime.now();
    return SavedDocument(
      id: id,
      title: title,
      html: html,
      createdAt: now,
      updatedAt: now,
      wordCount: wordCount,
      charCount: charCount,
    );
  }

  /// Update document content
  void updateContent({
    String? title,
    String? html,
    int? wordCount,
    int? charCount,
  }) {
    if (title != null) this.title = title;
    if (html != null) this.html = html;
    if (wordCount != null) this.wordCount = wordCount;
    if (charCount != null) this.charCount = charCount;
    updatedAt = DateTime.now();
  }

  /// Get preview text from HTML (strips tags)
  String get previewText {
    final text = html
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (text.length > 150) {
      return '${text.substring(0, 150)}...';
    }
    return text.isEmpty ? 'Empty document' : text;
  }
}

