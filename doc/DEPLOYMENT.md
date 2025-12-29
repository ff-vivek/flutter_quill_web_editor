# Deployment Strategy for Quill Web Editor

## Overview

This document outlines the deployment strategy for hosting Quill Web Editor HTML files and their dependencies in a production environment. The editor can be configured to use hosted URLs instead of local files.

## 1. Files to Host

### Build Folder Location

**⚠️ Important:** The build folder location depends on your project type:

- **For normal Flutter projects:** Build folder is at the **root**: `build/web/`
- **For the quill_web_editor package:** Build folder is in the example: `example/build/web/`

The build output automatically contains all required files properly structured.

### Source vs Build Files

**Important:** For deployment, use files from the **build output**, not the source files. The build output contains:
- All HTML files with correct paths
- All custom override files
- All package assets properly bundled
- All fonts (if included)

**Why use build files?**
- Flutter's build process ensures all assets are properly referenced
- Package assets are automatically included in the build output
- Paths are correctly resolved for production use

**Source files location:** 
- Normal Flutter project: `web/` (for development)
- Quill package: `example/web/` (for development)

**Build files location:** 
- Normal Flutter project: `build/web/` (for production deployment)
- Quill package: `example/build/web/` (for production deployment)

---

## 2. Files to Host (Detailed)

### 1.1 Core HTML Files (Required)

These are the main entry points that will be loaded in iframes:

- **`quill_editor.html`** - Main editor interface
- **`quill_viewer.html`** - Read-only viewer interface

### 1.2 JavaScript Override Files (Required)

Custom JavaScript files that extend/override package functionality:

```
js/
├── quill-setup-override.js    # Custom Quill initialization
├── clipboard-override.js      # Custom clipboard/paste handling
├── config-override.js         # Custom configuration (fonts, toolbar)
└── utils-override.js          # Custom utility functions (font mapping, etc.)
```

### 1.3 Custom Styles (Required)

Custom CSS files that override package styles:

```
styles/
└── mulish-font.css            # Custom Mulish font definitions
```

### 1.4 Package Assets (Required for Standalone Hosting)

**⚠️ IMPORTANT:** The HTML files reference package assets using absolute paths (`/assets/packages/quill_web_editor/web/...`). If you're hosting HTML files on a CDN separate from your Flutter app, you **must** also host these package assets.

Package JavaScript files:
```
assets/packages/quill_web_editor/web/js/
├── clipboard.js
├── commands.js
├── config.js
├── drag-drop.js
├── flutter-bridge.js
├── media-resize.js
├── quill-setup.js
├── table-resize.js
├── utils.js
└── viewer.js
```

Package CSS files:
```
assets/packages/quill_web_editor/web/styles/
├── base.css
├── fonts.css
├── media.css
├── quill-theme.css
├── sizes.css
├── tables.css
└── viewer.css
```

**Note:** These files are located in the package's `web/` directory. Copy them from `your_package/web/` or from the Flutter build output at `build/web/assets/packages/quill_web_editor/web/`.

### 1.5 Font Files (Optional - if not using CDN)

If you're hosting fonts locally instead of using CDN:

```
fonts/
├── Mulish-Regular.ttf
├── Mulish-Bold.ttf
├── Mulish-Italic.ttf
└── ... (all Mulish font variants)
```

**Note:** Fonts can also be loaded from CDN or your own font hosting service.

## 3. Recommended Folder Structure

### Option A: Flat Structure (Simple)

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
│               ├── js/
│               │   ├── clipboard.js
│               │   ├── commands.js
│               │   ├── config.js
│               │   ├── drag-drop.js
│               │   ├── flutter-bridge.js
│               │   ├── media-resize.js
│               │   ├── quill-setup.js
│               │   ├── table-resize.js
│               │   ├── utils.js
│               │   └── viewer.js
│               └── styles/
│                   ├── base.css
│                   ├── fonts.css
│                   ├── media.css
│                   ├── quill-theme.css
│                   ├── sizes.css
│                   ├── tables.css
│                   └── viewer.css
└── fonts/                    # Optional
    └── Mulish-*.ttf
```

**Usage:**
```dart
QuillEditorWidget(
  editorHtmlPath: 'https://your-cdn.com/quill-editor/quill_editor.html',
  viewerHtmlPath: 'https://your-cdn.com/quill-editor/quill_viewer.html',
)
```

### Option B: Versioned Structure (Recommended for Production)

```
https://your-cdn.com/quill-editor/
├── v2.0.0/
│   ├── quill_editor.html
│   ├── quill_viewer.html
│   ├── js/
│   │   ├── quill-setup-override.js
│   │   ├── clipboard-override.js
│   │   ├── config-override.js
│   │   └── utils-override.js
│   ├── styles/
│   │   └── mulish-font.css
│   ├── assets/
│   │   └── packages/
│   │       └── quill_web_editor/
│   │           └── web/
│   │               ├── js/
│   │               └── styles/
│   └── fonts/
│       └── Mulish-*.ttf
├── v2.1.0/
│   └── ...
└── latest/                   # Symlink or copy of current version
    └── ...
```

**Usage:**
```dart
QuillEditorWidget(
  editorHtmlPath: 'https://your-cdn.com/quill-editor/v2.0.0/quill_editor.html',
  viewerHtmlPath: 'https://your-cdn.com/quill-editor/v2.0.0/quill_viewer.html',
)
```

### Option C: Domain Root Structure

```
https://quill-editor.yourdomain.com/
├── quill_editor.html
├── quill_viewer.html
├── js/
├── styles/
└── fonts/
```

## 4. Path Resolution and Dependencies

### 3.1 Internal Dependencies

The HTML files reference files using relative paths:

**In `quill_editor.html` and `quill_viewer.html`:**
- `./js/quill-setup-override.js` → Resolves relative to HTML file location
- `styles/mulish-font.css` → Resolves relative to HTML file location
- `../fonts/Mulish-*.ttf` → Resolves relative to `styles/` directory

**Important:** The HTML files have `<base href="/">` which affects path resolution. Ensure:
- If HTML is at `https://cdn.com/quill-editor/quill_editor.html`
- Then `./js/` resolves to `https://cdn.com/quill-editor/js/`
- And `styles/` resolves to `https://cdn.com/quill-editor/styles/`

### 3.2 External Dependencies (CDN)

The HTML files load these from CDN (no hosting needed):

- **Quill.js**: `https://cdn.jsdelivr.net/npm/quill@2.0.0/dist/quill.js`
- **Quill CSS**: `https://cdn.jsdelivr.net/npm/quill@2.0.0/dist/quill.snow.css`
- **Quill Table Better**: `https://cdn.jsdelivr.net/npm/quill-table-better@1/dist/quill-table-better.js`
- **Google Fonts**: `https://fonts.googleapis.com/css2?family=...`

### 3.3 Package Assets (Flutter Package)

The HTML files reference Flutter package assets using absolute paths:

- `/assets/packages/quill_web_editor/web/js/commands.js`
- `/assets/packages/quill_web_editor/web/js/flutter-bridge.js`
- `/assets/packages/quill_web_editor/web/styles/base.css`
- `/assets/packages/quill_web_editor/web/styles/quill-theme.css`
- ... (other package files)

**⚠️ CRITICAL:** These paths are absolute and resolve from the **hosting domain**, not the Flutter app domain.

**Two Deployment Scenarios:**

1. **Same Domain as Flutter App:**
   - If HTML files are hosted on the same domain as your Flutter app, package assets are served from the Flutter app's `/assets/` directory
   - No additional hosting needed for package assets

2. **Different Domain (CDN):**
   - If HTML files are hosted on a CDN separate from your Flutter app, you **must** also host the package assets on the CDN
   - Copy `assets/packages/quill_web_editor/web/` to your CDN maintaining the same folder structure
   - The absolute paths will then resolve correctly from the CDN domain

## 5. Deployment Checklist

### 4.1 Pre-Deployment

#### Step 1: Build the Flutter App

Build your Flutter app to generate all required files:

**For normal Flutter projects:**
```bash
flutter build web
```
This creates a complete build output in `build/web/` with all files properly structured.

**For the quill_web_editor package:**
```bash
cd example
flutter build web
cd ..
```
This creates a complete build output in `example/build/web/` with all files properly structured.

#### Step 2: Copy Deployment Files

Copy files from the build output to your hosting location. The build folder location depends on your project type:
- For normal Flutter projects: `build/web/`
- For quill package: `example/build/web/`

#### Step 3: Copy Files to Hosting Location

Copy the following files/folders from your build output:

**For normal Flutter projects (from `build/web/`):**
- [ ] `quill_editor.html` → `your-cdn/quill-editor/quill_editor.html`
- [ ] `quill_viewer.html` → `your-cdn/quill-editor/quill_viewer.html`
- [ ] `js/` folder → `your-cdn/quill-editor/js/`
- [ ] `styles/` folder → `your-cdn/quill-editor/styles/`
- [ ] `assets/packages/quill_web_editor/web/` → `your-cdn/quill-editor/assets/packages/quill_web_editor/web/` (maintain exact folder structure)

**For quill package (from `example/build/web/`):**
- [ ] `quill_editor.html` → `your-cdn/quill-editor/quill_editor.html`
- [ ] `quill_viewer.html` → `your-cdn/quill-editor/quill_viewer.html`
- [ ] `js/` folder → `your-cdn/quill-editor/js/`
- [ ] `styles/` folder → `your-cdn/quill-editor/styles/`
- [ ] `assets/packages/quill_web_editor/web/` → `your-cdn/quill-editor/assets/packages/quill_web_editor/web/` (maintain exact folder structure)

**Optional - Fonts (if hosting locally):**
- [ ] `assets/assets/fonts/Mulish-*.ttf` → `your-cdn/quill-editor/fonts/Mulish-*.ttf`

#### Step 4: Verify File Structure

Your hosting location should have this structure:

```
your-cdn/quill-editor/
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
│               ├── js/        # 10 files
│               └── styles/    # 7 files
└── fonts/                     # Optional
    └── Mulish-*.ttf
```

#### Step 5: Test and Verify

- [ ] Verify all JavaScript files are present (13 total: 4 custom + 9 package)
- [ ] Verify all CSS files are present (8 total: 1 custom + 7 package)
- [ ] Test HTML files load correctly in browser
- [ ] Check browser console for any 404 errors
- [ ] Verify all paths resolve correctly (both relative and absolute)

### 5.2 Hosting Configuration

- [ ] Configure CORS headers (if hosting on different domain than Flutter app)
- [ ] Enable HTTPS (required for Flutter web)
- [ ] Set appropriate MIME types:
  - `.html` → `text/html`
  - `.js` → `application/javascript`
  - `.css` → `text/css`
  - `.ttf` → `font/ttf`
- [ ] Configure caching headers (optional but recommended):
  - HTML files: Short cache (1 hour) or no cache
  - JS/CSS: Longer cache (1 week) with versioning
  - Fonts: Long cache (1 year)

### 5.3 Testing

- [ ] Test editor loads correctly with hosted URLs
- [ ] Test viewer loads correctly with hosted URLs
- [ ] Verify all JavaScript modules load
- [ ] Verify all stylesheets load
- [ ] Verify fonts load (if hosting locally)
- [ ] Test editor functionality (typing, formatting, etc.)
- [ ] Test Flutter ↔ JavaScript communication

## 6. CORS Configuration

If hosting HTML files on a different domain than your Flutter app, configure CORS:

**Example Nginx configuration:**
```nginx
location /quill-editor/ {
    add_header 'Access-Control-Allow-Origin' '*' always;
    add_header 'Access-Control-Allow-Methods' 'GET, OPTIONS' always;
    add_header 'Access-Control-Allow-Headers' 'Content-Type' always;
}
```

**Example Apache `.htaccess`:**
```apache
<IfModule mod_headers.c>
    Header set Access-Control-Allow-Origin "*"
    Header set Access-Control-Allow-Methods "GET, OPTIONS"
    Header set Access-Control-Allow-Headers "Content-Type"
</IfModule>
```

## 7. Example Hosting Solutions

### 7.1 AWS S3 + CloudFront

**Structure:**
```
s3://your-bucket/quill-editor/
├── quill_editor.html
├── quill_viewer.html
├── js/
└── styles/
```

**Configuration:**
- Enable static website hosting
- Configure CloudFront distribution
- Set up CORS policy
- Use versioned paths for cache invalidation

### 7.2 Firebase Hosting

**Structure:**
```
public/
└── quill-editor/
    ├── quill_editor.html
    ├── quill_viewer.html
    ├── js/
    └── styles/
```

**Configuration:**
- Deploy using `firebase deploy`
- Configure `firebase.json` for proper headers
- Use versioned paths in `hosting.rewrites`

### 7.3 GitHub Pages / Netlify / Vercel

**Structure:**
```
docs/quill-editor/  # or root
├── quill_editor.html
├── quill_viewer.html
├── js/
└── styles/
```

**Configuration:**
- Push files to repository
- Configure build/deploy settings
- Set up custom domain (optional)

### 7.4 Self-Hosted (Nginx/Apache)

**Structure:**
```
/var/www/quill-editor/
├── quill_editor.html
├── quill_viewer.html
├── js/
└── styles/
```

**Configuration:**
- Configure virtual host
- Set up SSL certificate
- Configure CORS headers
- Set up caching

## 8. Integration Example

### 8.1 Development (Local Files)

```dart
QuillEditorWidget(
  // Uses default paths from EditorConfig
  // editorHtmlPath: 'quill_editor.html' (relative to web/)
  // viewerHtmlPath: 'quill_viewer.html' (relative to web/)
  onContentChanged: (html, delta) {
    // Handle content changes
  },
)
```

### 8.2 Production (Hosted Files)

```dart
QuillEditorWidget(
  editorHtmlPath: 'https://cdn.yourdomain.com/quill-editor/v2.0.0/quill_editor.html',
  viewerHtmlPath: 'https://cdn.yourdomain.com/quill-editor/v2.0.0/quill_viewer.html',
  onContentChanged: (html, delta) {
    // Handle content changes
  },
)
```

### 8.3 Environment-Based Configuration

```dart
class EditorConfig {
  static String get editorHtmlPath {
    if (kIsWeb && html.window.location.hostname == 'localhost') {
      return 'quill_editor.html'; // Local development
    }
    return 'https://cdn.yourdomain.com/quill-editor/v2.0.0/quill_editor.html';
  }
  
  static String get viewerHtmlPath {
    if (kIsWeb && html.window.location.hostname == 'localhost') {
      return 'quill_viewer.html'; // Local development
    }
    return 'https://cdn.yourdomain.com/quill-editor/v2.0.0/quill_viewer.html';
  }
}
```

## 9. Versioning Strategy

### 9.1 File Versioning

Use versioned folders to allow gradual rollout and rollback:

```
/quill-editor/
├── v2.0.0/  # Current production
├── v2.1.0/  # New version (testing)
└── latest/  # Symlink to current version
```

### 9.2 Cache Busting

For better cache control, consider:

1. **Query parameters:**
   ```
   https://cdn.com/quill-editor/quill_editor.html?v=2.0.0
   ```

2. **File hashing:**
   ```
   https://cdn.com/quill-editor/quill_editor.2.0.0.html
   ```

3. **Versioned folders (recommended):**
   ```
   https://cdn.com/quill-editor/v2.0.0/quill_editor.html
   ```

## 10. Security Considerations

1. **HTTPS Only:** Always use HTTPS for hosted files
2. **Content Security Policy:** Consider adding CSP headers
3. **Subresource Integrity:** Verify CDN resources with SRI hashes
4. **Access Control:** If needed, implement authentication/authorization
5. **Input Validation:** Ensure Flutter app validates all editor content

## 11. Monitoring and Maintenance

1. **Error Tracking:** Monitor 404 errors for missing files
2. **Performance:** Track load times for HTML and assets
3. **CDN Analytics:** Monitor bandwidth and cache hit rates
4. **Version Updates:** Plan for smooth version transitions
5. **Backup:** Keep backups of all hosted files

## 12. Troubleshooting

### Common Issues

**Issue:** HTML files load but JavaScript doesn't execute
- **Solution:** Check CORS headers and MIME types

**Issue:** Styles not loading
- **Solution:** Verify CSS file paths and CORS configuration

**Issue:** Fonts not loading
- **Solution:** Check font file paths and CORS for font files

**Issue:** Flutter ↔ JavaScript communication fails
- **Solution:** Ensure both are on same origin or CORS is properly configured

**Issue:** Package assets not found (404 errors for `/assets/packages/quill_web_editor/web/...`)
- **Solution:** 
  - If hosting on same domain as Flutter app: Ensure Flutter app is deployed correctly with package assets
  - If hosting on CDN: Copy `assets/packages/quill_web_editor/web/` folder to your CDN maintaining the exact folder structure
  - Verify the absolute paths resolve correctly from your hosting domain

## 13. Migration Guide

### From Local to Hosted

1. **Step 1:** Deploy files to hosting location
2. **Step 2:** Update `editorHtmlPath` and `viewerHtmlPath` in your Flutter app
3. **Step 3:** Test thoroughly in staging environment
4. **Step 4:** Deploy Flutter app with new paths
5. **Step 5:** Monitor for errors and performance issues

### Rollback Plan

1. Keep previous version files available
2. Update paths to point to previous version
3. Redeploy Flutter app
4. Investigate issues before re-deploying new version

