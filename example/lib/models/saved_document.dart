import 'package:hive/hive.dart';

part 'saved_document.g.dart';

@HiveType(typeId: 0)
class SavedDocument extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String htmlContent;

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
    required this.htmlContent,
    required this.createdAt,
    required this.updatedAt,
    this.wordCount = 0,
    this.charCount = 0,
  });

  SavedDocument copyWith({
    String? id,
    String? title,
    String? htmlContent,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? wordCount,
    int? charCount,
  }) {
    return SavedDocument(
      id: id ?? this.id,
      title: title ?? this.title,
      htmlContent: htmlContent ?? this.htmlContent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      wordCount: wordCount ?? this.wordCount,
      charCount: charCount ?? this.charCount,
    );
  }
}

