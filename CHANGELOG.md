# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2025-12-29

### Added
- **Custom Font Registration API** - New `FontRegistry` singleton for enterprise font management
  - `CustomFontConfig` class with priority-based loading (hosted → Google Fonts → system fallback)
  - `FontVariant` class for defining font weight/style variants
  - `registerFont()` / `registerFonts()` for adding custom fonts
  - Auto-generates @font-face CSS for hosted fonts
  - Auto-generates Google Fonts URL for fallback fonts
  - `generateLoadingStrategySummary()` for debugging font configuration
- **Default Font Support** - Configure a default font for the editor
- **FOUC Prevention** - Enhanced font loading experience to prevent Flash of Unstyled Content
- **Enterprise User Guide** - Comprehensive documentation for end users covering all editor features

### Fixed
- Fixed content replacement logic in `handleCommand` to ensure proper table module initialization when setting HTML content

### Changed
- Simplified font handling by removing unused font configurations
- Updated Google Fonts integration to be more modular

## [1.1.0] - 2025-12-23

### Added
- **QuillEditorController** - New controller-based state management for the editor
  - Similar to `TextEditingController`, eliminates need for `GlobalKey`
  - Provides reactive updates via `ChangeNotifier`
  - Properties: `isReady`, `html`, `currentZoom`, `registeredActionNames`
- **Controllerless mode** - Widget works without a controller (like `TextField`)
  - Internal controller created automatically when not provided
  - Just use callbacks for simple use cases
  - Provide your own controller only when you need programmatic access
- **Custom Actions API** - Register and execute user-defined actions
  - `QuillEditorAction` class for defining reusable actions
  - `registerAction()` / `registerActions()` for registering actions
  - `executeAction()` for executing registered actions with parameter merging
  - `executeCustom()` for one-off actions without registration
  - Action callbacks: `onExecute`, `onResponse`
  - JavaScript-side custom action handler support
- **Command Queue** - Proper FIFO queue for commands when editor not ready
  - Commands queued in order, processed when editor becomes ready
  - Maximum queue size (100) prevents memory issues
  - Proper cleanup on widget disposal
- **New Example Pages**
  - Dropdown Insert example - demonstrates inserting values from Flutter dropdowns
  - Custom Actions example - demonstrates registering and executing custom actions
- **45 new unit tests** for `QuillEditorController` and `QuillEditorAction`

### Changed
- Updated home page to show all three example options
- Example pages now use `QuillEditorController` instead of `GlobalKey`

## [1.0.2] - 2025-12-19

### Fixed
- Fixed issues with pub publishing.

## [1.0.1] - 2025-12-19

### Fixed
- Corrected dependency constraints for `google_fonts`.
- Renamed `docs` directory to `doc` to follow pub.dev conventions.
- Updated `.gitignore` to exclude unnecessary files from the package.
- Fixed deprecated `withOpacity()` calls - replaced with `withValues()` for Flutter compatibility.
- Removed invalid lint rule `use_late_for_private_fields_used_only_in_tests` from analysis_options.yaml.
- Suppressed `dart:html` deprecation warnings (intentional for web-only package).
- Replaced `print()` with `debugPrint()` in example code.

### Changed
- Updated repository URLs to point to `https://github.com/ff-vivek/flutter_quill_web_editor`.
- Updated README with live playground link: https://flourishing-lollipop-18e8de.netlify.app/.
- Added `example` field to pubspec.yaml for pub.dev.
- Updated `.pubignore` to exclude build artifacts, publish script, and deployment files.
- Package size reduced from 901 KB to 65 KB by excluding unnecessary files.

## [1.0.0] - 2024-12-17

### Added
- Initial release of Quill Web Editor package
- `QuillEditorWidget` - Main editor widget with bidirectional Flutter-JS communication
- Rich text editing with Quill.js 2.0
- Table support with quill-table-better
- Custom fonts (Roboto, Open Sans, Lato, Montserrat, Source Code Pro, Crimson Pro, DM Sans)
- Font sizes (small, normal, large, huge)
- Media embedding (images, videos, iframes) with resize controls
- Media alignment (left, center, right)
- Zoom controls (0.5x to 3.0x)
- HTML import/export with clean output
- Preview functionality
- `SaveStatusIndicator` widget for save state display
- `ZoomControls` widget for zoom management
- `OutputPreview` widget with HTML/text tabs
- `StatCard` and `StatCardRow` for statistics display
- `AppCard` styled card component
- `HtmlPreviewDialog` for full-screen HTML preview
- `InsertHtmlDialog` for HTML insertion
- `DocumentService` for download, copy, print operations
- `HtmlCleaner` utility for HTML processing
- `TextStats` utility for word/character counting
- `ExportStyles` with CSS for exported documents
- `AppColors` color palette constants
- `AppFonts` font configuration constants
- `EditorConfig` editor settings constants
- `AppTheme` theme configuration
- Example application demonstrating all features

### Dependencies
- flutter
- google_fonts: ^6.2.1
- pointer_interceptor: ^0.10.1+2