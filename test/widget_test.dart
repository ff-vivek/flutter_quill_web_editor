import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quill_web_editor/src/core/constants/app_colors.dart';
import 'package:quill_web_editor/src/core/constants/app_fonts.dart';
import 'package:quill_web_editor/src/core/constants/editor_config.dart';
import 'package:quill_web_editor/src/core/theme/app_theme.dart';
import 'package:quill_web_editor/src/widgets/app_card.dart';
import 'package:quill_web_editor/src/widgets/save_status_indicator.dart';
import 'package:quill_web_editor/src/widgets/stat_card.dart'
    show StatCard, StatCardRow;
import 'package:quill_web_editor/src/widgets/zoom_controls.dart';

/// Widget tests for the Quill Web Editor package.
///
/// Note: Full widget tests require a web browser environment.
/// These tests focus on the stateless utility widgets and configurations.
void main() {
  // Disable Google Fonts network fetching for tests
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('AppTheme Tests', () {
    test('Should provide light theme', () {
      final theme = AppTheme.lightTheme;
      expect(theme, isA<ThemeData>());
      expect(theme.useMaterial3, isTrue);
    });

    test('Theme should use correct scaffold background color', () {
      final theme = AppTheme.lightTheme;
      expect(theme.scaffoldBackgroundColor, equals(AppColors.background));
    });

    test('Should provide serif text style', () {
      final style = AppTheme.serifTextStyle;
      expect(style, isA<TextStyle>());
      expect(style.fontSize, equals(18));
    });

    test('Should provide sans text style', () {
      final style = AppTheme.sansTextStyle;
      expect(style, isA<TextStyle>());
      expect(style.fontSize, equals(14));
    });

    test('Should provide mono text style', () {
      final style = AppTheme.monoTextStyle;
      expect(style, isA<TextStyle>());
      expect(style.fontSize, equals(14));
    });

    test('Should provide editor container decoration', () {
      final decoration = AppTheme.editorContainerDecoration;
      expect(decoration, isA<BoxDecoration>());
      expect(decoration.color, equals(AppColors.surface));
      expect(decoration.borderRadius, isNotNull);
    });

    test('Should provide card decoration', () {
      final decoration = AppTheme.cardDecoration;
      expect(decoration, isA<BoxDecoration>());
      expect(decoration.color, equals(AppColors.surface));
    });
  });

  group('AppColors Tests', () {
    test('Should have all required colors defined', () {
      expect(AppColors.accent, isA<Color>());
      expect(AppColors.surface, isA<Color>());
      expect(AppColors.background, isA<Color>());
      expect(AppColors.textPrimary, isA<Color>());
      expect(AppColors.textSecondary, isA<Color>());
      expect(AppColors.border, isA<Color>());
    });

    test('Accent color should be the expected value', () {
      expect(AppColors.accent, equals(const Color(0xFFC45D35)));
    });

    test('Surface color should be white', () {
      expect(AppColors.surface, equals(const Color(0xFFFFFFFF)));
    });
  });

  group('AppFonts Tests', () {
    test('Should have default font families defined', () {
      expect(AppFonts.sansFontFamily, isNotEmpty);
      expect(AppFonts.serifFontFamily, isNotEmpty);
      expect(AppFonts.monoFontFamily, isNotEmpty);
    });

    test('Should have available fonts list', () {
      expect(AppFonts.availableFonts, isNotEmpty);
      expect(AppFonts.availableFonts.length, greaterThanOrEqualTo(7));
    });

    test('Each font should have required properties', () {
      for (final font in AppFonts.availableFonts) {
        expect(font.name, isNotEmpty);
        expect(font.fontFamily, isNotEmpty);
        // value can be empty for default font
      }
    });

    test('Should have available sizes list', () {
      expect(AppFonts.availableSizes, isNotEmpty);
      expect(AppFonts.availableSizes.length, greaterThanOrEqualTo(3));
    });

    test('Should have line heights list', () {
      expect(AppFonts.availableLineHeights, isNotEmpty);
      expect(AppFonts.availableLineHeights.length, equals(5));
    });

    test('Should have Google Fonts URL', () {
      expect(AppFonts.googleFontsUrl, contains('fonts.googleapis.com'));
    });
  });

  group('EditorConfig Tests', () {
    test('Should have zoom constraints defined', () {
      expect(EditorConfig.minZoom, lessThan(EditorConfig.maxZoom));
      expect(EditorConfig.defaultZoom, equals(1.0));
      expect(EditorConfig.zoomStep, greaterThan(0));
    });

    test('Should have table constraints defined', () {
      expect(EditorConfig.defaultTableRows, greaterThan(0));
      expect(EditorConfig.defaultTableCols, greaterThan(0));
      expect(
        EditorConfig.maxTableRows,
        greaterThan(EditorConfig.defaultTableRows),
      );
      expect(
        EditorConfig.maxTableCols,
        greaterThan(EditorConfig.defaultTableCols),
      );
    });

    test('Should have CDN URLs defined', () {
      expect(EditorConfig.quillCdnCss, contains('quill'));
      expect(EditorConfig.quillCdnJs, contains('quill'));
      expect(EditorConfig.quillTableBetterCss, contains('table-better'));
    });

    test('Should have artifact classes for cleanup', () {
      expect(EditorConfig.editorArtifactClasses, isNotEmpty);
      expect(
        EditorConfig.editorArtifactClasses.contains('ql-cell-focused'),
        isTrue,
      );
    });

    test('Should have artifact attributes for cleanup', () {
      expect(EditorConfig.editorArtifactAttributes, isNotEmpty);
      expect(
        EditorConfig.editorArtifactAttributes.contains('contenteditable'),
        isTrue,
      );
    });

    test('Should have default placeholder', () {
      expect(EditorConfig.defaultPlaceholder, isNotEmpty);
    });
  });

  group('SaveStatus Tests', () {
    test('Should have all status values', () {
      expect(SaveStatus.values.length, equals(3));
      expect(SaveStatus.values.contains(SaveStatus.saved), isTrue);
      expect(SaveStatus.values.contains(SaveStatus.saving), isTrue);
      expect(SaveStatus.values.contains(SaveStatus.unsaved), isTrue);
    });
  });

  group('SaveStatusIndicator Widget Tests', () {
    testWidgets('Should render saved status', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SaveStatusIndicator(status: SaveStatus.saved)),
        ),
      );

      expect(find.text('Saved'), findsOneWidget);
    });

    testWidgets('Should render saving status', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SaveStatusIndicator(status: SaveStatus.saving)),
        ),
      );

      expect(find.text('Saving...'), findsOneWidget);
    });

    testWidgets('Should render unsaved status', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SaveStatusIndicator(status: SaveStatus.unsaved)),
        ),
      );

      expect(find.text('Unsaved'), findsOneWidget);
    });
  });

  group('StatCard Widget Tests', () {
    testWidgets('Should render label and value', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatCard(label: 'Words', value: '42'),
          ),
        ),
      );

      expect(find.text('Words'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
    });
  });

  group('StatCardRow Widget Tests', () {
    testWidgets('Should render multiple stats', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatCardRow(
              stats: const [
                (label: 'Words', value: '100', icon: null),
                (label: 'Characters', value: '500', icon: null),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Words'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
      expect(find.text('Characters'), findsOneWidget);
      expect(find.text('500'), findsOneWidget);
    });
  });

  group('AppCard Widget Tests', () {
    testWidgets('Should render child widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppCard(child: Text('Card Content'))),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
    });

    testWidgets('Should render title when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppCard(title: 'Card Title', child: Text('Card Content')),
          ),
        ),
      );

      expect(find.text('CARD TITLE'), findsOneWidget);
      expect(find.text('Card Content'), findsOneWidget);
    });
  });

  group('ZoomControls Widget Tests', () {
    testWidgets('Should render zoom level', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZoomControls(
              zoomLevel: 1.0,
              onZoomIn: () {},
              onZoomOut: () {},
              onReset: () {},
            ),
          ),
        ),
      );

      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('Should call onZoomIn when zoom in button pressed', (
      tester,
    ) async {
      var zoomInCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZoomControls(
              zoomLevel: 1.0,
              onZoomIn: () => zoomInCalled = true,
              onZoomOut: () {},
              onReset: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.add));
      expect(zoomInCalled, isTrue);
    });

    testWidgets('Should call onZoomOut when zoom out button pressed', (
      tester,
    ) async {
      var zoomOutCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZoomControls(
              zoomLevel: 1.0,
              onZoomIn: () {},
              onZoomOut: () => zoomOutCalled = true,
              onReset: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.remove));
      expect(zoomOutCalled, isTrue);
    });
  });
}
