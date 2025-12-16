import 'package:flutter_test/flutter_test.dart';
import 'package:quill_web_editor/src/core/constants/editor_config.dart';
import 'package:quill_web_editor/src/core/utils/html_cleaner.dart';

/// Tests for HtmlCleaner utility.
///
/// These tests verify that:
/// - Editor artifacts are properly removed
/// - Content is preserved correctly
/// - Color normalization works
/// - Text extraction works
void main() {
  // ============================================
  // HTML Cleaning Tests
  // ============================================
  group('HTML Cleaning Tests', () {
    test('Should remove temporary tags', () {
      const html = '<p>Text</p><temporary>artifact</temporary><p>More</p>';
      final cleaned = HtmlCleaner.cleanForExport(html);

      expect(cleaned.contains('<temporary'), isFalse);
      expect(cleaned.contains('artifact'), isFalse);
      expect(cleaned.contains('Text'), isTrue);
      expect(cleaned.contains('More'), isTrue);
    });

    test('Should remove ql-cell-focused class', () {
      const html = '<td class="ql-cell-focused">Cell</td>';
      final cleaned = HtmlCleaner.cleanForExport(html);

      expect(cleaned.contains('ql-cell-focused'), isFalse);
      expect(cleaned.contains('Cell'), isTrue);
    });

    test('Should remove ql-table-selected class', () {
      const html = '<table class="ql-table-selected"><tr><td>Cell</td></tr></table>';
      final cleaned = HtmlCleaner.cleanForExport(html);

      expect(cleaned.contains('ql-table-selected'), isFalse);
    });

    test('Should remove ql-table-better selection classes', () {
      const html = '''
<td class="ql-table-better-selected-td">Cell 1</td>
<div class="ql-table-better-selection-line">Line</div>
<div class="ql-table-better-selection-block">Block</div>
''';
      final cleaned = HtmlCleaner.cleanForExport(html);

      expect(cleaned.contains('ql-table-better-selected-td'), isFalse);
      expect(cleaned.contains('ql-table-better-selection-line'), isFalse);
      expect(cleaned.contains('ql-table-better-selection-block'), isFalse);
    });

    test('Should remove data-row attribute', () {
      const html = '<td data-row="1">Cell</td>';
      final cleaned = HtmlCleaner.cleanForExport(html);

      expect(cleaned.contains('data-row'), isFalse);
    });

    test('Should remove data-cell attribute', () {
      const html = '<td data-cell="abc123">Cell</td>';
      final cleaned = HtmlCleaner.cleanForExport(html);

      expect(cleaned.contains('data-cell'), isFalse);
    });

    test('Should remove contenteditable attribute', () {
      const html = '<td contenteditable="true">Cell</td>';
      final cleaned = HtmlCleaner.cleanForExport(html);

      expect(cleaned.contains('contenteditable'), isFalse);
    });

    test('Should preserve user classes', () {
      const html = '<p class="my-custom-class ql-cell-focused">Text</p>';
      final cleaned = HtmlCleaner.cleanForExport(html);

      expect(cleaned.contains('my-custom-class'), isTrue);
      expect(cleaned.contains('ql-cell-focused'), isFalse);
    });

    test('Should preserve user styling', () {
      const html = '<span style="color: red; font-size: 16px;">Styled</span>';
      final cleaned = HtmlCleaner.cleanForExport(html);

      expect(cleaned.contains('color: red'), isTrue);
      expect(cleaned.contains('font-size: 16px'), isTrue);
    });

    test('Should preserve font classes', () {
      const html = '<span class="ql-font-roboto ql-cell-focused">Font</span>';
      final cleaned = HtmlCleaner.cleanForExport(html);

      expect(cleaned.contains('ql-font-roboto'), isTrue);
      expect(cleaned.contains('ql-cell-focused'), isFalse);
    });

    test('Should preserve size classes', () {
      const html = '<span class="ql-size-large">Large</span>';
      final cleaned = HtmlCleaner.cleanForExport(html);

      expect(cleaned.contains('ql-size-large'), isTrue);
    });

    test('Should clean up empty class attributes', () {
      const html = '<td class="">Cell</td>';
      final cleaned = HtmlCleaner.cleanForExport(html);

      expect(cleaned.contains('class=""'), isFalse);
    });

    test('Should handle complex table with mixed classes', () {
      const html = '''
<table class="ql-table-selected my-table">
  <tr>
    <td class="ql-cell-focused header-cell">Header</td>
    <td data-cell="abc" class="ql-cell-selected">Data</td>
  </tr>
</table>
''';
      final cleaned = HtmlCleaner.cleanForExport(html);

      // Artifact classes should be removed
      expect(cleaned.contains('ql-table-selected'), isFalse);
      expect(cleaned.contains('ql-cell-focused'), isFalse);
      expect(cleaned.contains('ql-cell-selected'), isFalse);
      expect(cleaned.contains('data-cell'), isFalse);

      // User classes should be preserved
      expect(cleaned.contains('my-table'), isTrue);
      expect(cleaned.contains('header-cell'), isTrue);

      // Content should be preserved
      expect(cleaned.contains('Header'), isTrue);
      expect(cleaned.contains('Data'), isTrue);
    });
  });

  // ============================================
  // Text Extraction Tests
  // ============================================
  group('Text Extraction Tests', () {
    test('Should extract text from simple HTML', () {
      const html = '<p>Hello World</p>';
      final text = HtmlCleaner.extractText(html);

      expect(text, equals('Hello World'));
    });

    test('Should extract text from nested HTML', () {
      const html = '<p><strong><em>Bold Italic</em></strong> text</p>';
      final text = HtmlCleaner.extractText(html);

      expect(text.contains('Bold Italic'), isTrue);
      expect(text.contains('text'), isTrue);
    });

    test('Should handle multiple paragraphs', () {
      const html = '<p>First</p><p>Second</p><p>Third</p>';
      final text = HtmlCleaner.extractText(html);

      expect(text.contains('First'), isTrue);
      expect(text.contains('Second'), isTrue);
      expect(text.contains('Third'), isTrue);
    });

    test('Should normalize whitespace', () {
      const html = '<p>Multiple    spaces</p>';
      final text = HtmlCleaner.extractText(html);

      expect(text, equals('Multiple spaces'));
    });

    test('Should handle empty HTML', () {
      const html = '';
      final text = HtmlCleaner.extractText(html);

      expect(text, isEmpty);
    });

    test('Should handle HTML with only tags', () {
      const html = '<p></p><br><div></div>';
      final text = HtmlCleaner.extractText(html);

      expect(text, isEmpty);
    });
  });

  // ============================================
  // Empty Check Tests
  // ============================================
  group('Empty Check Tests', () {
    test('Should return true for empty string', () {
      expect(HtmlCleaner.isEmpty(''), isTrue);
    });

    test('Should return true for empty paragraph', () {
      expect(HtmlCleaner.isEmpty('<p></p>'), isTrue);
    });

    test('Should return true for whitespace only', () {
      expect(HtmlCleaner.isEmpty('<p>   </p>'), isTrue);
    });

    test('Should return true for break only', () {
      expect(HtmlCleaner.isEmpty('<p><br></p>'), isTrue);
    });

    test('Should return false for paragraph with text', () {
      expect(HtmlCleaner.isEmpty('<p>Content</p>'), isFalse);
    });
  });

  // ============================================
  // Color Normalization Tests
  // ============================================
  group('Color Normalization Tests', () {
    test('Should preserve hex colors', () {
      expect(HtmlCleaner.normalizeColor('#ff0000'), equals('#ff0000'));
      expect(HtmlCleaner.normalizeColor('#00ff00'), equals('#00ff00'));
      expect(HtmlCleaner.normalizeColor('#0000ff'), equals('#0000ff'));
    });

    test('Should convert RGB to hex', () {
      expect(HtmlCleaner.normalizeColor('rgb(255, 0, 0)'), equals('#ff0000'));
      expect(HtmlCleaner.normalizeColor('rgb(0, 255, 0)'), equals('#00ff00'));
      expect(HtmlCleaner.normalizeColor('rgb(0, 0, 255)'), equals('#0000ff'));
    });

    test('Should convert RGBA to hex (ignoring alpha)', () {
      expect(
        HtmlCleaner.normalizeColor('rgba(255, 0, 0, 0.5)'),
        equals('#ff0000'),
      );
      expect(
        HtmlCleaner.normalizeColor('rgba(0, 128, 255, 1)'),
        equals('#0080ff'),
      );
    });

    test('Should handle RGB with different spacing', () {
      expect(HtmlCleaner.normalizeColor('rgb(255,0,0)'), equals('#ff0000'));
      expect(HtmlCleaner.normalizeColor('rgb(255,  0,  0)'), equals('#ff0000'));
    });

    test('Should return null for empty string', () {
      expect(HtmlCleaner.normalizeColor(''), isNull);
    });

    test('Should return null for null input', () {
      expect(HtmlCleaner.normalizeColor(null), isNull);
    });

    test('Should preserve named colors', () {
      expect(HtmlCleaner.normalizeColor('red'), equals('red'));
      expect(HtmlCleaner.normalizeColor('blue'), equals('blue'));
    });

    test('Should handle colors with whitespace', () {
      expect(HtmlCleaner.normalizeColor('  #ff0000  '), equals('#ff0000'));
    });
  });

  // ============================================
  // Editor Config Tests
  // ============================================
  group('Editor Config Tests', () {
    test('Should have all artifact classes defined', () {
      expect(EditorConfig.editorArtifactClasses, isNotEmpty);
      expect(
        EditorConfig.editorArtifactClasses.contains('ql-cell-focused'),
        isTrue,
      );
      expect(
        EditorConfig.editorArtifactClasses.contains('ql-table-selected'),
        isTrue,
      );
      expect(
        EditorConfig.editorArtifactClasses.contains('ql-cell-selected'),
        isTrue,
      );
    });

    test('Should have all artifact attributes defined', () {
      expect(EditorConfig.editorArtifactAttributes, isNotEmpty);
      expect(
        EditorConfig.editorArtifactAttributes.contains('data-row'),
        isTrue,
      );
      expect(
        EditorConfig.editorArtifactAttributes.contains('data-cell'),
        isTrue,
      );
      expect(
        EditorConfig.editorArtifactAttributes.contains('contenteditable'),
        isTrue,
      );
    });
  });
}

