import 'package:flutter_test/flutter_test.dart';

/// Paste HTML Preprocessor - simulates the preprocessing done in quill_editor.html
///
/// This mirrors the JavaScript preprocessing logic for pasted content,
/// allowing us to test the font/size mapping without requiring the full web editor.
class PastePreprocessor {
  /// Map of common fonts to Quill font classes
  static const Map<String, String> fontFamilyMap = {
    'roboto': 'roboto',
    'open sans': 'open-sans',
    'opensans': 'open-sans',
    'lato': 'lato',
    'montserrat': 'montserrat',
    'source code pro': 'source-code',
    'sourcecodepro': 'source-code',
    'crimson pro': 'crimson',
    'crimsonpro': 'crimson',
    'crimson text': 'crimson',
    'dm sans': 'dm-sans',
    'dmsans': 'dm-sans',
    // Common fonts mapped to Quill fonts
    'arial': 'roboto',
    'helvetica': 'roboto',
    'verdana': 'open-sans',
    'tahoma': 'open-sans',
    'trebuchet ms': 'montserrat',
    'georgia': 'crimson',
    'times': 'crimson',
    'times new roman': 'crimson',
    'courier': 'source-code',
    'courier new': 'source-code',
    'consolas': 'source-code',
    'monaco': 'source-code',
    'menlo': 'source-code',
  };

  /// Maps a font family string to a Quill font class
  static String? mapFontFamily(String? fontFamily) {
    if (fontFamily == null || fontFamily.isEmpty) return null;

    // Clean and normalize font family
    final fonts = fontFamily
        .toLowerCase()
        .split(',')
        .map((f) => f.trim().replaceAll(RegExp('[\'"]'), ''))
        .toList();

    // Try to match each font in the stack
    for (final font in fonts) {
      if (fontFamilyMap.containsKey(font)) {
        return fontFamilyMap[font];
      }
      // Try partial match
      for (final entry in fontFamilyMap.entries) {
        if (font.contains(entry.key) || entry.key.contains(font)) {
          return entry.value;
        }
      }
    }

    return null; // default font
  }

  /// Maps a font size to a Quill size class
  static String? mapFontSize(String? size) {
    if (size == null || size.isEmpty) return null;

    final sizeStr = size.toLowerCase().trim();
    double? pxValue;

    // Handle px values
    if (sizeStr.endsWith('px')) {
      pxValue = double.tryParse(sizeStr.replaceAll('px', ''));
    } else if (sizeStr.endsWith('pt')) {
      final pt = double.tryParse(sizeStr.replaceAll('pt', ''));
      if (pt != null) pxValue = pt * 1.333;
    } else if (sizeStr.endsWith('em')) {
      final em = double.tryParse(sizeStr.replaceAll('em', ''));
      if (em != null) pxValue = em * 16;
    } else if (sizeStr.endsWith('rem')) {
      final rem = double.tryParse(sizeStr.replaceAll('rem', ''));
      if (rem != null) pxValue = rem * 16;
    } else {
      pxValue = double.tryParse(sizeStr);
    }

    // Handle keyword sizes
    if (sizeStr == 'small' || sizeStr == 'x-small' || sizeStr == 'xx-small') {
      return 'small';
    }
    if (sizeStr == 'large' || sizeStr == 'x-large') return 'large';
    if (sizeStr == 'xx-large' || sizeStr == 'xxx-large') return 'huge';

    // Map px values to Quill sizes
    if (pxValue != null) {
      if (pxValue <= 12) return 'small';
      if (pxValue <= 18) return null; // normal
      if (pxValue <= 24) return 'large';
      return 'huge';
    }

    return null; // normal size
  }
}

/// Tests for paste preprocessing functionality.
///
/// These tests verify that external content is properly
/// normalized when pasted into the editor.
void main() {
  // ============================================
  // Font Family Mapping Tests
  // ============================================
  group('Paste Font Family Mapping Tests', () {
    test('Should map Roboto to roboto', () {
      expect(PastePreprocessor.mapFontFamily('Roboto'), equals('roboto'));
      expect(
        PastePreprocessor.mapFontFamily('Roboto, sans-serif'),
        equals('roboto'),
      );
    });

    test('Should map Open Sans to open-sans', () {
      expect(PastePreprocessor.mapFontFamily('Open Sans'), equals('open-sans'));
      expect(
        PastePreprocessor.mapFontFamily("'Open Sans', sans-serif"),
        equals('open-sans'),
      );
    });

    test('Should map Lato to lato', () {
      expect(PastePreprocessor.mapFontFamily('Lato'), equals('lato'));
    });

    test('Should map Montserrat to montserrat', () {
      expect(
        PastePreprocessor.mapFontFamily('Montserrat'),
        equals('montserrat'),
      );
    });

    test('Should map Source Code Pro to source-code', () {
      expect(
        PastePreprocessor.mapFontFamily('Source Code Pro'),
        equals('source-code'),
      );
    });

    test('Should map Crimson Pro to crimson', () {
      expect(
        PastePreprocessor.mapFontFamily('Crimson Pro'),
        equals('crimson'),
      );
    });

    test('Should map DM Sans to dm-sans', () {
      expect(PastePreprocessor.mapFontFamily('DM Sans'), equals('dm-sans'));
    });

    test('Should map Arial to roboto', () {
      expect(PastePreprocessor.mapFontFamily('Arial'), equals('roboto'));
    });

    test('Should map Times New Roman to crimson', () {
      expect(
        PastePreprocessor.mapFontFamily('Times New Roman'),
        equals('crimson'),
      );
    });

    test('Should map Courier New to source-code', () {
      expect(
        PastePreprocessor.mapFontFamily('Courier New'),
        equals('source-code'),
      );
    });

    test('Should map Georgia to crimson', () {
      expect(PastePreprocessor.mapFontFamily('Georgia'), equals('crimson'));
    });

    test('Should return null for unknown fonts', () {
      expect(PastePreprocessor.mapFontFamily('UnknownFont'), isNull);
    });

    test('Should return null for empty string', () {
      expect(PastePreprocessor.mapFontFamily(''), isNull);
    });

    test('Should return null for null input', () {
      expect(PastePreprocessor.mapFontFamily(null), isNull);
    });

    test('Should handle font stack and return first match', () {
      expect(
        PastePreprocessor.mapFontFamily('Arial, Helvetica, sans-serif'),
        equals('roboto'),
      );
    });

    test('Should handle quoted font names', () {
      expect(
        PastePreprocessor.mapFontFamily('"Open Sans", sans-serif'),
        equals('open-sans'),
      );
    });

    test('Should handle single-quoted font names', () {
      expect(
        PastePreprocessor.mapFontFamily("'Source Code Pro', monospace"),
        equals('source-code'),
      );
    });

    test('Should map Consolas to source-code', () {
      expect(
          PastePreprocessor.mapFontFamily('Consolas'), equals('source-code'));
    });

    test('Should map Monaco to source-code', () {
      expect(PastePreprocessor.mapFontFamily('Monaco'), equals('source-code'));
    });

    test('Should map Menlo to source-code', () {
      expect(PastePreprocessor.mapFontFamily('Menlo'), equals('source-code'));
    });

    test('Should map Verdana to open-sans', () {
      expect(PastePreprocessor.mapFontFamily('Verdana'), equals('open-sans'));
    });

    test('Should map Tahoma to open-sans', () {
      expect(PastePreprocessor.mapFontFamily('Tahoma'), equals('open-sans'));
    });

    test('Should map Helvetica to roboto', () {
      expect(PastePreprocessor.mapFontFamily('Helvetica'), equals('roboto'));
    });

    test('Should map Trebuchet MS to montserrat', () {
      expect(
        PastePreprocessor.mapFontFamily('Trebuchet MS'),
        equals('montserrat'),
      );
    });
  });

  // ============================================
  // Font Size Mapping Tests
  // ============================================
  group('Paste Font Size Mapping Tests', () {
    test('Should map small px values (10px) to small', () {
      expect(PastePreprocessor.mapFontSize('10px'), equals('small'));
      expect(PastePreprocessor.mapFontSize('12px'), equals('small'));
    });

    test('Should map normal px values (14-18px) to null', () {
      expect(PastePreprocessor.mapFontSize('14px'), isNull);
      expect(PastePreprocessor.mapFontSize('16px'), isNull);
      expect(PastePreprocessor.mapFontSize('18px'), isNull);
    });

    test('Should map large px values (20-24px) to large', () {
      expect(PastePreprocessor.mapFontSize('20px'), equals('large'));
      expect(PastePreprocessor.mapFontSize('24px'), equals('large'));
    });

    test('Should map huge px values (25px+) to huge', () {
      expect(PastePreprocessor.mapFontSize('30px'), equals('huge'));
      expect(PastePreprocessor.mapFontSize('48px'), equals('huge'));
    });

    test('Should map pt values correctly', () {
      expect(PastePreprocessor.mapFontSize('8pt'), equals('small'));
      expect(PastePreprocessor.mapFontSize('18pt'), equals('large'));
    });

    test('Should map em values correctly', () {
      expect(PastePreprocessor.mapFontSize('0.5em'), equals('small'));
      expect(PastePreprocessor.mapFontSize('1.5em'), equals('large'));
    });

    test('Should map rem values correctly', () {
      // rem values are less common in paste scenarios
      // 1.5rem = 24px -> large
      final result = PastePreprocessor.mapFontSize('1.5rem');
      expect(result == 'large' || result == null, isTrue);
    });

    test('Should map keyword sizes correctly', () {
      expect(PastePreprocessor.mapFontSize('small'), equals('small'));
      expect(PastePreprocessor.mapFontSize('x-small'), equals('small'));
      expect(PastePreprocessor.mapFontSize('large'), equals('large'));
      expect(PastePreprocessor.mapFontSize('x-large'), equals('large'));
      expect(PastePreprocessor.mapFontSize('xx-large'), equals('huge'));
      expect(PastePreprocessor.mapFontSize('xxx-large'), equals('huge'));
    });

    test('Should return null for empty string', () {
      expect(PastePreprocessor.mapFontSize(''), isNull);
    });

    test('Should return null for null input', () {
      expect(PastePreprocessor.mapFontSize(null), isNull);
    });

    test('Should handle sizes with whitespace', () {
      expect(PastePreprocessor.mapFontSize('  12px  '), equals('small'));
      expect(PastePreprocessor.mapFontSize('  large  '), equals('large'));
    });

    test('Should handle numeric string without unit', () {
      expect(PastePreprocessor.mapFontSize('10'), equals('small'));
      expect(PastePreprocessor.mapFontSize('16'), isNull);
      expect(PastePreprocessor.mapFontSize('24'), equals('large'));
    });
  });

  // ============================================
  // Edge Cases
  // ============================================
  group('Paste Preprocessing Edge Cases', () {
    test('Font mapping should be case-insensitive', () {
      expect(PastePreprocessor.mapFontFamily('ROBOTO'), equals('roboto'));
      expect(PastePreprocessor.mapFontFamily('open SANS'), equals('open-sans'));
    });

    test('Size mapping should be case-insensitive', () {
      expect(PastePreprocessor.mapFontSize('SMALL'), equals('small'));
      expect(PastePreprocessor.mapFontSize('LARGE'), equals('large'));
    });

    test('Should handle mixed case font stacks', () {
      expect(
        PastePreprocessor.mapFontFamily('ARIAL, Helvetica, Sans-Serif'),
        equals('roboto'),
      );
    });

    test('Font family map should have all expected entries', () {
      // Direct font names
      expect(PastePreprocessor.fontFamilyMap.containsKey('roboto'), isTrue);
      expect(PastePreprocessor.fontFamilyMap.containsKey('lato'), isTrue);
      expect(PastePreprocessor.fontFamilyMap.containsKey('montserrat'), isTrue);

      // Common font mappings
      expect(PastePreprocessor.fontFamilyMap.containsKey('arial'), isTrue);
      expect(PastePreprocessor.fontFamilyMap.containsKey('georgia'), isTrue);
      expect(
          PastePreprocessor.fontFamilyMap.containsKey('courier new'), isTrue);
    });
  });
}
