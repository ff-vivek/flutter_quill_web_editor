# Quill Web Editor

A rich text editor package for Flutter Web powered by [Quill.js](https://quilljs.com/).

## Features

- 📝 Full-featured rich text editing with formatting toolbar
- 📊 Table support with [quill-table-better](https://github.com/attojs/quill-table-better)
- 🖼️ Image, video, and media embedding with resize controls
- 🎨 Custom fonts (Roboto, Open Sans, Lato, Montserrat, etc.)
- 📏 Font sizes (small, normal, large, huge)
- 🔗 Links, blockquotes, code blocks
- 📋 Copy/paste with font preservation
- 💾 HTML import/export
- 🔍 Preview functionality
- 🔎 Zoom controls

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  quill_web_editor:
    git:
      url: https://github.com/icici/quill_web_editor.git
```

## Usage

### Basic Usage

```dart
import 'package:quill_web_editor/quill_web_editor.dart';

class MyEditor extends StatefulWidget {
  @override
  State<MyEditor> createState() => _MyEditorState();
}

class _MyEditorState extends State<MyEditor> {
  final GlobalKey<QuillEditorWidgetState> _editorKey = GlobalKey();
  String _html = '';

  @override
  Widget build(BuildContext context) {
    return QuillEditorWidget(
      key: _editorKey,
      onContentChanged: (html, delta) {
        setState(() => _html = html);
      },
      initialHtml: '<p>Hello World!</p>',
    );
  }
}
```

### Programmatic Control

```dart
// Set content
_editorKey.currentState?.setHTML('<p>New content</p>');

// Insert HTML at cursor
_editorKey.currentState?.insertHtml('<strong>Bold text</strong>');

// Clear editor
_editorKey.currentState?.clear();

// Zoom controls
_editorKey.currentState?.zoomIn();
_editorKey.currentState?.zoomOut();
_editorKey.currentState?.resetZoom();
```

### Using Components

```dart
// Save status indicator
SaveStatusIndicator(status: SaveStatus.saved)

// Zoom controls
ZoomControls(
  zoomLevel: 1.0,
  onZoomIn: () {},
  onZoomOut: () {},
  onReset: () {},
)

// Output preview with tabs
OutputPreview(html: _currentHtml)

// Statistics cards
StatCardRow(
  stats: [
    (label: 'Words', value: '150', icon: null),
    (label: 'Characters', value: '890', icon: null),
  ],
)

// Styled card
AppCard(
  title: 'Document Info',
  child: YourContent(),
)
```

### Services

```dart
// Download HTML
DocumentService.downloadHtml(htmlContent, filename: 'document.html');

// Copy to clipboard
await DocumentService.copyToClipboard(text);

// Print document
DocumentService.printHtml(htmlContent);

// Local storage
DocumentService.saveToLocalStorage('draft', htmlContent);
final saved = DocumentService.loadFromLocalStorage('draft');
```

### Utilities

```dart
// Clean HTML for export (removes editor artifacts)
final clean = HtmlCleaner.cleanForExport(dirtyHtml);

// Extract plain text
final text = HtmlCleaner.extractText(html);

// Get text statistics
final stats = TextStats.fromHtml(html);
print('Words: ${stats.wordCount}');
print('Characters: ${stats.charCount}');

// Generate export CSS
final css = ExportStyles.fullCss;
```

## Theming

Use the built-in theme or customize:

```dart
MaterialApp(
  theme: AppTheme.lightTheme,
  // ...
)
```

Or access individual colors:

```dart
Container(
  color: AppColors.accent,
  // ...
)
```

## Project Structure

```
lib/
├── quill_web_editor.dart          # Main export file
└── src/
    ├── core/
    │   ├── constants/
    │   │   ├── app_colors.dart    # Color palette
    │   │   ├── app_fonts.dart     # Font configurations
    │   │   └── editor_config.dart # Editor settings
    │   ├── theme/
    │   │   └── app_theme.dart     # Theme data
    │   └── utils/
    │       ├── html_cleaner.dart  # HTML processing
    │       ├── text_stats.dart    # Statistics
    │       └── export_styles.dart # Export CSS
    ├── widgets/
    │   ├── quill_editor_widget.dart
    │   ├── save_status_indicator.dart
    │   ├── zoom_controls.dart
    │   ├── output_preview.dart
    │   ├── stat_card.dart
    │   ├── app_card.dart
    │   ├── html_preview_dialog.dart
    │   └── insert_html_dialog.dart
    └── services/
        └── document_service.dart
```

## Web Assets

Copy the `web/quill_editor.html` and `web/quill_viewer.html` files to your app's `web/` directory.

## Example

See the `example/` directory for a complete example application.

```bash
cd example
flutter run -d chrome
```

## License

MIT License - see LICENSE file for details.

