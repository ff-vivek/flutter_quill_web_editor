# Plan: Making Example Folder Lean

## Current Situation Analysis

### Current Structure
- **Main Package (`web/`)**: 22 files (HTML, JS, CSS)
- **Example App (`example/web/`)**: 21 files (duplicates + `mulish-font.css`)
- **Duplication**: Example has copies of all JS and CSS files from main package

### Key Findings from Documentation

1. **Package Assets**: Only `web/quill_editor.html` and `web/quill_viewer.html` are declared as assets in main package's `pubspec.yaml`
2. **JS/CSS Files**: NOT declared as assets, so they're NOT automatically available at runtime
3. **Documentation Principle**: "You don't need to copy entire package CSS files - only write overrides"
4. **CSS Cascade**: Browser merges package CSS and custom CSS automatically

## Plan: Two Approaches

### Approach 1: Reference Package Assets (Recommended)

**Goal**: Example app references package's web files instead of duplicating them.

#### Step 1: Declare JS and CSS as Assets in Main Package

**File**: `pubspec.yaml` (main package)

**Add to assets section**:
```yaml
flutter:
  assets:
    - web/quill_editor.html
    - web/quill_viewer.html
    - web/js/          # Add entire JS directory
    - web/styles/      # Add entire styles directory (except mulish-font.css)
```

**Rationale**: Makes package's JS and CSS files available at runtime at:
- `assets/packages/quill_web_editor/web/js/*.js`
- `assets/packages/quill_web_editor/web/styles/*.css`

#### Step 2: Update Package HTML Files to Use Asset Paths

**Files**: `web/quill_editor.html`, `web/quill_viewer.html`

**Change relative paths to asset paths**:
```html
<!-- Before -->
<link rel="stylesheet" href="styles/base.css">
<script type="module">
  import { initializeQuill } from './js/quill-setup.js';
</script>

<!-- After -->
<link rel="stylesheet" href="assets/packages/quill_web_editor/web/styles/base.css">
<script type="module">
  import { initializeQuill } from './assets/packages/quill_web_editor/web/js/quill-setup.js';
</script>
```

**OR** use a base path approach:
```html
<base href="assets/packages/quill_web_editor/web/">
```

#### Step 3: Create Minimal Example HTML Files

**File**: `example/web/quill_editor.html` (NEW - wrapper)

```html
<!DOCTYPE html>
<html>
<head>
  <base href="assets/packages/quill_web_editor/web/">
  <!-- Load package HTML content via iframe or redirect -->
  <!-- OR use package HTML directly -->
</head>
<body>
  <!-- Minimal wrapper -->
</body>
</html>
```

**OR** simpler: Just reference package HTML directly in Flutter widget config.

#### Step 4: Keep Only Custom Files in Example

**Keep in `example/web/`**:
- `index.html` - Flutter app entry point
- `styles/mulish-font.css` - Custom font (only override needed)
- `quill_editor.html` - Wrapper OR reference to package
- `quill_viewer.html` - Wrapper OR reference to package

**Remove from `example/web/`**:
- `js/` folder (entire directory) - Use package's JS
- `styles/` folder (except `mulish-font.css`) - Use package's CSS

#### Step 5: Update Example HTML to Load Custom CSS After Package CSS

**File**: `example/web/quill_editor.html` (if wrapper approach)

```html
<!-- Load package CSS first -->
<link rel="stylesheet" href="assets/packages/quill_web_editor/web/styles/base.css">
<link rel="stylesheet" href="assets/packages/quill_web_editor/web/styles/fonts.css">
<!-- ... other package CSS ... -->

<!-- Load custom CSS after (for override precedence) -->
<link rel="stylesheet" href="styles/mulish-font.css">
```

---

### Approach 2: Keep Current Structure but Optimize (Simpler)

**Goal**: Keep duplicates but remove unnecessary files and optimize structure.

#### Step 1: Remove Duplicate Files That Match Package Exactly

**Action**: Compare files and remove exact duplicates, keeping only:
- Files that differ from package
- Custom files (`mulish-font.css`)

#### Step 2: Use Symbolic Links (if supported)

**Action**: Create symlinks from example to package for identical files
```bash
ln -s ../../web/js example/web/js
ln -s ../../web/styles example/web/styles
```

**Note**: May not work well with Flutter build system

#### Step 3: Document Why Duplication Exists

**File**: `example/README.md` (NEW)

Explain that:
- Package JS/CSS aren't assets, so they must be copied
- Example demonstrates complete setup
- Users should copy these files to their own projects

---

## Recommended Approach: Hybrid Solution

### Phase 1: Make Package Assets Available

1. **Update main package `pubspec.yaml`**:
   ```yaml
   assets:
     - web/quill_editor.html
     - web/quill_viewer.html
     - web/js/
     - web/styles/
   ```

2. **Update package HTML files** to use absolute asset paths OR keep relative paths (they'll work when HTML is loaded from package location)

### Phase 2: Simplify Example

1. **Keep example HTML files** but update them to:
   - Reference package CSS/JS via asset paths
   - Only include custom CSS (`mulish-font.css`)

2. **Remove duplicate JS/CSS** from example

3. **Update Flutter widget** to use package HTML paths:
   ```dart
   QuillEditorWidget(
     editorHtmlPath: 'assets/packages/quill_web_editor/web/quill_editor.html',
   )
   ```

### Phase 3: Create Custom Override File

**File**: `example/web/styles/mulish-overrides.css` (rename from `mulish-font.css`)

This file demonstrates the documentation's principle:
- Only contains customizations (Mulish font)
- Loads after package CSS
- Minimal and focused

---

## File Removal/Addition Plan

### Files to REMOVE from `example/web/`:

1. **`js/` directory** (entire folder - 10 files)
   - `clipboard.js`
   - `commands.js`
   - `config.js`
   - `drag-drop.js`
   - `flutter-bridge.js`
   - `media-resize.js`
   - `quill-setup.js`
   - `table-resize.js`
   - `utils.js`
   - `viewer.js`

2. **`styles/` directory files** (except `mulish-font.css`):
   - `base.css`
   - `fonts.css`
   - `media.css`
   - `quill-theme.css`
   - `sizes.css`
   - `tables.css`
   - `viewer.css`

### Files to KEEP in `example/web/`:

1. **`index.html`** - Flutter app entry point
2. **`quill_editor.html`** - Updated to reference package assets
3. **`quill_viewer.html`** - Updated to reference package assets  
4. **`styles/mulish-font.css`** - Custom font override (only customization)

### Files to ADD/MODIFY:

1. **`example/web/quill_editor.html`** - Update paths to reference package assets
2. **`example/web/quill_viewer.html`** - Update paths to reference package assets
3. **`pubspec.yaml` (main package)** - Add JS and CSS as assets
4. **`example/README.md`** - Document the lean structure

---

## Referencing Strategy

### Option A: Absolute Asset Paths

**In `example/web/quill_editor.html`**:
```html
<!-- Package CSS -->
<link rel="stylesheet" href="assets/packages/quill_web_editor/web/styles/base.css">
<link rel="stylesheet" href="assets/packages/quill_web_editor/web/styles/fonts.css">
<!-- ... -->

<!-- Package JS -->
<script type="module">
  import { initializeQuill } from './assets/packages/quill_web_editor/web/js/quill-setup.js';
</script>

<!-- Custom CSS (loads last) -->
<link rel="stylesheet" href="styles/mulish-font.css">
```

### Option B: Base Tag Approach

**In `example/web/quill_editor.html`**:
```html
<head>
  <base href="assets/packages/quill_web_editor/web/">
  <!-- Then use relative paths -->
  <link rel="stylesheet" href="styles/base.css">
  <!-- Custom CSS override -->
  <link rel="stylesheet" href="../styles/mulish-font.css">
</head>
```

### Option C: Use Package HTML Directly

**In Flutter widget**:
```dart
QuillEditorWidget(
  editorHtmlPath: 'assets/packages/quill_web_editor/web/quill_editor.html',
)
```

**Then create wrapper HTML** that loads custom CSS:
```html
<!-- example/web/quill_editor_wrapper.html -->
<link rel="stylesheet" href="assets/packages/quill_web_editor/web/styles/base.css">
<!-- ... all package CSS ... -->
<link rel="stylesheet" href="styles/mulish-font.css"> <!-- Custom override -->
```

---

## Implementation Steps

### Step 1: Update Main Package Assets
- [ ] Add `web/js/` to `pubspec.yaml` assets
- [ ] Add `web/styles/` to `pubspec.yaml` assets
- [ ] Verify build includes these files

### Step 2: Update Package HTML Files (if needed)
- [ ] Check if relative paths work when HTML is loaded as asset
- [ ] Update to absolute paths if needed
- [ ] Test in example app

### Step 3: Update Example HTML Files
- [ ] Update `quill_editor.html` to reference package assets
- [ ] Update `quill_viewer.html` to reference package assets
- [ ] Ensure custom CSS loads after package CSS

### Step 4: Remove Duplicate Files
- [ ] Delete `example/web/js/` directory
- [ ] Delete duplicate CSS files from `example/web/styles/`
- [ ] Keep only `mulish-font.css`

### Step 5: Update Flutter Widget Configuration
- [ ] Update `editorHtmlPath` to use package asset path
- [ ] Update `viewerHtmlPath` to use package asset path
- [ ] Test functionality

### Step 6: Documentation
- [ ] Create `example/README.md` explaining lean structure
- [ ] Update main README with example structure
- [ ] Document the customization approach

---

## Expected Outcome

### Before:
```
example/web/
├── index.html
├── quill_editor.html
├── quill_viewer.html
├── js/ (10 files - duplicates)
└── styles/ (8 files - duplicates)
```

### After:
```
example/web/
├── index.html
├── quill_editor.html (references package assets)
├── quill_viewer.html (references package assets)
└── styles/
    └── mulish-font.css (only custom file)
```

**Reduction**: From 21 files to ~4 files (81% reduction)

---

## Benefits

1. ✅ **Follows Documentation Principles**: Only custom CSS, not entire package CSS
2. ✅ **Easier Maintenance**: Changes to package JS/CSS automatically reflected
3. ✅ **Clearer Example**: Shows only what users need to customize
4. ✅ **Smaller Example**: Reduced file count and size
5. ✅ **Better Demonstration**: Shows proper asset referencing

---

## Risks & Considerations

1. **Asset Path Resolution**: Need to verify paths work in WebView context
2. **Build System**: Flutter build may handle assets differently
3. **Testing**: Need to test that all functionality still works
4. **Documentation**: Users may be confused if example structure differs from integration docs

---

## Alternative: Keep Current Structure

If the above approach is too complex, we can:
1. Keep current duplication
2. Add comments explaining why
3. Document that this is for demonstration purposes
4. Focus on making the example clearer rather than leaner


