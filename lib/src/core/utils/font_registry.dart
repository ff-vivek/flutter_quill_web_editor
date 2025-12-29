import '../constants/app_fonts.dart';

/// Configuration for a font weight/style variant.
///
/// Used to define individual font files for different weights and styles.
class FontVariant {
  const FontVariant({
    required this.url,
    this.weight = 400,
    this.isItalic = false,
    this.format = 'truetype',
  });

  /// URL to the font file (e.g., 'https://cdn.example.com/fonts/Font-Regular.woff2')
  final String url;

  /// Font weight (100-900). Default is 400 (regular).
  final int weight;

  /// Whether this is an italic variant.
  final bool isItalic;

  /// Font format ('woff2', 'woff', 'truetype', 'opentype').
  final String format;
}

/// Configuration for a custom font with priority-based loading.
///
/// ## Font Loading Priority
///
/// 1. **Hosted Assets** (Primary) - Load from your CDN or server
/// 2. **Google Fonts** (Fallback) - Optional, if hosted assets fail
/// 3. **System Fallback** (Final) - Always available system fonts
///
/// ## Example: Full Configuration
///
/// ```dart
/// CustomFontConfig(
///   name: 'Mulish',
///   value: 'mulish',
///   fontFamily: 'Mulish',
///   // Priority 1: Hosted font files
///   hostedFontBaseUrl: 'https://cdn.example.com/fonts/',
///   hostedFontVariants: [
///     FontVariant(url: 'Mulish-Regular.woff2', weight: 400, format: 'woff2'),
///     FontVariant(url: 'Mulish-Bold.woff2', weight: 700, format: 'woff2'),
///   ],
///   // Priority 2: Google Fonts fallback (optional)
///   googleFontsFamily: 'Mulish:wght@400;700',
///   // Priority 3: System fallback
///   fallback: 'sans-serif',
/// )
/// ```
class CustomFontConfig {
  const CustomFontConfig({
    required this.name,
    required this.value,
    required this.fontFamily,
    this.hostedFontBaseUrl,
    this.hostedFontVariants,
    this.googleFontsFamily,
    this.fontFaceCSS,
    this.fallback = 'sans-serif',
  });

  /// Display name in the font picker dropdown.
  final String name;

  /// Quill value (used in data-value attribute and CSS class).
  /// Example: 'mulish' generates class `.ql-font-mulish`
  final String value;

  /// CSS font-family value.
  /// Example: 'Mulish'
  final String fontFamily;

  /// Base URL for hosted font files (Priority 1).
  /// Example: 'https://cdn.example.com/fonts/'
  /// Font variant URLs will be appended to this base.
  final String? hostedFontBaseUrl;

  /// List of font variants with their URLs, weights, and styles.
  /// Used with [hostedFontBaseUrl] to generate @font-face declarations.
  final List<FontVariant>? hostedFontVariants;

  /// Google Fonts family parameter for URL (Priority 2 - optional fallback).
  /// Example: 'Mulish:wght@400;500;600;700'
  /// If null, Google Fonts fallback is disabled.
  final String? googleFontsFamily;

  /// Custom @font-face CSS declarations (alternative to hostedFontVariants).
  /// Use this for complete control over @font-face rules.
  /// This is included directly in the exported HTML.
  final String? fontFaceCSS;

  /// Fallback font family (Priority 3 - final fallback).
  /// Example: 'sans-serif', 'serif', 'monospace'
  final String fallback;

  /// Whether this font has hosted variants configured.
  bool get hasHostedFonts =>
      hostedFontBaseUrl != null &&
      hostedFontVariants != null &&
      hostedFontVariants!.isNotEmpty;

  /// Whether this font has Google Fonts fallback configured.
  bool get hasGoogleFontsFallback =>
      googleFontsFamily != null && googleFontsFamily!.isNotEmpty;

  /// Generates @font-face CSS for hosted fonts.
  String generateHostedFontFaceCSS() {
    if (!hasHostedFonts) return '';

    final buffer = StringBuffer();
    final baseUrl = hostedFontBaseUrl!.endsWith('/')
        ? hostedFontBaseUrl!
        : '${hostedFontBaseUrl!}/';

    for (final variant in hostedFontVariants!) {
      final fullUrl = variant.url.startsWith('http')
          ? variant.url
          : '$baseUrl${variant.url}';

      buffer.writeln('''
@font-face {
  font-family: '$fontFamily';
  src: url('$fullUrl') format('${variant.format}');
  font-weight: ${variant.weight};
  font-style: ${variant.isItalic ? 'italic' : 'normal'};
  font-display: swap;
}''');
    }

    return buffer.toString();
  }

  /// Generates the CSS class definition for this font.
  String get cssClass =>
      '.ql-font-$value { font-family: \'$fontFamily\', $fallback; }';

  /// Converts to FontConfig for compatibility with existing code.
  FontConfig toFontConfig() => FontConfig(
        name: name,
        value: value,
        fontFamily: fontFamily,
      );
}

/// A singleton registry for managing custom fonts in the Quill editor.
///
/// Supports three-priority font loading:
/// 1. **Hosted Assets** - Primary source from your CDN/server
/// 2. **Google Fonts** - Optional fallback if hosted fails
/// 3. **System Fallback** - Final fallback (sans-serif, serif, etc.)
///
/// ## Example Usage
///
/// ```dart
/// void main() {
///   // Register font with full priority chain
///   FontRegistry.instance.registerFont(
///     CustomFontConfig(
///       name: 'Corporate Font',
///       value: 'corporate',
///       fontFamily: 'CorporateFont',
///       // Priority 1: Your hosted fonts
///       hostedFontBaseUrl: 'https://cdn.yourcompany.com/fonts/',
///       hostedFontVariants: [
///         FontVariant(url: 'Corporate-Regular.woff2', weight: 400, format: 'woff2'),
///         FontVariant(url: 'Corporate-Bold.woff2', weight: 700, format: 'woff2'),
///       ],
///       // Priority 2: No Google Fonts fallback (proprietary font)
///       googleFontsFamily: null,
///       // Priority 3: System fallback
///       fallback: 'Arial, sans-serif',
///     ),
///   );
///
///   runApp(MyApp());
/// }
/// ```
///
/// ## For Fonts Available on Google Fonts
///
/// ```dart
/// FontRegistry.instance.registerFont(
///   CustomFontConfig(
///     name: 'Mulish',
///     value: 'mulish',
///     fontFamily: 'Mulish',
///     // Priority 1: Hosted fonts (faster, works offline if cached)
///     hostedFontBaseUrl: 'https://cdn.example.com/fonts/',
///     hostedFontVariants: [
///       FontVariant(url: 'Mulish-Regular.woff2', weight: 400, format: 'woff2'),
///       FontVariant(url: 'Mulish-Bold.woff2', weight: 700, format: 'woff2'),
///     ],
///     // Priority 2: Google Fonts fallback (if hosted fails)
///     googleFontsFamily: 'Mulish:wght@400;700',
///     // Priority 3: System fallback
///     fallback: 'sans-serif',
///   ),
/// );
/// ```
class FontRegistry {
  FontRegistry._();

  static final FontRegistry _instance = FontRegistry._();

  /// Singleton instance of the font registry.
  static FontRegistry get instance => _instance;

  final List<CustomFontConfig> _customFonts = [];

  /// List of registered custom fonts.
  List<CustomFontConfig> get customFonts => List.unmodifiable(_customFonts);

  /// All available fonts (package defaults + custom registered fonts).
  List<FontConfig> get allFonts {
    return [
      ...AppFonts.availableFonts,
      ..._customFonts.map((f) => f.toFontConfig()),
    ];
  }

  /// Registers a custom font.
  ///
  /// The font will be included in HTML exports with proper CSS classes
  /// and font loading based on the priority chain.
  void registerFont(CustomFontConfig font) {
    // Remove existing font with same value to allow updates
    _customFonts.removeWhere((f) => f.value == font.value);
    _customFonts.add(font);
  }

  /// Registers multiple custom fonts at once.
  void registerFonts(List<CustomFontConfig> fonts) {
    for (final font in fonts) {
      registerFont(font);
    }
  }

  /// Unregisters a custom font by its value.
  void unregisterFont(String value) {
    _customFonts.removeWhere((f) => f.value == value);
  }

  /// Clears all registered custom fonts.
  void clearCustomFonts() {
    _customFonts.clear();
  }

  /// Checks if a font is registered (either package default or custom).
  bool hasFont(String value) {
    return AppFonts.availableFonts.any((f) => f.value == value) ||
        _customFonts.any((f) => f.value == value);
  }

  /// Generates CSS classes for all fonts (package defaults + custom).
  String generateFontClasses() {
    final buffer = StringBuffer();

    // Package default fonts
    for (final font in AppFonts.availableFonts) {
      if (font.value.isNotEmpty) {
        buffer.writeln(
          ".ql-font-${font.value} { font-family: '${font.fontFamily}', sans-serif; }",
        );
      }
    }

    // Custom registered fonts
    for (final font in _customFonts) {
      buffer.writeln(font.cssClass);
    }

    return buffer.toString();
  }

  /// Generates @font-face CSS for all custom fonts.
  ///
  /// Priority order in generated CSS:
  /// 1. Hosted fonts (from hostedFontVariants)
  /// 2. Custom fontFaceCSS (if provided)
  String generateFontFaceCSS() {
    final buffer = StringBuffer();

    for (final font in _customFonts) {
      // Priority 1: Hosted font variants
      if (font.hasHostedFonts) {
        buffer.writeln('/* ${font.name} - Hosted Fonts (Priority 1) */');
        buffer.writeln(font.generateHostedFontFaceCSS());
      }

      // Alternative: Custom @font-face CSS
      if (font.fontFaceCSS != null && font.fontFaceCSS!.isNotEmpty) {
        buffer.writeln('/* ${font.name} - Custom @font-face */');
        buffer.writeln(font.fontFaceCSS);
      }
    }

    return buffer.toString();
  }

  /// Generates the complete Google Fonts URL including custom fonts.
  ///
  /// Only includes fonts that have googleFontsFamily configured
  /// (Priority 2 fallback fonts).
  String generateGoogleFontsUrl() {
    final families = <String>[];

    // Add custom fonts that have Google Fonts family defined
    for (final font in _customFonts) {
      if (font.hasGoogleFontsFallback) {
        families.add('family=${font.googleFontsFamily}');
      }
    }

    // If no custom Google Fonts, return the package default
    if (families.isEmpty) {
      return AppFonts.googleFontsUrl;
    }

    // Append custom fonts to the base URL
    final baseUrl = AppFonts.googleFontsUrl;
    final displaySwapIndex = baseUrl.indexOf('&display=swap');

    if (displaySwapIndex != -1) {
      final beforeDisplay = baseUrl.substring(0, displaySwapIndex);
      return '$beforeDisplay&${families.join('&')}&display=swap';
    } else {
      return '$baseUrl&${families.join('&')}';
    }
  }

  /// Gets the list of external stylesheets for HTML export.
  ///
  /// Includes:
  /// - Quill CSS
  /// - Table plugin CSS
  /// - Google Fonts URL (Priority 2 fallback fonts)
  List<String> get externalStylesheets => [
        'https://cdn.jsdelivr.net/npm/quill@2.0.0/dist/quill.snow.css',
        'https://cdn.jsdelivr.net/npm/quill-table-better@1/dist/quill-table-better.css',
        generateGoogleFontsUrl(),
      ];

  /// Generates a summary of the font loading strategy for debugging.
  String generateLoadingStrategySummary() {
    final buffer = StringBuffer();
    buffer.writeln('=== Font Loading Strategy ===\n');

    buffer.writeln('Package Default Fonts:');
    for (final font in AppFonts.availableFonts) {
      buffer.writeln('  - ${font.name} (${font.fontFamily})');
    }
    buffer.writeln();

    buffer.writeln('Custom Registered Fonts:');
    for (final font in _customFonts) {
      buffer.writeln('  ${font.name} (${font.fontFamily}):');
      buffer.writeln(
          '    Priority 1 (Hosted): ${font.hasHostedFonts ? "✓ Configured" : "✗ Not configured"}');
      if (font.hasHostedFonts) {
        buffer.writeln('      Base URL: ${font.hostedFontBaseUrl}');
        buffer.writeln(
            '      Variants: ${font.hostedFontVariants!.length} files');
      }
      buffer.writeln(
          '    Priority 2 (Google Fonts): ${font.hasGoogleFontsFallback ? "✓ Configured" : "✗ Disabled"}');
      if (font.hasGoogleFontsFallback) {
        buffer.writeln('      Family: ${font.googleFontsFamily}');
      }
      buffer.writeln('    Priority 3 (Fallback): ${font.fallback}');
      buffer.writeln();
    }

    return buffer.toString();
  }
}
