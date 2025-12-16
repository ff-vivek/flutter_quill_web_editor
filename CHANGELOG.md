# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

