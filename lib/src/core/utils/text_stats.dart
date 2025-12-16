import 'html_cleaner.dart';

/// Utility class for calculating text statistics.
abstract class TextStats {
  /// Calculates statistics from HTML content.
  static TextStatistics fromHtml(String html) {
    final text = HtmlCleaner.extractText(html);
    return fromText(text);
  }

  /// Calculates statistics from plain text.
  static TextStatistics fromText(String text) {
    final trimmedText = text.trim();

    if (trimmedText.isEmpty) {
      return const TextStatistics(
        wordCount: 0,
        charCount: 0,
        charCountNoSpaces: 0,
        paragraphCount: 0,
        sentenceCount: 0,
      );
    }

    // Word count: split by whitespace
    final words = trimmedText.split(RegExp(r'\s+'));
    final wordCount = words.where((w) => w.isNotEmpty).length;

    // Character counts
    final charCount = trimmedText.length;
    final charCountNoSpaces = trimmedText.replaceAll(RegExp(r'\s'), '').length;

    // Paragraph count (double line breaks or single for simple count)
    final paragraphs = trimmedText.split(RegExp(r'\n\s*\n'));
    final paragraphCount = paragraphs.where((p) => p.trim().isNotEmpty).length;

    // Sentence count (rough approximation)
    final sentences = trimmedText.split(RegExp(r'[.!?]+'));
    final sentenceCount = sentences.where((s) => s.trim().isNotEmpty).length;

    return TextStatistics(
      wordCount: wordCount,
      charCount: charCount,
      charCountNoSpaces: charCountNoSpaces,
      paragraphCount: paragraphCount > 0 ? paragraphCount : 1,
      sentenceCount: sentenceCount,
    );
  }

  /// Estimates reading time in minutes.
  ///
  /// Uses average reading speed of 200 words per minute.
  static int estimateReadingTime(int wordCount, {int wordsPerMinute = 200}) {
    if (wordCount == 0) return 0;
    return (wordCount / wordsPerMinute).ceil();
  }
}

/// Statistics about text content.
class TextStatistics {
  const TextStatistics({
    required this.wordCount,
    required this.charCount,
    required this.charCountNoSpaces,
    required this.paragraphCount,
    required this.sentenceCount,
  });

  /// Number of words
  final int wordCount;

  /// Number of characters (including spaces)
  final int charCount;

  /// Number of characters (excluding spaces)
  final int charCountNoSpaces;

  /// Number of paragraphs
  final int paragraphCount;

  /// Number of sentences (approximate)
  final int sentenceCount;

  /// Estimated reading time in minutes
  int get readingTimeMinutes => TextStats.estimateReadingTime(wordCount);

  @override
  String toString() {
    return 'TextStatistics(words: $wordCount, chars: $charCount, paragraphs: $paragraphCount)';
  }
}

