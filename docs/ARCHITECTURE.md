# Quill Web Editor - Architecture Document

## Table of Contents
1. [Overview](#overview)
2. [Design Principles](#design-principles)
3. [System Architecture](#system-architecture)
4. [Layer Architecture](#layer-architecture)
5. [Component Details](#component-details)
6. [Communication Protocol](#communication-protocol)
7. [Data Flow](#data-flow)
8. [Directory Structure](#directory-structure)
9. [Technology Stack](#technology-stack)
10. [Security Considerations](#security-considerations)

---

## Overview

**Quill Web Editor** is a Flutter Web package that provides a full-featured rich text editing experience by integrating [Quill.js](https://quilljs.com/) (v2.0.0) with Flutter. The package uses an **iframe-based embedding architecture** with bidirectional message passing to enable seamless communication between Flutter's Dart code and the JavaScript-based Quill editor.

### Key Capabilities
- Rich text editing with comprehensive formatting toolbar
- Table support via [quill-table-better](https://github.com/attojs/quill-table-better)
- Media embedding (images, videos, iframes) with resize controls
- Custom fonts and typography controls
- HTML import/export with style preservation
- Zoom controls and preview functionality
- Smart paste handling with format preservation

---

## Design Principles

### 1. **Separation of Concerns**
The architecture maintains clear boundaries between:
- **Presentation** (Flutter widgets)
- **Business Logic** (Services and utilities)
- **Editor Core** (JavaScript/Quill.js)

### 2. **Bridge Pattern**
Flutter and Quill.js communicate through a well-defined message-passing protocol, allowing each layer to evolve independently.

### 3. **Modularity**
Both Flutter and JavaScript code are organized into focused, reusable modules:
- Flutter: Widgets, Services, Core utilities
- JavaScript: Setup, Commands, Clipboard, Media handling, etc.

### 4. **Configuration over Code**
Settings are centralized in configuration classes (`EditorConfig`, `AppColors`, `AppFonts`) for easy customization.

### 5. **Clean Export**
HTML export is sanitized to remove editor artifacts, ensuring clean output suitable for external use.

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              FLUTTER APPLICATION                             │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │                           FLUTTER LAYER                                  │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │ │
│  │  │   Widgets    │  │   Services   │  │   Utilities  │  │  Constants   │ │ │
│  │  │              │  │              │  │              │  │              │ │ │
│  │  │ • QuillEditor│  │ • Document   │  │ • HtmlCleaner│  │ • AppColors  │ │ │
│  │  │   Widget     │  │   Service    │  │ • TextStats  │  │ • AppFonts   │ │ │
│  │  │ • ZoomCtrl   │  │              │  │ • ExportCSS  │  │ • EditorCfg  │ │ │
│  │  │ • StatusInd  │  │              │  │              │  │              │ │ │
│  │  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘ │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
│                                      │                                       │
│                                      │ postMessage API                       │
│                                      ▼                                       │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │                          BRIDGE LAYER (IFrame)                           │ │
│  │  ┌─────────────────────────────────────────────────────────────────────┐ │ │
│  │  │                      HTML Container                                  │ │ │
│  │  │  ┌─────────────────┐         ┌─────────────────┐                    │ │ │
│  │  │  │ quill_editor.   │         │ quill_viewer.   │                    │ │ │
│  │  │  │    html         │   OR    │    html         │                    │ │ │
│  │  │  │ (Full Editor)   │         │ (Read-Only)     │                    │ │ │
│  │  │  └─────────────────┘         └─────────────────┘                    │ │ │
│  │  └─────────────────────────────────────────────────────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
│                                      │                                       │
│                                      │ JavaScript Modules                    │
│                                      ▼                                       │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │                         JAVASCRIPT LAYER                                 │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │ │
│  │  │ quill-setup  │  │  commands    │  │  clipboard   │  │flutter-bridge│ │ │
│  │  │              │  │              │  │              │  │              │ │ │
│  │  │ • Initialize │  │ • Handle     │  │ • Paste      │  │ • Send msgs  │ │ │
│  │  │ • Register   │  │   Flutter    │  │   handling   │  │ • Receive    │ │ │
│  │  │   modules    │  │   commands   │  │ • Selection  │  │   cmds       │ │ │
│  │  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘ │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │ │
│  │  │ media-resize │  │ table-resize │  │  drag-drop   │  │   config     │ │ │
│  │  │              │  │              │  │              │  │              │ │ │
│  │  │ • Image/     │  │ • Cell/Col   │  │ • File drop  │  │ • Fonts      │ │ │
│  │  │   Video      │  │   resize     │  │ • Media      │  │ • Toolbar    │ │ │
│  │  │   resize     │  │ • Detection  │  │   observer   │  │ • Limits     │ │ │
│  │  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘ │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
│                                      │                                       │
│                                      ▼                                       │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │                      EXTERNAL DEPENDENCIES                               │ │
│  │  ┌──────────────────────┐       ┌────────────────────────┐              │ │
│  │  │    Quill.js 2.0.0    │       │  quill-table-better    │              │ │
│  │  │    (CDN)             │       │  (CDN)                 │              │ │
│  │  └──────────────────────┘       └────────────────────────┘              │ │
│  │  ┌──────────────────────┐       ┌────────────────────────┐              │ │
│  │  │   Google Fonts       │       │  Quill Snow Theme      │              │ │
│  │  │   (CDN)             │       │  (CDN)                 │              │ │
│  │  └──────────────────────┘       └────────────────────────┘              │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Layer Architecture

### Layer 1: Flutter Layer

The Flutter layer is responsible for:
- Providing the widget interface for embedding the editor
- Managing editor state and callbacks
- Offering helper widgets (zoom controls, save indicators, previews)
- Document operations (download, print, clipboard)
- HTML processing and text statistics

#### Key Components:

| Component | Location | Responsibility |
|-----------|----------|----------------|
| `QuillEditorWidget` | `lib/src/widgets/quill_editor_widget.dart` | Main editor widget, iframe management |
| `QuillEditorWidgetState` | Same file | Programmatic control API |
| `DocumentService` | `lib/src/services/document_service.dart` | File operations, clipboard, storage |
| `HtmlCleaner` | `lib/src/core/utils/html_cleaner.dart` | Sanitize HTML for export |
| `TextStats` | `lib/src/core/utils/text_stats.dart` | Word/character counting |
| `ExportStyles` | `lib/src/core/utils/export_styles.dart` | CSS generation for export |

### Layer 2: Bridge Layer (IFrame Container)

The bridge layer consists of HTML files that:
- Load external dependencies (Quill.js, CSS, fonts)
- Provide the container for the Quill editor
- Bootstrap the JavaScript modules
- Handle the postMessage communication

**Two HTML files:**
- `quill_editor.html` - Full-featured editing mode
- `quill_viewer.html` - Read-only viewing mode

### Layer 3: JavaScript Layer

The JavaScript layer is modularized into focused modules:

| Module | File | Responsibility |
|--------|------|----------------|
| **Config** | `js/config.js` | Fonts, sizes, toolbar options, constants |
| **Quill Setup** | `js/quill-setup.js` | Initialize Quill, register modules |
| **Commands** | `js/commands.js` | Handle commands from Flutter |
| **Flutter Bridge** | `js/flutter-bridge.js` | Message passing to/from Flutter |
| **Clipboard** | `js/clipboard.js` | Paste handling, selection preservation |
| **Media Resize** | `js/media-resize.js` | Image/video/iframe resize controls |
| **Table Resize** | `js/table-resize.js` | Table column/cell resize detection |
| **Drag Drop** | `js/drag-drop.js` | File drop handling, media observer |
| **Utils** | `js/utils.js` | Helper functions (color conversion, etc.) |
| **Viewer** | `js/viewer.js` | Read-only mode initialization |

---

## Component Details

### QuillEditorWidget

The core widget that embeds the Quill editor:

```dart
class QuillEditorWidget extends StatefulWidget {
  // Configuration
  final double? width;
  final double? height;
  final bool readOnly;
  final String? initialHtml;
  final dynamic initialDelta;
  final String? placeholder;
  final String? editorHtmlPath;
  final String? viewerHtmlPath;
  
  // Callbacks
  final void Function(String html, dynamic delta)? onContentChanged;
  final VoidCallback? onReady;
}
```

**State Management:**
- Uses `GlobalKey<QuillEditorWidgetState>` for programmatic access
- Maintains zoom level, ready state, and initialization flags
- Registers unique view factory per instance

### Communication Protocol

**Flutter → JavaScript (Commands):**
```json
{
  "type": "command",
  "source": "flutter",
  "action": "setHTML | insertText | undo | redo | format | insertTable | setZoom | ...",
  "...parameters": "..."
}
```

**JavaScript → Flutter (Events):**
```json
{
  "type": "contentChange | ready | response | zoomChange",
  "source": "quill-editor",
  "html": "...",
  "delta": {...},
  "text": "..."
}
```

### Command Types

| Command | Parameters | Description |
|---------|------------|-------------|
| `setContents` | `delta` | Set editor content from Quill Delta |
| `setHTML` | `html`, `replace` | Set content from HTML string |
| `insertText` | `text` | Insert text at cursor |
| `insertHtml` | `html`, `replace` | Insert HTML at cursor or replace |
| `getContents` | - | Request current contents |
| `clear` | - | Clear all content |
| `focus` | - | Focus the editor |
| `undo` | - | Undo last operation |
| `redo` | - | Redo last undone operation |
| `format` | `format`, `value` | Apply formatting |
| `insertTable` | `rows`, `cols` | Insert table |
| `setZoom` | `zoom` | Set zoom level |

---

## Data Flow

### Content Editing Flow

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│    User      │────▶│  Quill.js    │────▶│  text-change │
│   Typing     │     │   Editor     │     │    event     │
└──────────────┘     └──────────────┘     └──────────────┘
                                                 │
                                                 ▼
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   Flutter    │◀────│  postMessage │◀────│ sendContent  │
│  Callback    │     │   (JSON)     │     │   Change     │
└──────────────┘     └──────────────┘     └──────────────┘
       │
       ▼
┌──────────────┐
│  Update UI   │
│  (Stats,     │
│   Preview)   │
└──────────────┘
```

### Command Flow (Flutter → Quill)

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   Flutter    │────▶│  _sendCmd    │────▶│ postMessage  │
│   Method     │     │   (JSON)     │     │  to iframe   │
└──────────────┘     └──────────────┘     └──────────────┘
                                                 │
                                                 ▼
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   Editor     │◀────│ handleCmd    │◀────│  message     │
│   Update     │     │   switch     │     │   listener   │
└──────────────┘     └──────────────┘     └──────────────┘
```

### HTML Export Flow

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  Raw HTML    │────▶│ HtmlCleaner  │────▶│ ExportStyles │
│  (with       │     │ .cleanFor    │     │ .generate    │
│  artifacts)  │     │  Export()    │     │  HtmlDoc()   │
└──────────────┘     └──────────────┘     └──────────────┘
                                                 │
                                                 ▼
                                          ┌──────────────┐
                                          │   Complete   │
                                          │  HTML Doc    │
                                          │  with CSS    │
                                          └──────────────┘
```

---

## Directory Structure

```
quill_web_editor/
├── lib/
│   ├── quill_web_editor.dart              # Main library export
│   └── src/
│       ├── core/
│       │   ├── constants/
│       │   │   ├── app_colors.dart        # Color palette
│       │   │   ├── app_fonts.dart         # Font configurations
│       │   │   ├── constants.dart         # Barrel export
│       │   │   └── editor_config.dart     # Editor settings
│       │   ├── theme/
│       │   │   └── app_theme.dart         # Theme data
│       │   ├── utils/
│       │   │   ├── export_styles.dart     # Export CSS generation
│       │   │   ├── html_cleaner.dart      # HTML sanitization
│       │   │   ├── text_stats.dart        # Document statistics
│       │   │   └── utils.dart             # Barrel export
│       │   └── core.dart                  # Barrel export
│       ├── services/
│       │   ├── document_service.dart      # Document operations
│       │   └── services.dart              # Barrel export
│       └── widgets/
│           ├── app_card.dart              # Styled container
│           ├── html_preview_dialog.dart   # Preview dialog
│           ├── insert_html_dialog.dart    # HTML insertion dialog
│           ├── output_preview.dart        # HTML/text preview
│           ├── quill_editor_widget.dart   # Main editor widget
│           ├── save_status_indicator.dart # Save status display
│           ├── stat_card.dart             # Statistics cards
│           ├── widgets.dart               # Barrel export
│           └── zoom_controls.dart         # Zoom UI
├── web/
│   ├── quill_editor.html                  # Editor HTML container
│   ├── quill_viewer.html                  # Viewer HTML container
│   ├── js/
│   │   ├── clipboard.js                   # Paste/selection handling
│   │   ├── commands.js                    # Flutter command handling
│   │   ├── config.js                      # Shared configuration
│   │   ├── drag-drop.js                   # File drop handling
│   │   ├── flutter-bridge.js              # Message bridge
│   │   ├── media-resize.js                # Media resize controls
│   │   ├── quill-setup.js                 # Quill initialization
│   │   ├── table-resize.js                # Table resize detection
│   │   ├── utils.js                       # Utility functions
│   │   └── viewer.js                      # Read-only mode
│   └── styles/
│       ├── base.css                       # Base styles
│       ├── fonts.css                      # Font classes
│       ├── media.css                      # Media element styles
│       ├── quill-theme.css                # Quill theme overrides
│       ├── sizes.css                      # Size classes
│       ├── tables.css                     # Table styles
│       └── viewer.css                     # Viewer-specific styles
├── example/
│   ├── lib/
│   │   ├── main.dart                      # Example app entry
│   │   └── pages/
│   │       └── editor_example_page.dart   # Complete example
│   ├── web/
│   │   ├── index.html                     # Example app HTML
│   │   ├── quill_editor.html              # Copy of editor HTML
│   │   ├── quill_viewer.html              # Copy of viewer HTML
│   │   ├── js/                            # Copy of JS modules
│   │   └── styles/                        # Copy of styles
│   └── pubspec.yaml                       # Example dependencies
├── test/
│   ├── flutter_test_config.dart           # Test configuration
│   ├── fonts/                             # Test fonts
│   ├── html_cleaner_test.dart             # HtmlCleaner tests
│   ├── html_export_test.dart              # Export tests
│   ├── paste_preprocessing_test.dart      # Paste tests
│   ├── text_stats_test.dart               # TextStats tests
│   └── widget_test.dart                   # Widget tests
├── pubspec.yaml                           # Package definition
├── README.md                              # User documentation
├── ARCHITECTURE.md                        # This document
├── INTEGRATION.md                         # Integration guide
├── CHANGELOG.md                           # Version history
└── LICENSE                                # MIT License
```

---

## Technology Stack

### Flutter Side
| Technology | Version | Purpose |
|------------|---------|---------|
| Flutter | 3.x | UI framework |
| Dart | ^3.5.0 | Programming language |
| google_fonts | ^6.2.1 | Font loading |
| pointer_interceptor | ^0.10.1 | Click handling with iframes |

### JavaScript Side
| Technology | Version | Purpose |
|------------|---------|---------|
| Quill.js | 2.0.0 | Rich text editor core |
| quill-table-better | 1.x | Table editing support |
| ES Modules | - | Code organization |

### External Resources (CDN)
- Quill.js CSS & JS
- quill-table-better CSS & JS
- Google Fonts (Crimson Pro, DM Sans, Roboto, Open Sans, Lato, Montserrat, Source Code Pro)

---

## Security Considerations

### 1. IFrame Isolation
The Quill editor runs in an isolated iframe, providing:
- Separate JavaScript execution context
- Protection from script injection into Flutter layer
- Clean boundary for CSS styling

### 2. PostMessage Security
- Messages are JSON-serialized
- Origin checking can be added for production
- Message type validation on both ends

### 3. HTML Sanitization
- `HtmlCleaner` removes editor artifacts before export
- Prevents internal implementation details from leaking
- Cleans selection classes, data attributes, and tool elements

### 4. Content Security
- User input is processed through Quill's Delta format
- HTML conversion uses Quill's clipboard module
- Inline styles are normalized (e.g., colors to hex)

---

## Performance Considerations

### 1. Message Throttling
Content change events are throttled (200ms) to prevent flooding Flutter with updates during rapid typing.

### 2. Lazy Initialization
The editor initializes content only after the iframe is fully loaded, preventing race conditions.

### 3. Command Queuing
Commands sent before the editor is ready are queued and retried after a delay.

### 4. Zoom Optimization
Zoom is applied via CSS transform with width adjustment to prevent horizontal overflow.

---

## Extensibility Points

### 1. Custom HTML Files
Provide custom `editorHtmlPath` or `viewerHtmlPath` to use modified editor configurations.

### 2. Font Configuration
Extend `AppFonts` and JavaScript `config.js` to add custom fonts.

### 3. Toolbar Customization
Modify `TOOLBAR_OPTIONS` in `config.js` to customize the toolbar.

### 4. Custom Commands
Add new command types in both `commands.js` and `QuillEditorWidgetState`.

### 5. Theme Customization
Override `AppTheme` and CSS files for custom styling.

---

## Version Information

| Component | Version |
|-----------|---------|
| Package | 1.0.0 |
| Quill.js | 2.0.0 |
| quill-table-better | 1.x |
| Dart SDK | ^3.5.0 |

---

*Document Version: 1.0.0*
*Last Updated: December 2024*

