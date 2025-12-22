# Quill Web Editor - Developer Guide

> A comprehensive developer documentation for the Quill Web Editor Flutter package

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Installation & Setup](#2-installation--setup)
3. [Quick Start Guide](#3-quick-start-guide)
4. [Architecture Overview](#4-architecture-overview)
5. [Toolbar Features Reference](#5-toolbar-features-reference)
6. [API Reference](#6-api-reference)
7. [Extending & Customizing the Editor](#7-extending--customizing-the-editor)
8. [Troubleshooting & FAQ](#8-troubleshooting--faq)
9. [Best Practices](#9-best-practices)

---

## Quick Reference

### 🚀 Getting Started

| Task | Section | Quick Link |
|------|---------|------------|
| Install package | [Installation & Setup](#2-installation--setup) | [Step 1: Add Dependency](#step-1-add-dependency) |
| Copy web assets | [Installation & Setup](#2-installation--setup) | [Step 2: Copy Web Assets](#step-2-copy-web-assets) |
| Basic usage | [Quick Start Guide](#3-quick-start-guide) | [Minimal Example](#minimal-example) |
| Read-only mode | [Quick Start Guide](#3-quick-start-guide) | [Read-Only Viewer Mode](#read-only-viewer-mode) |

### 📝 Common Features

| Feature | Section | Details |
|---------|---------|--------|
| **Lists** | [5.6 Lists](#56-lists) | Bullet, Ordered, Checklist with nesting |
| **Tables** | [5.14 Tables](#514-tables) | Insert, resize, merge, header rows |
| **Text Formatting** | [5.4 Text Formatting](#54-text-formatting) | Bold, Italic, Underline, Strikethrough |
| **Fonts** | [5.2 Font Family](#52-font-family) | 7 custom fonts from Google Fonts |
| **Colors** | [5.5 Colors](#55-colors) | Text color and background color |
| **Media** | [5.12 Media: Images](#512-media-images) | Images, videos with resize controls |

### 🔧 Programmatic Control

| Action | Method | Example |
|--------|--------|--------|
| Insert text | `insertText(String)` | `_editorKey.currentState?.insertText('Hello')` |
| Set HTML | `setHTML(String)` | `_editorKey.currentState?.setHTML('<h1>Title</h1>')` |
| Format text | `format(String, dynamic)` | `_editorKey.currentState?.format('bold', true)` |
| Insert table | `insertTable(int, int)` | `_editorKey.currentState?.insertTable(3, 3)` |
| Undo/Redo | `undo()` / `redo()` | `_editorKey.currentState?.undo()` |
| Zoom | `zoomIn()` / `zoomOut()` | `_editorKey.currentState?.zoomIn()` |

### 🛠️ Customization

| Task | Section | File Location |
|------|---------|---------------|
| Add new font | [7.1 Adding a New Font](#71-adding-a-new-font) | `web/js/config.js`, `web/styles/fonts.css` |
| Add toolbar button | [7.2 Adding a New Toolbar Button](#72-adding-a-new-toolbar-button) | `web/js/config.js`, `web/js/quill-setup.js` |
| Add command | [7.3 Adding a New Command](#73-adding-a-new-command) | `web/js/commands.js`, `lib/src/widgets/quill_editor_widget.dart` |
| Modify feature | [7.7 Modifying Existing Features](#77-modifying-existing-features) | Various JS and CSS files |

### 📚 Key Files Reference

| File | Purpose | Location |
|------|---------|----------|
| `quill_editor.html` | Editor HTML container | `web/quill_editor.html` |
| `config.js` | Toolbar and editor configuration | `web/js/config.js` |
| `commands.js` | Command handlers (Flutter → JS) | `web/js/commands.js` |
| `quill-setup.js` | Quill initialization | `web/js/quill-setup.js` |
| `quill_editor_widget.dart` | Main Flutter widget | `lib/src/widgets/quill_editor_widget.dart` |
| `editor_config.dart` | Editor constants | `lib/src/core/constants/editor_config.dart` |

### ⚡ Quick Code Snippets

**Basic Editor Setup**:
```dart
QuillEditorWidget(
  key: _editorKey,
  onContentChanged: (html, delta) => setState(() => _currentHtml = html),
  initialHtml: '<p>Start typing...</p>',
)
```

**Format Text**:
```dart
_editorKey.currentState?.format('bold', true);
_editorKey.currentState?.format('color', '#ff0000');
_editorKey.currentState?.format('list', 'bullet');
```

**Insert Content**:
```dart
_editorKey.currentState?.insertText('Hello World');
_editorKey.currentState?.insertTable(3, 3);
_editorKey.currentState?.insertHtml('<h1>Title</h1>');
```

---

## 1. Introduction

### What is Quill Web Editor?

**Quill Web Editor** is a Flutter Web package that provides a full-featured rich text editing experience. It integrates the popular [Quill.js](https://quilljs.com/) (v2.0.0) editor with Flutter through an iframe-based architecture, enabling seamless bidirectional communication between Dart and JavaScript.

### Key Features

| Category | Features |
|----------|----------|
| **Text Formatting** | Bold, Italic, Underline, Strikethrough, Subscript, Superscript |
| **Structure** | Headers (H1-H6), Paragraphs, Blockquotes, Code Blocks |
| **Lists** | Ordered Lists, Bullet Lists, Checklists |
| **Typography** | 7+ Custom Fonts, 4 Font Sizes, Text Colors, Background Colors |
| **Media** | Images, Videos, Iframes with Resize Controls |
| **Tables** | Full table support via quill-table-better with resize and header options |
| **Alignment** | Left, Center, Right, Justify + RTL Support |
| **Export** | Clean HTML Export, Print Support, Local Storage |
| **UX** | Zoom Controls (50%-300%), Undo/Redo, Smart Paste |

### Platform Support

| Platform | Supported |
|----------|-----------|
| Flutter Web | ✅ Yes |
| Flutter Mobile (iOS/Android) | ❌ No (Web only) |
| Flutter Desktop | ❌ No (Web only) |

---

## 2. Installation & Setup

### Prerequisites

Before installing the Quill Web Editor package, ensure you have:

- **Flutter SDK**: ^3.5.0 or higher
- **Dart SDK**: ^3.5.0 or higher
- **Target Platform**: Web only (Chrome, Firefox, Safari, Edge)
- **Development Environment**: VS Code, Android Studio, or your preferred IDE

**Verify Flutter Installation**:
```bash
flutter --version
flutter doctor -v
```

Ensure Flutter Web is enabled:
```bash
flutter config --enable-web
```

### Step 1: Add Dependency

#### Option A: Git Dependency (Recommended for Development)

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  quill_web_editor:
    git:
      url: https://github.com/ff-vivek/flutter_quill_web_editor.git
      ref: main  # Use 'main' for latest, or specific tag/commit for stability
```

#### Option B: Pub.dev (When Published)

```yaml
dependencies:
  quill_web_editor: ^1.0.0
```

#### Install Dependencies

After adding the dependency, run:

```bash
flutter pub get
```

**Verification**: Check that the package is installed:
```bash
flutter pub deps | grep quill_web_editor
```

### Step 2: Copy Web Assets

The package requires HTML, JavaScript, and CSS files to be placed in your app's `web/` directory. These files enable the Quill.js editor to function within the Flutter Web app.

#### Manual Copy Method

Copy these files from the package's `web/` directory to your app's `web/` directory:

```
your_app/
└── web/
    ├── index.html          # Your existing Flutter app entry point
    ├── quill_editor.html   ← Copy from package/web/quill_editor.html
    ├── quill_viewer.html   ← Copy from package/web/quill_viewer.html
    ├── js/                 ← Copy entire folder from package/web/js/
    │   ├── clipboard.js      # Clipboard operations
    │   ├── commands.js        # Command handlers
    │   ├── config.js         # Editor configuration
    │   ├── drag-drop.js      # Drag and drop support
    │   ├── flutter-bridge.js # Flutter-JS communication
    │   ├── media-resize.js   # Media resize controls
    │   ├── quill-setup.js    # Quill initialization
    │   ├── table-resize.js   # Table resize functionality
    │   ├── utils.js          # Utility functions
    │   └── viewer.js         # Viewer mode support
    └── styles/             ← Copy entire folder from package/web/styles/
        ├── base.css          # Base styles
        ├── fonts.css         # Font definitions
        ├── media.css         # Media element styles
        ├── quill-theme.css   # Quill theme customization
        ├── sizes.css         # Size definitions
        └── tables.css        # Table styles
```

#### Automated Copy Method

Use the package's deployment script (if available):

```bash
# From your app directory
bash path/to/quill_web_editor/package_deployment.sh
```

Or create a custom script:

```bash
#!/bin/bash
# copy_assets.sh
PACKAGE_PATH="path/to/quill_web_editor"
cp -r "$PACKAGE_PATH/web/quill_editor.html" ./web/
cp -r "$PACKAGE_PATH/web/quill_viewer.html" ./web/
cp -r "$PACKAGE_PATH/web/js" ./web/
cp -r "$PACKAGE_PATH/web/styles" ./web/
echo "Assets copied successfully!"
```

#### Verify Asset Copy

After copying, verify the structure:

```bash
# Check HTML files exist
ls -la web/quill_editor.html
ls -la web/quill_viewer.html

# Check JS files exist
ls -la web/js/*.js | wc -l  # Should show 10 files

# Check CSS files exist
ls -la web/styles/*.css | wc -l  # Should show 6 files
```

### Step 3: Import the Package

In your Dart files where you want to use the editor:

```dart
import 'package:quill_web_editor/quill_web_editor.dart';
```

**Note**: The package exports all necessary widgets, services, and utilities from this single import.

### Step 4: Configure Your App

#### Basic MaterialApp Setup

```dart
import 'package:flutter/material.dart';
import 'package:quill_web_editor/quill_web_editor.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quill Editor Demo',
      theme: AppTheme.lightTheme, // Use built-in theme
      home: const EditorPage(),
    );
  }
}
```

### Step 5: Run Your App

#### Development Mode

```bash
cd your_app
flutter run -d chrome
```

#### Production Build

```bash
flutter build web --release
```

#### Verify Installation

1. **Check Browser Console**: Open DevTools (F12) and check for any errors
2. **Verify Editor Loads**: The editor should appear with a toolbar
3. **Test Basic Functionality**: Try typing and formatting text

**Common Installation Issues**:

| Issue | Solution |
|-------|----------|
| Editor shows blank screen | Verify `quill_editor.html` exists in `web/` directory |
| JavaScript errors in console | Check all JS files are copied to `web/js/` |
| Styles not applied | Verify CSS files are in `web/styles/` |
| CORS errors | Ensure running via `flutter run` or proper web server |
| Editor not responding | Check browser console for postMessage errors |

---

## 3. Quick Start Guide

This section provides practical examples to get you started quickly with the Quill Web Editor.

### Minimal Example

```dart
import 'package:flutter/material.dart';
import 'package:quill_web_editor/quill_web_editor.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme, // Use built-in theme
      home: const EditorPage(),
    );
  }
}

class EditorPage extends StatefulWidget {
  const EditorPage({super.key});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  // Key for accessing editor methods
  final GlobalKey<QuillEditorWidgetState> _editorKey = GlobalKey();
  
  String _currentHtml = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Editor')),
      body: QuillEditorWidget(
        key: _editorKey,
        onContentChanged: (html, delta) {
          setState(() => _currentHtml = html);
          print('Content updated: ${html.length} characters');
        },
        onReady: () {
          print('Editor is ready!');
        },
        initialHtml: '<p>Start typing here...</p>',
      ),
    );
  }
}
```

### Read-Only Viewer Mode

```dart
QuillEditorWidget(
  readOnly: true,
  initialHtml: '<h1>Read-Only Document</h1><p>This content cannot be edited.</p>',
)
```

### Programmatic Control

```dart
class _EditorPageState extends State<EditorPage> {
  final GlobalKey<QuillEditorWidgetState> _editorKey = GlobalKey();

  void _insertText() {
    _editorKey.currentState?.insertText('Hello, World!');
  }

  void _setContent() {
    _editorKey.currentState?.setHTML('<h1>New Content</h1>');
  }

  void _clearContent() {
    _editorKey.currentState?.clear();
  }

  void _undoLastAction() {
    _editorKey.currentState?.undo();
  }

  void _redoLastAction() {
    _editorKey.currentState?.redo();
  }

  void _insertTable() {
    _editorKey.currentState?.insertTable(3, 3); // 3 rows x 3 columns
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: _undoLastAction, icon: Icon(Icons.undo)),
          IconButton(onPressed: _redoLastAction, icon: Icon(Icons.redo)),
          IconButton(onPressed: _insertTable, icon: Icon(Icons.table_chart)),
          IconButton(onPressed: _clearContent, icon: Icon(Icons.delete)),
        ],
      ),
      body: QuillEditorWidget(
        key: _editorKey,
        onContentChanged: (html, delta) => print('Changed'),
      ),
    );
  }
}
```

### Common Use Cases

#### Use Case 1: Document Editor with Auto-Save

```dart
class DocumentEditorPage extends StatefulWidget {
  const DocumentEditorPage({super.key});

  @override
  State<DocumentEditorPage> createState() => _DocumentEditorPageState();
}

class _DocumentEditorPageState extends State<DocumentEditorPage> {
  final GlobalKey<QuillEditorWidgetState> _editorKey = GlobalKey();
  String _currentHtml = '';
  Timer? _saveTimer;
  SaveStatus _saveStatus = SaveStatus.saved;

  void _onContentChanged(String html, dynamic delta) {
    setState(() {
      _currentHtml = html;
      _saveStatus = SaveStatus.unsaved;
    });

    // Debounced auto-save
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 2000), () {
      _saveToBackend(html);
    });
  }

  Future<void> _saveToBackend(String html) async {
    setState(() => _saveStatus = SaveStatus.saving);
    try {
      // Your API call here
      await api.saveDocument(html);
      setState(() => _saveStatus = SaveStatus.saved);
    } catch (e) {
      setState(() => _saveStatus = SaveStatus.unsaved);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    }
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Editor'),
        actions: [
          SaveStatusIndicator(status: _saveStatus),
          const SizedBox(width: 16),
        ],
      ),
      body: QuillEditorWidget(
        key: _editorKey,
        onContentChanged: _onContentChanged,
        initialHtml: '<p>Start writing...</p>',
      ),
    );
  }
}
```

#### Use Case 2: Rich Text Comment Box

```dart
class CommentBox extends StatefulWidget {
  final Function(String html) onSubmit;

  const CommentBox({super.key, required this.onSubmit});

  @override
  State<CommentBox> createState() => _CommentBoxState();
}

class _CommentBoxState extends State<CommentBox> {
  final GlobalKey<QuillEditorWidgetState> _editorKey = GlobalKey();
  String _commentHtml = '';

  void _submitComment() {
    if (_commentHtml.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a comment')),
      );
      return;
    }
    widget.onSubmit(_commentHtml);
    _editorKey.currentState?.clear();
    setState(() => _commentHtml = '');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: QuillEditorWidget(
              key: _editorKey,
              onContentChanged: (html, delta) {
                setState(() => _commentHtml = html);
              },
              placeholder: 'Write your comment...',
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _editorKey.currentState?.clear(),
                  child: const Text('Clear'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _submitComment,
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

#### Use Case 3: Read-Only Document Viewer

```dart
class DocumentViewer extends StatelessWidget {
  final String documentHtml;
  final String title;

  const DocumentViewer({
    super.key,
    required this.documentHtml,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: QuillEditorWidget(
        readOnly: true,  // Viewer mode
        initialHtml: documentHtml,
      ),
    );
  }
}
```

#### Use Case 4: Editor with Statistics

```dart
class EditorWithStats extends StatefulWidget {
  const EditorWithStats({super.key});

  @override
  State<EditorWithStats> createState() => _EditorWithStatsState();
}

class _EditorWithStatsState extends State<EditorWithStats> {
  final GlobalKey<QuillEditorWidgetState> _editorKey = GlobalKey();
  String _currentHtml = '';
  TextStats? _stats;

  void _onContentChanged(String html, dynamic delta) {
    setState(() {
      _currentHtml = html;
      _stats = TextStats.fromHtml(html);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: QuillEditorWidget(
              key: _editorKey,
              onContentChanged: _onContentChanged,
            ),
          ),
          SizedBox(
            width: 300,
            child: AppCard(
              title: 'Statistics',
              child: _stats == null
                  ? const Text('No content yet')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Words: ${_stats!.wordCount}'),
                        Text('Characters: ${_stats!.charCount}'),
                        Text('Paragraphs: ${_stats!.paragraphCount}'),
                        Text('Reading Time: ${_stats!.readingTimeMinutes} min'),
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

---

## 4. Architecture Overview

### System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              FLUTTER APPLICATION                             │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │                           FLUTTER LAYER (Dart)                          │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │ │
│  │  │   Widgets    │  │   Services   │  │   Utilities  │  │  Constants   │ │ │
│  │  │              │  │              │  │              │  │              │ │ │
│  │  │ • QuillEditor│  │ • Document   │  │ • HtmlCleaner│  │ • AppColors  │ │ │
│  │  │   Widget     │  │   Service    │  │ • TextStats  │  │ • AppFonts   │ │ │
│  │  │ • ZoomCtrl   │  │              │  │ • ExportCSS  │  │ • EditorCfg  │ │ │
│  │  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘ │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
│                                      │                                       │
│                                      │ postMessage API                       │
│                                      ▼                                       │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │                      BRIDGE LAYER (HTML/IFrame)                         │ │
│  │  ┌─────────────────┐                 ┌─────────────────┐                │ │
│  │  │ quill_editor.   │       OR        │ quill_viewer.   │                │ │
│  │  │    html         │                 │    html         │                │ │
│  │  │ (Full Editor)   │                 │ (Read-Only)     │                │ │
│  │  └─────────────────┘                 └─────────────────┘                │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
│                                      │                                       │
│                                      │ JavaScript Modules                    │
│                                      ▼                                       │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │                         JAVASCRIPT LAYER                                 │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │ │
│  │  │ quill-setup  │  │  commands    │  │  clipboard   │  │flutter-bridge│ │ │
│  │  │ media-resize │  │ table-resize │  │  drag-drop   │  │   config     │ │ │
│  │  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘ │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
│                                      │                                       │
│                                      ▼                                       │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │                      EXTERNAL DEPENDENCIES (CDN)                         │ │
│  │    Quill.js 2.0.0  │  quill-table-better  │  Google Fonts               │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Communication Flow

#### Flutter → JavaScript (Commands)

```json
{
  "type": "command",
  "source": "flutter",
  "action": "setHTML | insertText | undo | redo | format | insertTable | setZoom",
  "...parameters": "..."
}
```

#### JavaScript → Flutter (Events)

```json
{
  "type": "contentChange | ready | response | zoomChange",
  "source": "quill-editor",
  "html": "...",
  "delta": {...},
  "text": "..."
}
```

### Directory Structure

```
quill_web_editor/
├── lib/
│   ├── quill_web_editor.dart          # Main export file
│   └── src/
│       ├── core/
│       │   ├── constants/
│       │   │   ├── app_colors.dart     # Color palette
│       │   │   ├── app_fonts.dart      # Font configurations
│       │   │   └── editor_config.dart  # Editor settings
│       │   ├── theme/
│       │   │   └── app_theme.dart      # Theme data
│       │   └── utils/
│       │       ├── html_cleaner.dart   # HTML sanitization
│       │       ├── text_stats.dart     # Document statistics
│       │       └── export_styles.dart  # Export CSS generation
│       ├── widgets/
│       │   ├── quill_editor_widget.dart   # Main editor widget
│       │   ├── save_status_indicator.dart # Save status
│       │   ├── zoom_controls.dart         # Zoom UI
│       │   ├── output_preview.dart        # Preview tabs
│       │   ├── stat_card.dart             # Statistics cards
│       │   ├── app_card.dart              # Styled container
│       │   ├── html_preview_dialog.dart   # Preview dialog
│       │   └── insert_html_dialog.dart    # HTML insertion
│       └── services/
│           └── document_service.dart      # Document operations
├── web/
│   ├── quill_editor.html              # Editor HTML container
│   ├── quill_viewer.html              # Viewer HTML container
│   ├── js/                            # JavaScript modules
│   └── styles/                        # CSS stylesheets
└── example/                           # Example application
```

---

## 5. Toolbar Features Reference

### 5.1 Text Structure

#### Headers (H1-H6)

The editor supports six heading levels, from H1 (largest) to H6 (smallest).

| Level | CSS Properties |
|-------|---------------|
| H1 | `font-size: 2.25rem; font-weight: 600` |
| H2 | `font-size: 1.75rem; font-weight: 600` |
| H3 | `font-size: 1.375rem; font-weight: 600` |
| H4 | `font-size: 1.125rem; font-weight: 600` |
| H5 | `font-size: 0.875rem; font-weight: 600` |
| H6 | `font-size: 0.75rem; font-weight: 600` |

**Toolbar Configuration** (`config.js`):
```javascript
[{ 'header': [1, 2, 3, 4, 5, 6, false] }]
```

**Programmatic Usage**:
```dart
_editorKey.currentState?.format('header', 1); // Apply H1
_editorKey.currentState?.format('header', false); // Remove header
```

---

### 5.2 Font Family

Seven custom fonts are available, loaded from Google Fonts CDN.

| Font Name | Quill Value | CSS Class |
|-----------|------------|-----------|
| Sans Serif (Default) | `''` | - |
| Roboto | `roboto` | `.ql-font-roboto` |
| Open Sans | `open-sans` | `.ql-font-open-sans` |
| Lato | `lato` | `.ql-font-lato` |
| Montserrat | `montserrat` | `.ql-font-montserrat` |
| Source Code Pro | `source-code` | `.ql-font-source-code` |
| Crimson Pro | `crimson` | `.ql-font-crimson` |
| DM Sans | `dm-sans` | `.ql-font-dm-sans` |

**Font Mapping (for paste handling)** - Common fonts are mapped to available fonts:
```javascript
// config.js
export const FONT_FAMILY_MAP = {
  'arial': 'roboto',
  'helvetica': 'roboto',
  'times new roman': 'crimson',
  'courier new': 'source-code',
  // ... more mappings
};
```

**Programmatic Usage**:
```dart
_editorKey.currentState?.format('font', 'crimson');
```

---

### 5.3 Font Size

Four size options are available:

| Size | Quill Value | CSS Class | Size |
|------|------------|-----------|------|
| Small | `small` | `.ql-size-small` | `0.75em` |
| Normal (Default) | `false` | - | `1em` |
| Large | `large` | `.ql-size-large` | `1.5em` |
| Huge | `huge` | `.ql-size-huge` | `2.5em` |

**Toolbar Configuration**:
```javascript
[{ 'size': ['small', false, 'large', 'huge'] }]
```

**Programmatic Usage**:
```dart
_editorKey.currentState?.format('size', 'large');
_editorKey.currentState?.format('size', false); // Reset to normal
```

---

### 5.4 Text Formatting

#### Basic Formatting

| Format | Keyboard Shortcut | Quill Value |
|--------|------------------|-------------|
| **Bold** | Ctrl+B / Cmd+B | `bold: true` |
| *Italic* | Ctrl+I / Cmd+I | `italic: true` |
| <u>Underline</u> | Ctrl+U / Cmd+U | `underline: true` |
| ~~Strikethrough~~ | - | `strike: true` |

**Toolbar Configuration**:
```javascript
['bold', 'italic', 'underline', 'strike']
```

**Programmatic Usage**:
```dart
_editorKey.currentState?.format('bold', true);
_editorKey.currentState?.format('bold', false); // Remove
```

#### Subscript & Superscript

| Format | Quill Value |
|--------|-------------|
| Subscript (H₂O) | `script: 'sub'` |
| Superscript (E=mc²) | `script: 'super'` |

**Toolbar Configuration**:
```javascript
[{ 'script': 'sub' }, { 'script': 'super' }]
```

---

### 5.5 Colors

#### Text Color & Background Color

Both use Quill's color picker with a full palette of colors.

**Toolbar Configuration**:
```javascript
[{ 'color': [] }, { 'background': [] }]
```

**Color Normalization**: RGB values are automatically converted to hex:
```javascript
// utils.js
export function rgbToHex(rgb) {
  // rgb(255, 0, 0) → #ff0000
}
```

**Programmatic Usage**:
```dart
_editorKey.currentState?.format('color', '#ff0000');
_editorKey.currentState?.format('background', '#ffff00');
```

---

### 5.6 Lists

The editor supports three types of lists: ordered (numbered), bullet (unordered), and checklist (task lists). Lists can be nested and support indentation.

#### List Types Overview

| List Type | Quill Value | HTML Output | Description |
|-----------|-------------|-------------|-------------|
| **Ordered List** | `list: 'ordered'` | `<ol><li>...</li></ol>` | Numbered items (1, 2, 3...) |
| **Bullet List** | `list: 'bullet'` | `<ul><li>...</li></ul>` | Bulleted items (•, ◦, ▪) |
| **Checklist** | `list: 'check'` | `<ul data-checked="true/false"><li>...</li></ul>` | Checkable task items (☐, ☑) |

#### Toolbar Configuration

```javascript
// In web/js/config.js
[{ 'list': 'ordered' }, { 'list': 'bullet' }, { 'list': 'check' }]
```

#### Creating Lists

**Via Toolbar**:
1. Place cursor where you want the list
2. Click the ordered list (1.), bullet list (•), or checklist (☐) button
3. Type your first item and press Enter
4. Continue typing items; each Enter creates a new list item

**Via Keyboard**:
- **Ordered List**: Select text → Click ordered list button
- **Bullet List**: Select text → Click bullet list button
- **Checklist**: Select text → Click checklist button

**Programmatic Usage**:

```dart
// Create a bullet list
_editorKey.currentState?.format('list', 'bullet');

// Create an ordered list
_editorKey.currentState?.format('list', 'ordered');

// Create a checklist
_editorKey.currentState?.format('list', 'check');

// Remove list formatting (convert to paragraph)
_editorKey.currentState?.format('list', false);
```

#### Nested Lists

Lists can be nested up to multiple levels using indentation:

**Creating Nested Lists**:
1. Place cursor in a list item
2. Press Tab or use the indent button to create a nested list
3. Press Shift+Tab or use the outdent button to move back up

**Example HTML Output**:
```html
<ul>
  <li>First level item
    <ul>
      <li>Second level item
        <ul>
          <li>Third level item</li>
        </ul>
      </li>
    </ul>
  </li>
</ul>
```

**Programmatic Nested Lists**:
```dart
// First, create a list
_editorKey.currentState?.format('list', 'bullet');

// Then indent to create nested list
_editorKey.currentState?.format('indent', '+1');
```

#### Checklist Features

Checklists are interactive task lists where items can be checked/unchecked.

**HTML Structure**:
```html
<!-- Unchecked item -->
<ul data-checked="false">
  <li>Task to complete</li>
</ul>

<!-- Checked item -->
<ul data-checked="true">
  <li>Completed task</li>
</ul>
```

**Using Checklists**:
1. Click the checklist button (☐) in the toolbar
2. Type your task item
3. Click the checkbox to toggle completion state
4. Or use the checklist button again to toggle

**Programmatic Checklist**:
```dart
// Create checklist
_editorKey.currentState?.format('list', 'check');

// Note: Toggling checked state is handled by Quill.js automatically
// when user clicks the checkbox in the editor
```

#### List Styling

Lists inherit styling from the editor theme. Customize via CSS:

```css
/* Customize bullet list markers */
.ql-editor ul li::before {
  content: '▸';
  color: #c45d35;
  font-weight: bold;
}

/* Customize ordered list numbers */
.ql-editor ol li {
  counter-increment: list-counter;
}

/* Customize checklist appearance */
.ql-editor ul[data-checked="true"] li::before {
  content: '✓';
  color: #4caf50;
}
```

#### List Best Practices

1. **Consistency**: Use the same list type for similar content
2. **Nesting**: Limit nesting to 2-3 levels for readability
3. **Checklists**: Use for actionable items, not for general lists
4. **Mixed Content**: Lists can contain formatted text, links, and even images

#### Complete List Example

```dart
// Insert formatted list content
final listHtml = '''
<ul>
  <li><strong>Bold item</strong> in bullet list</li>
  <li><em>Italic item</em> with <a href="https://example.com">link</a></li>
  <li>
    <ul>
      <li>Nested bullet item</li>
    </ul>
  </li>
</ul>
<ol>
  <li>First numbered item</li>
  <li>Second numbered item</li>
</ol>
<ul data-checked="false">
  <li>Unchecked task</li>
</ul>
<ul data-checked="true">
  <li>Completed task</li>
</ul>
''';

_editorKey.currentState?.insertHtml(listHtml);
```

---

### 5.7 Indentation

Increase or decrease indentation levels.

| Action | Quill Value |
|--------|-------------|
| Decrease Indent | `indent: '-1'` |
| Increase Indent | `indent: '+1'` |

**Toolbar Configuration**:
```javascript
[{ 'indent': '-1' }, { 'indent': '+1' }]
```

---

### 5.8 Text Alignment

Four alignment options are available:

| Alignment | Quill Value | CSS |
|-----------|-------------|-----|
| Left (Default) | `align: false` | `text-align: left` |
| Center | `align: 'center'` | `text-align: center` |
| Right | `align: 'right'` | `text-align: right` |
| Justify | `align: 'justify'` | `text-align: justify` |

**Toolbar Configuration**:
```javascript
[{ 'align': [] }]
```

**Programmatic Usage**:
```dart
_editorKey.currentState?.format('align', 'center');
```

---

### 5.9 Text Direction (RTL)

Toggle right-to-left text direction for languages like Arabic, Hebrew, etc.

**Toolbar Configuration**:
```javascript
[{ 'direction': 'rtl' }]
```

---

### 5.10 Block Formats

#### Blockquote

Creates a styled quote block with left border.

**CSS Styling**:
```css
.ql-editor blockquote {
  border-left: 4px solid #c45d35;
  padding-left: 16px;
  margin: 24px 0;
  color: #6b6560;
  font-style: italic;
}
```

#### Code Block

Creates a monospace code block with syntax highlighting support.

**CSS Styling**:
```css
.ql-editor pre {
  background: #f8f6f3;
  border-radius: 8px;
  padding: 16px;
  font-family: 'Source Code Pro', monospace;
  font-size: 0.875rem;
}
```

**Toolbar Configuration**:
```javascript
['blockquote', 'code-block']
```

---

### 5.11 Links

Insert hyperlinks with the link button. Supports:
- HTTP/HTTPS URLs
- Email links (mailto:)
- Anchor links (#section)

**CSS Styling**:
```css
.ql-editor a {
  color: #c45d35;
  text-decoration: underline;
  text-underline-offset: 2px;
}
```

**Toolbar Configuration**:
```javascript
['link']
```

---

### 5.12 Media: Images

#### Image Features
- Insert via URL or upload
- Resize with drag handles
- Align left/center/right
- Preset sizes (25%, 50%, 75%, 100%)
- Delete with toolbar or keyboard

#### Image Toolbar (appears on selection)
| Button | Action |
|--------|--------|
| Align Left | Float left with text wrap |
| Align Center | Center with no wrap |
| Align Right | Float right with text wrap |
| 25% / 50% / 75% / 100% | Set width percentage |
| Reset | Restore original size |
| Delete | Remove image |

#### Resize Handles
8 resize handles for all directions (N, NE, E, SE, S, SW, W, NW).

**Configuration** (`config.js`):
```javascript
export const MEDIA_MIN_SIZE = 50; // Minimum size in pixels
```

---

### 5.13 Media: Videos & Iframes

Similar to images, videos and iframes support:
- Resize controls
- Alignment options
- 16:9 aspect ratio by default

**Video-specific Features**:
- Double-click to play/pause
- Controls are automatically added

**CSS**:
```css
.ql-editor iframe {
  aspect-ratio: 16/9;
  border-radius: 8px;
  margin: 16px 0;
}
```

---

### 5.14 Tables

Tables are powered by **quill-table-better**, providing advanced table editing capabilities including resizing, merging, and header rows.

#### Table Features Overview

| Feature | Description | How to Use |
|---------|-------------|------------|
| **Insert Table** | Create tables with specified rows/columns | Click table button or use programmatic API |
| **Add Rows** | Insert rows above/below current row | Right-click → Row → Insert Above/Below |
| **Remove Rows** | Delete selected rows | Right-click → Row → Delete |
| **Add Columns** | Insert columns left/right of current column | Right-click → Column → Insert Left/Right |
| **Remove Columns** | Delete selected columns | Right-click → Column → Delete |
| **Merge Cells** | Combine multiple cells into one | Select cells → Right-click → Merge |
| **Split Cells** | Split merged cell back into individual cells | Right-click merged cell → Split |
| **Column Resize** | Adjust column width by dragging | Drag column border left/right |
| **Table Resize** | Resize entire table | Drag resize handle at bottom-right corner |
| **Header Row** | Mark first row as header (styling) | Right-click first row → Table → Header Row |
| **Cell Alignment** | Align content within cells | Right-click → Cell → Align Left/Center/Right |
| **Copy/Paste** | Copy table structure and content | Right-click → Copy, then paste elsewhere |

#### Table Configuration

The table module is configured in `web/js/quill-setup.js`:

```javascript
'table-better': {
  language: 'en_US',
  menus: [
    'column',  // Column operations (insert, delete)
    'row',     // Row operations (insert, delete)
    'merge',   // Cell merge/split
    'table',   // Table-level operations (header, resize)
    'cell',    // Cell operations (alignment, wrap)
    'wrap',    // Text wrapping
    'copy',    // Copy table
    'delete'   // Delete table
  ],
  toolbarTable: true  // Show table button in toolbar
}
```

#### Creating Tables

**Via Toolbar**:
1. Click the table button (grid icon) in the toolbar
2. A dropdown appears showing grid options (e.g., 3x3, 4x4)
3. Click to insert table at cursor position

**Via Right-Click Menu**:
1. Right-click in the editor
2. Select "Insert Table"
3. Choose dimensions from the grid

**Programmatic Table Insertion**:

```dart
// Insert a 4-row, 3-column table
_editorKey.currentState?.insertTable(4, 3);

// Insert default size table (3x3)
_editorKey.currentState?.insertTable(
  EditorConfig.defaultTableRows,
  EditorConfig.defaultTableCols,
);
```

#### Table Constraints

Table dimensions are constrained to prevent performance issues:

```dart
// From lib/src/core/constants/editor_config.dart
static const int defaultTableRows = 3;  // Default rows when inserting
static const int defaultTableCols = 3;   // Default columns when inserting
static const int maxTableRows = 20;      // Maximum allowed rows
static const int maxTableCols = 10;      // Maximum allowed columns
```

**Note**: These constraints are enforced in the JavaScript layer. Attempting to create larger tables may result in errors.

#### Header Row

Header rows provide visual distinction for the first row of a table.

**Setting Header Row**:
1. Right-click any cell in the first row
2. Select "Table" → "Header Row"
3. The first row will be styled with background color and bold text

**Keyboard Shortcut**: 
- **Windows/Linux**: `Ctrl+Shift+H`
- **Mac**: `Cmd+Shift+H`

**CSS Styling**:
```css
/* Header row styling */
.ql-editor table.table-with-header tr:first-child td {
  background: #f8f6f3;
  font-weight: 500;
  color: #333;
}

/* Optional: Different styling for header cells */
.ql-editor table.table-with-header tr:first-child td {
  border-bottom: 2px solid #c45d35;
}
```

**Programmatic Header Row**:
```dart
// Note: Header row toggle is handled by quill-table-better
// There's no direct Dart API, but you can insert HTML with header class
final tableHtml = '''
<table class="table-with-header">
  <tr>
    <td><strong>Header 1</strong></td>
    <td><strong>Header 2</strong></td>
    <td><strong>Header 3</strong></td>
  </tr>
  <tr>
    <td>Data 1</td>
    <td>Data 2</td>
    <td>Data 3</td>
  </tr>
</table>
''';
_editorKey.currentState?.insertHtml(tableHtml);
```

#### Resizing Tables

**Column Resize**:
- Hover over column border
- Click and drag left/right to adjust width
- Minimum width: 50px (configurable in `config.js`)

**Table Resize**:
- Look for resize handle at bottom-right corner of table
- Click and drag to resize entire table proportionally

**Configuration**:
```javascript
// In web/js/config.js
export const TABLE_MIN_WIDTH = 100;  // Minimum column width in pixels
```

#### Merging and Splitting Cells

**Merge Cells**:
1. Select multiple adjacent cells (click and drag)
2. Right-click → "Merge"
3. Cells combine into single cell

**Split Cells**:
1. Right-click on a merged cell
2. Select "Split"
3. Cell divides back into original cells

**Limitations**:
- Only rectangular selections can be merged
- Merged cells maintain content from top-left cell

#### Table Styling

Customize table appearance via CSS:

```css
/* Base table styles */
.ql-editor table {
  border-collapse: collapse;
  width: 100%;
  margin: 16px 0;
}

/* Table cells */
.ql-editor table td {
  border: 1px solid #ddd;
  padding: 8px 12px;
  min-width: 100px;
}

/* Table header cells (when header row is set) */
.ql-editor table.table-with-header tr:first-child td {
  background: #f8f6f3;
  font-weight: 600;
  text-align: center;
}

/* Alternating row colors (optional) */
.ql-editor table tr:nth-child(even) {
  background: #f9f9f9;
}

/* Hover effect */
.ql-editor table tr:hover {
  background: #f5f5f5;
}
```

#### Table Best Practices

1. **Use Header Rows**: Always mark the first row as header for data tables
2. **Consistent Alignment**: Use consistent cell alignment (left for text, center for numbers)
3. **Avoid Overly Large Tables**: Keep tables under 10 columns and 20 rows for performance
4. **Responsive Design**: Consider table width for mobile devices
5. **Accessibility**: Use semantic HTML (`<th>` tags when possible, though quill-table-better uses `<td>`)

#### Complete Table Example

```dart
// Insert a formatted table with header
final tableHtml = '''
<table class="table-with-header">
  <tbody>
    <tr>
      <td><strong>Product</strong></td>
      <td><strong>Price</strong></td>
      <td><strong>Stock</strong></td>
    </tr>
    <tr>
      <td>Widget A</td>
      <td style="text-align: center;">\$19.99</td>
      <td style="text-align: center;">45</td>
    </tr>
    <tr>
      <td>Widget B</td>
      <td style="text-align: center;">\$29.99</td>
      <td style="text-align: center;">12</td>
    </tr>
  </tbody>
</table>
''';

_editorKey.currentState?.insertHtml(tableHtml);
```

#### Table Limitations

- **Nested Tables**: Not supported by quill-table-better
- **Complex Merging**: Some complex merge patterns may not work as expected
- **Table Borders**: Border styling is controlled by CSS, not Quill
- **Cell Padding**: Padding is set via CSS, not through editor UI

---

### 5.15 Clear Formatting

Removes all formatting from selected text, returning it to default style.

**Toolbar Configuration**:
```javascript
['clean']
```

---

## 6. API Reference

### 6.1 QuillEditorWidget

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
final _editorKey = GlobalKey<QuillEditorWidgetState>();
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
| `undo()` | Undo the last operation |
| `redo()` | Redo the last undone operation |
| `format(String format, dynamic value)` | Apply formatting to selection |
| `insertTable(int rows, int cols)` | Insert a table at cursor |
| `zoomIn()` | Increase zoom by 10% |
| `zoomOut()` | Decrease zoom by 10% |
| `resetZoom()` | Reset zoom to 100% |
| `setZoom(double level)` | Set specific zoom level (0.5 - 3.0) |

#### State Properties

| Property | Type | Description |
|----------|------|-------------|
| `currentZoom` | `double` | Current zoom level (1.0 = 100%) |
| `isReady` | `bool` | Whether editor is ready for commands |

---

### 6.2 DocumentService

Utility service for document operations.

#### Download Operations

```dart
// Download as HTML (with embedded styles)
DocumentService.downloadHtml(
  htmlContent,
  filename: 'document.html',  // Optional
  cleanHtml: true,            // Remove editor artifacts (default: true)
);

// Download as plain text
DocumentService.downloadText(
  textContent,
  filename: 'document.txt',
);
```

#### Generate HTML Document

```dart
// Generate complete HTML document with styles
final fullHtml = DocumentService.generateHtmlDocument(
  htmlContent,
  cleanHtml: true,
  title: 'My Document',
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

### 6.3 HtmlCleaner

Process HTML for export.

```dart
// Clean editor artifacts
final clean = HtmlCleaner.cleanForExport(dirtyHtml);

// Extract plain text from HTML
final text = HtmlCleaner.extractText(html);

// Check if content is empty
if (HtmlCleaner.isEmpty(html)) {
  print('No content');
}

// Normalize color to hex
final hex = HtmlCleaner.normalizeColor('rgb(255, 0, 0)'); // '#ff0000'
```

---

### 6.4 TextStats

Calculate document statistics.

```dart
final stats = TextStats.fromHtml(html);

print('Words: ${stats.wordCount}');
print('Characters: ${stats.charCount}');
print('Characters (no spaces): ${stats.charCountNoSpaces}');
print('Paragraphs: ${stats.paragraphCount}');
print('Sentences: ${stats.sentenceCount}');
print('Reading time: ${stats.readingTimeMinutes} min');
```

---

### 6.5 UI Components

#### SaveStatusIndicator

```dart
SaveStatusIndicator(status: SaveStatus.saved)
SaveStatusIndicator(status: SaveStatus.saving)
SaveStatusIndicator(status: SaveStatus.unsaved)
```

#### ZoomControls

```dart
ZoomControls(
  zoomLevel: 1.0,
  onZoomIn: () => _editorKey.currentState?.zoomIn(),
  onZoomOut: () => _editorKey.currentState?.zoomOut(),
  onReset: () => _editorKey.currentState?.resetZoom(),
)
```

#### OutputPreview

```dart
OutputPreview(html: _currentHtml)
```

#### StatCard & StatCardRow

```dart
StatCardRow(
  stats: [
    (label: 'Words', value: '150', icon: Icons.text_fields),
    (label: 'Characters', value: '890', icon: Icons.format_size),
  ],
)
```

#### AppCard

```dart
AppCard(
  title: 'Document Info',
  child: YourContent(),
)
```

#### HtmlPreviewDialog

```dart
HtmlPreviewDialog.show(context, htmlContent);
```

#### InsertHtmlDialog

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

### 6.6 Constants & Configuration

#### EditorConfig

```dart
EditorConfig.minZoom           // 0.5 (50%)
EditorConfig.maxZoom           // 3.0 (300%)
EditorConfig.defaultZoom       // 1.0 (100%)
EditorConfig.zoomStep          // 0.1 (10%)

EditorConfig.defaultTableRows  // 3
EditorConfig.defaultTableCols  // 3
EditorConfig.maxTableRows      // 20
EditorConfig.maxTableCols      // 10

EditorConfig.contentChangeThrottleMs  // 200ms
EditorConfig.autoSaveDebounceMs       // 500ms
```

#### AppColors

```dart
AppColors.accent        // Primary accent color (#C45D35)
AppColors.surface       // Card/surface color
AppColors.background    // Scaffold background
AppColors.textPrimary   // Primary text color
AppColors.textSecondary // Secondary text color
AppColors.border        // Border color
AppColors.success       // Success state
AppColors.warning       // Warning state
AppColors.error         // Error state
```

#### AppFonts

```dart
AppFonts.availableFonts       // List<FontConfig>
AppFonts.availableSizes       // List<SizeConfig>
AppFonts.availableLineHeights // List<LineHeightConfig>
AppFonts.googleFontsUrl       // Google Fonts URL
```

---

## 7. Extending & Customizing the Editor

### 7.1 Adding a New Font

To add a new font to the editor, you need to update both the JavaScript and Dart configurations:

#### Step 1: Add Font to JavaScript Config

Edit `web/js/config.js`:

```javascript
// Add to FONT_WHITELIST
export const FONT_WHITELIST = [
  'roboto', 
  'open-sans', 
  // ... existing fonts
  'your-new-font'  // Add your font here
];

// Add to FONT_FAMILY_MAP for paste handling
export const FONT_FAMILY_MAP = {
  // ... existing mappings
  'your new font': 'your-new-font',
  'yournewfont': 'your-new-font',
};
```

#### Step 2: Add CSS Classes

Edit `web/styles/fonts.css`:

```css
/* Global */
.ql-font-your-new-font { font-family: 'Your New Font', sans-serif; }

/* Editor-specific */
.ql-editor .ql-font-your-new-font { font-family: 'Your New Font', sans-serif; }

/* Font picker label */
.ql-snow .ql-picker.ql-font .ql-picker-label[data-value="your-new-font"]::before,
.ql-snow .ql-picker.ql-font .ql-picker-item[data-value="your-new-font"]::before {
  content: 'Your New Font';
  font-family: 'Your New Font', sans-serif;
}
```

#### Step 3: Load the Font

Edit `web/quill_editor.html` to add Google Fonts link (or add @font-face):

```html
<link href="https://fonts.googleapis.com/css2?family=Your+New+Font:wght@400;500;600&display=swap" rel="stylesheet">
```

#### Step 4: Update Dart Configuration (Optional)

Edit `lib/src/core/constants/app_fonts.dart`:

```dart
static const List<FontConfig> availableFonts = [
  // ... existing fonts
  FontConfig(name: 'Your New Font', value: 'your-new-font', fontFamily: 'Your New Font'),
];
```

---

### 7.2 Adding a New Toolbar Button

To add a custom toolbar button:

#### Step 1: Update Toolbar Configuration

Edit `web/js/config.js`:

```javascript
export const TOOLBAR_OPTIONS = {
  container: [
    // ... existing options
    ['your-custom-button'],  // Add your button
  ]
};
```

#### Step 2: Register Custom Format (if needed)

Edit `web/js/quill-setup.js`:

```javascript
export function registerQuillModules(Quill, QuillTableBetter) {
  // ... existing registrations
  
  // Register custom format
  const Inline = Quill.import('blots/inline');
  
  class YourCustomBlot extends Inline {
    static blotName = 'your-custom';
    static tagName = 'span';
    static className = 'your-custom-class';
  }
  
  Quill.register(YourCustomBlot);
}
```

#### Step 3: Add Custom CSS

Edit `web/styles/quill-theme.css`:

```css
/* Custom button icon */
.ql-your-custom-button::after {
  content: '🔥';
  font-size: 14px;
}

/* Custom format styling */
.ql-editor .your-custom-class {
  /* Your custom styles */
}
```

---

### 7.3 Adding a New Command

To add a new command that Flutter can send to the editor:

#### Step 1: Add Command Handler in JavaScript

Edit `web/js/commands.js`:

```javascript
export function handleCommand(data, editor, Quill) {
  switch (data.action) {
    // ... existing cases
    
    case 'yourNewCommand':
      if (data.yourParam) {
        // Your command logic
        console.log('Executing yourNewCommand with:', data.yourParam);
        
        // Example: Insert custom content
        const range = editor.getSelection(true);
        editor.insertText(range.index, data.yourParam, Quill.sources.USER);
        
        // Notify Flutter
        sendContentChange(editor);
      }
      break;
  }
}
```

#### Step 2: Add Dart Method

Edit `lib/src/widgets/quill_editor_widget.dart`:

```dart
class QuillEditorWidgetState extends State<QuillEditorWidget> {
  // ... existing code
  
  /// Your new command method
  void yourNewCommand(String yourParam) {
    _sendCommand({
      'action': 'yourNewCommand',
      'yourParam': yourParam,
    });
  }
}
```

#### Usage

```dart
_editorKey.currentState?.yourNewCommand('Hello!');
```

---

### 7.4 Customizing the Theme

#### Override Flutter Theme

```dart
MaterialApp(
  theme: AppTheme.lightTheme.copyWith(
    colorScheme: ColorScheme.light(
      primary: Colors.blue,
      secondary: Colors.blueAccent,
    ),
  ),
  home: MyApp(),
)
```

#### Override CSS Theme

Create a custom CSS file and include it after the package CSS:

```html
<!-- In your custom quill_editor.html -->
<link rel="stylesheet" href="styles/base.css">
<link rel="stylesheet" href="styles/quill-theme.css">
<!-- Your custom overrides -->
<link rel="stylesheet" href="styles/my-custom-theme.css">
```

---

### 7.5 Custom HTML Files

You can provide completely custom HTML files:

```dart
QuillEditorWidget(
  editorHtmlPath: 'assets/my-custom-editor.html',
  viewerHtmlPath: 'assets/my-custom-viewer.html',
  onContentChanged: (html, delta) {
    // Handle changes
  },
)
```

Your custom HTML must:
1. Include Quill.js and quill-table-better
2. Set up the Flutter bridge for communication
3. Send `ready` message when initialized
4. Send `contentChange` messages on text changes

---

### 7.6 Modifying Table Behavior

#### Change Table Menu Options

Edit `web/js/quill-setup.js`:

```javascript
'table-better': {
  language: 'en_US',
  menus: ['column', 'row', 'merge', 'table', 'cell', 'wrap', 'copy', 'delete'],
  // Remove options you don't need:
  // menus: ['column', 'row', 'table', 'delete'],
  toolbarTable: true
}
```

#### Change Table Styling

Edit `web/styles/tables.css`:

```css
.ql-editor table td {
  border: 2px solid #333;  /* Thicker, darker border */
  padding: 12px 20px;      /* More padding */
  min-width: 100px;
}
```

---

### 7.7 Modifying Existing Features

This section provides step-by-step guidance on modifying existing toolbar features, including changing behavior, styling, and configuration.

#### Understanding the Architecture

Before modifying features, understand the three-layer architecture:

1. **Flutter Layer (Dart)**: `lib/src/widgets/quill_editor_widget.dart` - Sends commands to JavaScript
2. **Bridge Layer (HTML)**: `web/quill_editor.html` - Contains the iframe and loads JavaScript modules
3. **JavaScript Layer**: `web/js/*.js` - Handles editor logic, commands, and Quill.js integration

#### Modifying Toolbar Configuration

**Location**: `web/js/config.js`

**Example: Change Toolbar Order**

```javascript
// Original configuration
export const TOOLBAR_OPTIONS = {
  container: [
    [{ 'header': [1, 2, 3, 4, 5, 6, false] }],
    [{ 'font': ['', ...FONT_WHITELIST] }],
    ['bold', 'italic', 'underline', 'strike'],
  ]
};

// Modified: Move formatting before fonts
export const TOOLBAR_OPTIONS = {
  container: [
    [{ 'header': [1, 2, 3, 4, 5, 6, false] }],
    ['bold', 'italic', 'underline', 'strike'],  // Moved up
    [{ 'font': ['', ...FONT_WHITELIST] }],
  ]
};
```

**Example: Remove a Toolbar Button**

```javascript
// Remove the strike button
export const TOOLBAR_OPTIONS = {
  container: [
    [{ 'header': [1, 2, 3, 4, 5, 6, false] }],
    ['bold', 'italic', 'underline'],  // Removed 'strike'
    // ... rest of config
  ]
};
```

**Example: Customize Font Size Options**

```javascript
// In config.js, modify SIZE_WHITELIST
export const SIZE_WHITELIST = ['small', false, 'large'];  // Removed 'huge'

// Then update toolbar
export const TOOLBAR_OPTIONS = {
  container: [
    [{ 'size': SIZE_WHITELIST }],  // Uses modified whitelist
  ]
};
```

#### Modifying List Behavior

**Location**: `web/js/config.js` and `web/styles/quill-theme.css`

**Example: Change Bullet List Style**

1. **Update CSS** (`web/styles/quill-theme.css`):

```css
/* Custom bullet style */
.ql-editor ul li::before {
  content: '▸';  /* Changed from default bullet */
  color: #c45d35;
  font-weight: bold;
  margin-right: 8px;
}

/* Nested bullets */
.ql-editor ul ul li::before {
  content: '◦';
}

.ql-editor ul ul ul li::before {
  content: '▪';
}
```

**Example: Change Ordered List Numbering Style**

```css
/* Custom ordered list styling */
.ql-editor ol {
  counter-reset: list-counter;
  list-style: none;
}

.ql-editor ol li {
  counter-increment: list-counter;
  position: relative;
  padding-left: 2em;
}

.ql-editor ol li::before {
  content: counter(list-counter) '.';
  position: absolute;
  left: 0;
  font-weight: bold;
  color: #c45d35;
}
```

**Example: Modify Checklist Appearance**

```css
/* Custom checklist styling */
.ql-editor ul[data-checked="false"] li::before {
  content: '☐';
  font-size: 1.2em;
  color: #666;
}

.ql-editor ul[data-checked="true"] li::before {
  content: '☑';
  font-size: 1.2em;
  color: #4caf50;
  font-weight: bold;
}
```

#### Modifying Table Configuration

**Location**: `web/js/quill-setup.js` and `web/js/config.js`

**Example: Change Table Default Size**

1. **Update JavaScript Config** (`web/js/config.js`):

```javascript
// Add new constants
export const DEFAULT_TABLE_ROWS = 5;  // Changed from 3
export const DEFAULT_TABLE_COLS = 4;  // Changed from 3
```

2. **Update Dart Config** (`lib/src/core/constants/editor_config.dart`):

```dart
static const int defaultTableRows = 5;  // Updated
static const int defaultTableCols = 4;  // Updated
```

3. **Update Command Handler** (`web/js/commands.js`):

```javascript
case 'insertTable':
  if (data.rows && data.cols) {
    const tableModule = editor.getModule('tableWrapper');
    if (tableModule) {
      // Use defaults if not provided
      const rows = data.rows || DEFAULT_TABLE_ROWS;
      const cols = data.cols || DEFAULT_TABLE_COLS;
      tableModule.insertTable(rows, cols);
      sendContentChange(editor);
    }
  }
  break;
```

**Example: Disable Table Resize**

```javascript
// In quill-setup.js, modify table-better config
'table-better': {
  language: 'en_US',
  menus: ['column', 'row', 'merge', 'table', 'cell', 'wrap', 'copy', 'delete'],
  toolbarTable: true,
  // Disable resize by removing resize-related menu items
  // Note: This may require modifying quill-table-better source
}
```

#### Modifying Color Picker

**Location**: `web/js/config.js`

**Example: Limit Color Options**

```javascript
// In TOOLBAR_OPTIONS, specify exact colors
export const TOOLBAR_OPTIONS = {
  container: [
    // Limited color palette
    [{ 
      'color': [
        '#000000',  // Black
        '#ffffff',  // White
        '#ff0000',  // Red
        '#00ff00',  // Green
        '#0000ff',  // Blue
      ] 
    }],
  ]
};
```

**Example: Custom Background Colors**

```javascript
// Custom background color options
[{ 
  'background': [
    '#ffff00',  // Yellow highlight
    '#00ffff',  // Cyan highlight
    '#ff00ff',  // Magenta highlight
  ] 
}]
```

#### Modifying Media (Image/Video) Behavior

**Location**: `web/js/media-resize.js` and `web/styles/media.css`

**Example: Change Default Image Size**

```javascript
// In media-resize.js, modify default size
export const DEFAULT_IMAGE_WIDTH = '50%';  // Changed from default

// When inserting image
function insertImage(url) {
  // ... existing code
  img.style.width = DEFAULT_IMAGE_WIDTH;
  // ... rest of code
}
```

**Example: Change Image Alignment Options**

```css
/* In media.css, modify alignment styles */
.ql-editor img.align-left {
  float: left;
  margin-right: 16px;
  margin-bottom: 16px;
}

.ql-editor img.align-center {
  display: block;
  margin: 16px auto;
}

.ql-editor img.align-right {
  float: right;
  margin-left: 16px;
  margin-bottom: 16px;
}
```

**Example: Add Custom Image Size Presets**

```javascript
// In media-resize.js, add new size options
const SIZE_PRESETS = [
  { label: '25%', value: '25%' },
  { label: '50%', value: '50%' },
  { label: '75%', value: '75%' },
  { label: '100%', value: '100%' },
  { label: 'Custom', value: 'custom' },  // New option
  { label: 'Thumbnail', value: '150px' },  // New preset
];
```

#### Modifying Font Configuration

**Location**: `web/js/config.js`, `web/styles/fonts.css`, `lib/src/core/constants/app_fonts.dart`

**Example: Change Default Font**

```css
/* In fonts.css, modify default font */
.ql-editor {
  font-family: 'Roboto', sans-serif;  /* Changed from default */
}
```

**Example: Modify Font Size Values**

```css
/* In sizes.css, change size definitions */
.ql-size-small {
  font-size: 0.875em;  /* Changed from 0.75em */
}

.ql-size-large {
  font-size: 1.75em;  /* Changed from 1.5em */
}

.ql-size-huge {
  font-size: 2.75em;  /* Changed from 2.5em */
}
```

**Example: Add Custom Font Size**

1. **Update Config** (`web/js/config.js`):

```javascript
export const SIZE_WHITELIST = ['small', false, 'large', 'huge', 'extra-huge'];
```

2. **Add CSS** (`web/styles/sizes.css`):

```css
.ql-size-extra-huge {
  font-size: 3.5em;
}
```

3. **Update Dart** (`lib/src/core/constants/app_fonts.dart`):

```dart
static const List<SizeConfig> availableSizes = [
  SizeConfig(name: 'Small', value: 'small', size: '0.75em'),
  SizeConfig(name: 'Normal', value: null, size: '1em'),
  SizeConfig(name: 'Large', value: 'large', size: '1.5em'),
  SizeConfig(name: 'Huge', value: 'huge', size: '2.5em'),
  SizeConfig(name: 'Extra Huge', value: 'extra-huge', size: '3.5em'),  // New
];
```

#### Modifying Zoom Behavior

**Location**: `web/js/config.js` and `lib/src/core/constants/editor_config.dart`

**Example: Change Zoom Range**

```javascript
// In config.js
export const ZOOM_MIN = 0.25;  // Changed from 0.5 (25% minimum)
export const ZOOM_MAX = 4.0;  // Changed from 3.0 (400% maximum)
```

```dart
// In editor_config.dart
static const double minZoom = 0.25;
static const double maxZoom = 4.0;
```

**Example: Change Zoom Step**

```dart
// In editor_config.dart
static const double zoomStep = 0.25;  // Changed from 0.1 (25% increments)
```

#### Modifying Paste Behavior

**Location**: `web/js/clipboard.js` and `web/js/utils.js`

**Example: Customize Paste Preprocessing**

```javascript
// In utils.js, modify preprocessHtml function
export function preprocessHtml(html) {
  // Your custom preprocessing logic
  html = html.replace(/<script[^>]*>.*?<\/script>/gi, '');  // Remove scripts
  html = html.replace(/on\w+="[^"]*"/gi, '');  // Remove event handlers
  
  // Existing preprocessing
  html = convertInlineFontsToClasses(html);
  html = normalizeColors(html);
  
  return html;
}
```

#### Testing Your Modifications

After making modifications, follow these steps:

1. **Clear Browser Cache**: Hard refresh (Ctrl+Shift+R or Cmd+Shift+R)
2. **Check Browser Console**: Look for JavaScript errors
3. **Test Functionality**: Verify the modified feature works as expected
4. **Test Edge Cases**: Try various scenarios (empty content, large content, etc.)
5. **Verify Cross-Browser**: Test in Chrome, Firefox, Safari, Edge

**Debugging Tips**:

```javascript
// Add console logs in JavaScript
console.log('Toolbar options:', TOOLBAR_OPTIONS);
console.log('Command received:', data);

// Add debug prints in Dart
debugPrint('Editor state: isReady=$isReady, zoom=$currentZoom');
```

#### Best Practices for Modifications

1. **Backup Original Files**: Always keep a backup before modifying
2. **Version Control**: Commit changes incrementally with clear messages
3. **Document Changes**: Add comments explaining why changes were made
4. **Test Thoroughly**: Test all affected features, not just the modified one
5. **Consider Breaking Changes**: Some modifications may break existing content
6. **Update Documentation**: Keep this guide updated with your customizations

---

## 8. Troubleshooting & FAQ

### Common Issues

#### Editor Not Loading

**Problem**: Editor shows blank white screen

**Solutions**:
1. Verify `quill_editor.html` exists in `web/` directory
2. Check browser console for JavaScript errors
3. Ensure all JS modules are copied to `web/js/`
4. Verify CDN resources are accessible

```bash
# Check if files exist
ls -la web/quill_editor.html
ls -la web/js/
```

#### Content Not Saving

**Problem**: `onContentChanged` not being called

**Solutions**:
1. Verify callback is provided
2. Check if editor is in `readOnly` mode
3. Wait for `onReady` before expecting changes

```dart
QuillEditorWidget(
  onContentChanged: (html, delta) {
    print('Content changed: $html');  // Add debug print
  },
  onReady: () {
    print('Editor ready!');
  },
)
```

#### Fonts Not Working

**Problem**: Custom fonts not appearing

**Solutions**:
1. Verify Google Fonts link in HTML
2. Check font CSS classes in `fonts.css`
3. Ensure font is in `FONT_WHITELIST`

```javascript
// In config.js
console.log('Font whitelist:', FONT_WHITELIST);
```

#### Tables Not Rendering

**Problem**: Table button doesn't work

**Solutions**:
1. Verify quill-table-better is loaded
2. Check for console errors
3. Ensure keyboard bindings are registered

```javascript
// In quill-setup.js, add debug
console.log('Table module:', editor.getModule('table-better'));
```

#### Zoom Not Working

**Problem**: Zoom controls don't affect editor

**Solutions**:
1. Verify `isReady` is true before calling zoom methods
2. Check CSS transform is being applied

```dart
if (_editorKey.currentState?.isReady == true) {
  _editorKey.currentState?.zoomIn();
}
```

---

### FAQ

**Q: Can I use this on mobile Flutter apps?**

A: No, this package is designed specifically for Flutter Web. It uses iframe embedding which is not supported on mobile platforms.

**Q: How do I handle large documents?**

A: The editor handles large documents well, but for very large content (10,000+ words), consider:
- Implementing pagination
- Using virtual scrolling
- Lazy loading sections

**Q: Can I disable specific toolbar buttons?**

A: Yes, modify the `TOOLBAR_OPTIONS` in `config.js` to include only the buttons you need.

**Q: How do I save content to a backend?**

A: Use the `onContentChanged` callback:

```dart
void _onContentChanged(String html, dynamic delta) async {
  await api.saveDocument(html);
}
```

**Q: Can I customize the color picker?**

A: Yes, you can provide custom color options:

```javascript
[{ 'color': ['#ff0000', '#00ff00', '#0000ff', '#000000'] }]
```

**Q: How do I add spell-checking?**

A: Browser spell-check is enabled by default. Ensure your `<div>` has `spellcheck="true"` attribute.

**Q: Can I embed the editor in a dialog?**

A: Yes, but use `PointerInterceptor` to handle click events properly:

```dart
showDialog(
  context: context,
  builder: (context) => PointerInterceptor(
    child: Dialog(
      child: SizedBox(
        width: 800,
        height: 600,
        child: QuillEditorWidget(...),
      ),
    ),
  ),
);
```

---

## 9. Best Practices

### Performance

1. **Debounce Auto-Save**: Don't save on every keystroke
   ```dart
   Timer? _saveTimer;
   
   void _onContentChanged(String html, dynamic delta) {
     _saveTimer?.cancel();
     _saveTimer = Timer(Duration(milliseconds: 500), () {
       _saveToBackend(html);
     });
   }
   ```

2. **Use Read-Only Mode for Display**: When showing content without editing
   ```dart
   QuillEditorWidget(
     readOnly: true,
     initialHtml: content,
   )
   ```

3. **Lazy Load Editor**: Don't initialize editor until needed
   ```dart
   bool _showEditor = false;
   
   // Later...
   if (_showEditor) QuillEditorWidget(...)
   ```

### Security

1. **Sanitize HTML on Server**: Never trust client-side HTML
   ```dart
   // Server-side sanitization before storing
   final sanitized = sanitizeHtml(clientHtml);
   ```

2. **Use HTTPS**: Always serve editor files over HTTPS in production

3. **Content Security Policy**: Configure appropriate CSP headers

### UX Guidelines

1. **Show Loading State**: Display spinner while editor initializes
   ```dart
   bool _isReady = false;
   
   QuillEditorWidget(
     onReady: () => setState(() => _isReady = true),
   )
   
   if (!_isReady) CircularProgressIndicator()
   ```

2. **Handle Errors Gracefully**: Catch and display errors
   ```dart
   try {
     await DocumentService.downloadHtml(content);
   } catch (e) {
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text('Download failed: $e')),
     );
   }
   ```

3. **Provide Keyboard Shortcuts**: Document available shortcuts for power users

### Accessibility

1. **Semantic HTML**: The editor produces semantic HTML (h1-h6, lists, etc.)

2. **Keyboard Navigation**: Ensure all toolbar functions are keyboard-accessible

3. **ARIA Labels**: Add labels to custom buttons

---

## Appendix A: Complete Toolbar Configuration

```javascript
// web/js/config.js
export const TOOLBAR_OPTIONS = {
  container: [
    // Text structure - Headers
    [{ 'header': [1, 2, 3, 4, 5, 6, false] }],
    
    // Font family
    [{ 'font': ['', ...FONT_WHITELIST] }],
    
    // Font size
    [{ 'size': ['small', false, 'large', 'huge'] }],
    
    // Text formatting
    ['bold', 'italic', 'underline', 'strike'],
    
    // Subscript / Superscript
    [{ 'script': 'sub' }, { 'script': 'super' }],
    
    // Colors
    [{ 'color': [] }, { 'background': [] }],
    
    // Lists (ordered, bullet, checklist)
    [{ 'list': 'ordered' }, { 'list': 'bullet' }, { 'list': 'check' }],
    
    // Indentation
    [{ 'indent': '-1' }, { 'indent': '+1' }],
    
    // Text alignment
    [{ 'align': [] }],
    
    // Text direction (LTR/RTL)
    [{ 'direction': 'rtl' }],
    
    // Block formats
    ['blockquote', 'code-block'],
    
    // Media and embeds
    ['link', 'image', 'video'],
    
    // Table
    ['table-better'],
    
    // Clear formatting
    ['clean']
  ]
};
```

---

## Appendix B: Message Protocol Reference

### Commands (Flutter → JavaScript)

| Action | Parameters | Description |
|--------|------------|-------------|
| `setContents` | `delta` | Set content from Delta |
| `setHTML` | `html`, `replace` | Set content from HTML |
| `insertText` | `text` | Insert text at cursor |
| `insertHtml` | `html`, `replace` | Insert HTML at cursor |
| `getContents` | - | Request current contents |
| `clear` | - | Clear all content |
| `focus` | - | Focus the editor |
| `undo` | - | Undo last operation |
| `redo` | - | Redo last undone |
| `format` | `format`, `value` | Apply formatting |
| `insertTable` | `rows`, `cols` | Insert table |
| `setZoom` | `zoom` | Set zoom level |

### Events (JavaScript → Flutter)

| Type | Data | Description |
|------|------|-------------|
| `ready` | - | Editor initialized |
| `contentChange` | `html`, `delta`, `text` | Content updated |
| `response` | `action`, `html`, `delta`, `text` | Response to command |
| `zoomChange` | `zoom` | Zoom level changed |

---

## Appendix C: CSS Class Reference

### Font Classes
- `.ql-font-roboto`
- `.ql-font-open-sans`
- `.ql-font-lato`
- `.ql-font-montserrat`
- `.ql-font-source-code`
- `.ql-font-crimson`
- `.ql-font-dm-sans`

### Size Classes
- `.ql-size-small`
- `.ql-size-large`
- `.ql-size-huge`

### Alignment Classes
- `.align-left`
- `.align-center`
- `.align-right`

### Table Classes
- `.table-with-header` - Styles first row as header
- `.ql-table-wrapper` - Table container

### Media Classes
- `.selected` - Selected media element
- `.media-resizer` - Resize overlay

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.1 | Dec 2024 | Bug fixes, documentation updates |
| 1.0.0 | Dec 2024 | Initial release |

---

## License

MIT License - See [LICENSE](LICENSE) for details.

---

<p align="center">
  <strong>Quill Web Editor</strong><br>
  Made with ❤️ using Flutter & Quill.js
</p>
