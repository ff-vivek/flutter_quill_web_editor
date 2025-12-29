import 'package:flutter_test/flutter_test.dart';
import 'package:quill_web_editor/src/core/constants/app_fonts.dart';
import 'package:quill_web_editor/src/core/utils/font_registry.dart';
import 'package:quill_web_editor/src/core/utils/export_styles.dart';

/// Comprehensive tests for font-related functionality.
///
/// These tests cover:
/// - FontConfig, SizeConfig, LineHeightConfig models
/// - AppFonts constants
/// - FontVariant and CustomFontConfig models
/// - FontRegistry singleton (registration, generation, etc.)
/// - Font integration in ExportStyles
void main() {
  // ============================================
  // Setup and Teardown
  // ============================================
  setUp(() {
    // Clear custom fonts before each test to ensure isolation
    FontRegistry.instance.clearCustomFonts();
  });

  tearDown(() {
    // Clean up after each test
    FontRegistry.instance.clearCustomFonts();
  });

  // ============================================
  // 1. FontConfig Model Tests
  // ============================================
  group('FontConfig Model Tests', () {
    test('Should create FontConfig with required fields', () {
      const config = FontConfig(
        name: 'Test Font',
        value: 'test-font',
        fontFamily: 'TestFont',
      );

      expect(config.name, equals('Test Font'));
      expect(config.value, equals('test-font'));
      expect(config.fontFamily, equals('TestFont'));
    });

    test('Should generate correct cssClass from value', () {
      const config = FontConfig(
        name: 'Roboto',
        value: 'roboto',
        fontFamily: 'Roboto',
      );

      expect(config.cssClass, equals('ql-font-roboto'));
    });

    test('Should return empty cssClass for empty value', () {
      const config = FontConfig(
        name: 'Default',
        value: '',
        fontFamily: 'Arial',
      );

      expect(config.cssClass, equals(''));
    });

    test('Should handle special characters in value', () {
      const config = FontConfig(
        name: 'Open Sans',
        value: 'open-sans',
        fontFamily: 'Open Sans',
      );

      expect(config.cssClass, equals('ql-font-open-sans'));
    });
  });

  // ============================================
  // 2. SizeConfig Model Tests
  // ============================================
  group('SizeConfig Model Tests', () {
    test('Should create SizeConfig with required fields', () {
      const config = SizeConfig(
        name: 'Large',
        value: 'large',
        cssClass: 'ql-size-large',
      );

      expect(config.name, equals('Large'));
      expect(config.value, equals('large'));
      expect(config.cssClass, equals('ql-size-large'));
    });

    test('Should allow empty value for normal size', () {
      const config = SizeConfig(
        name: 'Normal',
        value: '',
        cssClass: '',
      );

      expect(config.value, isEmpty);
      expect(config.cssClass, isEmpty);
    });
  });

  // ============================================
  // 3. LineHeightConfig Model Tests
  // ============================================
  group('LineHeightConfig Model Tests', () {
    test('Should create LineHeightConfig with required fields', () {
      const config = LineHeightConfig(
        name: '1.5',
        value: '1-5',
        cssClass: 'ql-line-height-1-5',
      );

      expect(config.name, equals('1.5'));
      expect(config.value, equals('1-5'));
      expect(config.cssClass, equals('ql-line-height-1-5'));
    });

    test('Should use hyphen notation for decimal values', () {
      const config = LineHeightConfig(
        name: '2.5',
        value: '2-5',
        cssClass: 'ql-line-height-2-5',
      );

      expect(config.value.contains('-'), isTrue);
      expect(config.cssClass.contains('2-5'), isTrue);
    });
  });

  // ============================================
  // 4. AppFonts Constants Tests
  // ============================================
  group('AppFonts Constants Tests', () {
    test('Should have default sans font family set', () {
      expect(AppFonts.sansFontFamily, isNotEmpty);
      expect(AppFonts.sansFontFamily, equals('Roboto'));
    });

    test('Should have default serif font family set', () {
      expect(AppFonts.serifFontFamily, isNotEmpty);
    });

    test('Should have default mono font family set', () {
      expect(AppFonts.monoFontFamily, isNotEmpty);
    });

    test('Should have at least one available font (Roboto)', () {
      expect(AppFonts.availableFonts, isNotEmpty);
      expect(AppFonts.availableFonts.length, greaterThanOrEqualTo(1));

      // Roboto should be available
      final hasRoboto = AppFonts.availableFonts.any((f) => f.value == 'roboto');
      expect(hasRoboto, isTrue);
    });

    test('Should have exactly 4 available sizes', () {
      expect(AppFonts.availableSizes.length, equals(4));
    });

    test('Should include small, normal, large, huge sizes', () {
      final sizeValues = AppFonts.availableSizes.map((s) => s.value).toList();

      expect(sizeValues, contains('small'));
      expect(sizeValues, contains('')); // Normal has empty value
      expect(sizeValues, contains('large'));
      expect(sizeValues, contains('huge'));
    });

    test('Should have exactly 5 available line heights', () {
      expect(AppFonts.availableLineHeights.length, equals(5));
    });

    test('Should include all standard line heights (1.0, 1.5, 2.0, 2.5, 3.0)', () {
      final lineHeightNames =
          AppFonts.availableLineHeights.map((lh) => lh.name).toList();

      expect(lineHeightNames, contains('1.0'));
      expect(lineHeightNames, contains('1.5'));
      expect(lineHeightNames, contains('2.0'));
      expect(lineHeightNames, contains('2.5'));
      expect(lineHeightNames, contains('3.0'));
    });

    test('Should have valid Google Fonts URL', () {
      expect(AppFonts.googleFontsUrl, isNotEmpty);
      expect(AppFonts.googleFontsUrl, contains('fonts.googleapis.com'));
      expect(AppFonts.googleFontsUrl, contains('display=swap'));
    });

    test('Should include Roboto in Google Fonts URL', () {
      expect(AppFonts.googleFontsUrl, contains('Roboto'));
    });

    test('Each available font should have valid properties', () {
      for (final font in AppFonts.availableFonts) {
        expect(font.name, isNotEmpty);
        expect(font.fontFamily, isNotEmpty);
        // value can be empty for default font
      }
    });

    test('Each available size should have valid cssClass or be normal', () {
      for (final size in AppFonts.availableSizes) {
        expect(size.name, isNotEmpty);
        // Normal size has empty value and cssClass
        if (size.value.isNotEmpty) {
          expect(size.cssClass, isNotEmpty);
          expect(size.cssClass, contains('ql-size'));
        }
      }
    });

    test('Each available line height should have valid cssClass', () {
      for (final lineHeight in AppFonts.availableLineHeights) {
        expect(lineHeight.name, isNotEmpty);
        expect(lineHeight.value, isNotEmpty);
        expect(lineHeight.cssClass, isNotEmpty);
        expect(lineHeight.cssClass, contains('ql-line-height'));
      }
    });
  });

  // ============================================
  // 5. FontVariant Model Tests
  // ============================================
  group('FontVariant Model Tests', () {
    test('Should create FontVariant with required url only', () {
      const variant = FontVariant(url: 'Font-Regular.woff2');

      expect(variant.url, equals('Font-Regular.woff2'));
      expect(variant.weight, equals(400)); // Default
      expect(variant.isItalic, isFalse); // Default
      expect(variant.format, equals('truetype')); // Default
    });

    test('Should create FontVariant with custom weight', () {
      const variant = FontVariant(
        url: 'Font-Bold.woff2',
        weight: 700,
      );

      expect(variant.weight, equals(700));
    });

    test('Should create FontVariant with italic style', () {
      const variant = FontVariant(
        url: 'Font-Italic.woff2',
        isItalic: true,
      );

      expect(variant.isItalic, isTrue);
    });

    test('Should create FontVariant with custom format', () {
      const variant = FontVariant(
        url: 'Font-Regular.woff2',
        format: 'woff2',
      );

      expect(variant.format, equals('woff2'));
    });

    test('Should create FontVariant with all custom options', () {
      const variant = FontVariant(
        url: 'Font-BoldItalic.woff2',
        weight: 700,
        isItalic: true,
        format: 'woff2',
      );

      expect(variant.url, equals('Font-BoldItalic.woff2'));
      expect(variant.weight, equals(700));
      expect(variant.isItalic, isTrue);
      expect(variant.format, equals('woff2'));
    });

    test('Should support full URL in variant', () {
      const variant = FontVariant(
        url: 'https://cdn.example.com/fonts/Font-Regular.woff2',
      );

      expect(variant.url, contains('https://'));
    });
  });

  // ============================================
  // 6. CustomFontConfig Tests
  // ============================================
  group('CustomFontConfig Tests', () {
    test('Should create CustomFontConfig with required fields only', () {
      const config = CustomFontConfig(
        name: 'Custom Font',
        value: 'custom',
        fontFamily: 'CustomFont',
      );

      expect(config.name, equals('Custom Font'));
      expect(config.value, equals('custom'));
      expect(config.fontFamily, equals('CustomFont'));
      expect(config.fallback, equals('sans-serif')); // Default fallback
    });

    test('Should detect hasHostedFonts correctly - true', () {
      const config = CustomFontConfig(
        name: 'Hosted Font',
        value: 'hosted',
        fontFamily: 'HostedFont',
        hostedFontBaseUrl: 'https://cdn.example.com/fonts/',
        hostedFontVariants: [
          FontVariant(url: 'Font-Regular.woff2'),
        ],
      );

      expect(config.hasHostedFonts, isTrue);
    });

    test('Should detect hasHostedFonts correctly - false (no base URL)', () {
      const config = CustomFontConfig(
        name: 'No Base URL',
        value: 'no-base',
        fontFamily: 'NoBaseUrl',
        hostedFontVariants: [
          FontVariant(url: 'Font-Regular.woff2'),
        ],
      );

      expect(config.hasHostedFonts, isFalse);
    });

    test('Should detect hasHostedFonts correctly - false (no variants)', () {
      const config = CustomFontConfig(
        name: 'No Variants',
        value: 'no-variants',
        fontFamily: 'NoVariants',
        hostedFontBaseUrl: 'https://cdn.example.com/fonts/',
      );

      expect(config.hasHostedFonts, isFalse);
    });

    test('Should detect hasHostedFonts correctly - false (empty variants)', () {
      const config = CustomFontConfig(
        name: 'Empty Variants',
        value: 'empty-variants',
        fontFamily: 'EmptyVariants',
        hostedFontBaseUrl: 'https://cdn.example.com/fonts/',
        hostedFontVariants: [],
      );

      expect(config.hasHostedFonts, isFalse);
    });

    test('Should detect hasGoogleFontsFallback correctly - true', () {
      const config = CustomFontConfig(
        name: 'Google Font',
        value: 'google',
        fontFamily: 'Mulish',
        googleFontsFamily: 'Mulish:wght@400;700',
      );

      expect(config.hasGoogleFontsFallback, isTrue);
    });

    test('Should detect hasGoogleFontsFallback correctly - false (null)', () {
      const config = CustomFontConfig(
        name: 'No Google',
        value: 'no-google',
        fontFamily: 'NoGoogle',
      );

      expect(config.hasGoogleFontsFallback, isFalse);
    });

    test('Should detect hasGoogleFontsFallback correctly - false (empty)', () {
      const config = CustomFontConfig(
        name: 'Empty Google',
        value: 'empty-google',
        fontFamily: 'EmptyGoogle',
        googleFontsFamily: '',
      );

      expect(config.hasGoogleFontsFallback, isFalse);
    });

    test('Should generate correct cssClass', () {
      const config = CustomFontConfig(
        name: 'Mulish',
        value: 'mulish',
        fontFamily: 'Mulish',
        fallback: 'sans-serif',
      );

      expect(
        config.cssClass,
        equals(".ql-font-mulish { font-family: 'Mulish', sans-serif; }"),
      );
    });

    test('Should generate cssClass with custom fallback', () {
      const config = CustomFontConfig(
        name: 'Serif Font',
        value: 'serif-font',
        fontFamily: 'SerifFont',
        fallback: 'Georgia, serif',
      );

      expect(config.cssClass, contains('Georgia, serif'));
    });

    test('Should convert to FontConfig correctly', () {
      const customConfig = CustomFontConfig(
        name: 'Custom',
        value: 'custom',
        fontFamily: 'CustomFont',
        fallback: 'Arial, sans-serif',
      );

      final fontConfig = customConfig.toFontConfig();

      expect(fontConfig.name, equals('Custom'));
      expect(fontConfig.value, equals('custom'));
      expect(fontConfig.fontFamily, equals('CustomFont'));
    });

    test('Should generate hosted font face CSS with single variant', () {
      const config = CustomFontConfig(
        name: 'Hosted',
        value: 'hosted',
        fontFamily: 'HostedFont',
        hostedFontBaseUrl: 'https://cdn.example.com/fonts/',
        hostedFontVariants: [
          FontVariant(url: 'Font-Regular.woff2', weight: 400, format: 'woff2'),
        ],
      );

      final css = config.generateHostedFontFaceCSS();

      expect(css, contains('@font-face'));
      expect(css, contains("font-family: 'HostedFont'"));
      expect(css, contains('font-weight: 400'));
      expect(css, contains('font-style: normal'));
      expect(css, contains("format('woff2')"));
      expect(css, contains('https://cdn.example.com/fonts/Font-Regular.woff2'));
    });

    test('Should generate hosted font face CSS with multiple variants', () {
      const config = CustomFontConfig(
        name: 'Multi Variant',
        value: 'multi',
        fontFamily: 'MultiFont',
        hostedFontBaseUrl: 'https://cdn.example.com/fonts/',
        hostedFontVariants: [
          FontVariant(url: 'Font-Regular.woff2', weight: 400, format: 'woff2'),
          FontVariant(url: 'Font-Bold.woff2', weight: 700, format: 'woff2'),
          FontVariant(
              url: 'Font-Italic.woff2',
              weight: 400,
              isItalic: true,
              format: 'woff2'),
        ],
      );

      final css = config.generateHostedFontFaceCSS();

      // Should have 3 @font-face declarations
      expect('@font-face'.allMatches(css).length, equals(3));
      expect(css, contains('font-weight: 400'));
      expect(css, contains('font-weight: 700'));
      expect(css, contains('font-style: italic'));
    });

    test('Should handle base URL without trailing slash', () {
      const config = CustomFontConfig(
        name: 'No Slash',
        value: 'no-slash',
        fontFamily: 'NoSlashFont',
        hostedFontBaseUrl: 'https://cdn.example.com/fonts', // No trailing slash
        hostedFontVariants: [
          FontVariant(url: 'Font-Regular.woff2'),
        ],
      );

      final css = config.generateHostedFontFaceCSS();

      // Should still produce valid URL with slash
      expect(css, contains('https://cdn.example.com/fonts/Font-Regular.woff2'));
    });

    test('Should handle absolute URL in variant', () {
      const config = CustomFontConfig(
        name: 'Absolute URL',
        value: 'absolute',
        fontFamily: 'AbsoluteFont',
        hostedFontBaseUrl: 'https://cdn.example.com/fonts/',
        hostedFontVariants: [
          FontVariant(url: 'https://other-cdn.com/fonts/Font.woff2'),
        ],
      );

      final css = config.generateHostedFontFaceCSS();

      // Should use absolute URL as-is, not prepend base URL
      expect(css, contains('https://other-cdn.com/fonts/Font.woff2'));
      expect(css, isNot(contains('https://cdn.example.com/fonts/https://')));
    });

    test('Should return empty string for generateHostedFontFaceCSS when no hosted fonts', () {
      const config = CustomFontConfig(
        name: 'No Hosted',
        value: 'no-hosted',
        fontFamily: 'NoHosted',
      );

      expect(config.generateHostedFontFaceCSS(), isEmpty);
    });
  });

  // ============================================
  // 7. FontRegistry Singleton Tests
  // ============================================
  group('FontRegistry Singleton Tests', () {
    test('Should return same instance', () {
      final instance1 = FontRegistry.instance;
      final instance2 = FontRegistry.instance;

      expect(identical(instance1, instance2), isTrue);
    });

    test('Should start with no custom fonts', () {
      expect(FontRegistry.instance.customFonts, isEmpty);
    });

    test('Should register single font successfully', () {
      FontRegistry.instance.registerFont(
        const CustomFontConfig(
          name: 'Test Font',
          value: 'test',
          fontFamily: 'TestFont',
        ),
      );

      expect(FontRegistry.instance.customFonts.length, equals(1));
      expect(FontRegistry.instance.customFonts.first.value, equals('test'));
    });

    test('Should register multiple fonts', () {
      FontRegistry.instance.registerFonts([
        const CustomFontConfig(
            name: 'Font 1', value: 'font1', fontFamily: 'Font1'),
        const CustomFontConfig(
            name: 'Font 2', value: 'font2', fontFamily: 'Font2'),
        const CustomFontConfig(
            name: 'Font 3', value: 'font3', fontFamily: 'Font3'),
      ]);

      expect(FontRegistry.instance.customFonts.length, equals(3));
    });

    test('Should replace existing font with same value on re-register', () {
      FontRegistry.instance.registerFont(
        const CustomFontConfig(
          name: 'Original',
          value: 'test',
          fontFamily: 'OriginalFont',
        ),
      );

      FontRegistry.instance.registerFont(
        const CustomFontConfig(
          name: 'Updated',
          value: 'test', // Same value
          fontFamily: 'UpdatedFont',
        ),
      );

      expect(FontRegistry.instance.customFonts.length, equals(1));
      expect(FontRegistry.instance.customFonts.first.name, equals('Updated'));
      expect(FontRegistry.instance.customFonts.first.fontFamily,
          equals('UpdatedFont'));
    });

    test('Should unregister font by value', () {
      FontRegistry.instance.registerFonts([
        const CustomFontConfig(
            name: 'Font 1', value: 'font1', fontFamily: 'Font1'),
        const CustomFontConfig(
            name: 'Font 2', value: 'font2', fontFamily: 'Font2'),
      ]);

      FontRegistry.instance.unregisterFont('font1');

      expect(FontRegistry.instance.customFonts.length, equals(1));
      expect(FontRegistry.instance.customFonts.first.value, equals('font2'));
    });

    test('Should handle unregister of non-existent font gracefully', () {
      FontRegistry.instance.registerFont(
        const CustomFontConfig(
            name: 'Font', value: 'font', fontFamily: 'Font'),
      );

      // Should not throw
      FontRegistry.instance.unregisterFont('non-existent');

      expect(FontRegistry.instance.customFonts.length, equals(1));
    });

    test('Should clear all custom fonts', () {
      FontRegistry.instance.registerFonts([
        const CustomFontConfig(
            name: 'Font 1', value: 'font1', fontFamily: 'Font1'),
        const CustomFontConfig(
            name: 'Font 2', value: 'font2', fontFamily: 'Font2'),
      ]);

      FontRegistry.instance.clearCustomFonts();

      expect(FontRegistry.instance.customFonts, isEmpty);
    });

    test('Should detect package default font with hasFont', () {
      expect(FontRegistry.instance.hasFont('roboto'), isTrue);
    });

    test('Should detect custom font with hasFont', () {
      FontRegistry.instance.registerFont(
        const CustomFontConfig(
            name: 'Custom', value: 'custom', fontFamily: 'Custom'),
      );

      expect(FontRegistry.instance.hasFont('custom'), isTrue);
    });

    test('Should return false for non-existent font with hasFont', () {
      expect(FontRegistry.instance.hasFont('non-existent'), isFalse);
    });

    test('Should combine package and custom fonts in allFonts', () {
      FontRegistry.instance.registerFont(
        const CustomFontConfig(
            name: 'Custom', value: 'custom', fontFamily: 'Custom'),
      );

      final allFonts = FontRegistry.instance.allFonts;

      expect(allFonts.length,
          equals(AppFonts.availableFonts.length + 1)); // +1 custom
      expect(allFonts.any((f) => f.value == 'roboto'), isTrue);
      expect(allFonts.any((f) => f.value == 'custom'), isTrue);
    });

    test('Should return unmodifiable list from customFonts', () {
      FontRegistry.instance.registerFont(
        const CustomFontConfig(
            name: 'Custom', value: 'custom', fontFamily: 'Custom'),
      );

      final fonts = FontRegistry.instance.customFonts;

      // Attempting to modify should throw
      expect(
        () => fonts.add(const CustomFontConfig(
            name: 'Test', value: 'test', fontFamily: 'Test')),
        throwsUnsupportedError,
      );
    });
  });

  // ============================================
  // 8. FontRegistry CSS Generation Tests
  // ============================================
  group('FontRegistry CSS Generation Tests', () {
    test('Should generate font classes for package defaults', () {
      final css = FontRegistry.instance.generateFontClasses();

      expect(css, contains('.ql-font-roboto'));
      expect(css, contains("font-family: 'Roboto'"));
    });

    test('Should generate font classes for custom fonts', () {
      FontRegistry.instance.registerFont(
        const CustomFontConfig(
          name: 'Mulish',
          value: 'mulish',
          fontFamily: 'Mulish',
          fallback: 'sans-serif',
        ),
      );

      final css = FontRegistry.instance.generateFontClasses();

      expect(css, contains('.ql-font-mulish'));
      expect(css, contains("font-family: 'Mulish', sans-serif"));
    });

    test('Should generate @font-face CSS for hosted fonts', () {
      FontRegistry.instance.registerFont(
        const CustomFontConfig(
          name: 'Hosted',
          value: 'hosted',
          fontFamily: 'HostedFont',
          hostedFontBaseUrl: 'https://cdn.example.com/fonts/',
          hostedFontVariants: [
            FontVariant(url: 'Font-Regular.woff2', weight: 400, format: 'woff2'),
            FontVariant(url: 'Font-Bold.woff2', weight: 700, format: 'woff2'),
          ],
        ),
      );

      final css = FontRegistry.instance.generateFontFaceCSS();

      expect(css, contains('@font-face'));
      expect(css, contains("font-family: 'HostedFont'"));
      expect(css, contains('font-weight: 400'));
      expect(css, contains('font-weight: 700'));
      expect(css, contains('Priority 1'));
    });

    test('Should generate @font-face CSS from fontFaceCSS property', () {
      const customFontFace = '''
@font-face {
  font-family: 'CustomFont';
  src: url('custom-font.woff2') format('woff2');
}
''';
      FontRegistry.instance.registerFont(
        CustomFontConfig(
          name: 'Custom',
          value: 'custom',
          fontFamily: 'CustomFont',
          fontFaceCSS: customFontFace,
        ),
      );

      final css = FontRegistry.instance.generateFontFaceCSS();

      expect(css, contains("font-family: 'CustomFont'"));
      expect(css, contains('custom-font.woff2'));
    });

    test('Should return empty string for generateFontFaceCSS with no hosted fonts', () {
      // No custom fonts registered
      final css = FontRegistry.instance.generateFontFaceCSS();

      expect(css, isEmpty);
    });

    test('Should generate Google Fonts URL with custom fonts', () {
      FontRegistry.instance.registerFont(
        const CustomFontConfig(
          name: 'Mulish',
          value: 'mulish',
          fontFamily: 'Mulish',
          googleFontsFamily: 'Mulish:wght@400;700',
        ),
      );

      final url = FontRegistry.instance.generateGoogleFontsUrl();

      expect(url, contains('fonts.googleapis.com'));
      expect(url, contains('Mulish:wght@400;700'));
      expect(url, contains('display=swap'));
    });

    test('Should return package default URL when no custom Google fonts', () {
      // No custom fonts
      final url = FontRegistry.instance.generateGoogleFontsUrl();

      expect(url, equals(AppFonts.googleFontsUrl));
    });

    test('Should not include fonts without googleFontsFamily in URL', () {
      FontRegistry.instance.registerFont(
        const CustomFontConfig(
          name: 'Hosted Only',
          value: 'hosted-only',
          fontFamily: 'HostedOnly',
          hostedFontBaseUrl: 'https://cdn.example.com/',
          hostedFontVariants: [FontVariant(url: 'font.woff2')],
          // No googleFontsFamily
        ),
      );

      final url = FontRegistry.instance.generateGoogleFontsUrl();

      // Should just be the default URL
      expect(url, equals(AppFonts.googleFontsUrl));
    });

    test('Should include multiple Google fonts in URL', () {
      FontRegistry.instance.registerFonts([
        const CustomFontConfig(
          name: 'Mulish',
          value: 'mulish',
          fontFamily: 'Mulish',
          googleFontsFamily: 'Mulish:wght@400;700',
        ),
        const CustomFontConfig(
          name: 'Lato',
          value: 'lato',
          fontFamily: 'Lato',
          googleFontsFamily: 'Lato:wght@400;700',
        ),
      ]);

      final url = FontRegistry.instance.generateGoogleFontsUrl();

      expect(url, contains('Mulish:wght@400;700'));
      expect(url, contains('Lato:wght@400;700'));
    });
  });

  // ============================================
  // 9. FontRegistry External Stylesheets Tests
  // ============================================
  group('FontRegistry External Stylesheets Tests', () {
    test('Should include Quill CSS in stylesheets', () {
      final stylesheets = FontRegistry.instance.externalStylesheets;

      expect(stylesheets.any((s) => s.contains('quill.snow.css')), isTrue);
    });

    test('Should include quill-table-better CSS in stylesheets', () {
      final stylesheets = FontRegistry.instance.externalStylesheets;

      expect(
          stylesheets.any((s) => s.contains('quill-table-better.css')), isTrue);
    });

    test('Should include Google Fonts URL in stylesheets', () {
      final stylesheets = FontRegistry.instance.externalStylesheets;

      expect(
          stylesheets.any((s) => s.contains('fonts.googleapis.com')), isTrue);
    });

    test('Should have exactly 3 external stylesheets', () {
      final stylesheets = FontRegistry.instance.externalStylesheets;

      expect(stylesheets.length, equals(3));
    });
  });

  // ============================================
  // 10. FontRegistry Loading Strategy Summary Tests
  // ============================================
  group('FontRegistry Loading Strategy Summary Tests', () {
    test('Should include package default fonts in summary', () {
      final summary = FontRegistry.instance.generateLoadingStrategySummary();

      expect(summary, contains('Package Default Fonts'));
      expect(summary, contains('Roboto'));
    });

    test('Should include custom fonts in summary', () {
      FontRegistry.instance.registerFont(
        const CustomFontConfig(
          name: 'Custom Font',
          value: 'custom',
          fontFamily: 'CustomFont',
        ),
      );

      final summary = FontRegistry.instance.generateLoadingStrategySummary();

      expect(summary, contains('Custom Registered Fonts'));
      expect(summary, contains('Custom Font'));
    });

    test('Should show hosted fonts status in summary', () {
      FontRegistry.instance.registerFont(
        const CustomFontConfig(
          name: 'Hosted',
          value: 'hosted',
          fontFamily: 'HostedFont',
          hostedFontBaseUrl: 'https://cdn.example.com/',
          hostedFontVariants: [FontVariant(url: 'font.woff2')],
        ),
      );

      final summary = FontRegistry.instance.generateLoadingStrategySummary();

      expect(summary, contains('Priority 1 (Hosted): ✓ Configured'));
      expect(summary, contains('Base URL:'));
      expect(summary, contains('Variants:'));
    });

    test('Should show Google fonts status in summary', () {
      FontRegistry.instance.registerFont(
        const CustomFontConfig(
          name: 'Google',
          value: 'google',
          fontFamily: 'GoogleFont',
          googleFontsFamily: 'Mulish:wght@400',
        ),
      );

      final summary = FontRegistry.instance.generateLoadingStrategySummary();

      expect(summary, contains('Priority 2 (Google Fonts): ✓ Configured'));
      expect(summary, contains('Family:'));
    });

    test('Should show fallback in summary', () {
      FontRegistry.instance.registerFont(
        const CustomFontConfig(
          name: 'Fallback Test',
          value: 'fallback',
          fontFamily: 'FallbackFont',
          fallback: 'Arial, sans-serif',
        ),
      );

      final summary = FontRegistry.instance.generateLoadingStrategySummary();

      expect(summary, contains('Priority 3 (Fallback): Arial, sans-serif'));
    });
  });

  // ============================================
  // 11. ExportStyles Font Integration Tests
  // ============================================
  group('ExportStyles Font Integration Tests', () {
    test('Should include package default font classes in fullCss', () {
      final css = ExportStyles.fullCss;

      expect(css, contains('.ql-font-roboto'));
    });

    test('Should include custom font classes in fullCss after registration', () {
      FontRegistry.instance.registerFont(
        const CustomFontConfig(
          name: 'Mulish',
          value: 'mulish',
          fontFamily: 'Mulish',
        ),
      );

      final css = ExportStyles.fullCss;

      expect(css, contains('.ql-font-mulish'));
    });

    test('Should include custom @font-face in fullCss', () {
      FontRegistry.instance.registerFont(
        const CustomFontConfig(
          name: 'Hosted',
          value: 'hosted',
          fontFamily: 'HostedFont',
          hostedFontBaseUrl: 'https://cdn.example.com/',
          hostedFontVariants: [
            FontVariant(url: 'font.woff2', format: 'woff2'),
          ],
        ),
      );

      final css = ExportStyles.fullCss;

      expect(css, contains('@font-face'));
      expect(css, contains("font-family: 'HostedFont'"));
    });

    test('Should include all size classes in fullCss', () {
      final css = ExportStyles.fullCss;

      expect(css, contains('.ql-size-small'));
      expect(css, contains('.ql-size-large'));
      expect(css, contains('.ql-size-huge'));
    });

    test('Should include all line height classes in fullCss', () {
      final css = ExportStyles.fullCss;

      expect(css, contains('.ql-line-height-1'));
      expect(css, contains('.ql-line-height-1-5'));
      expect(css, contains('.ql-line-height-2'));
      expect(css, contains('.ql-line-height-2-5'));
      expect(css, contains('.ql-line-height-3'));
    });

    test('Should generate HTML with default font class when specified', () {
      final html = ExportStyles.generateHtmlDocument(
        '<p>Test</p>',
        defaultFont: 'mulish',
      );

      expect(html, contains('class="ql-editor ql-font-mulish"'));
    });

    test('Should generate HTML without font class when defaultFont is null', () {
      final html = ExportStyles.generateHtmlDocument('<p>Test</p>');

      // The editor div should only have "ql-editor" class, not a font class
      expect(html, contains('<div class="ql-editor">'));
      // Should NOT have a font class on the editor wrapper div
      expect(html, isNot(contains('class="ql-editor ql-font-')));
    });

    test('Should generate HTML without font class when defaultFont is empty', () {
      final html = ExportStyles.generateHtmlDocument(
        '<p>Test</p>',
        defaultFont: '',
      );

      expect(html, contains('class="ql-editor"'));
    });

    test('Should include Google Fonts in external stylesheets', () {
      final stylesheets = ExportStyles.externalStylesheets;

      expect(stylesheets.any((s) => s.contains('fonts.googleapis.com')), isTrue);
    });

    test('Should include custom Google fonts in generated HTML', () {
      FontRegistry.instance.registerFont(
        const CustomFontConfig(
          name: 'Mulish',
          value: 'mulish',
          fontFamily: 'Mulish',
          googleFontsFamily: 'Mulish:wght@400;700',
        ),
      );

      final html = ExportStyles.generateHtmlDocument('<p>Test</p>');

      expect(html, contains('Mulish:wght@400;700'));
    });
  });

  // ============================================
  // 12. Edge Cases and Error Handling Tests
  // ============================================
  group('Edge Cases and Error Handling Tests', () {
    test('Should handle font with special characters in name', () {
      FontRegistry.instance.registerFont(
        const CustomFontConfig(
          name: "Font's Name \"Special\"",
          value: 'special',
          fontFamily: 'SpecialFont',
        ),
      );

      expect(FontRegistry.instance.hasFont('special'), isTrue);
    });

    test('Should handle very long font names', () {
      final longName = 'A' * 100;
      FontRegistry.instance.registerFont(
        CustomFontConfig(
          name: longName,
          value: 'long',
          fontFamily: longName,
        ),
      );

      expect(FontRegistry.instance.hasFont('long'), isTrue);
    });

    test('Should handle unicode characters in font name', () {
      FontRegistry.instance.registerFont(
        const CustomFontConfig(
          name: 'フォント',
          value: 'japanese',
          fontFamily: 'JapaneseFont',
        ),
      );

      expect(FontRegistry.instance.hasFont('japanese'), isTrue);
      expect(FontRegistry.instance.customFonts.first.name, equals('フォント'));
    });

    test('Should handle empty custom fonts list', () {
      // No fonts registered
      final css = FontRegistry.instance.generateFontClasses();

      // Should still include package defaults
      expect(css, contains('.ql-font-roboto'));
    });

    test('Should handle allFonts with no custom fonts', () {
      final allFonts = FontRegistry.instance.allFonts;

      expect(allFonts.length, equals(AppFonts.availableFonts.length));
    });

    test('Should preserve font order in allFonts', () {
      FontRegistry.instance.registerFont(
        const CustomFontConfig(
            name: 'First', value: 'first', fontFamily: 'First'),
      );
      FontRegistry.instance.registerFont(
        const CustomFontConfig(
            name: 'Second', value: 'second', fontFamily: 'Second'),
      );

      final customFonts = FontRegistry.instance.customFonts;

      expect(customFonts[0].value, equals('first'));
      expect(customFonts[1].value, equals('second'));
    });
  });

  // ============================================
  // 13. Font Size CSS Value Tests
  // ============================================
  group('Font Size CSS Value Tests', () {
    test('Small size should use 0.75em', () {
      final css = ExportStyles.fullCss;
      expect(css, contains('.ql-size-small { font-size: 0.75em; }'));
    });

    test('Large size should use 1.5em', () {
      final css = ExportStyles.fullCss;
      expect(css, contains('.ql-size-large { font-size: 1.5em; }'));
    });

    test('Huge size should use 2.5em', () {
      final css = ExportStyles.fullCss;
      expect(css, contains('.ql-size-huge { font-size: 2.5em; }'));
    });
  });

  // ============================================
  // 14. Line Height CSS Value Tests
  // ============================================
  group('Line Height CSS Value Tests', () {
    test('Line height 1.0 should use line-height: 1', () {
      final css = ExportStyles.fullCss;
      expect(css, contains('.ql-line-height-1 { line-height: 1; }'));
    });

    test('Line height 1.5 should use line-height: 1.5', () {
      final css = ExportStyles.fullCss;
      expect(css, contains('.ql-line-height-1-5 { line-height: 1.5; }'));
    });

    test('Line height 2.0 should use line-height: 2', () {
      final css = ExportStyles.fullCss;
      expect(css, contains('.ql-line-height-2 { line-height: 2; }'));
    });

    test('Line height 2.5 should use line-height: 2.5', () {
      final css = ExportStyles.fullCss;
      expect(css, contains('.ql-line-height-2-5 { line-height: 2.5; }'));
    });

    test('Line height 3.0 should use line-height: 3', () {
      final css = ExportStyles.fullCss;
      expect(css, contains('.ql-line-height-3 { line-height: 3; }'));
    });
  });

  // ============================================
  // 15. Full Priority Chain Integration Tests
  // ============================================
  group('Full Priority Chain Integration Tests', () {
    test('Should support full priority chain configuration', () {
      FontRegistry.instance.registerFont(
        const CustomFontConfig(
          name: 'Enterprise Font',
          value: 'enterprise',
          fontFamily: 'EnterpriseFont',
          // Priority 1: Hosted
          hostedFontBaseUrl: 'https://cdn.enterprise.com/fonts/',
          hostedFontVariants: [
            FontVariant(
                url: 'Enterprise-Regular.woff2', weight: 400, format: 'woff2'),
            FontVariant(
                url: 'Enterprise-Bold.woff2', weight: 700, format: 'woff2'),
          ],
          // Priority 2: Google Fonts
          googleFontsFamily: 'Open+Sans:wght@400;700',
          // Priority 3: System fallback
          fallback: 'Arial, Helvetica, sans-serif',
        ),
      );

      final config = FontRegistry.instance.customFonts.first;

      expect(config.hasHostedFonts, isTrue);
      expect(config.hasGoogleFontsFallback, isTrue);
      expect(config.fallback, equals('Arial, Helvetica, sans-serif'));

      // Check CSS generation includes all priorities
      final fontFaceCSS = FontRegistry.instance.generateFontFaceCSS();
      expect(fontFaceCSS, contains('@font-face'));
      expect(fontFaceCSS, contains('Priority 1'));

      final googleUrl = FontRegistry.instance.generateGoogleFontsUrl();
      expect(googleUrl, contains('Open+Sans:wght@400;700'));

      final cssClass = config.cssClass;
      expect(cssClass, contains('Arial, Helvetica, sans-serif'));
    });

    test('Should work with only Priority 1 (hosted only)', () {
      FontRegistry.instance.registerFont(
        const CustomFontConfig(
          name: 'Hosted Only',
          value: 'hosted-only',
          fontFamily: 'HostedOnly',
          hostedFontBaseUrl: 'https://cdn.example.com/',
          hostedFontVariants: [FontVariant(url: 'font.woff2')],
          // No Google Fonts
          fallback: 'sans-serif',
        ),
      );

      final config = FontRegistry.instance.customFonts.first;

      expect(config.hasHostedFonts, isTrue);
      expect(config.hasGoogleFontsFallback, isFalse);
    });

    test('Should work with only Priority 2 (Google Fonts only)', () {
      FontRegistry.instance.registerFont(
        const CustomFontConfig(
          name: 'Google Only',
          value: 'google-only',
          fontFamily: 'Mulish',
          googleFontsFamily: 'Mulish:wght@400;700',
          fallback: 'sans-serif',
        ),
      );

      final config = FontRegistry.instance.customFonts.first;

      expect(config.hasHostedFonts, isFalse);
      expect(config.hasGoogleFontsFallback, isTrue);
    });

    test('Should work with only Priority 3 (fallback only)', () {
      FontRegistry.instance.registerFont(
        const CustomFontConfig(
          name: 'Fallback Only',
          value: 'fallback-only',
          fontFamily: 'Arial',
          fallback: 'Arial, sans-serif',
        ),
      );

      final config = FontRegistry.instance.customFonts.first;

      expect(config.hasHostedFonts, isFalse);
      expect(config.hasGoogleFontsFallback, isFalse);
      expect(config.cssClass, contains('Arial, sans-serif'));
    });
  });
}

