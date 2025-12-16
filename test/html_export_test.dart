import 'package:flutter_test/flutter_test.dart';
import 'package:quill_web_editor/src/core/constants/app_fonts.dart';
import 'package:quill_web_editor/src/core/utils/export_styles.dart';

/// Tests for HTML export functionality.
///
/// These tests verify that:
/// - Generated HTML has proper structure
/// - All font classes are included in CSS
/// - All size classes are included in CSS
/// - Table styles are present
/// - Editor content is preserved correctly
void main() {
  // ============================================
  // Export Tests - HTML Structure
  // ============================================
  group('Export HTML Structure Tests', () {
    test('Should include DOCTYPE declaration', () {
      final html = ExportStyles.generateHtmlDocument('<p>Test</p>');
      expect(html.contains('<!DOCTYPE html>'), isTrue);
    });

    test('Should include UTF-8 charset meta tag', () {
      final html = ExportStyles.generateHtmlDocument('<p>Test</p>');
      expect(html.contains('charset="UTF-8"'), isTrue);
    });

    test('Should include viewport meta tag', () {
      final html = ExportStyles.generateHtmlDocument('<p>Test</p>');
      expect(html.contains('viewport'), isTrue);
    });

    test('Should include Quill CSS link', () {
      final html = ExportStyles.generateHtmlDocument('<p>Test</p>');
      expect(html.contains('quill.snow.css'), isTrue);
    });

    test('Should include quill-table-better CSS link', () {
      final html = ExportStyles.generateHtmlDocument('<p>Test</p>');
      expect(html.contains('quill-table-better.css'), isTrue);
    });

    test('Should include Google Fonts link', () {
      final html = ExportStyles.generateHtmlDocument('<p>Test</p>');
      expect(html.contains('fonts.googleapis.com'), isTrue);
    });

    test('Should include ql-editor wrapper div', () {
      final html = ExportStyles.generateHtmlDocument('<p>Test content</p>');
      expect(html.contains('<div class="ql-editor">'), isTrue);
    });

    test('Should preserve editor content in export', () {
      const content = '<p>My custom content here</p>';
      final html = ExportStyles.generateHtmlDocument(content);
      expect(html.contains('My custom content here'), isTrue);
    });

    test('Should include optional title when provided', () {
      final html = ExportStyles.generateHtmlDocument(
        '<p>Test</p>',
        title: 'My Document',
      );
      expect(html.contains('<title>My Document</title>'), isTrue);
    });
  });

  // ============================================
  // Export Tests - Font CSS Classes
  // ============================================
  group('Export Font CSS Classes Tests', () {
    test('Should include all font CSS classes from AppFonts', () {
      final css = ExportStyles.fullCss;

      for (final font in AppFonts.availableFonts) {
        if (font.value.isNotEmpty) {
          expect(
            css.contains('.ql-font-${font.value}'),
            isTrue,
            reason: 'Missing CSS class: ql-font-${font.value}',
          );
        }
      }
    });

    test('Should include correct font-family values for each font class', () {
      final css = ExportStyles.fullCss;

      expect(css.contains(".ql-font-roboto { font-family: 'Roboto'"), isTrue);
      expect(
          css.contains(".ql-font-open-sans { font-family: 'Open Sans'"), isTrue);
      expect(css.contains(".ql-font-lato { font-family: 'Lato'"), isTrue);
      expect(css.contains(".ql-font-montserrat { font-family: 'Montserrat'"),
          isTrue);
      expect(
          css.contains(
              ".ql-font-source-code { font-family: 'Source Code Pro'"),
          isTrue);
      expect(
          css.contains(".ql-font-crimson { font-family: 'Crimson Pro'"), isTrue);
      expect(
          css.contains(".ql-font-dm-sans { font-family: 'DM Sans'"), isTrue);
    });

    test('Should include all required Google Fonts in link', () {
      final stylesheets = ExportStyles.externalStylesheets;
      final fontsUrl = stylesheets.firstWhere(
        (s) => s.contains('fonts.googleapis.com'),
        orElse: () => '',
      );

      expect(fontsUrl.contains('Crimson+Pro'), isTrue);
      expect(fontsUrl.contains('DM+Sans'), isTrue);
      expect(fontsUrl.contains('Roboto'), isTrue);
      expect(fontsUrl.contains('Open+Sans'), isTrue);
      expect(fontsUrl.contains('Lato'), isTrue);
      expect(fontsUrl.contains('Montserrat'), isTrue);
      expect(fontsUrl.contains('Source+Code+Pro'), isTrue);
    });
  });

  // ============================================
  // Export Tests - Size CSS Classes
  // ============================================
  group('Export Size CSS Classes Tests', () {
    test('Should include all size CSS classes', () {
      final css = ExportStyles.fullCss;

      for (final size in AppFonts.availableSizes) {
        if (size.cssClass.isNotEmpty) {
          expect(
            css.contains('.${size.cssClass}'),
            isTrue,
            reason: 'Missing CSS class: ${size.cssClass}',
          );
        }
      }
    });

    test('Should include correct font-size values', () {
      final css = ExportStyles.fullCss;

      expect(css.contains('.ql-size-small { font-size: 0.75em; }'), isTrue);
      expect(css.contains('.ql-size-large { font-size: 1.5em; }'), isTrue);
      expect(css.contains('.ql-size-huge { font-size: 2.5em; }'), isTrue);
    });
  });

  // ============================================
  // Export Tests - Line Height CSS Classes
  // ============================================
  group('Export Line Height CSS Classes Tests', () {
    test('Should include all line height CSS classes', () {
      final css = ExportStyles.fullCss;

      for (final lineHeight in AppFonts.availableLineHeights) {
        expect(
          css.contains('.${lineHeight.cssClass}'),
          isTrue,
          reason: 'Missing CSS class: ${lineHeight.cssClass}',
        );
      }
    });

    test('Should include correct line-height values', () {
      final css = ExportStyles.fullCss;

      expect(css.contains('.ql-line-height-1 { line-height: 1; }'), isTrue);
      expect(css.contains('.ql-line-height-1-5 { line-height: 1.5; }'), isTrue);
      expect(css.contains('.ql-line-height-2 { line-height: 2; }'), isTrue);
      expect(css.contains('.ql-line-height-2-5 { line-height: 2.5; }'), isTrue);
      expect(css.contains('.ql-line-height-3 { line-height: 3; }'), isTrue);
    });
  });

  // ============================================
  // Export Tests - Table CSS Styles
  // ============================================
  group('Export Table CSS Styles Tests', () {
    test('Should include table border-collapse style', () {
      final css = ExportStyles.fullCss;
      expect(css.contains('border-collapse: collapse'), isTrue);
    });

    test('Should include table cell border style', () {
      final css = ExportStyles.fullCss;
      expect(css.contains('.ql-editor table td'), isTrue);
      expect(css.contains('border: 1px solid'), isTrue);
    });

    test('Should include table cell padding style', () {
      final css = ExportStyles.fullCss;
      expect(css.contains('padding: 8px 16px'), isTrue);
    });

    test('Should include table header row style', () {
      final css = ExportStyles.fullCss;
      expect(css.contains('table-with-header'), isTrue);
    });

    test('Should include table alignment classes', () {
      final css = ExportStyles.fullCss;
      expect(css.contains('table.align-left'), isTrue);
      expect(css.contains('table.align-center'), isTrue);
      expect(css.contains('table.align-right'), isTrue);
    });

    test('Should hide table selection artifacts', () {
      final css = ExportStyles.fullCss;
      expect(css.contains('ql-table-better-selected-td'), isTrue);
      expect(css.contains('display: none'), isTrue);
    });
  });

  // ============================================
  // Export Tests - Typography Styles
  // ============================================
  group('Export Typography Styles Tests', () {
    test('Should include heading styles (h1-h6)', () {
      final css = ExportStyles.fullCss;

      expect(css.contains('.ql-editor h1'), isTrue);
      expect(css.contains('.ql-editor h2'), isTrue);
      expect(css.contains('.ql-editor h3'), isTrue);
      expect(css.contains('.ql-editor h4'), isTrue);
      expect(css.contains('.ql-editor h5'), isTrue);
      expect(css.contains('.ql-editor h6'), isTrue);
    });

    test('Should include blockquote style with border-left', () {
      final css = ExportStyles.fullCss;
      expect(css.contains('.ql-editor blockquote'), isTrue);
      expect(css.contains('border-left'), isTrue);
    });

    test('Should include pre/code block style', () {
      final css = ExportStyles.fullCss;
      expect(css.contains('.ql-editor pre'), isTrue);
    });

    test('Should include link style', () {
      final css = ExportStyles.fullCss;
      expect(css.contains('.ql-editor a'), isTrue);
    });

    test('Should include inline code style', () {
      final css = ExportStyles.fullCss;
      expect(css.contains('.ql-editor code'), isTrue);
    });
  });

  // ============================================
  // Export Tests - Alignment & Direction Styles
  // ============================================
  group('Export Alignment & Direction Styles Tests', () {
    test('Should include all alignment classes', () {
      final css = ExportStyles.fullCss;

      expect(css.contains('.ql-align-center'), isTrue);
      expect(css.contains('.ql-align-right'), isTrue);
      expect(css.contains('.ql-align-justify'), isTrue);
    });

    test('Should include correct text-align values', () {
      final css = ExportStyles.fullCss;

      expect(css.contains('.ql-align-center { text-align: center; }'), isTrue);
      expect(css.contains('.ql-align-right { text-align: right; }'), isTrue);
      expect(css.contains('.ql-align-justify { text-align: justify; }'), isTrue);
    });

    test('Should include RTL direction style', () {
      final css = ExportStyles.fullCss;
      expect(css.contains('.ql-direction-rtl'), isTrue);
      expect(css.contains('direction: rtl'), isTrue);
    });
  });

  // ============================================
  // Export Tests - List Styles
  // ============================================
  group('Export List Styles Tests', () {
    test('Should include ul/ol list styles', () {
      final css = ExportStyles.fullCss;
      expect(css.contains('.ql-editor ul'), isTrue);
      expect(css.contains('.ql-editor ol'), isTrue);
    });

    test('Should include list padding-left', () {
      final css = ExportStyles.fullCss;
      expect(css.contains('padding-left: 24px'), isTrue);
    });

    test('Should include checklist styles', () {
      final css = ExportStyles.fullCss;
      expect(css.contains('data-checked="true"'), isTrue);
      expect(css.contains('data-checked="false"'), isTrue);
    });

    test('Should include all indent classes', () {
      final css = ExportStyles.fullCss;

      for (var i = 1; i <= 8; i++) {
        expect(
          css.contains('.ql-indent-$i'),
          isTrue,
          reason: 'Missing CSS class: ql-indent-$i',
        );
      }
    });

    test('Should include correct padding-left values for indents', () {
      final css = ExportStyles.fullCss;

      expect(css.contains('.ql-indent-1 { padding-left: 3em; }'), isTrue);
      expect(css.contains('.ql-indent-2 { padding-left: 6em; }'), isTrue);
      expect(css.contains('.ql-indent-3 { padding-left: 9em; }'), isTrue);
      expect(css.contains('.ql-indent-4 { padding-left: 12em; }'), isTrue);
    });
  });

  // ============================================
  // Export Tests - Media Styles
  // ============================================
  group('Export Media Styles Tests', () {
    test('Should include image max-width style', () {
      final css = ExportStyles.fullCss;
      expect(css.contains('.ql-editor img'), isTrue);
      expect(css.contains('max-width: 100%'), isTrue);
    });

    test('Should include iframe/video styles', () {
      final css = ExportStyles.fullCss;
      expect(css.contains('.ql-editor iframe'), isTrue);
      expect(css.contains('.ql-editor video'), isTrue);
    });

    test('Should include media alignment classes', () {
      final css = ExportStyles.fullCss;
      expect(css.contains('img.align-left'), isTrue);
      expect(css.contains('img.align-center'), isTrue);
      expect(css.contains('img.align-right'), isTrue);
    });
  });

  // ============================================
  // Export Tests - Text Formatting Styles
  // ============================================
  group('Export Text Formatting Styles Tests', () {
    test('Should include subscript (sub) style', () {
      final css = ExportStyles.fullCss;
      expect(css.contains('sub {'), isTrue);
      expect(css.contains('vertical-align: sub'), isTrue);
    });

    test('Should include superscript (sup) style', () {
      final css = ExportStyles.fullCss;
      expect(css.contains('sup {'), isTrue);
      expect(css.contains('vertical-align: super'), isTrue);
    });

    test('Should include clear floats style', () {
      final css = ExportStyles.fullCss;
      expect(css.contains('clear: both'), isTrue);
    });
  });

  // ============================================
  // Export Content Preservation Tests
  // ============================================
  group('Export Content Preservation Tests', () {
    test('Should preserve HTML content with fonts', () {
      const content = '<p><span class="ql-font-roboto">Roboto text</span></p>';
      final html = ExportStyles.generateHtmlDocument(content);

      expect(html.contains('ql-font-roboto'), isTrue);
      expect(html.contains('Roboto text'), isTrue);
    });

    test('Should preserve HTML content with multiple fonts', () {
      const content = '''
<p><span class="ql-font-roboto">Roboto</span></p>
<p><span class="ql-font-lato">Lato</span></p>
<p><span class="ql-font-montserrat">Montserrat</span></p>
''';
      final html = ExportStyles.generateHtmlDocument(content);

      expect(html.contains('ql-font-roboto'), isTrue);
      expect(html.contains('ql-font-lato'), isTrue);
      expect(html.contains('ql-font-montserrat'), isTrue);
    });

    test('Should preserve HTML content with sizes', () {
      const content = '''
<p><span class="ql-size-small">Small</span></p>
<p><span class="ql-size-large">Large</span></p>
<p><span class="ql-size-huge">Huge</span></p>
''';
      final html = ExportStyles.generateHtmlDocument(content);

      expect(html.contains('class="ql-size-small"'), isTrue);
      expect(html.contains('class="ql-size-large"'), isTrue);
      expect(html.contains('class="ql-size-huge"'), isTrue);
    });

    test('Should preserve table structure', () {
      const content = '''
<table>
  <tbody>
    <tr><td>Cell 1</td><td>Cell 2</td></tr>
    <tr><td>Cell 3</td><td>Cell 4</td></tr>
  </tbody>
</table>
''';
      final html = ExportStyles.generateHtmlDocument(content);

      expect(html.contains('<table>'), isTrue);
      expect(html.contains('<tbody>'), isTrue);
      expect(html.contains('<tr>'), isTrue);
      expect(html.contains('<td>'), isTrue);
      expect(html.contains('Cell 1'), isTrue);
    });

    test('Should preserve formatted text in tables', () {
      const content = '''
<table>
  <tbody>
    <tr><td><strong>Bold</strong></td><td><em>Italic</em></td></tr>
  </tbody>
</table>
''';
      final html = ExportStyles.generateHtmlDocument(content);

      expect(html.contains('<strong>Bold</strong>'), isTrue);
      expect(html.contains('<em>Italic</em>'), isTrue);
    });

    test('Should preserve inline styles', () {
      const content =
          '<span style="color: #ff0000; background-color: #ffff00;">Colored text</span>';
      final html = ExportStyles.generateHtmlDocument(content);

      expect(html.contains('color: #ff0000'), isTrue);
      expect(html.contains('background-color: #ffff00'), isTrue);
    });
  });

  // ============================================
  // Edge Cases Tests
  // ============================================
  group('Edge Cases Tests', () {
    test('Should handle empty content', () {
      final html = ExportStyles.generateHtmlDocument('');

      expect(html.contains('<div class="ql-editor"></div>'), isTrue);
      // CSS should still be present
      expect(html.contains('.ql-font-roboto'), isTrue);
    });

    test('Should handle content with special characters', () {
      const content = '<p>Special: &amp; &lt; &gt; "quotes"</p>';
      final html = ExportStyles.generateHtmlDocument(content);

      expect(html.contains('&amp;'), isTrue);
      expect(html.contains('&lt;'), isTrue);
      expect(html.contains('&gt;'), isTrue);
    });

    test('Should handle deeply nested formatting', () {
      const content =
          '<p><strong><em><span class="ql-font-roboto">Bold Italic Roboto</span></em></strong></p>';
      final html = ExportStyles.generateHtmlDocument(content);

      expect(html.contains('<strong>'), isTrue);
      expect(html.contains('<em>'), isTrue);
      expect(html.contains('ql-font-roboto'), isTrue);
    });

    test('Font list should have exactly 8 fonts (including default)', () {
      expect(AppFonts.availableFonts.length, equals(8));
    });

    test('Size list should have exactly 4 sizes (including normal)', () {
      expect(AppFonts.availableSizes.length, equals(4));
    });

    test('Line height list should have exactly 5 heights', () {
      expect(AppFonts.availableLineHeights.length, equals(5));
    });
  });
}

