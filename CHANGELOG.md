# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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