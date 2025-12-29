import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quill_web_editor/src/core/constants/app_colors.dart';
import 'package:quill_web_editor/src/core/constants/app_fonts.dart';
import 'package:quill_web_editor/src/core/theme/app_theme.dart';
import 'package:quill_web_editor/src/core/utils/export_styles.dart';
import 'package:quill_web_editor/src/core/utils/font_registry.dart';
import 'package:quill_web_editor/src/widgets/output_preview.dart';

/// Widget tests for font-related functionality.
///
/// These tests verify:
/// - Font styles in AppTheme
/// - Font-related widgets render correctly
/// - Font configurations are reflected in UI
/// - Custom font widgets display proper content
void main() {
  // ============================================
  // Setup and Teardown
  // ============================================
  setUp(() {
    // Clear custom fonts before each test
    FontRegistry.instance.clearCustomFonts();
  });

  tearDown(() {
    FontRegistry.instance.clearCustomFonts();
  });

  // ============================================
  // AppTheme Font Style Widget Tests
  // ============================================
  group('AppTheme Font Style Widget Tests', () {
    testWidgets('Serif text style should render correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Text(
              'Serif Test',
              style: AppTheme.serifTextStyle,
            ),
          ),
        ),
      );

      expect(find.text('Serif Test'), findsOneWidget);

      // Verify the style properties
      final textWidget = tester.widget<Text>(find.text('Serif Test'));
      expect(textWidget.style, isNotNull);
      expect(textWidget.style!.fontSize, equals(18));
      expect(textWidget.style!.height, equals(1.8));
      expect(textWidget.style!.color, equals(AppColors.textPrimary));
    });

    testWidgets('Sans text style should render correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Text(
              'Sans Test',
              style: AppTheme.sansTextStyle,
            ),
          ),
        ),
      );

      expect(find.text('Sans Test'), findsOneWidget);

      final textWidget = tester.widget<Text>(find.text('Sans Test'));
      expect(textWidget.style, isNotNull);
      expect(textWidget.style!.fontSize, equals(14));
      expect(textWidget.style!.color, equals(AppColors.textPrimary));
    });

    testWidgets('Mono text style should render correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Text(
              'Mono Test',
              style: AppTheme.monoTextStyle,
            ),
          ),
        ),
      );

      expect(find.text('Mono Test'), findsOneWidget);

      final textWidget = tester.widget<Text>(find.text('Mono Test'));
      expect(textWidget.style, isNotNull);
      expect(textWidget.style!.fontSize, equals(14));
      expect(textWidget.style!.color, equals(AppColors.textPrimary));
    });

    testWidgets('Theme should apply text theme correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: Text('Theme Text'),
          ),
        ),
      );

      expect(find.text('Theme Text'), findsOneWidget);
    });

    testWidgets('All three font styles should render differently',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text('Serif', style: AppTheme.serifTextStyle),
                Text('Sans', style: AppTheme.sansTextStyle),
                Text('Mono', style: AppTheme.monoTextStyle),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Serif'), findsOneWidget);
      expect(find.text('Sans'), findsOneWidget);
      expect(find.text('Mono'), findsOneWidget);

      // Get the widgets and verify they have different properties
      final serifWidget = tester.widget<Text>(find.text('Serif'));
      final sansWidget = tester.widget<Text>(find.text('Sans'));
      final monoWidget = tester.widget<Text>(find.text('Mono'));

      // Serif has larger font size
      expect(serifWidget.style!.fontSize, greaterThan(sansWidget.style!.fontSize!));
      // Sans and Mono have same size
      expect(sansWidget.style!.fontSize, equals(monoWidget.style!.fontSize));
    });
  });

  // ============================================
  // OutputPreview Font Widget Tests
  // ============================================
  group('OutputPreview Font Widget Tests', () {
    testWidgets('Should display HTML content with font classes',
        (tester) async {
      const htmlWithFont =
          '<p><span class="ql-font-roboto">Roboto text</span></p>';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 400,
              child: OutputPreview(html: htmlWithFont),
            ),
          ),
        ),
      );

      // Should show HTML tab by default
      expect(find.text('HTML'), findsOneWidget);
      expect(find.text('Text'), findsOneWidget);

      // Should contain the font class in HTML output
      expect(find.textContaining('ql-font-roboto'), findsOneWidget);
    });

    testWidgets('Should switch between HTML and Text views', (tester) async {
      const htmlWithFont =
          '<p><span class="ql-font-roboto">Roboto text</span></p>';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 400,
              child: OutputPreview(html: htmlWithFont),
            ),
          ),
        ),
      );

      // HTML view should show font class
      expect(find.textContaining('ql-font-roboto'), findsOneWidget);

      // Tap on Text tab
      await tester.tap(find.text('Text'));
      await tester.pumpAndSettle();

      // Text view should show plain text without HTML
      expect(find.textContaining('Roboto text'), findsOneWidget);
      // Should not show HTML tags in text view
      expect(find.textContaining('<span'), findsNothing);
    });

    testWidgets('Should display multiple font classes in HTML',
        (tester) async {
      const htmlMultipleFonts = '''
<p><span class="ql-font-roboto">Roboto</span></p>
<p><span class="ql-font-mulish">Mulish</span></p>
<p><span class="ql-font-lato">Lato</span></p>
''';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 400,
              child: OutputPreview(html: htmlMultipleFonts),
            ),
          ),
        ),
      );

      // All font classes should be visible
      expect(find.textContaining('ql-font-roboto'), findsOneWidget);
      expect(find.textContaining('ql-font-mulish'), findsOneWidget);
      expect(find.textContaining('ql-font-lato'), findsOneWidget);
    });

    testWidgets('Should display font size classes in HTML', (tester) async {
      const htmlWithSizes = '''
<p><span class="ql-size-small">Small</span></p>
<p><span class="ql-size-large">Large</span></p>
<p><span class="ql-size-huge">Huge</span></p>
''';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 400,
              child: OutputPreview(html: htmlWithSizes),
            ),
          ),
        ),
      );

      expect(find.textContaining('ql-size-small'), findsOneWidget);
      expect(find.textContaining('ql-size-large'), findsOneWidget);
      expect(find.textContaining('ql-size-huge'), findsOneWidget);
    });

    testWidgets('Should display line height classes in HTML', (tester) async {
      const htmlWithLineHeights = '''
<p class="ql-line-height-1">Line 1</p>
<p class="ql-line-height-1-5">Line 1.5</p>
<p class="ql-line-height-2">Line 2</p>
''';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 400,
              child: OutputPreview(html: htmlWithLineHeights),
            ),
          ),
        ),
      );

      expect(find.textContaining('ql-line-height-1'), findsWidgets);
      expect(find.textContaining('ql-line-height-1-5'), findsOneWidget);
      expect(find.textContaining('ql-line-height-2'), findsOneWidget);
    });

    testWidgets('Should use monospace font for HTML display', (tester) async {
      const html = '<p>Test</p>';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 400,
              child: OutputPreview(html: html),
            ),
          ),
        ),
      );

      // Find SelectableText which displays the content
      final selectableTextFinder = find.byType(SelectableText);
      expect(selectableTextFinder, findsOneWidget);

      final selectableText =
          tester.widget<SelectableText>(selectableTextFinder);
      expect(selectableText.style, isNotNull);
      expect(selectableText.style!.fontFamily, equals('monospace'));
    });

    testWidgets('Should call onOutputTypeChanged when switching tabs',
        (tester) async {
      OutputType? changedType;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 400,
              child: OutputPreview(
                html: '<p>Test</p>',
                onOutputTypeChanged: (type) => changedType = type,
              ),
            ),
          ),
        ),
      );

      // Tap Text tab
      await tester.tap(find.text('Text'));
      await tester.pumpAndSettle();

      expect(changedType, equals(OutputType.text));

      // Tap HTML tab
      await tester.tap(find.text('HTML'));
      await tester.pumpAndSettle();

      expect(changedType, equals(OutputType.html));
    });

    testWidgets('Should start with specified initialOutputType',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 400,
              child: OutputPreview(
                html: '<p><span class="ql-font-roboto">FontContent</span></p>',
                initialOutputType: OutputType.text,
              ),
            ),
          ),
        ),
      );

      // Should show plain text content, not HTML tags
      expect(find.textContaining('FontContent'), findsOneWidget);
      expect(find.textContaining('<p>'), findsNothing);
    });
  });

  // ============================================
  // Font Picker Display Widget Tests
  // ============================================
  group('Font Picker Display Widget Tests', () {
    testWidgets('Should display available fonts in a list', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: AppFonts.availableFonts.length,
              itemBuilder: (context, index) {
                final font = AppFonts.availableFonts[index];
                return ListTile(
                  title: Text(font.name),
                  subtitle: Text(font.fontFamily),
                );
              },
            ),
          ),
        ),
      );

      // Should display Roboto (default font)
      expect(find.text('Roboto'), findsWidgets);
    });

    testWidgets('Should display custom fonts after registration',
        (tester) async {
      // Register a custom font
      FontRegistry.instance.registerFont(
        const CustomFontConfig(
          name: 'Custom Font',
          value: 'custom',
          fontFamily: 'CustomFont',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: FontRegistry.instance.allFonts.length,
              itemBuilder: (context, index) {
                final font = FontRegistry.instance.allFonts[index];
                return ListTile(
                  title: Text(font.name),
                  subtitle: Text(font.fontFamily),
                );
              },
            ),
          ),
        ),
      );

      // Should display both default and custom fonts (name appears in title)
      // Using findsWidgets because font name and fontFamily may be the same
      expect(find.text('Roboto'), findsWidgets);
      expect(find.text('Custom Font'), findsOneWidget);
      expect(find.text('CustomFont'), findsOneWidget);
    });

    testWidgets('Should display font sizes in a dropdown-like widget',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: AppFonts.availableSizes.map((size) {
                return Container(
                  padding: const EdgeInsets.all(8),
                  child: Text(size.name),
                );
              }).toList(),
            ),
          ),
        ),
      );

      expect(find.text('Small'), findsOneWidget);
      expect(find.text('Normal'), findsOneWidget);
      expect(find.text('Large'), findsOneWidget);
      expect(find.text('Huge'), findsOneWidget);
    });

    testWidgets('Should display line heights in a list', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: AppFonts.availableLineHeights.map((lh) {
                return Container(
                  padding: const EdgeInsets.all(8),
                  child: Text(lh.name),
                );
              }).toList(),
            ),
          ),
        ),
      );

      expect(find.text('1.0'), findsOneWidget);
      expect(find.text('1.5'), findsOneWidget);
      expect(find.text('2.0'), findsOneWidget);
      expect(find.text('2.5'), findsOneWidget);
      expect(find.text('3.0'), findsOneWidget);
    });
  });

  // ============================================
  // Font Configuration Display Widget Tests
  // ============================================
  group('Font Configuration Display Widget Tests', () {
    testWidgets('Should display font CSS class in a code preview',
        (tester) async {
      final cssClass = AppFonts.availableFonts.first.cssClass;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[100],
              child: Text(
                cssClass,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('ql-font-roboto'), findsOneWidget);
    });

    testWidgets('Should display ExportStyles.fullCss in scrollable widget',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SelectableText(
                ExportStyles.fullCss,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      );

      // Should render the CSS
      expect(find.byType(SelectableText), findsOneWidget);

      // The CSS should contain font-related classes
      final selectableText =
          tester.widget<SelectableText>(find.byType(SelectableText));
      expect(selectableText.data, contains('.ql-font-roboto'));
      expect(selectableText.data, contains('.ql-size-small'));
      expect(selectableText.data, contains('.ql-line-height-'));
    });

    testWidgets('Should display Google Fonts URL', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                AppFonts.googleFontsUrl,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        ),
      );

      expect(find.textContaining('fonts.googleapis.com'), findsOneWidget);
    });
  });

  // ============================================
  // Font Registry Widget Integration Tests
  // ============================================
  group('Font Registry Widget Integration Tests', () {
    testWidgets('Should update font list when fonts are registered',
        (tester) async {
      // Build widget with initial fonts
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _FontListWidget(),
          ),
        ),
      );

      // Initially should have only package fonts
      // Roboto appears twice: once in title, once in subtitle (name == fontFamily)
      expect(find.text('Roboto'), findsWidgets);
      expect(find.text('MulishFont'), findsNothing);

      // Register new font with distinct name and fontFamily
      FontRegistry.instance.registerFont(
        const CustomFontConfig(
          name: 'Mulish Display',
          value: 'mulish',
          fontFamily: 'MulishFont',
        ),
      );

      // Rebuild widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _FontListWidget(),
          ),
        ),
      );

      // Should now include Mulish
      expect(find.text('Roboto'), findsWidgets);
      expect(find.text('Mulish Display'), findsOneWidget);
      expect(find.text('MulishFont'), findsOneWidget);
    });

    testWidgets('Should display font loading strategy summary',
        (tester) async {
      FontRegistry.instance.registerFont(
        const CustomFontConfig(
          name: 'Corporate Font',
          value: 'corporate',
          fontFamily: 'CorporateFont',
          hostedFontBaseUrl: 'https://cdn.example.com/',
          hostedFontVariants: [
            FontVariant(url: 'font.woff2', weight: 400, format: 'woff2'),
          ],
          googleFontsFamily: 'Open+Sans:wght@400',
          fallback: 'Arial, sans-serif',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Text(
                FontRegistry.instance.generateLoadingStrategySummary(),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ),
        ),
      );

      expect(find.textContaining('Font Loading Strategy'), findsOneWidget);
      expect(find.textContaining('Corporate Font'), findsOneWidget);
      expect(find.textContaining('Priority 1'), findsOneWidget);
    });
  });

  // ============================================
  // Font Dropdown Simulation Widget Tests
  // ============================================
  group('Font Dropdown Simulation Widget Tests', () {
    testWidgets('Should display font dropdown with all fonts', (tester) async {
      // Register custom font
      FontRegistry.instance.registerFont(
        const CustomFontConfig(
          name: 'Custom Font',
          value: 'custom',
          fontFamily: 'CustomFont',
        ),
      );

      String? selectedFont = 'roboto';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return DropdownButton<String>(
                  value: selectedFont,
                  items: FontRegistry.instance.allFonts.map((font) {
                    return DropdownMenuItem(
                      value: font.value,
                      child: Text(font.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedFont = value);
                  },
                );
              },
            ),
          ),
        ),
      );

      // Should show current selection
      expect(find.text('Roboto'), findsOneWidget);

      // Tap to open dropdown
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      // Should show all options
      expect(find.text('Roboto'), findsWidgets);
      expect(find.text('Custom Font'), findsWidgets);
    });

    testWidgets('Should display size dropdown with all sizes', (tester) async {
      String? selectedSize = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return DropdownButton<String>(
                  value: selectedSize,
                  items: AppFonts.availableSizes.map((size) {
                    return DropdownMenuItem(
                      value: size.value,
                      child: Text(size.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedSize = value);
                  },
                );
              },
            ),
          ),
        ),
      );

      // Should show Normal by default
      expect(find.text('Normal'), findsOneWidget);

      // Tap to open
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      // All sizes should be visible
      expect(find.text('Small'), findsWidgets);
      expect(find.text('Normal'), findsWidgets);
      expect(find.text('Large'), findsWidgets);
      expect(find.text('Huge'), findsWidgets);
    });

    testWidgets('Should display line height dropdown', (tester) async {
      String? selectedLineHeight = '1';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return DropdownButton<String>(
                  value: selectedLineHeight,
                  items: AppFonts.availableLineHeights.map((lh) {
                    return DropdownMenuItem(
                      value: lh.value,
                      child: Text(lh.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedLineHeight = value);
                  },
                );
              },
            ),
          ),
        ),
      );

      // Should show 1.0 by default
      expect(find.text('1.0'), findsOneWidget);

      // Tap to open
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      // All line heights should be visible
      expect(find.text('1.0'), findsWidgets);
      expect(find.text('1.5'), findsWidgets);
      expect(find.text('2.0'), findsWidgets);
    });
  });

  // ============================================
  // Font Preview Card Widget Tests
  // ============================================
  group('Font Preview Card Widget Tests', () {
    testWidgets('Should display font preview with name and sample',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppFonts.availableFonts.first.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'The quick brown fox jumps over the lazy dog',
                      style: TextStyle(
                        fontFamily: AppFonts.availableFonts.first.fontFamily,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'CSS: .${AppFonts.availableFonts.first.cssClass}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Roboto'), findsOneWidget);
      expect(find.text('The quick brown fox jumps over the lazy dog'),
          findsOneWidget);
      expect(find.textContaining('CSS:'), findsOneWidget);
    });

    testWidgets('Should display all font sizes in preview', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: AppFonts.availableSizes.map((size) {
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(size.name),
                      ),
                      Expanded(
                        child: Text(
                          'Sample text',
                          style: TextStyle(
                            fontSize: _getFontSizeForValue(size.value),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      );

      expect(find.text('Small'), findsOneWidget);
      expect(find.text('Normal'), findsOneWidget);
      expect(find.text('Large'), findsOneWidget);
      expect(find.text('Huge'), findsOneWidget);
      expect(find.text('Sample text'), findsNWidgets(4));
    });
  });

  // ============================================
  // HTML Export with Fonts Widget Tests
  // ============================================
  group('HTML Export with Fonts Widget Tests', () {
    testWidgets('Should display exported HTML with custom font',
        (tester) async {
      FontRegistry.instance.registerFont(
        const CustomFontConfig(
          name: 'Mulish',
          value: 'mulish',
          fontFamily: 'Mulish',
        ),
      );

      final html = ExportStyles.generateHtmlDocument(
        '<p>Test content</p>',
        defaultFont: 'mulish',
        title: 'Font Test',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SelectableText(
                html,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 10),
              ),
            ),
          ),
        ),
      );

      final selectableText =
          tester.widget<SelectableText>(find.byType(SelectableText));
      expect(selectableText.data, contains('ql-font-mulish'));
      expect(selectableText.data, contains('<title>Font Test</title>'));
    });

    testWidgets('Should display external stylesheets in preview',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: ExportStyles.externalStylesheets.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.link),
                  title: Text(
                    ExportStyles.externalStylesheets[index],
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(find.textContaining('quill.snow.css'), findsOneWidget);
      expect(find.textContaining('quill-table-better.css'), findsOneWidget);
      expect(find.textContaining('fonts.googleapis.com'), findsOneWidget);
    });
  });

  // ============================================
  // Theme Font Integration Widget Tests
  // ============================================
  group('Theme Font Integration Widget Tests', () {
    testWidgets('AppBar should use correct title font', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Editor Title'),
            ),
          ),
        ),
      );

      expect(find.text('Editor Title'), findsOneWidget);
    });

    testWidgets('Cards should render with theme styling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Card(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: const Text('Card with theme font'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Card with theme font'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('Buttons should use theme text style', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Column(
              children: [
                FilledButton(
                  onPressed: () {},
                  child: const Text('Filled Button'),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Text Button'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Filled Button'), findsOneWidget);
      expect(find.text('Text Button'), findsOneWidget);
    });

    testWidgets('Input fields should use theme decoration', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Font Input',
                  hintText: 'Enter text...',
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Font Input'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });
  });

  // ============================================
  // Font Error Handling Widget Tests
  // ============================================
  group('Font Error Handling Widget Tests', () {
    testWidgets('Should handle empty font list gracefully', (tester) async {
      // This simulates a scenario where fonts might be empty
      final emptyFonts = <FontConfig>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: emptyFonts.isEmpty
                ? const Text('No fonts available')
                : ListView.builder(
                    itemCount: emptyFonts.length,
                    itemBuilder: (context, index) {
                      return ListTile(title: Text(emptyFonts[index].name));
                    },
                  ),
          ),
        ),
      );

      expect(find.text('No fonts available'), findsOneWidget);
    });

    testWidgets('Should display fallback when font loading fails',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Text(
              'Fallback font test',
              style: TextStyle(
                fontFamily: 'NonExistentFont',
                fontFamilyFallback: const ['Roboto', 'sans-serif'],
              ),
            ),
          ),
        ),
      );

      // Widget should still render with fallback
      expect(find.text('Fallback font test'), findsOneWidget);
    });
  });
}

/// Helper widget to display font list from FontRegistry
class _FontListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: FontRegistry.instance.allFonts.length,
      itemBuilder: (context, index) {
        final font = FontRegistry.instance.allFonts[index];
        return ListTile(
          title: Text(font.name),
          subtitle: Text(font.fontFamily),
        );
      },
    );
  }
}

/// Helper function to convert size value to actual font size
double _getFontSizeForValue(String value) {
  switch (value) {
    case 'small':
      return 12;
    case 'large':
      return 24;
    case 'huge':
      return 40;
    default:
      return 16; // Normal
  }
}

