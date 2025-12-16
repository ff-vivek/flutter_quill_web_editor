import '../constants/editor_config.dart';

/// Utility class for cleaning and processing HTML content from the editor.
///
/// Handles removal of editor artifacts and prepares HTML for export.
abstract class HtmlCleaner {
  /// Cleans HTML by removing editor artifacts while preserving user styles.
  ///
  /// This removes:
  /// - Selection classes (ql-cell-focused, ql-table-selected, etc.)
  /// - Editor-internal data attributes
  /// - Tool/UI elements injected by the editor
  /// - Temporary tags
  static String cleanForExport(String html) {
    var cleaned = html;

    // Remove <temporary> tags (quill-table-better artifacts)
    cleaned = cleaned.replaceAll(
      RegExp(r'<temporary[^>]*>.*?</temporary>', dotAll: true),
      '',
    );
    cleaned = cleaned.replaceAll(
      RegExp(r'<temporary[^>]*><br></temporary>'),
      '',
    );

    // Remove selection classes
    for (final cls in EditorConfig.editorArtifactClasses) {
      cleaned = cleaned.replaceAllMapped(
        RegExp(r'class="([^"]*)"'),
        (match) {
          final classes = match.group(1)!;
          final updatedClasses = classes
              .split(RegExp(r'\s+'))
              .where((c) => c != cls && c.isNotEmpty)
              .join(' ');
          return updatedClasses.isEmpty ? '' : 'class="$updatedClasses"';
        },
      );
    }

    // Clean up empty class attributes
    cleaned = cleaned.replaceAll(RegExp(r'\s*class="\s*"'), '');

    // Remove editor-internal data attributes
    for (final attr in EditorConfig.editorArtifactAttributes) {
      cleaned = cleaned.replaceAll(RegExp('\\s*$attr="[^"]*"'), '');
    }

    // Remove tool/UI elements injected by editor
    cleaned = cleaned.replaceAll(
      RegExp(
        r'<div[^>]*class="[^"]*ql-table-better-[^"]*"[^>]*>.*?</div>',
        dotAll: true,
      ),
      '',
    );

    return cleaned;
  }

  /// Extracts plain text from HTML by removing all tags.
  static String extractText(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Checks if HTML content is effectively empty.
  static bool isEmpty(String html) {
    final text = extractText(html);
    return text.isEmpty;
  }

  /// Normalizes color values to hex format.
  ///
  /// Converts rgb/rgba to hex, handles named colors.
  static String? normalizeColor(String? color) {
    if (color == null || color.isEmpty) return null;

    final trimmed = color.trim();

    // Already hex
    if (trimmed.startsWith('#')) return trimmed;

    // RGB/RGBA format
    final rgbMatch = RegExp(r'rgba?\((\d+),\s*(\d+),\s*(\d+)').firstMatch(trimmed);
    if (rgbMatch != null) {
      final r = int.parse(rgbMatch.group(1)!).toRadixString(16).padLeft(2, '0');
      final g = int.parse(rgbMatch.group(2)!).toRadixString(16).padLeft(2, '0');
      final b = int.parse(rgbMatch.group(3)!).toRadixString(16).padLeft(2, '0');
      return '#$r$g$b';
    }

    return trimmed;
  }
}

