# Quill Web Editor - Example Application

This example application demonstrates the features and capabilities of the **Quill Web Editor** Flutter package.

## 🚀 Getting Started

### Prerequisites

- Flutter SDK ^3.5.0
- Dart SDK ^3.5.0
- Web browser (Chrome, Firefox, Safari, Edge)

### Running the Example

```bash
cd example
flutter pub get
flutter run -d chrome
```

## 📱 Example Pages

The example app includes three demonstration pages accessible from the home screen:

### 1. Full Editor (`EditorExamplePage`)

A complete editor implementation showcasing all features:

- **Rich text editing** with full toolbar
- **Undo/Redo** buttons with keyboard shortcuts
- **Zoom controls** (50% - 300%)
- **HTML insertion** via dialog
- **Sample content** loading
- **HTML preview** in modal
- **Document download** as HTML file
- **Auto-save simulation** with status indicator
- **Live statistics** (word count, character count)
- **Output preview** panel with HTML/Text tabs

**Key Implementation Details:**

```dart
// Uses GlobalKey for editor access
final GlobalKey<QuillEditorWidgetState> _editorKey = GlobalKey();

// Default font configuration
static const String _defaultFont = 'mulish';

// Editor widget with callbacks
QuillEditorWidget(
  key: _editorKey,
  onContentChanged: _onContentChanged,
  initialHtml: _sampleHtml,
  defaultEditorFont: _defaultFont,
)

// Programmatic operations
_editorKey.currentState?.setHTML(htmlContent);
_editorKey.currentState?.undo();
_editorKey.currentState?.zoomIn();
```

---

### 2. Dropdown Insert (`DropdownInsertExamplePage`)

Demonstrates using `QuillEditorController` to insert content from Flutter dropdowns:

- **Template insertion** - Pre-defined text blocks
- **Variable insertion** - Placeholder tokens like `{{CUSTOMER_NAME}}`
- **Controller-based state management**
- **Reactive UI** with `ChangeNotifier`

**Key Implementation Details:**

```dart
// Controller for programmatic access
final QuillEditorController _editorController = QuillEditorController();

@override
void initState() {
  super.initState();
  _editorController.addListener(_onControllerChanged);
}

@override
void dispose() {
  _editorController.removeListener(_onControllerChanged);
  _editorController.dispose();
  super.dispose();
}

// Editor widget with controller
QuillEditorWidget(
  controller: _editorController,
  onContentChanged: _onContentChanged,
  initialHtml: '<p>Start typing...</p>',
)

// Insert content programmatically
_editorController.insertText('Hello, World!');
```

**Available Templates:**
| Template | Content |
|----------|---------|
| Greeting | "Hello, welcome to our service!" |
| Thank You | "Thank you for your business." |
| Signature | "Best regards,\nThe Team" |
| Disclaimer | Confidentiality notice |
| Contact | Contact information block |

**Available Variables:**
| Variable | Placeholder |
|----------|-------------|
| Customer Name | `{{CUSTOMER_NAME}}` |
| Order ID | `{{ORDER_ID}}` |
| Date | `{{DATE}}` |
| Amount | `{{AMOUNT}}` |
| Product Name | `{{PRODUCT_NAME}}` |
| Company Name | `{{COMPANY_NAME}}` |

---

### 3. Custom Actions (`CustomActionsExamplePage`)

Demonstrates the Custom Actions API for registering and executing user-defined actions:

- **Register reusable actions** with callbacks
- **Execute registered actions** from dropdown
- **One-off actions** without registration
- **Action response handling**
- **Execution counter**

**Key Implementation Details:**

```dart
// Register an action
_editorController.registerAction(
  QuillEditorAction(
    name: 'insertTimestamp',
    parameters: {'format': 'ISO'},
    onExecute: () => debugPrint('Executing: insertTimestamp'),
    onResponse: (response) => _handleActionResponse('Timestamp', response),
  ),
);

// Execute registered action
_editorController.executeAction('insertTimestamp');

// Execute one-off action (without registration)
_editorController.executeCustom(
  action: 'quickNote',
  parameters: {'type': 'note', 'priority': 'high'},
  onResponse: (response) => print('Done'),
);
```

**Available Actions:**
| Action | Description | Content Inserted |
|--------|-------------|------------------|
| Insert Timestamp | Current date/time | 📅 2025-12-30 10:30:45 |
| Insert Divider | Horizontal rule | ────────────────── |
| Insert Warning Box | Warning callout | ⚠️ Warning blockquote |
| Insert Info Box | Info callout | ℹ️ Info blockquote |
| Insert Success Box | Success callout | ✅ Success blockquote |
| Insert Code Block | Code snippet | Dart code template |
| Insert Signature | Signature block | Name, title, date |

---

## 🎨 Custom Font Registration

The example demonstrates registering a custom font (Mulish) with priority-based loading:

```dart
// In main.dart, before runApp()
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Register custom font with three-priority loading
  FontRegistry.instance.registerFont(
    const CustomFontConfig(
      name: 'Mulish',
      value: 'mulish',
      fontFamily: 'Mulish',
      // Priority 1: Hosted fonts (your CDN/server)
      hostedFontBaseUrl: 'https://cdn.example.com/fonts/',
      hostedFontVariants: [
        FontVariant(url: 'Mulish-Regular.ttf', weight: 400, format: 'truetype'),
        FontVariant(url: 'Mulish-Bold.ttf', weight: 700, format: 'truetype'),
        // ... more variants
      ],
      // Priority 2: Google Fonts fallback (if hosted fails)
      googleFontsFamily: 'Mulish:wght@400;500;600;700',
      // Priority 3: System fallback
      fallback: 'sans-serif',
    ),
  );

  runApp(const QuillEditorExampleApp());
}
```

### Font Loading Priority

1. **Hosted Assets** - Load from your CDN/server (fastest, works offline)
2. **Google Fonts** - Fallback if hosted assets fail
3. **System Fallback** - Final fallback (sans-serif, serif, etc.)

---

## 📁 Project Structure

```
example/
├── lib/
│   ├── main.dart                         # App entry point + font registration
│   └── pages/
│       ├── editor_example_page.dart      # Full editor demo
│       ├── dropdown_insert_example_page.dart  # Dropdown insert demo
│       └── custom_actions_example_page.dart   # Custom actions demo
├── web/
│   ├── index.html                        # Flutter web entry point
│   ├── quill_editor.html                 # Editor HTML (copy from package)
│   ├── quill_viewer.html                 # Viewer HTML (copy from package)
│   ├── js/
│   │   ├── config-override.js            # Custom font configuration
│   │   └── ... (copy from package)
│   └── styles/
│       ├── mulish-font.css               # Custom font @font-face
│       └── ... (copy from package)
└── assets/
    └── fonts/                            # Local font files (optional)
```

---

## 🔧 Key Components Used

### Widgets

| Widget | Purpose |
|--------|---------|
| `QuillEditorWidget` | Main rich text editor |
| `QuillEditorController` | Programmatic editor control |
| `ZoomControls` | Zoom in/out/reset UI |
| `SaveStatusIndicator` | Shows save state (saved/saving/unsaved) |
| `OutputPreview` | HTML/Text preview tabs |
| `AppCard` | Styled card container |
| `StatCardRow` | Statistics display row |
| `HtmlPreviewDialog` | Full-screen HTML preview |
| `InsertHtmlDialog` | HTML insertion dialog |

### Services

| Service | Purpose |
|---------|---------|
| `DocumentService` | Download, print, clipboard operations |
| `TextStats` | Word/character counting from HTML |
| `FontRegistry` | Custom font registration |

### Constants

| Constant | Purpose |
|----------|---------|
| `AppColors` | Color palette |
| `AppTheme` | Theme configuration |
| `EditorConfig` | Editor settings (zoom limits, table size, etc.) |

---

## 📋 Features Demonstrated

- ✅ Rich text formatting (bold, italic, underline, strikethrough)
- ✅ Headers (H1-H6)
- ✅ Lists (ordered, bullet, checklist)
- ✅ Blockquotes and code blocks
- ✅ Links and media embedding
- ✅ Tables with resize and header rows
- ✅ Custom fonts via FontRegistry
- ✅ Zoom controls (50%-300%)
- ✅ Undo/Redo with history
- ✅ HTML import/export
- ✅ Controller-based programmatic access
- ✅ Custom actions API
- ✅ Auto-save simulation
- ✅ Document statistics

---

## 📚 Learn More

- [Developer Guide](../DEVELOPER_GUIDE.md) - Complete API documentation
- [Deployment Guide](../doc/DEPLOYMENT.md) - Production deployment instructions
- [Quill.js Documentation](https://quilljs.com/docs/) - Underlying editor

---

*Last Updated: December 2024*  
*Compatible with Quill Web Editor v1.2.0*
