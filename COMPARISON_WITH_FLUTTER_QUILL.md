
# Comparison: quill_web_editor vs flutter_quill

This document provides a detailed comparison between `quill_web_editor` (this package) and `flutter_quill` (the official Flutter Quill package).

## Executive Summary

| Aspect | quill_web_editor | flutter_quill |
|--------|------------------|---------------|
| **Platform** | Web only | Android, iOS, Web, Desktop (multi-platform) |
| **Architecture** | Iframe + Quill.js (native JS) | Flutter widgets (native Dart) |
| **Core Technology** | Quill.js 2.0 + HTML/JS | Flutter rendering engine |
| **Data Format** | HTML + Delta | Delta (primary), HTML (conversion) |
| **Bundle Size** | Smaller (leverages browser) | Larger (includes rendering) |
| **Performance** | Native browser performance | Flutter rendering performance |
| **Customization** | CSS/JS customization | Flutter widget customization |

---

## 1. Platform Support

### flutter_quill
- ✅ **Android** - Native Flutter implementation
- ✅ **iOS** - Native Flutter implementation  
- ✅ **Web** - Flutter web rendering
- ✅ **Linux** - Desktop support
- ✅ **macOS** - Desktop support
- ✅ **Windows** - Desktop support

### quill_web_editor
- ✅ **Web only** - Optimized specifically for Flutter Web
- ❌ **Mobile** - Not supported
- ❌ **Desktop** - Not supported

**Winner:** `flutter_quill` for multi-platform support, `quill_web_editor` for web-specific optimization.

---

## 2. Architecture Differences

### flutter_quill
```
┌─────────────────────────────────────┐
│      Flutter Widget Tree           │
│  ┌───────────────────────────────┐ │
│  │   QuillEditor (Flutter)       │ │
│  │   - Renders using Flutter     │ │
│  │   - Custom toolbar widgets    │ │
│  │   - Platform-specific APIs    │ │
│  └───────────────────────────────┘ │
└─────────────────────────────────────┘
         ↓ Uses
┌─────────────────────────────────────┐
│   Quill Delta Format (Dart)        │
│   - Document model                  │
│   - Operations                      │
└─────────────────────────────────────┘
```

**Key Characteristics:**
- Pure Flutter/Dart implementation
- Uses Flutter's rendering engine
- Platform-specific plugins (`quill_native_bridge`, `url_launcher`)
- Custom toolbar built with Flutter widgets
- Requires platform-specific setup (Android manifest, etc.)

### quill_web_editor
```
┌─────────────────────────────────────┐
│      Flutter Widget (Web)          │
│  ┌───────────────────────────────┐ │
│  │   QuillEditorWidget           │ │
│  │   - Embeds iframe             │ │
│  │   - PostMessage communication │ │
│  └───────────────────────────────┘ │
└─────────────────────────────────────┘
         ↓ Communicates via
┌─────────────────────────────────────┐
│   HTML iframe + Quill.js            │
│   - Native Quill.js 2.0             │
│   - Full Quill.js toolbar           │
│   - Browser-native rendering        │
│   - CSS/JS customization            │
└─────────────────────────────────────┘
```

**Key Characteristics:**
- Hybrid approach: Flutter wrapper + native Quill.js
- Uses browser's native rendering
- Communication via `postMessage` API
- Leverages Quill.js ecosystem directly
- No platform-specific setup needed

**Winner:** Depends on use case - `flutter_quill` for native Flutter feel, `quill_web_editor` for web-native performance.

---

## 3. Feature Comparison

### Core Editing Features

| Feature | flutter_quill | quill_web_editor | Notes |
|---------|---------------|------------------|-------|
| **Rich Text Formatting** | ✅ | ✅ | Both support bold, italic, underline, etc. |
| **Headers** | ✅ | ✅ | Both support H1-H6 |
| **Lists** | ✅ | ✅ | Ordered and unordered |
| **Links** | ✅ | ✅ | Hyperlink support |
| **Images** | ✅ (via extensions) | ✅ | Native support |
| **Videos** | ✅ (via extensions) | ✅ | Native support |
| **Tables** | ✅ (via extensions) | ✅ | Uses quill-table-better |
| **Code Blocks** | ✅ | ✅ | Inline and block code |
| **Blockquotes** | ✅ | ✅ | Quote formatting |
| **Text Alignment** | ✅ | ✅ | Left, center, right, justify |
| **Text Color** | ✅ | ✅ | Foreground color |
| **Background Color** | ✅ | ✅ | Highlight color |
| **Undo/Redo** | ✅ | ✅ | Both support |
| **Emoji** | ✅ | ✅ | Emoji picker support |
| **Checklists** | ✅ | ✅ | Task lists |

### Advanced Features

| Feature | flutter_quill | quill_web_editor | Notes |
|---------|---------------|------------------|-------|
| **Custom Fonts** | ✅ (via config) | ✅ | 7 built-in fonts + custom |
| **Font Sizes** | ✅ | ✅ | Multiple size options |
| **Line Heights** | ✅ | ✅ | 1.0 - 3.0 range |
| **Zoom Controls** | ❌ | ✅ | 50% - 300% zoom |
| **HTML Export** | ⚠️ (via packages) | ✅ | Built-in with cleaning |
| **HTML Import** | ⚠️ (via packages) | ✅ | Built-in paste handling |
| **Preview Mode** | ✅ (readOnly) | ✅ | Full-screen preview |
| **Print Support** | ❌ | ✅ | Print-ready HTML |
| **Local Storage** | ❌ | ✅ | Draft saving |
| **Clipboard Operations** | ✅ (native bridge) | ✅ | Copy/paste utilities |
| **Document Stats** | ❌ | ✅ | Word/character counts |
| **Media Resize** | ⚠️ | ✅ | Drag handles for images/videos |
| **Table Resize** | ⚠️ | ✅ | Column/row resizing |
| **Drag & Drop** | ⚠️ | ✅ | File drop support |

**Winner:** `quill_web_editor` has more web-specific features (zoom, HTML export, preview, stats).

---

## 4. API Comparison

### flutter_quill

```dart
// Controller-based approach
QuillController _controller = QuillController.basic();

// Widgets
QuillSimpleToolbar(
  controller: _controller,
  config: const QuillSimpleToolbarConfig(),
),
QuillEditor.basic(
  controller: _controller,
  config: const QuillEditorConfig(),
)

// Access content
_controller.document.toDelta()  // Get Delta
_controller.document.toPlainText()  // Get plain text
_controller.readOnly = true  // Toggle read-only
```

**Characteristics:**
- Controller-based state management
- Separate toolbar widget
- Delta-focused API
- Flutter widget composition

### quill_web_editor

```dart
// State-based approach
final GlobalKey<QuillEditorWidgetState> _editorKey = GlobalKey();

// Single widget (toolbar included)
QuillEditorWidget(
  key: _editorKey,
  onContentChanged: (html, delta) {
    // Handle changes
  },
  initialHtml: '<p>Start...</p>',
)

// Access content via state methods
_editorKey.currentState?.setHTML(html)
_editorKey.currentState?.insertText(text)
_editorKey.currentState?.undo()
_editorKey.currentState?.zoomIn()
_editorKey.currentState?.getContents()  // Triggers callback
```

**Characteristics:**
- State-based control via GlobalKey
- All-in-one widget (toolbar in HTML)
- HTML + Delta dual format
- Method-based API

**Winner:** `flutter_quill` for Flutter-native patterns, `quill_web_editor` for simpler web integration.

---

## 5. Data Format & Storage

### flutter_quill

**Primary Format:** Quill Delta (JSON)
```dart
// Save
final json = jsonEncode(_controller.document.toDelta().toJson());

// Load
_controller.document = Document.fromJson(jsonDecode(json));
```

**HTML Conversion:**
- Requires external packages (`vsc_quill_delta_to_html`, `flutter_quill_delta_from_html`)
- Not recommended for storage (see [flutter_quill docs](https://pub.dev/packages/flutter_quill))
- Lossy conversion

### quill_web_editor

**Dual Format:** HTML + Delta
```dart
// Save HTML
onContentChanged: (html, delta) {
  // html: Clean HTML string
  // delta: Quill Delta object
}

// Load HTML
_editorKey.currentState?.setHTML(html);

// Load Delta
_editorKey.currentState?.setContents(delta);
```

**HTML Features:**
- Built-in HTML cleaning (`HtmlCleaner.cleanForExport`)
- Export-ready HTML with styles
- Direct HTML import/export
- HTML preview and print

**Winner:** `quill_web_editor` for HTML-first workflows, `flutter_quill` for Delta-first workflows.

---

## 6. Customization & Theming

### flutter_quill

**Customization:**
- Flutter widget customization
- Custom toolbar buttons
- Custom embed blocks
- Platform-specific styling
- Material/Cupertino themes

```dart
QuillSimpleToolbar(
  controller: _controller,
  config: QuillSimpleToolbarConfig(
    // Customize toolbar
    buttonOptions: QuillSimpleToolbarButtonOptions(...),
  ),
)
```

### quill_web_editor

**Customization:**
- CSS-based styling
- JavaScript module overrides
- HTML template customization
- Custom fonts via CSS
- Modular architecture

```css
/* Custom styles */
.ql-editor {
  font-family: 'Custom Font', sans-serif;
}
```

```javascript
// Custom JavaScript overrides
// web/js/config-override.js
// web/js/quill-setup-override.js
```

**Winner:** `flutter_quill` for Flutter-native theming, `quill_web_editor` for CSS/JS flexibility.

---

## 7. Performance Considerations

### flutter_quill

**Pros:**
- Consistent performance across platforms
- Flutter's optimized rendering
- No iframe overhead

**Cons:**
- Larger bundle size (Flutter engine)
- Web performance may lag native JS
- Requires compilation for web

### quill_web_editor

**Pros:**
- Native browser performance
- Smaller Flutter bundle (delegates to browser)
- Leverages browser optimizations
- No compilation needed for Quill.js

**Cons:**
- Iframe communication overhead
- PostMessage latency
- Limited to web platform

**Winner:** `quill_web_editor` for web performance, `flutter_quill` for cross-platform consistency.

---

## 8. Bundle Size

### flutter_quill
- Includes Flutter rendering engine
- Platform-specific plugins
- Custom toolbar widgets
- **Estimated:** ~500KB+ (compressed)

### quill_web_editor
- Minimal Flutter wrapper
- Quill.js loaded from CDN or bundled
- HTML/CSS/JS assets
- **Estimated:** ~200KB+ (compressed) + Quill.js CDN

**Winner:** `quill_web_editor` for smaller Flutter bundle.

---

## 9. Setup & Configuration

### flutter_quill

**Setup Steps:**
1. Add dependency to `pubspec.yaml`
2. Add localization delegates
3. Configure Android manifest (for image clipboard)
4. Create `file_paths.xml` (Android)
5. Initialize controller
6. Add widgets to tree

**Platform-Specific:**
- Android: FileProvider configuration
- iOS: Info.plist permissions
- Web: Standard Flutter web setup

### quill_web_editor

**Setup Steps:**
1. Add dependency to `pubspec.yaml`
2. Copy HTML files to `web/` directory
3. Use widget directly

**Platform-Specific:**
- Web only - no platform config needed

**Winner:** `quill_web_editor` for simpler setup (web only).

---

## 10. Use Case Recommendations

### Choose flutter_quill if:
- ✅ You need **multi-platform support** (mobile + web + desktop)
- ✅ You want **Flutter-native UI** and theming
- ✅ You prefer **Delta format** for storage
- ✅ You need **platform-specific features** (native clipboard, file picker)
- ✅ You want **consistent UX** across platforms
- ✅ You're building a **Flutter-first** application

### Choose quill_web_editor if:
- ✅ You're building **web-only** applications
- ✅ You need **HTML import/export** capabilities
- ✅ You want **native browser performance**
- ✅ You prefer **CSS/JS customization**
- ✅ You need **web-specific features** (zoom, print, preview)
- ✅ You want **smaller bundle size**
- ✅ You're integrating with **existing HTML/JS workflows**

---

## 11. Migration Considerations

### From flutter_quill to quill_web_editor

**Challenges:**
- ❌ Loses mobile/desktop support
- ❌ Different API (controller → state methods)
- ❌ HTML-first vs Delta-first
- ❌ Widget-based → iframe-based

**Benefits:**
- ✅ Better web performance
- ✅ HTML export built-in
- ✅ More web-specific features

### From quill_web_editor to flutter_quill

**Challenges:**
- ❌ Different API (state methods → controller)
- ❌ HTML conversion required
- ❌ Platform setup needed
- ❌ Different customization approach

**Benefits:**
- ✅ Multi-platform support
- ✅ Flutter-native integration
- ✅ Better mobile experience

---

## 12. Feature Parity Matrix

| Feature Category | flutter_quill | quill_web_editor | Gap Analysis |
|------------------|---------------|------------------|--------------|
| **Core Editing** | ✅ | ✅ | Parity |
| **Formatting** | ✅ | ✅ | Parity |
| **Media** | ✅ (extensions) | ✅ | Parity |
| **Tables** | ✅ (extensions) | ✅ | Parity |
| **Customization** | ✅ (Flutter) | ✅ (CSS/JS) | Different approaches |
| **Export** | ⚠️ (packages) | ✅ (built-in) | quill_web_editor advantage |
| **Web Features** | ⚠️ | ✅ | quill_web_editor advantage |
| **Mobile Features** | ✅ | ❌ | flutter_quill advantage |
| **Desktop Features** | ✅ | ❌ | flutter_quill advantage |

---

## 13. Conclusion

### Summary

**flutter_quill** is the **comprehensive, multi-platform solution** that provides:
- Native Flutter integration
- Cross-platform support
- Flutter-native customization
- Delta-focused data model

**quill_web_editor** is the **web-optimized solution** that provides:
- Native browser performance
- HTML-first workflow
- Web-specific features
- Simpler web setup

### Final Recommendation

- **Multi-platform app:** Use `flutter_quill`
- **Web-only app:** Use `quill_web_editor` for better performance and features
- **HTML-heavy workflow:** Use `quill_web_editor`
- **Delta-focused workflow:** Use `flutter_quill`
- **Need mobile support:** Use `flutter_quill`

Both packages are excellent choices for their respective use cases. The decision should be based on your platform requirements, performance needs, and data format preferences.

---

## References

- [flutter_quill Package](https://pub.dev/packages/flutter_quill)
- [Quill.js Documentation](https://quilljs.com/)
- [quill_web_editor README](README.md)
- [quill_web_editor Developer Guide](DEVELOPER_GUIDE.md)

