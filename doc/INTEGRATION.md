# Quill Web Editor - Integration Guide

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Installation](#installation)
3. [Web Assets Setup](#web-assets-setup)
4. [Basic Usage](#basic-usage)
5. [Advanced Usage](#advanced-usage)
6. [Configuration Options](#configuration-options)
7. [Theming & Customization](#theming--customization)
8. [Common Integration Patterns](#common-integration-patterns)
9. [API Reference](#api-reference)
10. [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before integrating the Quill Web Editor package, ensure your project meets the following requirements:

### System Requirements
| Requirement | Version |
|-------------|---------|
| Flutter SDK | 3.x or later |
| Dart SDK | ^3.5.0 |
| Platform | Web only |
| Browser | Chrome, Firefox, Safari, Edge (modern versions) |

### Project Requirements
- Flutter Web project (`flutter create --platforms web my_app`)
- `web/` directory with `index.html`

---

## Installation

### Step 1: Add Dependency

Add the package to your `pubspec.yaml`:

**Option A: Git Dependency**
```yaml
dependencies:
  quill_web_editor:
    git:
      url: https://github.com/icici/quill_web_editor.git
      ref: main  # or specific tag/commit
```

**Option B: Path Dependency (for local development)**
```yaml
dependencies:
  quill_web_editor:
    path: ../quill_web_editor
```

**Option C: Published Package (when available)**
```yaml
dependencies:
  quill_web_editor: ^1.0.0
```

### Step 2: Install Dependencies

```bash
flutter pub get
```

### Step 3: Verify Installation

```dart
import 'package:quill_web_editor/quill_web_editor.dart';

void main() {
  // If this compiles without errors, installation is successful
  print('QuillEditorWidget available: ${QuillEditorWidget}');
}
```

---

## Web Assets Setup

The Quill Web Editor requires HTML and JavaScript assets to be copied to your project's `web/` directory.

### Required Files

Copy the following from the package to your `web/` directory:

```
your_project/
└── web/
    ├── index.html            # Your existing file
    ├── quill_editor.html     # ← Copy from package
    ├── quill_viewer.html     # ← Copy from package
    ├── js/                   # ← Copy entire folder
    │   ├── clipboard.js
    │   ├── commands.js
    │   ├── config.js
    │   ├── drag-drop.js
    │   ├── flutter-bridge.js
    │   ├── media-resize.js
    │   ├── quill-setup.js
    │   ├── table-resize.js
    │   ├── utils.js
    │   └── viewer.js
    └── styles/               # ← Copy entire folder
        ├── base.css
        ├── fonts.css
        ├── media.css
        ├── quill-theme.css
        ├── sizes.css
        ├── tables.css
        └── viewer.css
```

### Copy Commands

```bash
# From your project root
cp -r path/to/quill_web_editor/web/quill_editor.html web/
cp -r path/to/quill_web_editor/web/quill_viewer.html web/
cp -r path/to/quill_web_editor/web/js web/
cp -r path/to/quill_web_editor/web/styles web/
```

### Verify Setup

After copying, your `web/` directory should look like:

```bash
ls -la web/
# Output should include:
# quill_editor.html
# quill_viewer.html
# js/
# styles/
```

---

## Basic Usage

### Minimal Example

```dart
import 'package:flutter/material.dart';
import 'package:quill_web_editor/quill_web_editor.dart';

class BasicEditorPage extends StatefulWidget {
  const BasicEditorPage({super.key});

  @override
  State<BasicEditorPage> createState() => _BasicEditorPageState();
}

class _BasicEditorPageState extends State<BasicEditorPage> {
  final GlobalKey<QuillEditorWidgetState> _editorKey = GlobalKey();
  String _html = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editor')),
      body: QuillEditorWidget(
        key: _editorKey,
        onContentChanged: (html, delta) {
          setState(() => _html = html);
        },
      ),
    );
  }
}
```

### With Initial Content

```dart
QuillEditorWidget(
  key: _editorKey,
  initialHtml: '''
    <h1>Welcome</h1>
    <p>This is the <strong>initial content</strong> of the editor.</p>
  ''',
  onContentChanged: (html, delta) {
    print('Content changed: $html');
  },
)
```

### Read-Only Viewer

```dart
QuillEditorWidget(
  readOnly: true,
  initialHtml: '<p>This content cannot be edited.</p>',
)
```

---

## Advanced Usage

### Complete Editor with All Features

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quill_web_editor/quill_web_editor.dart';

class FullEditorPage extends StatefulWidget {
  const FullEditorPage({super.key});

  @override
  State<FullEditorPage> createState() => _FullEditorPageState();
}

class _FullEditorPageState extends State<FullEditorPage> {
  final GlobalKey<QuillEditorWidgetState> _editorKey = GlobalKey();
  
  String _currentHtml = '';
  double _zoomLevel = 1.0;
  SaveStatus _saveStatus = SaveStatus.saved;
  Timer? _saveTimer;

  @override
  void dispose() {
    _saveTimer?.cancel();
    super.dispose();
  }

  void _onContentChanged(String html, dynamic delta) {
    setState(() {
      _currentHtml = html;
      _saveStatus = SaveStatus.unsaved;
    });

    // Auto-save simulation with debounce
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 500), () {
      _saveDocument();
    });
  }

  Future<void> _saveDocument() async {
    setState(() => _saveStatus = SaveStatus.saving);
    
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Save to local storage
    DocumentService.saveToLocalStorage('draft', _currentHtml);
    
    if (mounted) {
      setState(() => _saveStatus = SaveStatus.saved);
    }
  }

  void _downloadDocument() {
    if (_currentHtml.isEmpty) return;
    DocumentService.downloadHtml(
      _currentHtml,
      filename: 'document.html',
      cleanHtml: true,
    );
  }

  void _showPreview() {
    if (_currentHtml.isEmpty) return;
    HtmlPreviewDialog.show(context, _currentHtml);
  }

  @override
  Widget build(BuildContext context) {
    final stats = TextStats.fromHtml(_currentHtml);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Editor'),
        actions: [
          // Undo/Redo
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: () => _editorKey.currentState?.undo(),
            tooltip: 'Undo',
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            onPressed: () => _editorKey.currentState?.redo(),
            tooltip: 'Redo',
          ),
          
          const SizedBox(width: 16),
          
          // Zoom Controls
          ZoomControls(
            zoomLevel: _zoomLevel,
            onZoomIn: () {
              _editorKey.currentState?.zoomIn();
              setState(() => _zoomLevel = (_zoomLevel + 0.1).clamp(0.5, 3.0));
            },
            onZoomOut: () {
              _editorKey.currentState?.zoomOut();
              setState(() => _zoomLevel = (_zoomLevel - 0.1).clamp(0.5, 3.0));
            },
            onReset: () {
              _editorKey.currentState?.resetZoom();
              setState(() => _zoomLevel = 1.0);
            },
          ),
          
          const SizedBox(width: 16),
          
          // Preview
          TextButton.icon(
            icon: const Icon(Icons.preview),
            label: const Text('Preview'),
            onPressed: _showPreview,
          ),
          
          // Save Status
          SaveStatusIndicator(status: _saveStatus),
          
          const SizedBox(width: 8),
          
          // Download
          FilledButton.icon(
            icon: const Icon(Icons.download),
            label: const Text('Download'),
            onPressed: _downloadDocument,
          ),
          
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          // Main Editor
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(24),
              decoration: AppTheme.editorContainerDecoration,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: QuillEditorWidget(
                  key: _editorKey,
                  onContentChanged: _onContentChanged,
                  onReady: () => print('Editor ready!'),
                ),
              ),
            ),
          ),
          
          // Sidebar
          SizedBox(
            width: 280,
            child: Padding(
              padding: const EdgeInsets.only(top: 24, right: 24, bottom: 24),
              child: Column(
                children: [
                  // Statistics
                  AppCard(
                    title: 'Statistics',
                    child: StatCardRow(
                      stats: [
                        (label: 'Words', value: stats.wordCount.toString(), icon: null),
                        (label: 'Chars', value: stats.charCount.toString(), icon: null),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Output Preview
                  Expanded(
                    child: AppCard(
                      title: 'Preview',
                      child: OutputPreview(html: _currentHtml),
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

### Programmatic Control

```dart
// Get reference to editor state
final editorState = _editorKey.currentState;

// Set content
editorState?.setHTML('<h1>New Content</h1><p>Hello World</p>');

// Insert at cursor
editorState?.insertText('Inserted text');
editorState?.insertHtml('<strong>Bold text</strong>');

// Format selection
editorState?.format('bold', true);
editorState?.format('color', '#ff0000');
editorState?.format('font', 'montserrat');

// Insert table
editorState?.insertTable(3, 4); // 3 rows, 4 columns

// Undo/Redo
editorState?.undo();
editorState?.redo();

// Zoom
editorState?.zoomIn();
editorState?.zoomOut();
editorState?.setZoom(1.5); // 150%
editorState?.resetZoom();

// Clear
editorState?.clear();

// Focus
editorState?.focus();
```

---

## Configuration Options

### EditorConfig Constants

The package provides sensible defaults through `EditorConfig`:

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

// Paths
EditorConfig.editorHtmlPath  // 'quill_editor.html'
EditorConfig.viewerHtmlPath  // 'quill_viewer.html'
```

### Custom HTML Paths

If you need a customized editor:

```dart
QuillEditorWidget(
  editorHtmlPath: 'custom_editor.html',  // Custom editor
  viewerHtmlPath: 'custom_viewer.html',  // Custom viewer
  onContentChanged: (html, delta) => print(html),
)
```

### Available Fonts

```dart
// AppFonts.availableFonts includes:
// - Roboto
// - Open Sans
// - Lato
// - Montserrat
// - Crimson Pro (serif)
// - DM Sans
// - Source Code Pro (monospace)
```

### Available Sizes

```dart
// small, normal (default), large, huge
```

---

## Theming & Customization

### Using Built-in Theme

```dart
MaterialApp(
  theme: AppTheme.lightTheme,
  home: const MyApp(),
)
```

### Color Palette

```dart
// Primary accent
AppColors.accent        // #C45D35 (Rust orange)
AppColors.accentHover   // #A84D2B
AppColors.accentLight   // 10% opacity accent

// Text
AppColors.textPrimary   // #2C2825
AppColors.textSecondary // #6B6560
AppColors.textMuted     // #9A948E

// Backgrounds
AppColors.background    // #F8F6F3
AppColors.surface       // #FFFFFF

// Status
AppColors.success       // #22C55E
AppColors.warning       // #E57C23
AppColors.error         // #EF4444
```

### Text Styles

```dart
AppTheme.serifTextStyle  // Crimson Pro, 18px
AppTheme.sansTextStyle   // DM Sans, 14px
AppTheme.monoTextStyle   // Source Code Pro, 14px
```

### Container Decorations

```dart
// For the editor container
Container(
  decoration: AppTheme.editorContainerDecoration,
  child: ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: QuillEditorWidget(...),
  ),
)

// For cards
Container(
  decoration: AppTheme.cardDecoration,
  child: YourContent(),
)
```

### Custom CSS

Modify files in `web/styles/` for CSS customization:

- `base.css` - Global resets and layout
- `quill-theme.css` - Quill toolbar and editor styling
- `fonts.css` - Font family classes
- `sizes.css` - Font size classes
- `tables.css` - Table styling
- `media.css` - Image/video/iframe styling
- `viewer.css` - Read-only mode styling

---

## Common Integration Patterns

### Pattern 1: Form Integration

```dart
class DocumentFormPage extends StatefulWidget {
  @override
  State<DocumentFormPage> createState() => _DocumentFormPageState();
}

class _DocumentFormPageState extends State<DocumentFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _editorKey = GlobalKey<QuillEditorWidgetState>();
  final _titleController = TextEditingController();
  
  String _documentContent = '';

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      await saveDocument(
        title: _titleController.text,
        content: _documentContent,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
          ),
          Expanded(
            child: QuillEditorWidget(
              key: _editorKey,
              onContentChanged: (html, _) => _documentContent = html,
            ),
          ),
          ElevatedButton(
            onPressed: _saveForm,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
```

### Pattern 2: Draft Auto-Save

```dart
class AutoSaveEditor extends StatefulWidget {
  final String documentId;
  const AutoSaveEditor({required this.documentId, super.key});

  @override
  State<AutoSaveEditor> createState() => _AutoSaveEditorState();
}

class _AutoSaveEditorState extends State<AutoSaveEditor> {
  final _editorKey = GlobalKey<QuillEditorWidgetState>();
  Timer? _autoSaveTimer;
  
  String get _draftKey => 'draft_${widget.documentId}';

  @override
  void initState() {
    super.initState();
    _loadDraft();
  }

  void _loadDraft() {
    final draft = DocumentService.loadFromLocalStorage(_draftKey);
    if (draft != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _editorKey.currentState?.setHTML(draft);
      });
    }
  }

  void _onContentChanged(String html, dynamic delta) {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 2), () {
      DocumentService.saveToLocalStorage(_draftKey, html);
    });
  }

  void _clearDraft() {
    DocumentService.removeFromLocalStorage(_draftKey);
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return QuillEditorWidget(
      key: _editorKey,
      onContentChanged: _onContentChanged,
    );
  }
}
```

### Pattern 3: Conditional Read-Only

```dart
class ReviewableDocument extends StatefulWidget {
  final bool isReviewer;
  final String content;
  
  const ReviewableDocument({
    required this.isReviewer,
    required this.content,
    super.key,
  });

  @override
  State<ReviewableDocument> createState() => _ReviewableDocumentState();
}

class _ReviewableDocumentState extends State<ReviewableDocument> {
  @override
  Widget build(BuildContext context) {
    return QuillEditorWidget(
      readOnly: widget.isReviewer,  // Reviewers can only view
      initialHtml: widget.content,
      onContentChanged: widget.isReviewer 
        ? null  // No callback for read-only
        : (html, _) => print('Updated: $html'),
    );
  }
}
```

### Pattern 4: Print & Export

```dart
class ExportableEditor extends StatefulWidget {
  @override
  State<ExportableEditor> createState() => _ExportableEditorState();
}

class _ExportableEditorState extends State<ExportableEditor> {
  final _editorKey = GlobalKey<QuillEditorWidgetState>();
  String _html = '';

  void _exportAsHtml() {
    if (_html.isEmpty) return;
    DocumentService.downloadHtml(_html, filename: 'document.html');
  }

  void _exportAsText() {
    if (_html.isEmpty) return;
    final text = HtmlCleaner.extractText(_html);
    DocumentService.downloadText(text, filename: 'document.txt');
  }

  void _print() {
    if (_html.isEmpty) return;
    DocumentService.printHtml(_html);
  }

  void _copyHtml() async {
    final clean = HtmlCleaner.cleanForExport(_html);
    final success = await DocumentService.copyToClipboard(clean);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('HTML copied to clipboard')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: QuillEditorWidget(
            key: _editorKey,
            onContentChanged: (html, _) => setState(() => _html = html),
          ),
        ),
        Row(
          children: [
            TextButton.icon(
              icon: const Icon(Icons.download),
              label: const Text('HTML'),
              onPressed: _exportAsHtml,
            ),
            TextButton.icon(
              icon: const Icon(Icons.text_snippet),
              label: const Text('Text'),
              onPressed: _exportAsText,
            ),
            TextButton.icon(
              icon: const Icon(Icons.print),
              label: const Text('Print'),
              onPressed: _print,
            ),
            TextButton.icon(
              icon: const Icon(Icons.copy),
              label: const Text('Copy'),
              onPressed: _copyHtml,
            ),
          ],
        ),
      ],
    );
  }
}
```

---

## API Reference

### QuillEditorWidget

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `key` | `GlobalKey<QuillEditorWidgetState>?` | - | Key for programmatic access |
| `width` | `double?` | `null` | Fixed width (fills parent if null) |
| `height` | `double?` | `null` | Fixed height (fills parent if null) |
| `readOnly` | `bool` | `false` | Enable read-only mode |
| `initialHtml` | `String?` | `null` | Initial HTML content |
| `initialDelta` | `dynamic` | `null` | Initial Delta content |
| `placeholder` | `String?` | `null` | Placeholder text |
| `editorHtmlPath` | `String?` | `'quill_editor.html'` | Custom editor HTML |
| `viewerHtmlPath` | `String?` | `'quill_viewer.html'` | Custom viewer HTML |
| `onContentChanged` | `Function(String, dynamic)?` | `null` | Content change callback |
| `onReady` | `VoidCallback?` | `null` | Editor ready callback |

### QuillEditorWidgetState Methods

| Method | Parameters | Description |
|--------|------------|-------------|
| `setHTML` | `(String html, {bool replace = true})` | Set HTML content |
| `insertHtml` | `(String html, {bool replace = false})` | Insert HTML at cursor |
| `setContents` | `(dynamic delta)` | Set Quill Delta content |
| `insertText` | `(String text)` | Insert text at cursor |
| `getContents` | `()` | Request current content |
| `clear` | `()` | Clear all content |
| `focus` | `()` | Focus the editor |
| `undo` | `()` | Undo last operation |
| `redo` | `()` | Redo last operation |
| `format` | `(String format, dynamic value)` | Apply formatting |
| `insertTable` | `(int rows, int cols)` | Insert table |
| `zoomIn` | `()` | Increase zoom by 10% |
| `zoomOut` | `()` | Decrease zoom by 10% |
| `resetZoom` | `()` | Reset to 100% |
| `setZoom` | `(double level)` | Set specific zoom level |

### DocumentService Methods

| Method | Parameters | Description |
|--------|------------|-------------|
| `downloadHtml` | `(String, {String filename, bool cleanHtml})` | Download as HTML file |
| `downloadText` | `(String, {String filename})` | Download as text file |
| `copyToClipboard` | `(String)` | Copy to clipboard |
| `readFromClipboard` | `()` | Read from clipboard |
| `printHtml` | `(String)` | Open print dialog |
| `saveToLocalStorage` | `(String key, String content)` | Save to localStorage |
| `loadFromLocalStorage` | `(String key)` | Load from localStorage |
| `removeFromLocalStorage` | `(String key)` | Remove from localStorage |
| `hasLocalStorage` | `(String key)` | Check if key exists |

### HtmlCleaner Methods

| Method | Parameters | Description |
|--------|------------|-------------|
| `cleanForExport` | `(String html)` | Remove editor artifacts |
| `extractText` | `(String html)` | Extract plain text |
| `isEmpty` | `(String html)` | Check if effectively empty |
| `normalizeColor` | `(String? color)` | Convert to hex format |

### TextStats

```dart
final stats = TextStats.fromHtml(html);

stats.wordCount        // Number of words
stats.charCount        // Total characters
stats.charCountNoSpaces // Characters without spaces
stats.paragraphCount   // Number of paragraphs
stats.sentenceCount    // Number of sentences
```

---

## Troubleshooting

### Issue: Editor Not Loading

**Symptoms:** Blank white area where editor should be

**Solutions:**
1. Verify HTML files are in `web/` directory:
   ```bash
   ls web/quill_editor.html web/quill_viewer.html
   ```
2. Check browser console for 404 errors
3. Ensure `js/` and `styles/` directories are copied
4. Verify file paths match exactly (case-sensitive)

### Issue: Commands Not Working

**Symptoms:** `setHTML()`, `undo()`, etc. have no effect

**Solutions:**
1. Wait for `onReady` callback before sending commands:
   ```dart
   QuillEditorWidget(
     onReady: () {
       _editorKey.currentState?.setHTML('<p>Now ready!</p>');
     },
   )
   ```
2. Check `isReady` property before commands:
   ```dart
   if (_editorKey.currentState?.isReady ?? false) {
     _editorKey.currentState?.setHTML(html);
   }
   ```

### Issue: Content Not Persisting

**Symptoms:** Content disappears on hot reload

**Solutions:**
1. Save content in parent widget state
2. Use auto-save pattern with localStorage:
   ```dart
   DocumentService.saveToLocalStorage('key', html);
   ```
3. Restore on init:
   ```dart
   @override
   void initState() {
     super.initState();
     _initialContent = DocumentService.loadFromLocalStorage('key');
   }
   ```

### Issue: Styling Not Applied

**Symptoms:** Editor looks unstyled or broken

**Solutions:**
1. Verify `styles/` directory is present
2. Check CSS files are not 404
3. Ensure Quill.js CDN is accessible
4. Check browser CSP (Content Security Policy) settings

### Issue: Tables Not Working

**Symptoms:** "Insert Table" button missing or non-functional

**Solutions:**
1. Verify quill-table-better CSS/JS loaded (check Network tab)
2. Check for JavaScript errors in console
3. Ensure `js/quill-setup.js` includes table registration

### Issue: Fonts Not Rendering

**Symptoms:** Fonts fall back to system defaults

**Solutions:**
1. Verify Google Fonts CDN is accessible
2. Check `styles/fonts.css` is loaded
3. Ensure font names match in `config.js` and CSS

### Issue: PointerInterceptor Needed

**Symptoms:** Clicks on overlays (dialogs) don't register

**Solutions:**
```dart
import 'package:pointer_interceptor/pointer_interceptor.dart';

showDialog(
  context: context,
  builder: (context) => PointerInterceptor(
    child: AlertDialog(
      title: const Text('Title'),
      content: const Text('Content'),
    ),
  ),
);
```

### Issue: Cross-Origin Errors

**Symptoms:** PostMessage errors in console

**Solutions:**
1. Ensure all resources are from same origin or valid CDNs
2. Check CORS settings if using custom CDN
3. Verify iframe src is correct relative path

### Debugging Tips

1. **Enable verbose logging:**
   ```javascript
   // In js/flutter-bridge.js
   console.log('Sending to Flutter:', data);
   ```

2. **Check editor state:**
   ```dart
   print('Ready: ${_editorKey.currentState?.isReady}');
   print('Zoom: ${_editorKey.currentState?.currentZoom}');
   ```

3. **Inspect iframe content:**
   - Use browser DevTools
   - Select iframe in Elements panel
   - Switch to iframe context in Console

---

## Running the Example

The package includes a complete example application:

```bash
cd example
flutter run -d chrome
```

The example demonstrates:
- Full editor with toolbar
- Zoom controls
- Save status indicator
- Statistics sidebar
- HTML preview
- Content export

---

## Support

For issues, questions, or feature requests:
- GitHub Issues: [https://github.com/icici/quill_web_editor/issues](https://github.com/icici/quill_web_editor/issues)
- Documentation: See `README.md` and `ARCHITECTURE.md`

---

*Document Version: 1.0.0*
*Last Updated: December 2024*

