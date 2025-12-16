# Quill Web Editor

A powerful, full-featured rich text editor package for **Flutter Web** powered by [Quill.js](https://quilljs.com/).

[![Flutter](https://img.shields.io/badge/Flutter-Web-blue?logo=flutter)](https://flutter.dev)
[![Quill.js](https://img.shields.io/badge/Quill.js-2.0-purple)](https://quilljs.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

<p align="center">
  <img src="https://quilljs.com/assets/images/logo.svg" width="120" alt="Quill Logo">
</p>

## ✨ Features

| Feature | Description |
|---------|-------------|
| 📝 **Rich Text Editing** | Full formatting toolbar with bold, italic, underline, strikethrough |
| 📊 **Table Support** | Create and edit tables with [quill-table-better](https://github.com/attojs/quill-table-better) |
| 🖼️ **Media Embedding** | Images, videos, and iframes with resize controls |
| 🎨 **Custom Fonts** | Roboto, Open Sans, Lato, Montserrat, Crimson Pro, DM Sans, Source Code Pro |
| 📏 **Font Sizes** | Small, Normal, Large, Huge |
| 📐 **Line Heights** | 1.0, 1.5, 2.0, 2.5, 3.0 |
| 🔗 **Links & Code** | Hyperlinks, blockquotes, inline code, code blocks |
| 📋 **Smart Paste** | Preserves fonts and formatting when pasting |
| 💾 **HTML Export** | Clean HTML export with all styles preserved |
| 🔍 **Preview** | Full-screen preview with print support |
| 🔎 **Zoom Controls** | 50% to 300% zoom range |
| 😀 **Emoji Support** | Built-in emoji picker |
| ✅ **Checklists** | Task lists with checkboxes |
| 🎯 **Alignment** | Left, center, right, justify |

---

## 📦 Installation

### Step 1: Add Dependency

Add to your `pubspec.yaml`:

```yaml
dependencies:
  quill_web_editor:
    git:
      url: https://github.com/icici/quill_web_editor.git
```

### Step 2: Copy Web Assets

Copy the HTML files from the package to your app's `web/` directory:

```
your_app/
└── web/
    ├── index.html
    ├── quill_editor.html    ← Copy from package
    └── quill_viewer.html    ← Copy from package
```

### Step 3: Import

```dart
import 'package:quill_web_editor/quill_web_editor.dart';
```

---

## 🚀 Quick Start

### Basic Editor

```dart
import 'package:flutter/material.dart';
import 'package:quill_web_editor/quill_web_editor.dart';

class MyEditor extends StatefulWidget {
  const MyEditor({super.key});

  @override
  State<MyEditor> createState() => _MyEditorState();
}

class _MyEditorState extends State<MyEditor> {
  final GlobalKey<QuillEditorWidgetState> _editorKey = GlobalKey();
  String _currentHtml = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: QuillEditorWidget(
        key: _editorKey,
        onContentChanged: (html, delta) {
          setState(() => _currentHtml = html);
        },
        initialHtml: '<p>Start writing...</p>',
      ),
    );
  }
}
```

### Read-Only Viewer

```dart
QuillEditorWidget(
  readOnly: true,
  initialHtml: '<p>This content is read-only</p>',
)
```

---

## 📖 API Reference

### QuillEditorWidget

The main editor widget that embeds Quill.js via an iframe.

#### Constructor Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `key` | `GlobalKey<QuillEditorWidgetState>` | - | Key for accessing editor state |
| `width` | `double?` | `null` | Editor width (expands to fill if null) |
| `height` | `double?` | `null` | Editor height (expands to fill if null) |
| `onContentChanged` | `Function(String html, dynamic delta)?` | `null` | Callback when content changes |
| `onReady` | `VoidCallback?` | `null` | Callback when editor is initialized |
| `readOnly` | `bool` | `false` | Enable viewer mode |
| `initialHtml` | `String?` | `null` | Initial HTML content |
| `initialDelta` | `dynamic` | `null` | Initial Quill Delta content |
| `placeholder` | `String?` | `null` | Placeholder text |
| `editorHtmlPath` | `String?` | `'quill_editor.html'` | Custom editor HTML path |
| `viewerHtmlPath` | `String?` | `'quill_viewer.html'` | Custom viewer HTML path |

#### State Methods

Access via `GlobalKey<QuillEditorWidgetState>`:

```dart
final GlobalKey<QuillEditorWidgetState> _editorKey = GlobalKey();

// Later...
_editorKey.currentState?.methodName();
```

| Method | Description |
|--------|-------------|
| `setHTML(String html, {bool replace = true})` | Set editor content from HTML |
| `insertHtml(String html, {bool replace = false})` | Insert HTML at cursor position |
| `setContents(dynamic delta)` | Set content from Quill Delta |
| `insertText(String text)` | Insert plain text at cursor |
| `getContents()` | Request current content (triggers callback) |
| `clear()` | Clear all editor content |
| `focus()` | Focus the editor |
| `zoomIn()` | Increase zoom by 10% |
| `zoomOut()` | Decrease zoom by 10% |
| `resetZoom()` | Reset zoom to 100% |
| `setZoom(double level)` | Set specific zoom level (0.5 - 3.0) |

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `currentZoom` | `double` | Current zoom level (1.0 = 100%) |
| `isReady` | `bool` | Whether editor is ready for commands |

---

## 🧩 Components

### SaveStatusIndicator

Displays save status with animated transitions.

```dart
SaveStatusIndicator(status: SaveStatus.saved)
SaveStatusIndicator(status: SaveStatus.saving)
SaveStatusIndicator(status: SaveStatus.unsaved)
```

### ZoomControls

Zoom in/out controls with percentage display.

```dart
ZoomControls(
  zoomLevel: _zoomLevel,
  onZoomIn: () => _editorKey.currentState?.zoomIn(),
  onZoomOut: () => _editorKey.currentState?.zoomOut(),
  onReset: () => _editorKey.currentState?.resetZoom(),
)
```

### OutputPreview

Tabbed preview showing HTML source and plain text.

```dart
OutputPreview(html: _currentHtml)
```

### StatCard & StatCardRow

Display document statistics.

```dart
// Single stat
StatCard(label: 'Words', value: '150')

// Multiple stats in a row
StatCardRow(
  stats: [
    (label: 'Words', value: '150', icon: Icons.text_fields),
    (label: 'Characters', value: '890', icon: Icons.format_size),
  ],
)
```

### AppCard

Styled container card with optional title.

```dart
AppCard(
  title: 'Document Info',  // Optional
  child: YourContent(),
)
```

### HtmlPreviewDialog

Full-screen HTML preview dialog with copy and print options.

```dart
// Show preview dialog
HtmlPreviewDialog.show(context, htmlContent);
```

### InsertHtmlDialog

Dialog for inserting raw HTML into the editor.

```dart
final result = await InsertHtmlDialog.show(context);
if (result != null) {
  _editorKey.currentState?.insertHtml(
    result.html,
    replace: result.replaceContent,
  );
}
```

---

## 🛠️ Services

### DocumentService

Utility service for document operations.

#### Download Files

```dart
// Download as HTML (with styles)
DocumentService.downloadHtml(
  htmlContent,
  filename: 'document.html',
  cleanHtml: true,  // Remove editor artifacts
);

// Download as plain text
DocumentService.downloadText(
  textContent,
  filename: 'document.txt',
);
```

#### Clipboard Operations

```dart
// Copy to clipboard
final success = await DocumentService.copyToClipboard(text);

// Read from clipboard
final text = await DocumentService.readFromClipboard();
```

#### Print

```dart
// Opens print-ready document in new tab
DocumentService.printHtml(htmlContent);
```

#### Local Storage

```dart
// Save draft
DocumentService.saveToLocalStorage('my-draft', htmlContent);

// Load draft
final draft = DocumentService.loadFromLocalStorage('my-draft');

// Check if exists
if (DocumentService.hasLocalStorage('my-draft')) {
  // ...
}

// Remove
DocumentService.removeFromLocalStorage('my-draft');
```

---

## 🔧 Utilities

### HtmlCleaner

Process HTML for export.

```dart
// Clean editor artifacts (selection classes, data attributes)
final clean = HtmlCleaner.cleanForExport(dirtyHtml);

// Extract plain text from HTML
final text = HtmlCleaner.extractText(html);

// Check if content is empty
if (HtmlCleaner.isEmpty(html)) {
  print('No content');
}

// Normalize color to hex
final hex = HtmlCleaner.normalizeColor('rgb(255, 0, 0)');  // '#ff0000'
```

### TextStats

Calculate document statistics.

```dart
final stats = TextStats.fromHtml(html);

print('Words: ${stats.wordCount}');
print('Characters: ${stats.charCount}');
print('Characters (no spaces): ${stats.charCountNoSpaces}');
print('Paragraphs: ${stats.paragraphCount}');
print('Sentences: ${stats.sentenceCount}');
```

### ExportStyles

Generate CSS for exported HTML.

```dart
// Get full CSS string
final css = ExportStyles.fullCss;

// Generate complete HTML document
final fullHtml = ExportStyles.generateHtmlDocument(
  content,
  title: 'My Document',  // Optional
);
```

---

## 🎨 Theming

### Using Built-in Theme

```dart
MaterialApp(
  theme: AppTheme.lightTheme,
  home: MyApp(),
)
```

### Color Palette

```dart
AppColors.accent        // Primary accent color (#C45D35)
AppColors.surface       // Card/surface color (white)
AppColors.background    // Scaffold background
AppColors.textPrimary   // Primary text color
AppColors.textSecondary // Secondary text color
AppColors.border        // Border color
AppColors.success       // Success state color
AppColors.warning       // Warning state color
AppColors.error         // Error state color
```

### Text Styles

```dart
AppTheme.serifTextStyle  // Crimson Pro, 18px
AppTheme.sansTextStyle   // DM Sans, 14px
AppTheme.monoTextStyle   // Source Code Pro, 14px
```

### Decorations

```dart
Container(
  decoration: AppTheme.editorContainerDecoration,
  child: QuillEditorWidget(...),
)

Container(
  decoration: AppTheme.cardDecoration,
  child: YourContent(),
)
```

---

## ⚙️ Configuration

### EditorConfig

```dart
// Zoom settings
EditorConfig.minZoom         // 0.5 (50%)
EditorConfig.maxZoom         // 3.0 (300%)
EditorConfig.defaultZoom     // 1.0 (100%)
EditorConfig.zoomStep        // 0.1 (10%)

// Table defaults
EditorConfig.defaultTableRows  // 3
EditorConfig.defaultTableCols  // 3
EditorConfig.maxTableRows      // 20
EditorConfig.maxTableCols      // 10

// Timing
EditorConfig.contentChangeThrottleMs  // 200ms
EditorConfig.autoSaveDebounceMs       // 500ms
```

### AppFonts

```dart
// Available fonts
AppFonts.availableFonts  // List<FontConfig>

// Available sizes
AppFonts.availableSizes  // [small, normal, large, huge]

// Available line heights
AppFonts.availableLineHeights  // [1.0, 1.5, 2.0, 2.5, 3.0]
```

---

## 📁 Project Structure

```
lib/
├── quill_web_editor.dart              # Main export file
└── src/
    ├── core/
    │   ├── constants/
    │   │   ├── app_colors.dart        # Color palette
    │   │   ├── app_fonts.dart         # Font configurations
    │   │   └── editor_config.dart     # Editor settings
    │   ├── theme/
    │   │   └── app_theme.dart         # Theme data
    │   └── utils/
    │       ├── html_cleaner.dart      # HTML processing
    │       ├── text_stats.dart        # Document statistics
    │       └── export_styles.dart     # Export CSS generation
    ├── widgets/
    │   ├── quill_editor_widget.dart   # Main editor widget
    │   ├── save_status_indicator.dart # Save status display
    │   ├── zoom_controls.dart         # Zoom UI
    │   ├── output_preview.dart        # HTML/text preview
    │   ├── stat_card.dart             # Statistics cards
    │   ├── app_card.dart              # Styled container
    │   ├── html_preview_dialog.dart   # Preview dialog
    │   └── insert_html_dialog.dart    # HTML insertion dialog
    └── services/
        └── document_service.dart      # Document operations

web/
├── quill_editor.html                  # Editor HTML (full-featured)
└── quill_viewer.html                  # Viewer HTML (read-only)
```

---

## 🧪 Testing

The package includes comprehensive tests. Run them with:

```bash
flutter test
```

### Testing with Google Fonts

The package uses Google Fonts which require special setup for testing. Font files are bundled in `test/fonts/` and configured in `flutter_test_config.dart`.

---

## 💡 Examples

### Complete Editor with Sidebar

```dart
class EditorPage extends StatefulWidget {
  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  final _editorKey = GlobalKey<QuillEditorWidgetState>();
  String _html = '';
  double _zoom = 1.0;
  SaveStatus _status = SaveStatus.saved;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editor'),
        actions: [
          ZoomControls(
            zoomLevel: _zoom,
            onZoomIn: () {
              _editorKey.currentState?.zoomIn();
              setState(() => _zoom += 0.1);
            },
            onZoomOut: () {
              _editorKey.currentState?.zoomOut();
              setState(() => _zoom -= 0.1);
            },
            onReset: () {
              _editorKey.currentState?.resetZoom();
              setState(() => _zoom = 1.0);
            },
          ),
          SaveStatusIndicator(status: _status),
          FilledButton.icon(
            onPressed: () => DocumentService.downloadHtml(_html),
            icon: Icon(Icons.save),
            label: Text('Save'),
          ),
        ],
      ),
      body: Row(
        children: [
          // Editor
          Expanded(
            child: Container(
              margin: EdgeInsets.all(24),
              decoration: AppTheme.editorContainerDecoration,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: QuillEditorWidget(
                  key: _editorKey,
                  onContentChanged: (html, delta) {
                    setState(() {
                      _html = html;
                      _status = SaveStatus.unsaved;
                    });
                  },
                ),
              ),
            ),
          ),
          // Sidebar
          SizedBox(
            width: 320,
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  AppCard(
                    title: 'Statistics',
                    child: StatCardRow(
                      stats: [
                        (
                          label: 'Words',
                          value: TextStats.fromHtml(_html).wordCount.toString(),
                          icon: null,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: AppCard(
                      title: 'Preview',
                      child: OutputPreview(html: _html),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

### Auto-Save Implementation

```dart
Timer? _saveTimer;

void _onContentChanged(String html, dynamic delta) {
  setState(() => _status = SaveStatus.unsaved);
  
  _saveTimer?.cancel();
  _saveTimer = Timer(Duration(milliseconds: 500), () {
    setState(() => _status = SaveStatus.saving);
    
    // Save to backend or local storage
    DocumentService.saveToLocalStorage('draft', html);
    
    setState(() => _status = SaveStatus.saved);
  });
}
```

---

## 🔗 Running the Example

```bash
cd example
flutter run -d chrome
```

---

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

---

## 🤝 Contributing

Contributions are welcome! Please read our contributing guidelines before submitting PRs.

---

<p align="center">
  Made with ❤️ using Flutter & Quill.js
</p>
