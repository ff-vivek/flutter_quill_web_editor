/// Font configurations for the Quill Web Editor package.
///
/// Defines available fonts, their CSS class names, and display labels.
abstract class AppFonts {
  /// Default sans-serif font family
  static const String sansFontFamily = 'DM Sans';

  /// Default serif font family (for editor content)
  static const String serifFontFamily = 'Crimson Pro';

  /// Monospace font family (for code blocks)
  static const String monoFontFamily = 'Source Code Pro';

  /// Available fonts in the editor with their Quill class names
  static const List<FontConfig> availableFonts = [
    FontConfig(name: 'Sans Serif', value: '', fontFamily: 'sans-serif'),
    FontConfig(name: 'Roboto', value: 'roboto', fontFamily: 'Roboto'),
    FontConfig(name: 'Open Sans', value: 'open-sans', fontFamily: 'Open Sans'),
    FontConfig(name: 'Lato', value: 'lato', fontFamily: 'Lato'),
    FontConfig(name: 'Montserrat', value: 'montserrat', fontFamily: 'Montserrat'),
    FontConfig(name: 'Source Code', value: 'source-code', fontFamily: 'Source Code Pro'),
    FontConfig(name: 'Crimson Pro', value: 'crimson', fontFamily: 'Crimson Pro'),
    FontConfig(name: 'DM Sans', value: 'dm-sans', fontFamily: 'DM Sans'),
  ];

  /// Font size options
  static const List<SizeConfig> availableSizes = [
    SizeConfig(name: 'Small', value: 'small', cssClass: 'ql-size-small'),
    SizeConfig(name: 'Normal', value: '', cssClass: ''),
    SizeConfig(name: 'Large', value: 'large', cssClass: 'ql-size-large'),
    SizeConfig(name: 'Huge', value: 'huge', cssClass: 'ql-size-huge'),
  ];

  /// Line height options
  static const List<LineHeightConfig> availableLineHeights = [
    LineHeightConfig(name: '1.0', value: '1', cssClass: 'ql-line-height-1'),
    LineHeightConfig(name: '1.5', value: '1-5', cssClass: 'ql-line-height-1-5'),
    LineHeightConfig(name: '2.0', value: '2', cssClass: 'ql-line-height-2'),
    LineHeightConfig(name: '2.5', value: '2-5', cssClass: 'ql-line-height-2-5'),
    LineHeightConfig(name: '3.0', value: '3', cssClass: 'ql-line-height-3'),
  ];

  /// Google Fonts URL for loading all required fonts
  static const String googleFontsUrl =
      'https://fonts.googleapis.com/css2?family=Crimson+Pro:wght@400;500;600&family=DM+Sans:wght@400;500;600&family=Roboto:wght@400;500&family=Open+Sans:wght@400;500&family=Lato:wght@400;700&family=Montserrat:wght@400;500;600&family=Source+Code+Pro:wght@400;500&display=swap';
}

/// Configuration for a font option
class FontConfig {
  const FontConfig({
    required this.name,
    required this.value,
    required this.fontFamily,
  });

  /// Display name in the dropdown
  final String name;

  /// Quill value (used in data-value attribute)
  final String value;

  /// CSS font-family value
  final String fontFamily;

  /// CSS class name for this font
  String get cssClass => value.isEmpty ? '' : 'ql-font-$value';
}

/// Configuration for a size option
class SizeConfig {
  const SizeConfig({
    required this.name,
    required this.value,
    required this.cssClass,
  });

  final String name;
  final String value;
  final String cssClass;
}

/// Configuration for a line height option
class LineHeightConfig {
  const LineHeightConfig({
    required this.name,
    required this.value,
    required this.cssClass,
  });

  final String name;
  final String value;
  final String cssClass;
}

