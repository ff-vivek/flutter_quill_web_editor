# Deployment Quick Reference

## Files to Host

### Required Files
```
quill_editor.html              # Main editor HTML
quill_viewer.html              # Viewer HTML
js/
  ├── quill-setup-override.js
  ├── clipboard-override.js
  ├── config-override.js
  └── utils-override.js
styles/
  └── mulish-font.css
assets/packages/quill_web_editor/web/
  ├── js/                      # Package JavaScript files
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
  └── styles/                  # Package CSS files
      ├── base.css
      ├── fonts.css
      ├── media.css
      ├── quill-theme.css
      ├── sizes.css
      ├── tables.css
      └── viewer.css
```

### Optional Files
```
fonts/                         # Only if hosting fonts locally
  └── Mulish-*.ttf
```

**⚠️ Important:** Package assets (`assets/packages/quill_web_editor/web/`) are required when hosting HTML files on a CDN separate from your Flutter app. Copy from `example/build/web/assets/packages/quill_web_editor/web/`.

## Recommended Folder Structure

```
https://your-cdn.com/quill-editor/
├── quill_editor.html
├── quill_viewer.html
├── js/
│   ├── quill-setup-override.js
│   ├── clipboard-override.js
│   ├── config-override.js
│   └── utils-override.js
├── styles/
│   └── mulish-font.css
├── assets/
│   └── packages/
│       └── quill_web_editor/
│           └── web/
│               ├── js/        # 10 JS files
│               └── styles/    # 7 CSS files
└── fonts/                    # Optional
    └── Mulish-*.ttf
```

## Usage in Flutter

```dart
QuillEditorWidget(
  editorHtmlPath: 'https://your-cdn.com/quill-editor/quill_editor.html',
  viewerHtmlPath: 'https://your-cdn.com/quill-editor/quill_viewer.html',
  onContentChanged: (html, delta) {
    // Handle changes
  },
)
```

## Path Resolution

- **Relative paths** (`./js/`, `styles/`) resolve relative to HTML file location
- **Package assets** (`/assets/packages/...`) resolve from Flutter app's web root
- **CDN resources** (Quill.js, Google Fonts) load from external CDN

## Hosting Requirements

- ✅ HTTPS enabled
- ✅ CORS headers configured (if different domain)
- ✅ Correct MIME types
- ✅ Proper file structure maintained

## Quick Checklist

- [ ] Copy HTML files from `example/web/` to hosting location
- [ ] Copy custom JS/CSS from `example/web/` to hosting location
- [ ] **Copy package assets** from `example/build/web/assets/packages/quill_web_editor/web/` to hosting location
- [ ] Maintain folder structure (js/, styles/, assets/)
- [ ] Configure CORS (if needed)
- [ ] Test HTML files load in browser
- [ ] Verify all assets load (check browser console)
- [ ] Update Flutter app with hosted URLs
- [ ] Test editor functionality

## Common Hosting Solutions

- **AWS S3 + CloudFront**
- **Firebase Hosting**
- **Netlify / Vercel**
- **GitHub Pages**
- **Self-hosted (Nginx/Apache)**

See [DEPLOYMENT.md](./DEPLOYMENT.md) for detailed instructions.

